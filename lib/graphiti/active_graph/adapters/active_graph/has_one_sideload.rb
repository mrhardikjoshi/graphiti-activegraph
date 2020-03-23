class Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload < Graphiti::Sideload::HasOne
  def default_base_scope
    resource_class.model.all
  end

  def infer_foreign_key
    association_name.to_sym
  end
end
