module Graphiti::ActiveGraph
  module Util
    module Parsers
      class RelChain < Parslet::Parser
        VAR_CHAR = "a-z_"

        rule(:asterisk) { str("*") }
        rule(:range) { str("..") }
        rule(:dot) { str(".") }
        rule(:none) { str("") }
        rule(:number) { match('[\d]').repeat(1) }
        rule(:number?) { number | none }
        rule(:identifier) { match("[#{VAR_CHAR}]") >> match("[#{VAR_CHAR}0-9]").repeat(0) }
        rule(:identifier?) { identifier | none }
        rule(:rel_name) { identifier?.as(:rel_name) }
        rule(:length) { asterisk.as(:ast) >> number?.maybe.as(:min) >> range.as(:range).maybe >> number?.maybe.as(:max) }
        rule(:rel) { rel_name >> length.maybe }

        rule(:rel_chain) { rel >> (dot >> rel).repeat(0) }
        root(:rel_chain)

        rule(:limit) { number?.as(:limit_digit) >> asterisk.as(:limit_ast) }
        rule(:rel_param_rule) { limit.maybe.as(:limit_part) >> rel_name >> length.maybe.as(:length_part) }
      end
    end
  end
end
