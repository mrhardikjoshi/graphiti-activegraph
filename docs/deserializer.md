# Deserializer

### Overview
Handles incoming JSON:API payloads for Graphiti. Deserializes the request body and provides helper methods to extract and reconcile data, relationships and meta.

### Methods

#### `relationship_id(name)`
Returns the single related id for the given association name.  
Used when the relationship is `has_one`.

#### `relationship_ids(name)`
Returns an array of related ids for the given association name.  
Used when the relationship is `has_many`.

#### `add_path_id_to_relationships!(params)`
Ensures that relationship ids passed in the request path are reflected in `params[:data][:relationships]` when missing in the request body.
If the request body already contains an id for the same relationship, it compares the path and body ids using `detect_conflict` to prevent mismatched identifiers.  
The method is idempotent per request—subsequent calls are ignored once processed.

**Behavior summary:**
- Adds missing relationship ids to the request body.
- Detects and surfaces id mismatches between path and body.
- Updates the internal `relationships` hash for consistency.
- Marks the deserializer as updated to avoid repeated execution.

**Parameters:**
- `params` — Hash (usually the request parameters).

**Returns:**
- Modified `params` Hash with relationship ids added where necessary.

**Example:**
```ruby
# Given a path like /authors/42/books
path_map = { author: "42" }
params = { data: { type: "books", attributes: { title: "Graph Databases" } } }

deserializer.add_path_id_to_relationships!(params)
# => params[:data][:relationships][:author][:data][:id] == "42"
