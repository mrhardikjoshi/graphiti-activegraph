module Graphiti::ActiveGraph
  module SideloadResolve
    def initialize(object, resource, query, opts = {})
      @object = object
      @resource = resource
      @query = query
      @opts = opts
      @unpaginated_object = opts[:unpaginated_query].presence || @object

      return if opts[:preloaded]
      @object = @resource.around_scoping(@object, @query.hash) { |scope|
        apply_scoping(scope, opts)
      }
    end

    def resolve_sideloads(parents)
    end
  end
end
