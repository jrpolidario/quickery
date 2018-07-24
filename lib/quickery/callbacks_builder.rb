module Quickery
  class CallbacksBuilder
    def initialize(dependee_column_name:, last_association_builder:)
      @dependee_column_name = dependee_column_name
      @last_association_builder = last_association_builder
    end

    def ==(depender_column_name)
      last_association_builder = @last_association_builder
      dependee_column_name = @dependee_column_name

      # add callback to immediately sync value after a record has been created
      last_association_builder._quickery_get_parent_builders.last.tap do |first_association_builder|
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
      last_association_builder.model.class_exec do

        before_update do
          if changes.keys.include? dependee_column_name
            new_value = send(dependee_column_name)

            dependent_records = last_association_builder._quickery_dependent_records(self)
            dependent_records.update_all(depender_column_name => new_value)
          end
        end
      end

      # also add callbacks to sync changes when intermediary associations has been changed (which then should ignore first and last builder)
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
