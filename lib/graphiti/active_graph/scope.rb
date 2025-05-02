module Graphiti
  module ActiveGraph
    class Scope < Graphiti::Scope
      def non_applicable_for_unpaginated
        %i[association_eagerload]
      end

      def apply_scoping(scope, opts)
        opts[:query_obj] = @query
        super

        append_scopings(opts) unless @resource.remote?
        @object
      end

      def append_scopings(opts)
        add_scoping(:include, Scoping::Include, opts)
        add_scoping(:association_eagerload, Scoping::AssociationEagerLoad, opts)
      end

      def add_scoping(key, scoping_class, opts, _ = {})
        @object = scoping_class.new(@resource, @query.hash, @object, opts).apply
        return if non_applicable_for_unpaginated.include?(key)
        @unpaginated_object = scoping_class.new(@resource, @query.hash, @unpaginated_object, opts.merge(unpaginated_query: true)).apply
      end
    end
  end
end
