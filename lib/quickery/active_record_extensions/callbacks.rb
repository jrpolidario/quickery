module Quickery
  module ActiveRecordExtensions
    module Callbacks
      class << self
        def included(base)
          base.extend ClassMethods
          base.include InstanceMethods
          base.class_eval do
            before_create :quickery_before_create_callback
            before_update :quickery_before_update_callback
            before_destroy :quickery_before_destroy_callback
          end
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        private

        def quickery_before_create_callback
          model = self.class
          changed_attributes = changes.keys

          if model.quickery_association_chain_dependers.present?
            new_values = {}.with_indifferent_access

            model.quickery_association_chain_dependers.each do |association_chain_depender|
              quickery_builder = association_chain_depender.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if changed_attributes.include? association_chain_depender.belongs_to.foreign_key
                if send(association_chain_depender.belongs_to.foreign_key).nil?
                  new_value = nil
                else
                  dependee_record = association_chain_depender.dependee_record(self)
                  new_value = dependee_record.send(dependee_column_name)
                end

                new_values[depender_column_name] = new_value
              end

              # set to true because on-create, all quickery-attributes are evaluated and assigned
              new_values[:"#{depender_column_name}_is_synced"] = true if has_attribute? :"#{depender_column_name}_is_synced"
            end

            self.class.quickery_before_create_or_update(self, new_values)
          end
        end

        def quickery_before_update_callback
          model = self.class
          changed_attributes = changes.keys

          if model.quickery_association_chain_dependers.present?
            new_values = {}.with_indifferent_access

            model.quickery_association_chain_dependers.each do |association_chain_depender|
              quickery_builder = association_chain_depender.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if changed_attributes.include? association_chain_depender.belongs_to.foreign_key
                if send(association_chain_depender.belongs_to.foreign_key).nil?
                  new_value = nil
                else
                  dependee_record = association_chain_depender.dependee_record(self)
                  new_value = dependee_record.send(dependee_column_name)
                end

                new_values[depender_column_name] = new_value
                new_values[:"#{depender_column_name}_is_synced"] = true if has_attribute? :"#{depender_column_name}_is_synced"
              end
            end

            self.class.quickery_before_create_or_update(self, new_values)
          end

          dependent_records_attributes_to_be_updated = {}.with_indifferent_access

          if model.quickery_association_chain_dependees.present?
            model.quickery_association_chain_dependees.each do |association_chain_dependee|
              quickery_builder = association_chain_dependee.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if changed_attributes.include? dependee_column_name
                new_value = send(dependee_column_name)

                dependent_records = association_chain_dependee.dependent_records(self)
                # use the SQL as the uniqueness identifier, so that multiple quickery-attributes dependent-records are updated in one go, instead of updating each
                records_sql_identifier = dependent_records.to_sql.to_sym
                dependent_records_attributes_to_be_updated[records_sql_identifier] ||= {}.with_indifferent_access
                dependent_records_attributes_to_be_updated[records_sql_identifier][:dependent_records] ||= dependent_records
                dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values] ||= {}.with_indifferent_access
                dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values][depender_column_name.to_sym] = new_value
                if dependent_records.model.column_names.include? "#{depender_column_name}_is_synced"
                  dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values][:"#{depender_column_name}_is_synced"] = true
                end
              end
            end
          end

          if model.quickery_association_chain_intermediaries.present?
            model.quickery_association_chain_intermediaries.each do |association_chain_intermediary|
              quickery_builder = association_chain_intermediary.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if changed_attributes.include? association_chain_intermediary.belongs_to.foreign_key
                if send(association_chain_intermediary.belongs_to.foreign_key).nil?
                  new_value = nil
                else
                  dependee_record = association_chain_intermediary.dependee_record(self)
                  new_value = dependee_record.send(dependee_column_name)
                end

                dependent_records = association_chain_intermediary.dependent_records(self)
                # use the SQL as the uniqueness identifier, so that multiple quickery-attributes dependent-records are updated in one go, instead of updating each
                records_sql_identifier = dependent_records.to_sql.to_sym
                dependent_records_attributes_to_be_updated[records_sql_identifier] ||= {}.with_indifferent_access
                dependent_records_attributes_to_be_updated[records_sql_identifier][:dependent_records] ||= dependent_records
                dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values] ||= {}.with_indifferent_access
                dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values][depender_column_name.to_sym] = new_value

                if dependent_records.model.column_names.include? "#{depender_column_name}_is_synced"
                  dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values][:"#{depender_column_name}_is_synced"] = true
                end
              end
            end
          end

          dependent_records_attributes_to_be_updated.each do |sql_identifier, hash|
            dependent_records = hash.fetch(:dependent_records)
            new_values = hash.fetch(:new_values)

            dependent_records.model.quickery_before_association_update(dependent_records, self, new_values)
          end
        end

        def quickery_before_destroy_callback
          model = self.class

          dependent_records_attributes_to_be_updated = {}.with_indifferent_access

          if model.quickery_association_chain_dependees.present?
            model.quickery_association_chain_dependees.each do |association_chain_dependee|
              quickery_builder = association_chain_dependee.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if attributes.keys.include? dependee_column_name
                new_value = nil

                dependent_records = association_chain_dependee.dependent_records(self)
                # use the SQL as the uniqueness identifier, so that multiple quickery-attributes dependent-records are updated in one go, instead of updating each
                records_sql_identifier = dependent_records.to_sql.to_sym
                dependent_records_attributes_to_be_updated[records_sql_identifier] ||= {}.with_indifferent_access
                dependent_records_attributes_to_be_updated[records_sql_identifier][:dependent_records] ||= dependent_records
                dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values] ||= {}.with_indifferent_access
                dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values][depender_column_name.to_sym] = new_value
                if dependent_records.model.column_names.include? "#{depender_column_name}_is_synced"
                  dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values][:"#{depender_column_name}_is_synced"] = true
                end
              end
            end
          end

          if model.quickery_association_chain_intermediaries.present?
            model.quickery_association_chain_intermediaries.each do |association_chain_intermediary|
              quickery_builder = association_chain_intermediary.quickery_builder
              depender_column_name = quickery_builder.depender_column_name
              dependee_column_name = quickery_builder.dependee_column_name

              if attributes.keys.include? association_chain_intermediary.belongs_to.foreign_key
                new_value = nil

                dependent_records = association_chain_intermediary.dependent_records(self)
                # use the SQL as the uniqueness identifier, so that multiple quickery-attributes dependent-records are updated in one go, instead of updating each
                records_sql_identifier = dependent_records.to_sql.to_sym
                dependent_records_attributes_to_be_updated[records_sql_identifier] ||= {}.with_indifferent_access
                dependent_records_attributes_to_be_updated[records_sql_identifier][:dependent_records] ||= dependent_records
                dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values] ||= {}.with_indifferent_access
                dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values][depender_column_name.to_sym] = new_value
                if dependent_records.model.column_names.include? "#{depender_column_name}_is_synced"
                  dependent_records_attributes_to_be_updated[records_sql_identifier][:new_values][:"#{depender_column_name}_is_synced"] = true
                end
              end
            end
          end

          dependent_records_attributes_to_be_updated.each do |sql_identifier, hash|
            dependent_records = hash.fetch(:dependent_records)
            new_values = hash.fetch(:new_values)

            dependent_records.model.quickery_before_association_destroy(dependent_records, self, new_values)
          end
        end
      end
    end
  end
end
