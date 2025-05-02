module Graphiti::ActiveGraph
  module Scoping
    module Internal
      class SortNormalizer
        attr_reader :scope

        def initialize(scope)
          @scope = scope
        end

        def normalize(includes_hash, sorts, deep_sorts)
          normalized_deep_sort = normalize_deep_sort(includes_hash, deep_sorts || [])
          normalized_base_sort = normalize_base_sort(sorts)
          normalized_deep_sort.merge(normalized_base_sort)
        end

        def normalize_base_sort(sorts)
          sorts.present? ? { '' => sorts.map { |sort| "#{sort.keys.first} #{sort.values.first}" } } : {}
        end

        def normalize_deep_sort(includes_hash, sorts)
          sorts
            .map { |sort| sort(includes_hash, sort) }
            .compact
            .group_by(&:first)
            .map { |key, value| combined_order_spec(key, value) }
            .to_h
        end

        private

        def combined_order_spec(key, value)
          [key.join('.'), value.map(&:last)]
        end

        def sort(includes_hash, sort)
          path = sort.keys.first.map { |key| { rel_name: key.to_s } }
          return nil unless (descriptor = PathDescriptor.parse(scope, path))

          sort_spec(descriptor, sort.values.first) if valid_sort?(includes_hash.deep_dup, descriptor.path_relationships)
        end

        def valid_sort?(hash, rels)
          rels.empty? || rels.all? { |rel| hash = hash[rel] || hash[:"#{rel.to_s + '*'}"] }
        end

        def sort_spec(descriptor, direction)
          sort_attr = [descriptor.attribute, direction].join(' ')
          [descriptor.path_relationships, descriptor.rel.present? ? { rel: sort_attr } : sort_attr]
        end
      end
    end
  end
end
