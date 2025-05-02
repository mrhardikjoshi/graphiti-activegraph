module Graphiti::ActiveGraph
  module Util
    module Transformers
      class RelationParam
        attr_reader :map

        def initialize(relation_param_str)
          @map = Graphiti::ActiveGraph::Util::Parsers::RelChain.new.rel_param_rule.parse(relation_param_str.to_s)
        end

        def split_rel_length(retain_rel_limit)
          rel_name_part = if retain_rel_limit
                            (rel_limit || '') + rel_name
                          else
                            rel_name_sym
                          end
          [rel_name_part.to_sym, rel_length_number]
        end

        def rel_name_n_length
          "#{rel_name}#{rel_length}"
        end

        def rel_limit(limit_part = nil)
          join(limit_part || map[:limit_part])
        end

        def rel_limit_number
          rel_limit(map[:limit_part]&.except(:limit_ast))
        end

        def rel_name
          map[:rel_name].to_s
        end

        def rel_name_sym
          rel_name.to_sym
        end

        def rel_length(length_part = nil)
          join(length_part || map[:length_part])
        end

        def rel_length_number
          rel_length(map[:length_part]&.except(:ast))
        end

        private

        def join(hash)
          hash&.values&.map(&:to_s)&.join
        end
      end
    end
  end
end
