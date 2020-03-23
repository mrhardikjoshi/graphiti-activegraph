module Graphiti::ActiveGraph
  module ResourceProxy
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
      if @preloaded
        if @data
          @data
        else
          @resource.decorate_record(@preloaded)
          @data = @preloaded
        end
      else
        super
      end
    end
  end
end

class ::Graphiti::ResourceProxy
  prepend ::Graphiti::ActiveGraph::ResourceProxy
end
