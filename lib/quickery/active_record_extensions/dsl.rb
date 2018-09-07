require 'active_support'

module Quickery
  module ActiveRecordExtensions
    module DSL
      def self.included(base)
        base.extend ClassMethods
        base.include InstanceMethods
      end

      module ClassMethods
        def quickery(&block)
          association_builder = AssociationBuilder.new(model: self)
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
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Quickery::ActiveRecordExtensions::DSL
end
