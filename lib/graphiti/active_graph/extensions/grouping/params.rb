module Graphiti::ActiveGraph::Extensions::Grouping
  class Params
    attr_reader :params, :grouping_criteria_list, :resource_class

    def initialize(params, resource_class)
      @params = params
      group_by_string = params.fetch(:group_by, nil)
      @grouping_criteria_list = split_grouping_criteria(group_by_string)
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
        return false unless (model = associated_model(model, segment))
      end
      model
    end

    def attribute?(model, segment)
      model.attribute_names.include?(segment)
    end

    def associated_model(model, segment)
      model.associations[segment.to_sym]&.target_class
    end

    def split_grouping_criteria(group_by_string)
      return [] if group_by_string.nil? || group_by_string.empty?

      result = []
      current = ''
      depth = 0

      group_by_string.each_char do |char|
        depth, current = process_char(char, depth, current, result)
      end

      add_criterion(result, current)
      handle_mismatched_parentheses(result, depth)
    end

    def process_char(char, depth, current, result)
      case char
      when '(' then [depth + 1, current + char]
      when ')' then [depth - 1, current + char]
      when ',' then process_comma(depth, current, result)
      else [depth, current + char]
      end
    end

    def process_comma(depth, current, result)
      if depth <= 0
        add_criterion(result, current)
        [depth, '']
      else
        [depth, current + ',']
      end
    end

    def add_criterion(result, current)
      stripped = current.strip
      result << stripped unless stripped.empty?
    end

    def handle_mismatched_parentheses(result, final_depth)
      return result if final_depth <= 0 || result.empty?

      # If we ended with unclosed parentheses, re-split the last segment
      last_segment = result.pop
      result.concat(last_segment.split(',').map(&:strip).reject(&:empty?))
      result
    end
  end
end
