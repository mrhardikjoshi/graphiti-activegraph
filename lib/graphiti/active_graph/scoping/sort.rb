module Graphiti::ActiveGraph
  module Scoping
    module Sort
      def apply_standard_scope
        each_sort do |attribute, direction|
          resource.get_attr!(attribute, :sortable, request: true)
          sort = resource.sorts[attribute]
          if sort[:only] && sort[:only] != direction
            raise Errors::UnsupportedSort.new resource,
              attribute, sort[:only], direction
          else
            @scope = if sort[:proc]
              resource.instance_exec(@scope, direction, &sort[:proc])
            else
              resource.adapter.order(@scope, attribute, direction)
            end
          end
        end
        @scope
      end
    end
  end
end
