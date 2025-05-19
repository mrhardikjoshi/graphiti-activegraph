# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Graphiti Compatibility**: Added support for Graphiti versions up to 1.8.x, fixing previously broken sideloading behavior.

### Fixed

- **Serializer**: Resolved an issue where polymorphic resources were not functioning correctly in serializers.

## [1.1.0] - 2025-05-2

### Added

- **Deep sideloading**: introduced Include scoping class to support deep sideloading using single query (e.g. include='author.posts')
- **Deep sorting**: added SortNormalizer to support sorting by deep sideloaded resource's attribute (e.g. sort='author.posts.title')
- **Links control**: Control the links(pagination and resource) in response via request query params (pagination_links=true|false, links=true|false)

## [1.0.0] - 2025-03-18

### Added

- **MRI Support**: Introduced compatibility with MRI (Matz's Ruby Interpreter), expanding the gem's usability beyond JRuby (#38).
- **Documentation Updates**: Expanded the README to provide clearer guidance on gem usage and integration (#38).
- **Sideloading Workflow**: Enhanced scoping mechanisms and added support for eager loading associations to improve data retrieval efficiency and flexibility (#38).

### Changed
- **Resource Class**: Instead of modifying the `Graphiti::Resource` class, we now define `Graphiti::ActiveGraph::Resource`,  
  which must be inherited in all resource classes to enable ActiveGraph support (#38).

---

*Note: For details on changes prior to version 1.0.0, please refer to the [`CHANGELOG_PRE_1.0.0.md`](CHANGELOG_PRE_1.0.0.md) file.*

[unreleased]: https://github.com/mrhardikjoshi/graphiti-activegraph/compare/v1.0.0...master
[1.0.0]: https://github.com/mrhardikjoshi/graphiti-activegraph/compare/9f837108ae57287c65b0f6fd2609dd56a95cd461...v1.0.0
