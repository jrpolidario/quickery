require 'byebug'
require 'active_support'

module Quickery
  module ActiveRecordExtensions
    module DSL
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def quickery(&block)
          association_builder = AssociationBuilder.new(model: self)
          association_builder.instance_exec(&block)
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Quickery::ActiveRecordExtensions::DSL
end
