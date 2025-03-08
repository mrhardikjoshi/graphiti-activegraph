module Graphiti::ActiveGraph::Extensions::Resources
  module Preloadable
    extend ActiveSupport::Concern

    class_methods do
      def with_preloaded_obj(obj, params)
        id = params[:data].try(:[], :id) || params.delete(:id)
        params[:filter] ||= {}
        params[:filter][:id] = id if id

        build(params, nil, raise_on_missing: false, preloaded: obj)
      end

      def all_with_preloaded(obj_arr, params)
        build(params, nil, single: false, raise_on_missing: false, preloaded: obj_arr)
      end
    end
  end
end
