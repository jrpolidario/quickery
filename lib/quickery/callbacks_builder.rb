module Quickery
  class CallbacksBuilder
    attr_reader :quickery_builder

    def initialize(quickery_builder:, should_add_callbacks: true)
      @quickery_builder = quickery_builder
      add_callbacks if should_add_callbacks
    end

    private

    def add_callbacks
      add_callback_to_depender_model
      add_callback_to_dependee_model
      add_callback_to_each_intermediate_model
    end

    # add callback to immediately sync value after a record has been created / updated
    def add_callback_to_depender_model
      first_association_builder = @quickery_builder.first_association_builder
      depender_column_name = @quickery_builder.depender_column_name
      dependee_column_name = @quickery_builder.dependee_column_name

      first_association_builder.model.class_exec do

        # before create or update
        before_save do
          if changes.keys.include? first_association_builder.belongs_to.foreign_key
            if send(first_association_builder.belongs_to.foreign_key).nil?
              new_value = nil
            else
              dependee_record = first_association_builder._quickery_dependee_record(self)
              new_value = dependee_record.send(dependee_column_name)

              assign_attributes(depender_column_name => new_value)
            end
          end
        end
      end
    end

    # add callback to sync changes when dependee_column has been updated
    def add_callback_to_dependee_model
      last_association_builder = @quickery_builder.first_association_builder
      depender_column_name = @quickery_builder.depender_column_name
      dependee_column_name = @quickery_builder.dependee_column_name

      last_association_builder.model.class_exec do

        before_update do
          if changes.keys.include? dependee_column_name
            new_value = send(dependee_column_name)

            dependent_records = last_association_builder._quickery_dependent_records(self)
            dependent_records.update_all(depender_column_name => new_value)
          end
        end
      end
    end

    # also add callbacks to sync changes when intermediary associations have been changed (this does not include first and last builder)
    def add_callback_to_each_intermediate_model
      last_association_builder = @quickery_builder.first_association_builder
      depender_column_name = @quickery_builder.depender_column_name
      dependee_column_name = @quickery_builder.dependee_column_name

      last_association_builder._quickery_get_parent_builders(include_self: true)[1..-2].each do |association_builder|
        intermediate_model = association_builder.model

        intermediate_model.class_exec do

          before_update do
            if changes.keys.include? association_builder.belongs_to.foreign_key
              if send(association_builder.belongs_to.foreign_key).nil?
                new_value = nil
              else
                dependee_record = association_builder._quickery_dependee_record(self)
                new_value = dependee_record.send(dependee_column_name)

                dependent_records = association_builder._quickery_dependent_records(self)
                dependent_records.update_all(depender_column_name => new_value)
              end
            end
          end
        end
      end
    end
  end
end
