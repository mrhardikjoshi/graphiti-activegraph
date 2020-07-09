module Graphiti::ActiveGraph::Adapters::ActiveGraph::Sideload
  def self.included(base)
    base.class_eval do
      class_attribute :sideload_scope
    end
    base.extend(ClassMethods)
  end

  module ClassMethods
    def sideload_scope(&blk)
      self.sideload_scope = blk
    end
  end

  # def base_scope
  #   if @base_scope
  #     @base_scope.respond_to?(:call) ? @base_scope.call : @base_scope
  #   else
  #     resource.base_scope
  #   end
  # end

  # def load(parents, query, graph_parent)
  #   params, opts, proxy = nil, nil, nil

  #   with_error_handling Errors::SideloadParamsError do
  #     params = load_params(parents, query)
  #     params_proc&.call(params, parents, context)
  #     return [] if blank_query?(params)
  #     opts = load_options(parents, query)
  #     opts[:sideload] = self
  #     opts[:parent] = graph_parent
  #   end

  #   with_error_handling(Errors::SideloadQueryBuildingError) do
  #     proxy = resource.class._all(params, opts, base_scope)
  #     pre_load_proc&.call(proxy, parents)
  #   end

  #   proxy.to_a
  # end

  # def load(parents, _, _)
  #   child_arr = []
  #   @child_map = resource_with_parent_assoc(parents).each_with_object({}) do |arr, hash|
  #     child_obj = arr.first
  #     parent_uuid = arr.last
  #     hash[parent_uuid] ||= []
  #     hash[parent_uuid] << child_obj
  #     child_arr << child_obj
  #   end

  #   fire_assign(parents, child_arr)
  #   child_arr
  # end

  # def resource_with_parent_assoc(parents)
  #   parent_ids = parents.pluck(:id)
  #   proxy = parent_resource_class.model.as(:p).where(id: parent_ids)
  #   scope = self.class.sideload_scope

  #   if scope.present?
  #     scope.call(proxy)
  #   else
  #     proxy.send(association_name, :children)
  #   end.query.pluck(:children, p: :neo_id)
  # end
end
