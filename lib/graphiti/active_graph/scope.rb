module Graphiti::ActiveGraph
  module Scope
    def resolve
      if @query.zero_results?
        []
      else
        apply_includes_on_scope
        resolved = broadcast_data { |payload|
          @object = @resource.before_resolve(@object, @query)
          payload[:results] = @resource.resolve(@object)
          payload[:results]
        }

        resolved.compact!
        assign_serializer(resolved)
        yield resolved if block_given?
        @opts[:after_resolve]&.call(resolved)
        resolved
      end
    end

    def apply_includes_on_scope
      @object.with_associations(processed_sideloads)
    end

    def processed_sideloads
      all_sideloads.map(&:to_sym)
    end

    def all_sideloads
      @query.sideloads.keys
    end

    def resolve_sideloads(results)
    end
  end
end

class ::Graphiti::Scope
  prepend ::Graphiti::ActiveGraph::Scope
end
