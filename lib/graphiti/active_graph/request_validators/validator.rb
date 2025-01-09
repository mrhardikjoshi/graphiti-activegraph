module Graphiti::ActiveGraph
  module RequestValidators
    module Validator
      def deserialized_payload
        @deserialized_payload ||= Graphiti::ActiveGraph::Deserializer.new(@params)
      end
    end
  end
end
