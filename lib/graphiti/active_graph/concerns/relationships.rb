module Graphiti::ActiveGraph::Concerns
  module Relationships
    def relationship?(name)
      relationships[name.to_sym].present?
    end

    def relationship_id(name)
      relationships[name]&.dig(:attributes, :id)
    end

    def relationship_ids(name)
      Array.wrap(relationships[name]).pluck(:attributes).pluck(:id)
    end
  end
end
