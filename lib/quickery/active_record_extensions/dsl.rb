require 'active_support'

module Quickery
  module ActiveRecordExtensions
    module DSL
      class << self
        def included(base)
          base.extend ClassMethods
          base.include InstanceMethods
        end
      end

      private

      module ClassMethods
        def quickery(&block)
          association_builder = Block.new(model: self)
          association_builder.instance_exec(&block)
        end
      end

      module InstanceMethods
        def recreate_quickery_cache!
          self.class.quickery_builders.each do |depender_column_name, quickery_builder|
            new_value = determine_quickery_value(depender_column_name)
            update_columns(depender_column_name => new_value)
          end

          true
        end

        def determine_quickery_value(depender_column_name)
          quickery_builder = self.class.quickery_builders[depender_column_name]

          raise ArgumentError, "No defined quickery builder for #{depender_column_name}. Defined values are #{self.class.quickery_builders.keys}" unless quickery_builder

          dependee_record = quickery_builder.first_association_builder._quickery_dependee_record(self)
          dependee_record.send(quickery_builder.dependee_column_name)
        end

        private

        def quickery_before_create_callback
          model = self.class
          changed_attributes = changes.keys

          if model.quickery_association_builder_dependers.present?
            model.quickery_association_builder_dependers.each do |association_builder_depender|
              quickery_builder = association_builder_depender.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              byebug

              if changed_attributes.include? association_builder_depender.belongs_to.foreign_key
                if send(association_builder_depender.belongs_to.foreign_key).nil?
                  new_value = nil
                else
                  dependee_record = association_builder_depender._quickery_dependee_record(self)
                  new_value = dependee_record.send(dependee_column_name)
                end

                assign_attributes(depender_column_name => new_value)
              end
            end
          end

          byebug
        end

        def quickery_before_update_callback
          model = self.class
          changed_attributes = changes.keys

          if model.quickery_association_builder_dependers.present?
            model.quickery_association_builder_dependers.each do |association_builder_depender|
              quickery_builder = association_builder_depender.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if changed_attributes.include? association_builder_depender.belongs_to.foreign_key
                if send(association_builder_depender.belongs_to.foreign_key).nil?
                  new_value = nil
                else
                  dependee_record = association_builder_depender._quickery_dependee_record(self)
                  new_value = dependee_record.send(dependee_column_name)
                end

                assign_attributes(depender_column_name => new_value)
              end
            end
          end

          dependent_records_attributes_to_be_updated = {}

          if model.quickery_association_builder_dependees.present?
            model.qquickery_association_builder_dependees.each do |association_builder_dependee|
              quickery_builder = association_builder_dependee.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if changed_attributes.include? dependee_column_name
                new_value = send(dependee_column_name)

                dependent_records = association_builder_dependee._quickery_dependent_records(self)
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym] ||= {}
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:dependent_records] ||= dependent_records
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:new_values] ||= {}
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:new_values][depender_column_name.to_sym] = new_value
              end
            end
          end

          if model.quickery_association_builder_intermediaries.present?
            model.quickery_association_builder_intermediaries.each do |association_builder_intermediary|
              quickery_builder = association_builder_intermediary.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if changed_attributes.include? association_builder_intermediary.belongs_to.foreign_key
                if send(association_builder_intermediary.belongs_to.foreign_key).nil?
                  new_value = nil
                else
                  dependee_record = association_builder_intermediary._quickery_dependee_record(self)
                  new_value = dependee_record.send(dependee_column_name)
                end

                dependent_records = association_builder_intermediary._quickery_dependent_records(self)
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym] ||= {}
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:dependent_records] ||= dependent_records
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:new_values] ||= {}
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:new_values][depender_column_name.to_sym] = new_value
              end
            end
          end

          dependent_records_attributes_to_be_updated.each do |sql_identifier, hash|
            dependent_records = hash.fetch(:dependent_records)
            new_values = hash.fetch(:new_values)

            dependent_records.update_all(new_values)
          end
        end

        def quickery_before_destroy_callback
          model = self.class

          dependent_records_attributes_to_be_updated = {}

          if model.quickery_association_builder_dependees.present?
            model.quickery_association_builder_dependees.each do |association_builder_dependee|
              quickery_builder = association_builder_dependee.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if attributes.keys.include? dependee_column_name
                new_value = nil

                dependent_records = association_builder_dependee._quickery_dependent_records(self)
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym] ||= {}
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:dependent_records] ||= dependent_records
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:new_values] ||= {}
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:new_values][depender_column_name.to_sym] = new_value
              end
            end
          end

          if model.quickery_association_builder_intermediaries.present?
            model.quickery_association_builder_intermediaries.each do |association_builder_intermediary|
              quickery_builder = association_builder_intermediary.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if attributes.keys.include? association_builder_intermediary.belongs_to.foreign_key
                new_value = nil

                dependent_records = association_builder_intermediary._quickery_dependent_records(self)
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym] ||= {}
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:dependent_records] ||= dependent_records
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:new_values] ||= {}
                dependent_records_attributes_to_be_updated[dependent_records.to_sql.to_sym][:new_values][depender_column_name.to_sym] = new_value
              end
            end
          end

          dependent_records_attributes_to_be_updated.each do |sql_identifier, hash|
            dependent_records = hash.fetch(:dependent_records)
            new_values = hash.fetch(:new_values)

            dependent_records.update_all(new_values)
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Quickery::ActiveRecordExtensions::DSL
end
