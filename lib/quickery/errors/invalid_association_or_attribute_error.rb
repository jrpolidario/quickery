module Quickery
  module Errors
    class InvalidAssociationOrAttributeError < StandardError
      def initialize(name)
        message = "#{name} is not a valid association or attribute name"
        super(message)
      end
    end
  end
end
