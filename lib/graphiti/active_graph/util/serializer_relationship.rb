module Graphiti::ActiveGraph
  module Util
    module SerializerRelationship
      def data_proc
        sideload_ref = @sideload
        ->(_) {
          # use custom assigned sideload if it is specified via "assign_each_proc"
          # otherwise retrieve sideload using normal getter on parent object
          records = if custom_proc = sideload_ref.assign_each_proc
                      custom_proc.call(@object)
                    else
                      @object.public_send(sideload_ref.association_name)
                    end

          if records
            if records.respond_to?(:to_ary)
              records.each { |r| sideload_ref.resource.decorate_record(r) }
            else
              sideload_ref.resource.decorate_record(records)
            end

            records
          end
        }
      end
    end
  end
end
