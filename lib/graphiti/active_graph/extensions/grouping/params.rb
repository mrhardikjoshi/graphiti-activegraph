module Graphiti::ActiveGraph::Extensions::Grouping
  class Params
    attr_reader :params, :grouping_criteria_list, :resource_class
    def initialize(params, resource_class)
      @params = params
      @grouping_criteria_list = params.fetch(:group_by, nil)&.split(',') || []
      @resource_class = resource_class
    end

    def single_grouping_criteria?
      grouping_criteria_list.size < 2
    end

    def grouping_criteria_on_attribute?
      grouping_criteria_list.any? { |criteria| ends_with_attribute?(resource_class.model, criteria) }
    end

    def empty?
      grouping_criteria_list.empty?
    end

    def ends_with_attribute?(model, criteria)
      return false if criteria.blank?

      last_segment_attribute?(model, criteria.split('.'))
    end

    private

    def last_segment_attribute?(model, segments)
      last_segment = segments.last
      intermediate_model = traverse_to_last_associated_model(model, segments[0...-1])

      intermediate_model && attribute?(intermediate_model, last_segment)
    end

    def traverse_to_last_associated_model(model, intermediate_segments)
      intermediate_segments.each do |segment|
        return false unless(model = associated_model(model, segment))
      end
      model
    end

    def attribute?(model, segment)
      model.attribute_names.include?(segment)
    end

    def associated_model(model, segment)
      model.associations[segment.to_sym]&.target_class
    end
  end
end
