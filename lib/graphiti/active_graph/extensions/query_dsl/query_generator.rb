module Graphiti::ActiveGraph::Extensions::QueryDsl
  class QueryGenerator
    def initialize(query_param, query:, **config)
      @query_param = query_param
      @query = query
    end

    def generate_functions_optional_match
    end

    def generate_with_clause_partition_query
    end

    def generate_match_query
    end

    def generate_with_clause_query
    end
  end
end
