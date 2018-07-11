module Quickery
  class AssociationBuilder
    attr_reader :model

    def initialize(model:, parent_builder: nil, referring_association_name: nil)
      @model = model
      @parent_builder = parent_builder
      @referring_association_name = referring_association_name
      @reflections = model.reflections
      @belongs_to_association_names = @reflections.map{ |key, value| value.macro == :belongs_to ? key : nil }.compact
      @column_names = model.column_names
    end

    def get_most_parent_builder
      if @parent_builder.nil?
        self
      else
        @parent_builder.get_most_parent_builder
      end
    end

    private

    def method_missing(method_name, *args, &block)
      method_name_str = method_name.to_s
      if @belongs_to_association_names.include? method_name_str
        belongs_to_model = @reflections[method_name_str].class_name.constantize
        AssociationBuilder.new(model: belongs_to_model, parent_builder: self, referring_association_name: method_name_str)
      elsif @column_names.include? method_name_str
        CallbacksBuilder.new(dependent_column_name: method_name_str, association_builder: self) # model_to_add_callbacks: @model, model_that_has_foreign_key: get_most_parent_builder.model)
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
