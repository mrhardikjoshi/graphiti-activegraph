module Graphiti::ActiveGraph
  module Scoping
    # Handles sideloading via scoping instead of sideloading query as in original jsonapi_suite
    class AssociationEagerLoad < Graphiti::Scoping::Base
      def custom_scope
        nil
      end

      def apply_standard_scope
        return @scope unless eagerload_associations?
        if (ids = @scope.collect(&:id)).present?
          @opts[:query_obj].include_hash.each_key do |key|
            eagerload_association(key, ids)
          end
        end
        @scope
      end

      def eagerload_associations?
        @opts[:query_obj].include_hash.present? && @resource.model.include?(ActiveGraph::Node) &&
          @resource.model.associations_to_eagerload.present?
      end

      def eagerload_association(key, ids)
        return unless @resource.model.eagerload_association?(key)
        nodes = @resource.model.association_nodes(key, ids, @resource.context.send(:association_filter_params))
        @scope.each { |node| node.send("#{key}=", nodes[node.id] || nil_or_empty(key)) }
      end

      def nil_or_empty(key)
        @resource.class.config[:sideloads][key].type == :has_one ? nil : []
      end
    end
  end
end
