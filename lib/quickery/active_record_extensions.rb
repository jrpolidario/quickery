require 'active_support'

module Quickery
  module ActiveRecordExtensions
    class << self
      def included(base)
        base.include Quickery::ActiveRecordExtensions::DSL
        base.include Quickery::ActiveRecordExtensions::Callbacks
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Quickery::ActiveRecordExtensions
end
