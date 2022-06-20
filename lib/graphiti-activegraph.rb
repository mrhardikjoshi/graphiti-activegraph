require 'zeitwerk'

# Workaround for missing zeitwerk support as of jruby-9.2.13.0
module Graphiti
  module Scoping
  end
  module ActiveGraph
    module Scoping
    end
    module Adapters
    end
    module Util
    end
    module JsonapiExt
      module Serializable
      end
    end
  end
end
# End workaround

# Workaround for jruby prepend issue https://github.com/jruby/jruby/issues/6971
require 'graphiti/scoping/filterable'
require 'graphiti/resource/persistence'
# End workaround for jruby prepend issue

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect 'version' => 'VERSION'
loader.ignore(File.expand_path('graphiti-activegraph.rb', __dir__))
loader.setup

Graphiti::Scoping::Filterable.prepend Graphiti::ActiveGraph::Scoping::Filterable
Graphiti::Resource::Persistence.prepend Graphiti::ActiveGraph::Resource::Persistence
require 'graphiti'
Graphiti::Scoping::Filter.prepend Graphiti::ActiveGraph::Scoping::Filter
Graphiti::Util::SerializerRelationship.prepend Graphiti::ActiveGraph::Util::SerializerRelationship
Graphiti::Util::SerializerAttribute.prepend Graphiti::ActiveGraph::Util::SerializerAttribute
Graphiti::Util::RelationshipPayload.prepend Graphiti::ActiveGraph::Util::RelationshipPayload
Graphiti::Deserializer.prepend Graphiti::ActiveGraph::Deserializer
Graphiti::Query.prepend Graphiti::ActiveGraph::Query
Graphiti::Resource.prepend Graphiti::ActiveGraph::ResourceInstanceMethods
Graphiti::Resource.extend Graphiti::ActiveGraph::Resource
Graphiti::ResourceProxy.prepend Graphiti::ActiveGraph::ResourceProxy
Graphiti::Runner.prepend Graphiti::ActiveGraph::Runner
Graphiti::Scope.prepend Graphiti::ActiveGraph::SideloadResolve

# JSONAPI extensions
JSONAPI::Serializable::Resource.prepend Graphiti::ActiveGraph::JsonapiExt::Serializable::ResourceExt
