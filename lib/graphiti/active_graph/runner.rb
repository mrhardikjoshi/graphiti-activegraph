module Graphiti::ActiveGraph
  module Runner
    def proxy(base = nil, opts = {})
      base ||= jsonapi_resource.base_scope
      scope_opts = opts.slice :sideload_parent_length,
        :default_paginate,
        :after_resolve,
        :sideload,
        :parent,
        :params
      scope = jsonapi_scope(base, scope_opts)
      ::Graphiti::ResourceProxy.new jsonapi_resource,
        scope,
        query,
        payload: deserialized_payload,
        single: opts[:single],
        raise_on_missing: opts[:raise_on_missing],
        preloaded: opts[:preloaded]
    end
  end
end

class ::Graphiti::Runner
  prepend ::Graphiti::ActiveGraph::Runner
end
