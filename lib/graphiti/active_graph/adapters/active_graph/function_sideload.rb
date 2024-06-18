class Graphiti::ActiveGraph::Adapters::ActiveGraph::FunctionSideload < Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload
  class_attribute :function_proc, :param_proc

  def association?
    false
  end

  def self.function_proc(&blk)
    self.function_proc = blk
  end

  def self.param_proc(&blk)
    self.param_proc = blk
  end
end
