module Graphiti::ActiveGraph
  module Scoping
    # Handles sideloading via scoping instead of sideloading query as in original jsonapi_suite
    # This avoids extra queries for fetching sideload
    class Include < Graphiti::Scoping::Base
      include Internal::SortingAliases

      def custom_scope
        nil
      end

      def apply_standard_scope
        return scope if normalized_includes.empty?

        self.scope = resource.handle_includes(scope, normalized_includes, normalized_sorts,
          extra_fields_includes:, with_vars: with_vars_for_sort, paginate: paginate?)
      end

      private

      attr_accessor :scope

      def query
        @opts[:query_obj]
      end

      def extra_fields_includes
        normalized_extra_fields if @query_hash[:extra_fields]
      end

      def normalized_extra_fields
        Internal::ExtraFieldNormalizer.new(@query_hash[:extra_fields]).normalize(resource, normalized_includes)
      end

      def paginate?
        Graphiti::Scoping::Paginate.new(@resource, @query_hash, scope, @opts).apply?
      end

      def normalized_sorts
        Internal::SortNormalizer.new(scope).normalize(normalized_includes, query.sorts, query.deep_sort)
      end

      def include_normalizer
        Internal::IncludeNormalizer
      end

      def normalized_includes
        @normalized_includes ||= include_normalizer.new(resource.class, scope, query_hash[:fields]).normalize(query.include_hash)
      end
    end
  end
end
