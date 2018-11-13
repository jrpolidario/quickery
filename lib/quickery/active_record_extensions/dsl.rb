module Quickery
  module ActiveRecordExtensions
    module DSL
      class << self
        def included(base)
          base.extend ClassMethods
          base.include InstanceMethods
        end
      end

      module ClassMethods
        attr_accessor :quickery_association_chain_dependers
        attr_accessor :quickery_association_chain_dependees
        attr_accessor :quickery_association_chain_intermediaries
        attr_accessor :quickery_builders

        def quickery(mappings)
          mappings_builder = MappingsBuilder.new(model: self, mappings: mappings.with_indifferent_access)
          mappings_builder.map_attributes
        end
      end

      module InstanceMethods
        def recreate_quickery_cache!
          self.class.quickery_builders.each do |depender_column_name, quickery_builder|
            new_value = determine_quickery_value(depender_column_name)
            update_columns(depender_column_name => new_value)
          end
        end

        def determine_quickery_value(depender_column_name)
          quickery_builder = self.class.quickery_builders[depender_column_name]

          raise ArgumentError, "No defined quickery builder for #{depender_column_name}. Defined values are #{self.class.quickery_builders.keys}" unless quickery_builder

          dependee_record = quickery_builder.association_chains.first.dependee_record(self)
          dependee_record.public_send(quickery_builder.dependee_column_name) if dependee_record
        end

        def determine_quickery_values
          quickery_values = {}
          self.class.quickery_builders.each do |depender_column_name, quickery_builder|
            quickery_values[depender_column_name] = determine_quickery_value(depender_column_name)
          end
          quickery_values
        end
      end
    end
  end
end
