module Graphiti::ActiveGraph::JsonapiExt::Serializable
  module ResourceExt
    def as_jsonapi(fields: nil, include: [])
      include.merge(fields) if fields.present?
      super
    end
  end
end
