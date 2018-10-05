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
      # depender_column_name = @quickery_builder.depender_column_name
      # dependee_column_name = @quickery_builder.dependee_column_name

      byebug

      unless first_association_builder.model.respond_to? :quickery_association_builder_dependers
        first_association_builder.model.class_eval do
          @quickery_association_builder_dependers = []

          class << self
            attr_accessor :quickery_association_builder_dependers
          end
        end
      end

      first_association_builder.model.quickery_association_builder_dependers ||= []
      first_association_builder.model.quickery_association_builder_dependers << first_association_builder

      byebug

      unless first_association_builder.model.respond_to? :quickery_before_create_callback
        first_association_builder.model.class_eval do
          before_create :quickery_before_create_callback
        end
      end

      unless first_association_builder.model.respond_to? :quickery_before_update_callback
        first_association_builder.model.class_eval do
          before_update :quickery_before_update_callback
        end
      end

      byebug
        # quickery_association_builder_dependers ||= []
        # quickery_association_builder_dependers << first_association_builder
        # # before create or update
        # before_save do
        #   if changes.keys.include? first_association_builder.belongs_to.foreign_key
        #     if send(first_association_builder.belongs_to.foreign_key).nil?
        #       new_value = nil
        #     else
        #       dependee_record = first_association_builder._quickery_dependee_record(self)
        #       new_value = dependee_record.send(dependee_column_name)
        #     end
        #
        #     assign_attributes(depender_column_name => new_value)
        #   end
        # end
      # end
    end

    # add callback to sync changes when dependee_column has been updated
    def add_callback_to_dependee_model
      last_association_builder = @quickery_builder.last_association_builder
      # depender_column_name = @quickery_builder.depender_column_name
      # dependee_column_name = @quickery_builder.dependee_column_name

      unless last_association_builder.model.respond_to? :quickery_association_builder_dependees
        last_association_builder.model.class_eval do
          @quickery_association_builder_dependees = []

          class << self
            attr_accessor :quickery_association_builder_dependees
          end
        end
      end

      last_association_builder.model.quickery_association_builder_dependees ||= []
      last_association_builder.model.quickery_association_builder_dependees << last_association_builder

      unless last_association_builder.model.respond_to? :quickery_before_update_callback
        last_association_builder.model.class_eval do
          before_update :quickery_before_update_callback
        end
      end

      unless last_association_builder.model.respond_to? :quickery_before_destroy_callback
        last_association_builder.model.class_eval do
          before_destroy :quickery_before_destroy_callback
        end
      end
        # before_update do
        #   if changes.keys.include? dependee_column_name
        #     new_value = send(dependee_column_name)
        #
        #     dependent_records = last_association_builder._quickery_dependent_records(self)
        #     dependent_records.update_all(depender_column_name => new_value)
        #   end
        # end
        #
        # before_destroy do
        #   if attributes.keys.include? dependee_column_name
        #     new_value = nil
        #
        #     dependent_records = last_association_builder._quickery_dependent_records(self)
        #     dependent_records.update_all(depender_column_name => new_value)
        #   end
        # end
      # end
    end

    # also add callbacks to sync changes when intermediary associations have been changed (this does not include first and last builder)
    def add_callback_to_each_intermediate_model
      last_association_builder = @quickery_builder.last_association_builder
      # depender_column_name = @quickery_builder.depender_column_name
      # dependee_column_name = @quickery_builder.dependee_column_name

      last_association_builder._quickery_get_parent_builders(include_self: true)[1..-2].each do |association_builder|
        unless association_builder.model.respond_to? :quickery_association_builder_intermediaries
          association_builder.model.class_eval do
            @quickery_association_builder_intermediaries = []

            class << self
              attr_accessor :quickery_association_builder_intermediaries
            end
          end
        end

        association_builder.model.quickery_association_builder_intermediaries ||= []
        association_builder.model.quickery_association_builder_intermediaries << association_builder

        unless association_builder.model.respond_to? :quickery_before_update_callback
          association_builder.model.class_eval do
            before_update :quickery_before_update_callback
          end
        end

        unless association_builder.model.respond_to? :quickery_before_destroy_callback
          association_builder.model.class_eval do
            before_destroy :quickery_before_destroy_callback
          end
        end
        # intermediate_model = association_builder.model
        #
        # intermediate_model.class_exec do
        #
        #   before_update do
        #     if changes.keys.include? association_builder.belongs_to.foreign_key
        #       if send(association_builder.belongs_to.foreign_key).nil?
        #         new_value = nil
        #       else
        #         dependee_record = association_builder._quickery_dependee_record(self)
        #         new_value = dependee_record.send(dependee_column_name)
        #       end
        #
        #       dependent_records = association_builder._quickery_dependent_records(self)
        #       dependent_records.update_all(depender_column_name => new_value)
        #     end
        #   end
        #
        #   before_destroy do
        #     if attributes.keys.include? association_builder.belongs_to.foreign_key
        #       new_value = nil
        #
        #       dependent_records = last_association_builder._quickery_dependent_records(self)
        #       dependent_records.update_all(depender_column_name => new_value)
        #     end
        #   end
        # end
      end
    end
  end
end
