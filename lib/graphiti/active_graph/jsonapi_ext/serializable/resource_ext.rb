module Graphiti
  module ActiveGraph
    module JsonapiExt
      module Serializable
        module ResourceExt
          def as_jsonapi(fields: nil, include: [])
            include.merge(fields) if fields.present?
            super(fields: fields, include: include)
          end
        end
      end
    end
  end
end
