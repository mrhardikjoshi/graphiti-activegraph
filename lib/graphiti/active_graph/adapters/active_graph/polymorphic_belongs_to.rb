class Graphiti::ActiveGraph::Adapters::ActiveGraph::PolymorphicBelongsTo < Graphiti::Sideload::PolymorphicBelongsTo
  include Graphiti::ActiveGraph::Adapters::ActiveGraph::Sideload

  def default_value_when_empty
    nil
  end

  def polymorphic?
    true
  end
end
