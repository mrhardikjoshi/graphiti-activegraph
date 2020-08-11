module Graphiti
  module ActiveGraph
    module Resource
      def relation_resource?
        config[:relation_resource] || false
      end

      def relationship_resource=(value)
        config[:relation_resource] = value
      end

      def with_preloaded_obj(obj, params)
        id = params[:data].try(:[], :id) || params.delete(:id)
        params[:filter] ||= {}
        params[:filter][:id] = id if id

        validate!(params)
        runner = ::Graphiti::Runner.new(self, params)
        runner.proxy(nil, single: true, raise_on_missing: false, preloaded: obj, bypass_required_filters: true)
      end

      def all_with_preloaded(obj_arr, params)
        validate!(params)

        runner = ::Graphiti::Runner.new(self, params)
        runner.proxy(nil, raise_on_missing: false, preloaded: obj_arr)
      end
    end

    module ResourceInstanceMethods
      def relation_resource?
        self.class.relation_resource?
      end

      def before_resolve(scope, query)
        scope.with_associations(sideload_name_arr(query))
      end

      def sideload_name_arr(query)
        query.sideloads.keys.map(&:to_sym)
      end
    end
  end
end
