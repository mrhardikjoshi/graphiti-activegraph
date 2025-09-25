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
        @include_directive_cache ||= {}

        directive = @include_directive_cache[includes] ||=
          JSONAPI::IncludeDirective.new(includes, retain_rel_limit: true)

        includes_str = directive.to_string.split(",")
        extra_includes_str = opts.delete(:extra_fields_includes) || []
        options = opts.merge(max_page_size:).merge!(authorize_scope_params)
        scope.with_ordered_associations(includes_str.union(extra_includes_str), sorts, options)
      end

      def sideload_name_arr(query)
        @sideload_name_cache ||= {}
        sideload_keys = query.sideloads.keys

        @sideload_name_cache[sideload_keys] ||= sideload_keys.map(&:to_sym).freeze
      end

      def resolve(scope)
        adapter.resolve(scope, relation_resource?)
      end

      def typecast(name, value, flag)
        # Early return for nil value optimization
        return value unless value || (att = get_attr!(name, flag, request: true))
        return value unless att

        type_name = if flag == :filterable
          filters[name][:type]
        else
          att[:type]
        end

        type = Graphiti::Types[type_name]
        return if value.nil? && type[:kind] != "array"

        begin
          normalized_flag = case flag
          when :readable then :read
          when :writable then :write
          when :sortable, :filterable then :params
          else flag
          end

          type[normalized_flag][value]
        rescue => e
          raise Errors::TypecastFailed.new(self, name, value, e, type_name)
        end
      end

      def authorize_scope_params
        @authorize_scope_params ||= {}.freeze
      end

      def all_models
        @all_models ||= if polymorphic?
          self.class.children.map(&:model).freeze
        else
          [model].freeze
        end
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
