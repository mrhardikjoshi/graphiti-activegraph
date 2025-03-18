module Graphiti::ActiveGraph::Extensions::Resources
  module Authorizationable
    extend ActiveSupport::Concern

    included do
      class << self
        attr_reader :authorize_attributes
      end
    end

    class_methods do
      def attribute_authorization
        @authorize_attributes = true
      end

      def authorize_attributes?
        @authorize_attributes
      end

      def readable_attributes
        attributes.select { |_attr_name, options_map| options_map[:readable] }
      end

      def readable_sideloads
        sideloads.select { |_sideloads_name, sideload_obj| sideload_obj.readable? }
      end
    end
  end
end
