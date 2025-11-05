module Graphiti::ActiveGraph::Extensions::QueryDsl
  module Performer
    attr_accessor :with_vars, :skip_arrow_cypher_rels

    def apply_query_dsl
      query_param = resource.context&.params[:query]
      query_param.present? ? apply_query_param(query_param) : scope
    end

    def apply_query_param(query_param)
      @scope = query_generator.new(query_param, **query_generator_config).tap do |qg|
        qg.generate_functions_optional_match
        qg.generate_with_clause_partition_query
        qg.generate_match_query
        qg.generate_with_clause_query
      end.query
    end

    private

    def query_generator
      Graphiti::ActiveGraph::Extensions::QueryDsl::QueryGenerator
    end

    def query_generator_config
      require 'pry'
      binding.pry
      {
        query: scope,
        with_vars_to_carry:,
        skip_arrow_cypher_rels: skip_arrow_cypher_rels || [],
        resource: resource.class
      }
    end

    def with_vars_to_carry
      (query ? with_vars_for_sort : []).push(*with_vars).push(*Graphiti.context[:with_vars]).compact
    end
  end
end
