module Graphiti::ActiveGraph::Concerns
  module PathRelationships
    def add_path_id_to_relationships!(params)
      return params if path_relationships_updated?
      detect_conflict(:id, @params[:id]&.to_s, attributes[:id]&.to_s)
      path_map.each do |rel_name, path_value|
        body_value = relationships.dig(rel_name, :attributes, :id)
        if body_value
          detect_conflict(rel_name, path_value&.to_s, body_value&.to_s)
        else
          update_params(params, rel_name, path_value)
          update_realationships(rel_name, path_value)
        end
      end
      path_relationships_updated!
      params
    end

    private

    def path_relationships_updated!
      @path_relationships_updated = true
    end

    def path_relationships_updated?
      @path_relationships_updated.present?
    end

    def update_params(params, rel_name, path_value)
      params[:data] ||= {}
      params[:data][:relationships] ||= {}
      params[:data][:relationships][rel_name] = {
        data: {
          type: derive_resource_type(rel_name),
          id: path_value
        }
      }
    end

    def update_realationships(rel_name, path_value)
      relationships[rel_name] = { meta: {}, attributes: { id: path_value } }
    end
  end
end
