module Graphiti::ActiveGraph
  module Scoping
    module Internal
      class SortNormalizer
        attr_reader :scope

        def initialize(scope)
          @scope = scope
          @path_cache = {}
        end

        def normalize(includes_hash, sorts, deep_sorts)
          normalized_deep_sort = normalize_deep_sort(includes_hash, deep_sorts || [])
          normalized_base_sort = normalize_base_sort(sorts)
          normalized_deep_sort.merge(normalized_base_sort)
        end

        def normalize_base_sort(sorts)
          return {} if sorts.blank?

          sort_specs = sorts.map do |sort|
            "#{sort.keys.first} #{sort.values.first}"
          end

          {"" => sort_specs}
        end

        def normalize_deep_sort(includes_hash, sorts)
          return {} if sorts.empty?

          # Group sorts first to reduce duplicate processing
          grouped_sorts = sorts.group_by { |sort| sort.keys.first }

          result = {}
          grouped_sorts.each do |path_key, path_sorts|
            path = path_key.map { |key| {rel_name: key.to_s} }
            cached_path = cache_key_for_path(path)

            descriptor = @path_cache[cached_path] ||= PathDescriptor.parse(scope, path.dup)
            next unless descriptor

            path_relationships = descriptor.path_relationships
            next unless valid_sort?(includes_hash.deep_dup, path_relationships)

            sort_specs = path_sorts.map do |sort|
              create_sort_spec(descriptor, sort.values.first)
            end

            combined_key = path_relationships.join(".")
            result[combined_key] = (result[combined_key] || []) + sort_specs
          end

          result
        end

        private

        def cache_key_for_path(path)
          path.map { |p| p[:rel_name] }.join(".")
        end

        def create_sort_spec(descriptor, direction)
          sort_attr = "#{descriptor.attribute} #{direction}"
          descriptor.rel.present? ? {rel: sort_attr} : sort_attr
        end

        def valid_sort?(hash, rels)
          return true if rels.empty?

          rels.all? do |rel|
            hash = hash[rel] || hash[:"#{rel}*"]
            hash.present?
          end
        end
      end
    end
  end
end
