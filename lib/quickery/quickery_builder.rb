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
      define_quickery_builders_in_model_class unless @model.respond_to? :quickery_builders
      # define_quickery_association_builders_in_model_class unless @model.respond_to? :quickery_association_builder_dependers

      @depender_column_name = depender_column_name

      @callbacks_builder = CallbacksBuilder.new(quickery_builder: self)

      # include this to the list of quickery builders defined for this model
      @model.quickery_builders[depender_column_name] = self

      puts 'RRRRRRRRRRRRRR'
      puts depender_column_name

      # add_quickery_callbacks_to_model_class
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

    # def define_quickery_association_builders_in_model_class
    #   @model.class_eval do
    #     @quickery_association_builder_dependers = []
    #     @quickery_association_builder_dependees = []
    #     @quickery_association_builder_intermediaries = []
    #
    #     class << self
    #       attr_accessor :quickery_association_builder_dependers
    #       attr_accessor :quickery_association_builder_dependees
    #       attr_accessor :quickery_association_builder_intermediaries
    #     end
    #   end
    # end

    # def add_quickery_callbacks_to_model_class
    #   @model.before_create :quickery_before_create_callback
    #   @model.before_update :quickery_before_update_callback
    #   @model.before_destroy :quickery_before_destroy_callback
    # end
  end
end
