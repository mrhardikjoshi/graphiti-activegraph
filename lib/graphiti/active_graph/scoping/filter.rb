module Graphiti::ActiveGraph
  module Scoping
    module Filter
      include Filterable
      include Internal::SortingAliases
      include Extensions::QueryDsl::Performer

      def apply
        super
        apply_query_dsl
      end

      def each_filter
        filter_param.each_pair do |param_name, param_value|
          filter = find_filter!(param_name)

          normalize_param(filter, param_value).each do |operator, value|
            operator = operator.to_s.gsub("!", "not_").to_sym

            # dynamic filters errors for validating and typecasting value below
            # so they are skipped here without validation or typecast
            filter_map = filter.values[0]
            if filter_map[:dynamic_filter]
              yield filter, operator, value
              next
            end
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
  end
end
