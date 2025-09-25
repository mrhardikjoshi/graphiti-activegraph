module Graphiti::ActiveGraph
  module Util
    module Transformers
      class RelationParam
        attr_reader :map

        def initialize(relation_param_str)
          @relation_param_str = relation_param_str.to_s
          @map = nil
          @rel_name = nil
          @rel_name_sym = nil
          @rel_limit = nil
          @rel_length = nil
        end

        def split_rel_length(retain_rel_limit)
          rel_name_part = if retain_rel_limit
            (rel_limit || "") + rel_name
          else
            rel_name_sym
          end
          [rel_name_part.to_sym, rel_length_number]
        end

        def rel_name_n_length
          @rel_name_n_length ||= "#{rel_name}#{rel_length}"
        end

        def rel_limit(limit_part = nil)
          return @rel_limit if @rel_limit && limit_part.nil?

          result = join(limit_part || parsed_map[:limit_part])
          @rel_limit = result if limit_part.nil?
          result
        end

        def rel_limit_number
          @rel_limit_number ||= rel_limit(parsed_map[:limit_part]&.except(:limit_ast))
        end

        def rel_name
          @rel_name ||= parsed_map[:rel_name].to_s
        end

        def rel_name_sym
          @rel_name_sym ||= rel_name.to_sym
        end

        def rel_length(length_part = nil)
          return @rel_length if @rel_length && length_part.nil?

          result = join(length_part || parsed_map[:length_part])
          @rel_length = result if length_part.nil?
          result
        end

        def rel_length_number
          @rel_length_number ||= rel_length(parsed_map[:length_part]&.except(:ast))
        end

        private

        def parsed_map
          @map ||= Graphiti::ActiveGraph::Util::Parsers::RelChain.new.rel_param_rule.parse(@relation_param_str)
        end

        def join(hash)
          return "" if hash.nil?

          case hash
          when Hash
            hash.values.join("")
          else
            hash.to_s
          end
        end
      end
    end
  end
end
