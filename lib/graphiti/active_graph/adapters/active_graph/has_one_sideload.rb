class Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload < Graphiti::Sideload::HasOne
  include Graphiti::ActiveGraph::Adapters::ActiveGraph::Sideload

  def default_value_when_empty
    nil
  end
end
