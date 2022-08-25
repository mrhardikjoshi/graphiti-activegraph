require 'zeitwerk'

# Workaround for jruby prepend issue https://github.com/jruby/jruby/issues/6971
module Graphiti
  module Scoping
  end
end
require 'graphiti/scoping/filterable'
require 'graphiti/resource/persistence'
# End workaround for jruby prepend issue

Zeitwerk::Loader.for_gem(warn_on_extra_files: false).setup

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
