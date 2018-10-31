module Quickery
  class MappingsBuilder
    attr_reader :model
    attr_reader :mappings

    def initialize(model:, mappings:)
      @model = model
      @mappings = mappings
    end

    # https://stackoverflow.com/questions/9647997/converting-a-nested-hash-into-a-flat-hash
    def flat_hash(hash, k = [])
      return {k => hash} unless hash.is_a?(Hash)
      hash.inject({}){ |h, v| h.merge! flat_hash(v[-1], k + [v[0]]) }
    end

    def map_attributes
      flat_hash(@mappings).each do |names, depender_column_name|
        first_association_chain = AssociationChain.new(model: model)
        first_association_chain.build_children_association_chains(names_left: names)

        all_association_chains = first_association_chain.child_association_chains(include_self: true)
        dependee_column_name = all_association_chains.last.dependee_column_name

        quickery_builder = QuickeryBuilder.new(
          model: @model,
          association_chains: all_association_chains,
          dependee_column_name: dependee_column_name,
          depender_column_name: depender_column_name,
        )

        quickery_builder.add_to_model
        quickery_builder.add_to_association_chains
        quickery_builder.create_model_callbacks
      end
    end
  end
end
