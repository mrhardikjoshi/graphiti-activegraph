module Graphiti::ActiveGraph::Extensions::Resources
  module Rel
    extend ActiveSupport::Concern

    def relation_resource?
      self.class.relation_resource?
    end

    class_methods do
      def relation_resource?
        config[:relation_resource] || false
      end

      def relationship_resource=(value)
        config[:relation_resource] = value
      end
    end
  end
end
