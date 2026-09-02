module Graphiti
  module ActiveGraph
    module Util
      module SerializerRelationships
        private

        def apply?(sideload)
          return super if dynamically_readable?(sideload)

          super && sideload.readable?
        end

        def dynamically_readable?(sideload)
          flag = sideload.instance_variable_get(:@readable)
          flag.is_a?(Symbol) || flag.is_a?(String) || flag.is_a?(Proc)
        end
      end
    end
  end
end
