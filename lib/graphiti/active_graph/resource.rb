module Graphiti
  module ActiveGraph
    class Resource < Graphiti::Resource
      include Extensions::Resources::Authorizationable
      include Extensions::Resources::PayloadCombinable
      include Extensions::Resources::Preloadable
      include Extensions::Resources::Rel

      self.adapter = Adapters::ActiveGraph
      self.abstract_class = true

      def self.use_uuid
        define_singleton_method(:inherited) do |klass|
          super(klass)
          klass.attribute :id, :uuid
        end
      end

      def self.guard_nil_id!(params)
      end

      def self.extra_attribute?(name)
        extra_attributes.has_key?(name)
      end

      def self.sideload_config(sideload_name)
        config[:sideloads][sideload_name]
      end

      def self.sideload_resource_class(sideload_name)
        sideload_config(sideload_name)&.resource_class
      end

      def self.custom_eagerload(sideload_name)
        sideload_config(sideload_name)&.custom_eagerload
      end

      def extra_attribute?(name)
        self.class.extra_attribute?(name)
      end

      def build_scope(base, query, opts = {})
        scoping_class.new(base, self, query, opts)
      end

      def handle_includes(scope, includes, sorts, **opts)
        includes_str = JSONAPI::IncludeDirective.new(includes, retain_rel_limit: true).to_string.split(',')
        options = opts.merge(max_page_size:).merge!(authorize_scope_params)
        scope.with_ordered_associations(includes_str, sorts, options)
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

      def authorize_scope_params
        {}
      end

      def all_models
        polymorphic? ? self.class.children.map(&:model) : [model]
      end

      private

      def scoping_class
        Scope
      end

      def update_foreign_key(*)
        true
      end
    end
  end
end
