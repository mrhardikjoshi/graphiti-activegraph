module Graphiti::ActiveGraph
  module Scoping
    module Filterable
      def find_filter!(name)
        val = resource.filters[name] || {
          operators: {}, type: :string, single: false, dynamic_filter: true
        }
        {name => val}
      end
    end
  end
end

module ::Graphiti::Scoping::Filterable
  prepend ::Graphiti::ActiveGraph::Scoping::Filterable
end
