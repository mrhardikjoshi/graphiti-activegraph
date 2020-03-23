module Graphiti::ActiveGraph
  module Resource
    def with_preloaded_obj(obj, params)
      validate!(params)

      runner = ::Graphiti::Runner.new(self, params)
      runner.proxy(nil, single: true, raise_on_missing: false, preloaded: obj)
    end
  end
end

class ::Graphiti::Resource
  extend ::Graphiti::ActiveGraph::Resource
end
