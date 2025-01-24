module Graphiti::ActiveGraph
  module ResourceProxy
    include Graphiti::ActiveGraph::SideloadResolve
    attr_reader :preloaded

    def initialize(resource, scope, query,
      payload: nil,
      single: false,
      raise_on_missing: false,
      preloaded: false)
      @resource = resource
      @scope = scope
      @query = query
      @payload = payload
      @single = single
      @raise_on_missing = raise_on_missing
      @preloaded = preloaded
    end

    def data
      return @data if @data

      return super unless @preloaded

      resolve_sideloads(@preloaded)
      @single ? data_for_preloaded_record : data_for_preloaded_records
    end

    alias_method :resolve_data, :data

    def data_for_preloaded_record
      @preloaded = @preloaded.is_a?(Array) ? @preloaded[0] : @preloaded
      @resource.decorate_record(@preloaded)
      @data = @preloaded
    end

    def data_for_preloaded_records
      @preloaded.each do |r|
        @resource.decorate_record(r)
      end
      @data = @preloaded
    end

    def stats
      @stats ||= if @query.stats && !resource.relation_resource?
        payload = ::Graphiti::Stats::Payload.new @resource,
          @query,
          @scope.unpaginated_object,
          data
        payload.generate
      else
        {}
      end
    end

    def save(action: :create)
      # TODO: remove this. Only used for persisting many-to-many with AR
      # (see activerecord adapter)
      original = Graphiti.context[:namespace]
      begin
        Graphiti.context[:namespace] = action
        ::Graphiti::RequestValidator.new(@resource, @payload.params, action).validate!
        validator = persist {
          @resource.persist_with_relationships \
            @payload.meta(action: action),
            @payload.attributes,
            @payload.relationships
        }
      ensure
        Graphiti.context[:namespace] = original
      end
      @data, success = validator.to_a

      if success && !resource.relation_resource?
        # If the context namespace is `update` or `create`, certain
        # adapters will cause N+1 validation calls, so lets explicitly
        # switch to a lookup context.
        Graphiti.with_context(Graphiti.context[:object], :show) do
          @scope.resolve_sideloads([@data])
        end
      end

      success
    end
  end
end
