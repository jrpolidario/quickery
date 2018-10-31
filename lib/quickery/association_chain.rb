module Quickery
  class AssociationChain
    attr_accessor :quickery_builder
    attr_reader :model
    attr_reader :parent_association_chain
    attr_reader :child_association_chain
    attr_reader :name
    attr_reader :dependee_column_name
    attr_reader :belongs_to

    def initialize(model:, parent_association_chain: nil, name: nil)
      @model = model
      @parent_association_chain = parent_association_chain
      @name = name
    end

    def build_children_association_chains(names_left:)
      current_name = names_left.first

      reflections = @model.reflections
      column_names = @model.column_names
      belongs_to_association_names = reflections.map{ |key, value| value.macro == :belongs_to ? key : nil }.compact

      if belongs_to_association_names.include? current_name
        @belongs_to = reflections[current_name]
        @child_association_chain = AssociationChain.new(
          model: belongs_to.class_name.constantize,
          parent_association_chain: self,
          name: current_name,
        )
        @child_association_chain.build_children_association_chains(names_left: names_left[1..-1])
        return self

      elsif column_names.include? current_name
        @dependee_column_name = current_name
        return self

      else
        raise Quickery::Errors::InvalidAssociationOrAttributeError.new(current_name)
      end
    end

    def child_association_chains(include_self: false, association_chains: [])
      association_chains << self if include_self

      if @child_association_chain.nil?
        association_chains
      else
        association_chains << @child_association_chain
        return @child_association_chain.child_association_chains(association_chains: association_chains)
      end
    end

    def parent_association_chains(include_self: false, association_chains: [])
      association_chains << self if include_self

      if @parent_association_chain.nil?
        association_chains
      else
        association_chains << @parent_association_chain
        @parent_association_chain.parent_association_chains(association_chains: association_chains)
      end
    end

    def joins_arg(current_joins_arg = nil)
      if @parent_association_chain.nil?
        current_joins_arg
      else
        if current_joins_arg.nil?
          @parent_association_chain.joins_arg(@name.to_sym)
        else
          @parent_association_chain.joins_arg({ @name.to_sym => current_joins_arg })
        end
      end
    end

    def dependee_record(from_record)
      raise ArgumentError, 'argument should be an instance of @model' unless from_record.is_a? model

      child_association_chains(include_self: true).inject(from_record) do |from_record, association_chain|
        if association_chain.belongs_to
          from_record.send(association_chain.belongs_to.name)
        else
          from_record
        end
      end
    end

    def dependent_records(from_record)
      primary_key_value = from_record.send(from_record.class.primary_key)
      most_parent_model = parent_association_chains.last.model

      records = most_parent_model.all

      unless (joins_arg_tmp = joins_arg).nil?
        records = records.joins(joins_arg_tmp)
      end

      records = records.where(
        model.table_name => {
          model.primary_key => primary_key_value
        }
      )
    end
  end
end
