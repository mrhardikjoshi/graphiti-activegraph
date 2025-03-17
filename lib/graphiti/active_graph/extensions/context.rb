module Graphiti::ActiveGraph::Extensions
  require 'ostruct' if RUBY_PLATFORM != 'java'

  module Context
    extend ActiveSupport::Concern

    class_methods do
      def context
        Thread.current.thread_variable_get(:context) || {}.tap(&method(:context=))
      end

      def context=(val)
        Thread.current.thread_variable_set(:context, val)
      end
    end
  end
end
