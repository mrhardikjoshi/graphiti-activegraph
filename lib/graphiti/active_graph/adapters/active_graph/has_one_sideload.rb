class Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload < Graphiti::Sideload::HasOne
  include Graphiti::ActiveGraph::Adapters::ActiveGraph::Sideload

  def default_base_scope
    resource_class.model.all
  end

  def infer_foreign_key
    association_name.to_sym
  end

  def default_value_when_empty
    nil
  end
end
