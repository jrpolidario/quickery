module Quickery
  class AssociationBuilder
    attr_reader :model
    attr_reader :parent_builder
    attr_reader :child_builder
    attr_reader :inverse_association_name
    attr_reader :belongs_to

    def initialize(model:, parent_builder: nil, inverse_association_name: nil)
      @model = model
      @parent_builder = parent_builder
      @inverse_association_name = inverse_association_name
      @reflections = model.reflections
      @belongs_to_association_names = @reflections.map{ |key, value| value.macro == :belongs_to ? key : nil }.compact
      @column_names = model.column_names
    end

    def get_child_builders(include_self: false, builders: [])
      builders << self if include_self

      if @child_builder.nil?
        builders
      else
        builders << @child_builder
        return @child_builder.get_child_builders(builders: builders)
      end
    end

    def get_parent_builders(include_self: false, builders: [])
      builders << self if include_self

      if @parent_builder.nil?
        builders
      else
        builders << @parent_builder
        @parent_builder.get_parent_builders(builders: builders)
      end
    end

    def get_joins_arg(current_joins_arg = nil)
      if @parent_builder.nil?
        if current_joins_arg.nil?
          return nil
        else
          return current_joins_arg
        end
      else

        if current_joins_arg.nil?
          return @parent_builder.get_joins_arg(@inverse_association_name.to_sym)
        else
          return @parent_builder.get_joins_arg({ @inverse_association_name.to_sym => current_joins_arg })
        end
      end
    end

    def dependent_records(record_to_be_saved)
      primary_key_value = record_to_be_saved.send(record_to_be_saved.class.primary_key)
      most_parent_model = get_parent_builders.last.model

      records = most_parent_model.all

      unless get_joins_arg.empty?
        records = records.joins(get_joins_arg)
      end

      records = records.where(
        model.table_name => {
          model.primary_key => primary_key_value
        }
      )
    end

    def dependee_record(record_to_be_saved)
      get_child_builders(include_self: true).inject(record_to_be_saved) do |record, association_builder|
        if association_builder.belongs_to
          record.send(association_builder.belongs_to.name)
        else
          record
        end
      end
    end

    def all_association_builders(current_association_builders = [])
      current_association_builders << self
      if @parent_builder.nil?
        current_association_builders
      else
        @parent_builder.all_association_builders(current_association_builders)
      end
    end

    private

    def method_missing(method_name, *args, &block)
      method_name_str = method_name.to_s
      if @belongs_to_association_names.include? method_name_str
        @belongs_to = @reflections[method_name_str]
        @child_builder = AssociationBuilder.new(model: belongs_to.class_name.constantize, parent_builder: self, inverse_association_name: method_name_str)
      elsif @column_names.include? method_name_str
        CallbacksBuilder.new(dependee_column_name: method_name_str, last_association_builder: self)
      else
        super
      end
    end

    def respond_to_missing(method_name, include_private = false)
      method_name_str = method_name.to_s
      if @belongs_to_association_names.include? method_name_str
        true
      elsif @column_names.include? method_name_str
        true
      else
        super
      end
    end
  end
end
