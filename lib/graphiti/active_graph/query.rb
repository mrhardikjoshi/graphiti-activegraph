module Graphiti::ActiveGraph
  module Query
    attr_reader :deep_sort

    def filters
      @filters ||= begin
        {}.tap do |hash|
          (@params[:filter] || {}).each_pair do |name, value|
            name = name.to_sym

            if legacy_nested?(name)
              value.keys.each do |key|
                filter_name = key.to_sym
                filter_value = value[key]

                if @resource.get_attr!(filter_name, :filterable, request: true)
                  hash[filter_name] = filter_value
                end
              end
            elsif nested?(name)
              name = name.to_s.split(".").last.to_sym
              validate!(name, :filterable)
              hash[name] = value
            else
              hash[name] = value
            end
          end
        end
      end
    end

    def sorts
      return super unless (sort = params[:sort]) && sort.include?('.')

      @deep_sort = sort_criteria(sort)
      []
    end

    def include_directive
      @include_directive ||= Graphiti::ActiveGraph::JsonapiExt::IncludeDirective.new(@include_param, retain_rel_limit: true)
    end

    def parse_sort_criteria_hash(hash)
      hash.map { |key, value| [key.to_s.split('.').map(&:to_sym), value] }.to_h
    end

    def links?
      [:json, :xml, 'json', 'xml'].exclude?(params[:format]) && show_resource_links?
    end

    def pagination_links?
      action != :find && show_pagination_links?
    end

    private

    def show_pagination_links?
      return @show_pagination_links unless @show_pagination_links.nil?
      @show_pagination_links = read_link_params(:pagination_links)
    end

    def show_resource_links?
      return @show_resource_links unless @show_resource_links.nil?

      @show_resource_links = read_link_params(:links)
    end

    def read_link_params(name)
      ActiveModel::Type::Boolean.new.cast(params[name]) != false
    end

    def sort_criteria(sort)
      sort.split(',').map(&method(:sort_hash)).map(&method(:parse_sort_criteria_hash))
    end
  end
end
