module Graphiti::ActiveGraph
  module Resource
    module Interface
      extend ActiveSupport::Concern
      class_methods do
        def build(params, base_scope = nil, opts = {})
          validate_request!(params)
          runner = ::Graphiti::Runner.new(self, params)
          runner.proxy(base_scope, { single: true, raise_on_missing: true }.merge(opts) )
        end
      end
    end
  end
end
