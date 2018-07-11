module Quickery
  class CallbacksBuilder
    def initialize(dependent_column_name:, association_builder:)
      @dependent_column_name = dependent_column_name
      @association_builder = association_builder
    end

    def >>(foreign_key)
      association_builder = @association_builder
      dependent_column_name = @dependent_column_name
      model_to_add_callbacks = association_builder.model

      model_to_add_callbacks.class_eval do
        after_update do
          if changes.has_key?(dependent_column_name)
            puts association_builder
            byebug
          end
        end
      end
    end
  end
end
