module Graphiti::ActiveGraph
  module SideloadResolve
    PRELOAD_METHOD_PREFIX = 'preload_'.freeze

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
      @query.extra_fields.each do |type, extra_field_names|
        extra_field_names.each do |name|
          next unless preload_extra_field?(type, name)

          records_for_preload = collect_records_for_preload(type, results)
          result_map = fetch_preloaded_data(type, name, records_for_preload)
          assign_preloaded_data(records_for_preload, name, result_map)
        end
      end
    end

    def fetch_preloaded_data(type, extra_field_name, results)
      resource_for_preload(type).model.public_send(default_preload_method(extra_field_name), results.pluck(:id).uniq)
    end

    def assign_preloaded_data(results, extra_field_name, result_map)
      results.each { |r| r.public_send("#{extra_field_name}=", result_map[r.id]) }
    end

    def preload_extra_field?(type, extra_field_name)
      resource = resource_for_preload(type)
      resource && resource.extra_attribute?(extra_field_name) && resource.model.respond_to?(default_preload_method(extra_field_name))
    end

    def resource_for_preload(type)
      return @resource if type == @resource.type

      find_resource_in_included_associations(type) unless @query.sideloads.empty?
    end

    def find_resource_in_included_associations(type, sideload_query = @query)
      sideload_query.sideloads.values.each do |sideload|
        return sideload.resource if sideload.resource.type == type

        resource = find_resource_in_included_associations(type, sideload)
        return resource if resource
      end

      nil
    end

    def default_preload_method(extra_field_name)
      "#{PRELOAD_METHOD_PREFIX}#{extra_field_name}"
    end

    def collect_records_for_preload(type, results)
      base_records = resource_matches_type?(@resource, type) ? Array(results) : []
      sideloaded_records = collect_sideloaded_records(Array(results), @query, type)
      (base_records + sideloaded_records).flatten.compact.uniq
    end

    def collect_sideloaded_records(source_records, sideload_query, type)
      return [] if source_records.empty? || sideload_query.sideloads.empty?

      sideload_query.sideloads.flat_map do |sideload_name, nested_query|
        associated_records = collect_associated_records(source_records, sideload_name)
        matched_records = resource_matches_type?(nested_query.resource, type) ? associated_records : []
        matched_records + collect_sideloaded_records(associated_records, nested_query, type)
      end
    end

    def resource_matches_type?(resource, type)
      resource&.type == type
    end

    def collect_associated_records(source_records, sideload_name)
      source_records.flat_map do |parent|
        next [] unless parent.respond_to?(sideload_name)

        Array(parent.public_send(sideload_name)).compact
      end
    end
  end
end
