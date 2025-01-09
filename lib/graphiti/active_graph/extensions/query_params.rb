module Graphiti::ActiveGraph::Extensions
  class QueryParams
    attr_reader :params, :grouping_extra_params, :resource_class

    def initialize(params, resource_class, grouping_extra_params: {})
      @params = params
      @resource_class = resource_class
      @grouping_extra_params = grouping_extra_params
    end

    def group_by
      Grouping::Params.new(params, resource_class)
    end

    def group_by_params
      group_by_params_hash unless group_by.empty?
    end

    def group_by_params_hash
      { group_by: group_by.grouping_criteria_list }.merge(grouping_extra_params)
    end

    def extra_field?(type, name)
      params.dig(:extra_fields, type)&.include?(name.to_s)
    end
  end
end
