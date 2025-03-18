# Graphiti ActiveGraph

[![Gem Version](https://badge.fury.io/rb/graphiti-activegraph.svg)](https://badge.fury.io/rb/graphiti-activegraph) [![Build Status](https://github.com/mrhardikjoshi/graphiti-activegraph/actions/workflows/specs.yml/badge.svg?branch=master)](https://github.com/mrhardikjoshi/graphiti-activegraph/actions?query=branch%3Amaster) [![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

An adapter to make Graphiti work with the ActiveGraph(former Neo4jrb) OGM. This gem allows you to easily build [jsonapi.org](https://jsonapi.org) compatible APIs for GraphDB using [Graphiti](https://www.graphiti.dev) and [ActiveGraph](https://github.com/neo4jrb/activegraph). 

### Installation
Add this line to your application's `Gemfile`:
```ruby
gem 'graphiti-activegraph'
```

And then execute:
```shell
bundle install
```

Or install it yourself as:
```shell
gem install graphiti-activegraph
```


## Usage
While defining a Resource class, inherit it from `Graphiti::ActiveGraph::Resource`
```ruby
class PlanetResource < Graphiti::ActiveGraph::Resource
```

For model backed by `ApplicationRelationship` instead of `ApplicationNode`, we have to set `relationship_resource` to `true` while defining resource class.
```ruby
class RelationshipBackedResource < Graphiti::ActiveGraph::Resource
  self.relationship_resource = true
end
```

### Documentation
##### **Key Differences from Graphiti**
- **Efficient Sideloading:**
Unlike Graphiti, which executes multiple queries for sideloading, graphiti-activegraph leverages `with_ordered_associations` from ActiveGraph to fetch sideloaded data in a single query, improving performance.

- **Sideposting Behavior:**
graphiti-activegraph allows assigning and unassigning relationships via sideposting but does not support modifying a resource’s attributes through sideposting.

- **Thread Context Handling:**
Graphiti stores context using `Thread.current[]`, which does not persist across different fibers within the same thread. In graphiti-activegraph, when running on MRI (non-JRuby environments), the gem uses `thread_variable_get` and `thread_variable_set`. Ensuring the context remains consistent across different fibers in the same thread.

##### **New Features in graphiti-activegraph**
###### Rendering Preloaded Objects Without Extra Queries
graphiti-activegraph introduces two new methods on the Graphiti resource class:
`with_preloaded_obj(record, params)` – Renders a single preloaded ActiveGraph object without querying the database.
`all_with_preloaded(records, params)` – Renders multiple preloaded ActiveGraph objects without additional queries.
**Note:** These methods assume that the provided records are final and will not apply Graphiti’s filtering, sorting, or scoping logic.

### Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/mrhardikjoshi/graphiti-activegraph. This project is intended to be a safe, welcoming space for collaboration.

### Release
1. Make sure version file is updated/incremented in master branch
2. git checkout master
3. git pull origin master
4. git tag v1.2.3
5. git push origin v1.2.3
6. gem build graphiti-activegraph.gemspec
7. gem push graphiti-activegraph-1.2.3.gem

### License
The gem is available as open-source under the terms of the MIT License.
