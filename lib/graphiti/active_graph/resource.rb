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

      def guard_nil_id!(params)
      end
    end

    module ResourceInstanceMethods
      def relation_resource?
        self.class.relation_resource?
      end

      def sideload_name_arr(query)
        query.sideloads.keys.map(&:to_sym)
      end

      def resolve(scope)
        adapter.resolve(scope, relation_resource?)
      end

      def typecast(name, value, flag)
        att = get_attr!(name, flag, request: true)

        # in case of attribute is not declared on resource
        # do not throw error, return original value without typecast
        return value unless att

        type_name = att[:type]
        if flag == :filterable
          type_name = filters[name][:type]
        end
        type = Graphiti::Types[type_name]
        return if value.nil? && type[:kind] != "array"
        begin
          flag = :read if flag == :readable
          flag = :write if flag == :writable
          flag = :params if [:sortable, :filterable].include?(flag)
          type[flag][value]
        rescue => e
          raise Errors::TypecastFailed.new(self, name, value, e, type_name)
        end
      end
    end
  end
end
