module Graphiti::ActiveGraph
  module Scoping
    module Filter
      include Filterable

      def each_filter
        return unless filter_param.respond_to?(:each_pair)

        filter_param.each_pair do |param_name, param_value|
          process_filter_param(param_name, param_value) { |filter, operator, value|
            yield filter, operator, value
          }
        end
      end

      private

      def process_filter_param(param_name, param_value)
        filter = find_filter!(param_name)
        filter_map = filter.values[0]

        normalize_param(filter, param_value).each do |operator, value|
          operator = normalize_operator(operator)

          # Skip validation and typecast for dynamic filters
          if filter_map[:dynamic_filter]
            yield filter, operator, value
            next
          end

          # Process regular filters with validation and typecast
          process_regular_filter(filter, filter_map, operator, value, param_name) { |f, op, val|
            yield f, op, val
          }
        end
      end

      def normalize_operator(operator)
        operator.to_s.gsub("!", "not_").to_sym
      end

      def process_regular_filter(filter, filter_map, operator, value, param_name)
        validate_operator(filter, operator)

        type = ::Graphiti::Types[filter_map[:type]]
        unless type[:canonical_name] == :hash || !value.is_a?(String)
          value = parse_string_value(filter_map, value)
        end

        check_deny_empty_filters!(resource, filter, value)
        value = parse_string_null(filter_map, value)
        validate_singular(resource, filter, value)
        value = coerce_types(filter_map, param_name.to_sym, value)
        validate_allowlist(resource, filter, value)
        validate_denylist(resource, filter, value)
        value = value[0] if filter_map[:single]

        yield filter, operator, value
      end
    end
  end
end
