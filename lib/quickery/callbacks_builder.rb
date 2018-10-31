module Quickery
  class CallbacksBuilder
    attr_reader :quickery_builder

    def initialize(quickery_builder:)
      @quickery_builder = quickery_builder
    end

    def build_callbacks
      build_callback_to_depender_model
      build_callback_to_dependee_model
      build_callback_to_each_intermediate_model
    end

    private

    # add callback to immediately sync value after a record has been created / updated
    def build_callback_to_depender_model
      first_association_chain = @quickery_builder.association_chains.first
      first_association_chain.model.quickery_association_chain_dependers ||= []
      first_association_chain.model.quickery_association_chain_dependers << first_association_chain
    end

    # add callback to sync changes when dependee_column has been updated
    def build_callback_to_dependee_model
      last_association_chain = @quickery_builder.association_chains.last
      last_association_chain.model.quickery_association_chain_dependees ||= []
      last_association_chain.model.quickery_association_chain_dependees << last_association_chain
    end

    # also add callbacks to sync changes when intermediary associations have been changed (this does not include first and last builder)
    def build_callback_to_each_intermediate_model
      last_association_chain = @quickery_builder.association_chains.last
      last_association_chain.parent_association_chains(include_self: true)[1..-2].each do |association_chain|
        association_chain.model.quickery_association_chain_intermediaries ||= []
        association_chain.model.quickery_association_chain_intermediaries << association_chain
      end
    end
  end
end
