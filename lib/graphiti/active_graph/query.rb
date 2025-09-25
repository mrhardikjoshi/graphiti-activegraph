module Graphiti::ActiveGraph
  module Query
    attr_reader :deep_sort

    def filters
      @filters ||= begin
        result = {}
        filter_params = @params[:filter] || {}

        filter_params.each_pair do |name, value|
          name = name.to_sym

          if legacy_nested?(name)
            process_legacy_nested_filter(name, value, result)
          elsif nested?(name)
            process_nested_filter(name, value, result)
          else
            result[name] = value
          end
        end

        result.freeze
      end
    end

    def sorts
      return super unless (sort = params[:sort]) && sort.include?(".")

      @deep_sort = sort_criteria(sort)
      []
    end

    def include_directive
      @include_directive ||= Graphiti::ActiveGraph::JsonapiExt::IncludeDirective.new(@include_param, retain_rel_limit: true)
    end

    def parse_sort_criteria_hash(hash)
      hash.transform_keys { |key| key.to_s.split(".").map(&:to_sym) }
    end

    def links?
      @links_checked ||= begin
        format_excluded = [:json, :xml, "json", "xml"].include?(params[:format])
        !format_excluded && show_resource_links?
      end
    end

    def pagination_links?
      @pagination_links_checked ||= action != :find && show_pagination_links?
    end

    private

    def process_legacy_nested_filter(name, value, result)
      value.keys.each do |key|
        filter_name = key.to_sym
        filter_value = value[key]

        if @resource.get_attr!(filter_name, :filterable, request: true)
          result[filter_name] = filter_value
        end
      end
    end

    def process_nested_filter(name, value, result)
      filter_name = name.to_s.split(".").last.to_sym
      validate!(filter_name, :filterable)
      result[filter_name] = value
    end

    def show_pagination_links?
      return @show_pagination_links unless @show_pagination_links.nil?
      @show_pagination_links = read_link_params(:pagination_links)
    end

    def show_resource_links?
      return @show_resource_links unless @show_resource_links.nil?
      @show_resource_links = read_link_params(:links)
    end

    def read_link_params(name)
      param_value = params[name]
      return true if param_value.nil?

      ActiveModel::Type::Boolean.new.cast(param_value) != false
    end

    def sort_criteria(sort)
      @sort_criteria_cache ||= {}
      @sort_criteria_cache[sort] ||= sort.split(",").map(&method(:sort_hash)).map(&method(:parse_sort_criteria_hash))
    end
  end
end
