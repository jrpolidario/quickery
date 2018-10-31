module Quickery
  class QuickeryBuilder
    attr_reader :model
    attr_reader :depender_column_name
    attr_reader :dependee_column_name
    attr_reader :association_chains

    def initialize(model:, association_chains:, dependee_column_name:, depender_column_name:)
      @model = model
      @association_chains = association_chains
      @dependee_column_name = dependee_column_name
      @depender_column_name = depender_column_name
    end

    def add_to_model
      define_quickery_builders_in_model_class unless @model.respond_to? :quickery_builders
      # include this to the list of quickery builders defined for this model
      @model.quickery_builders[depender_column_name] = self
    end

    def add_to_association_chains
      association_chains.each do |association_chain|
        association_chain.quickery_builder = self
      end
    end

    def create_model_callbacks
      @callbacks_builder = CallbacksBuilder.new(quickery_builder: self)
      @callbacks_builder.build_callbacks
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
