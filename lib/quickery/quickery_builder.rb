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
      @model.quickery_builders ||= {}
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
  end
end
