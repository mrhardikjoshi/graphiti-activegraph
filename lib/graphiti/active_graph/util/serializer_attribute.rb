module Graphiti::ActiveGraph
  module Util
    module SerializerAttribute
      def wrap_proc(inner)
        typecast_ref = typecast(Graphiti::Types[@attr[:type]][:read])
        ->(serializer_instance = nil) {
          val = serializer_instance.instance_eval(&inner)
          if Graphiti.config.typecast_reads && inner.nil?
            typecast_ref.call(val)
          else
            val
          end
        }
      end
    end
  end
end
