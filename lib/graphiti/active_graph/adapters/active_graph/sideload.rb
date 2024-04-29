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

  def default_base_scope
    resource_class.model.all
  end

  def infer_foreign_key
    association_name.to_sym
  end

  def polymorphic?
    false
  end
end
