module Graphiti::ActiveGraph
  module SideloadResolve
    PRELOAD_METHOD_PREFIX = "preload_".freeze

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

    def resolve
      resolve_with_callbacks.tap { |results| preload_extra_fields(results) }
    end

    private

    def resolve_with_callbacks
      if @query.zero_results?
        []
      else
        resolved = broadcast_data { |payload|
          @object = @resource.before_resolve(@object, @query)
          payload[:results] = @resource.resolve(@object)
          payload[:results]
        }
        resolved.compact!
        assign_serializer(resolved)
        yield resolved if block_given?
        @opts[:after_resolve]&.call(resolved)
        resolve_sideloads(resolved) unless @query.sideloads.empty?
        resolved
      end
    end

    def preload_extra_fields(results)
      requested_extra_fields.each do |extra_field_name|
        next unless preload_extra_field?(extra_field_name)

        result_map = fetch_preloaded_data(extra_field_name, results)
        assign_preloaded_data(results, extra_field_name, result_map)
      end
    end

    def requested_extra_fields
      @query.extra_fields[@resource.type] || []
    end

    def fetch_preloaded_data(extra_field_name, results)
      @resource.model.public_send(default_preload_method(extra_field_name), results.pluck(:id))
    end

    def assign_preloaded_data(results, extra_field_name, result_map)
      results.each { |r| r.public_send("#{extra_field_name}=", result_map[r.id]) }
    end

    def preload_extra_field?(extra_field_name)
      @resource.extra_attribute?(extra_field_name) && @resource.model.respond_to?(default_preload_method(extra_field_name))
    end

    def default_preload_method(extra_field_name)
      "#{PRELOAD_METHOD_PREFIX}#{extra_field_name}"
    end
  end
end
