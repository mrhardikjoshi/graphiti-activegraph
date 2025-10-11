# Graphiti ActiveGraph

[![Gem Version](https://badge.fury.io/rb/graphiti-activegraph.svg)](https://badge.fury.io/rb/graphiti-activegraph) [![Build Status](https://github.com/mrhardikjoshi/graphiti-activegraph/actions/workflows/specs.yml/badge.svg?branch=master)](https://github.com/mrhardikjoshi/graphiti-activegraph/actions?query=branch%3Amaster) [![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

An adapter to make Graphiti work with the ActiveGraph(former Neo4jrb) OGM. This gem allows you to easily build [jsonapi.org](https://jsonapi.org) compatible APIs for GraphDB using [Graphiti](https://www.graphiti.dev) and [ActiveGraph](https://github.com/neo4jrb/activegraph). 

## Installation
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

## Documentation
### Key Differences from Graphiti
#### Efficient Sideloading:
Unlike Graphiti, which executes multiple queries for sideloading, graphiti-activegraph leverages `with_ordered_associations` from ActiveGraph to fetch sideloaded data in a single query, improving performance.

#### Sideposting Behavior:
graphiti-activegraph allows assigning and unassigning relationships via sideposting but does not support modifying a resource’s attributes through sideposting.

#### Thread Context Handling:
Graphiti stores context using `Thread.current[]`, which does not persist across different fibers within the same thread. In graphiti-activegraph, when running on MRI (non-JRuby environments), the gem uses `thread_variable_get` and `thread_variable_set`. Ensuring the context remains consistent across different fibers in the same thread.

### New Features in graphiti-activegraph
#### Rendering Preloaded Objects Without Extra Queries
graphiti-activegraph introduces two new methods on the Graphiti resource class:
`with_preloaded_obj(record, params)` – Renders a single preloaded ActiveGraph object without querying the database.
`all_with_preloaded(records, params)` – Renders multiple preloaded ActiveGraph objects without additional queries.
**Note:** These methods assume that the provided records are final and will not apply Graphiti’s filtering, sorting, or scoping logic.

#### Efficient Deep Sorting
Graphiti does not natively support deep sorting (i.e., sorting based on attributes of associated resources), `graphiti-activegraph` adds this feature by allowing you to chain associations using dot (.) notation.
For example, to sort Post records based on their Author's Country's name, you can use following query string:
```
sort=author.country.name&include=author.country
```
Here, `Author` and `Country` are associated resources, and `name` is an attribute on `Country`. The posts will be sorted by the country's name. You can chain any number of associations in this way to achieve deep sorting.
Note: The `include` parameter must be present and include the full association path (`author.country`) for the sorting to work correctly.

#### Response Payload Links control
Control the links in response payload via request query params:
- `pagination_links=true|false` — toggle top-level pagination links
- `links=true|false` — toggle links inside each resource object

#### Preload Extra Attribute Associations via `preload:` option
You can declare an extra attribute on your resource and specify an association to preload using the `preload:` option.
  Example:
  ```ruby
    extra_attribute :full_post_title, :string, preload: :author
  ```
Check [spec/active_graph/scoping/internal/extra_field_normalizer_spec.rb](https://github.com/mrhardikjoshi/graphiti-activegraph/blob/master/spec/active_graph/scoping/internal/extra_field_normalizer_spec.rb) for examples of usage `preload:` option.

#### Preload Extra Fields via Model Preload Method
You can define a custom preload method with prefix `preload_` in your model (e.g., `preload_posts_number` for the posts_number extra field) that fetches values for the extra attribute.
When you request an extra field (e.g., `posts_number`) in your query, graphiti-activegraph will call this method, passing all relevant record IDs, and assign the returned values to each record’s extra attribute.
This works for both top-level results and sideloaded records of the matching resource type.

##### Usage example
```ruby
  class Comment
    # Allows assignment of the extra field value by the preloader
    attr_writer :author_activity

    def author_activity
      @author_activity ||= author.comments.count + author.posts.count
    end

    # Preload method which fetches values for the extra_attribute
    def self.preload_author_activity(comment_ids)
      where(id: comment_ids).with_associations(author: [:posts, :comments]).to_h do |comment|
        author = comment.author
        [comment.id, author.posts.count + author.comments.count]
      end
    end
  end

  class CommentResource < Graphiti::ActiveGraph::Resource
    extra_attribute :author_activity, :integer
  end
```

**Note:**
Currently, this feature does not support preloading for deep sideloads such as `posts.comment.author*`. Deeply sideloaded records will not appear in the array of relevant records for preload, and thus will not have extra fields assigned.

Check [spec/support/factory_bot_setup.rb](https://github.com/mrhardikjoshi/graphiti-activegraph/blob/master/spec/support/factory_bot_setup.rb) and [spec/active_graph/sideload_resolve_spec.rb](https://github.com/mrhardikjoshi/graphiti-activegraph/blob/master/spec/active_graph/sideload_resolve_spec.rb) for examples of usage.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/mrhardikjoshi/graphiti-activegraph. This project is intended to be a safe, welcoming space for collaboration.

## Release
1. Make sure version file is updated/incremented in master branch
2. git checkout master
3. git pull origin master
4. git tag v1.2.3
5. git push origin v1.2.3
6. gem build graphiti-activegraph.gemspec
7. gem push graphiti-activegraph-1.2.3.gem

## License
The gem is available as open-source under the terms of the MIT License.
