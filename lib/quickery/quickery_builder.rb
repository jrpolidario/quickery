module Quickery
  class QuickeryBuilder
    attr_reader :model
    attr_reader :depender_column_name
    attr_reader :dependee_column_name
    attr_reader :first_association_builder
    attr_reader :last_association_builder
    attr_reader :callbacks_builder

    def initialize(dependee_column_name:, last_association_builder:)
      @dependee_column_name = dependee_column_name
      @last_association_builder = last_association_builder
      @first_association_builder = last_association_builder._quickery_get_parent_builders.last
      @model = @first_association_builder.model
    end

    def ==(depender_column_name)
      @depender_column_name = depender_column_name

      @callbacks_builder = CallbacksBuilder.new(quickery_builder: self)

      define_quickery_builders_in_model_class unless @model.respond_to? :quickery_builders

      # include this to the list of quickery builders defined for this model
      @model.quickery_builders[depender_column_name] = self
    end

    private

    def define_quickery_builders_in_model_class
      # set default empty Hash if first time setting quickery_builders
      @model.class_eval do
        @quickery_builders = {}

        class << self
          attr_reader :quickery_builders
        end
      end
    end
  end
end
