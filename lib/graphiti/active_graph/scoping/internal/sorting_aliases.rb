module Graphiti::ActiveGraph
  module Scoping
    module Internal
      # Carrying forward valriables from neo4j procedure call to sort with include
      module SortingAliases
        def with_vars_for_sort
          [] unless add_extra_vars_to_query?
          (deep_sort_keys + sort_keys) & resource.extra_attributes.keys
        end

        def add_extra_vars_to_query?
          resource.extra_attributes.present? && (query.sorts.present? || query.deep_sort.present?)
        end

        def deep_sort_keys
          (query.deep_sort || []).collect { |sort| sort.keys.first.first }
        end

        def sort_keys
          query.sorts.collect(&:keys).flatten
        end
      end
    end
  end
end
