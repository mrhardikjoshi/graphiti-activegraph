## Unreleased

-

## 0.1.8 (09-06-2021)

Features:

- Added support for polymorphic relationship.

## 0.1.13 (21-12-2021)

Features:

- Supports Jruby-9.3.2.0

## 0.1.14 (21-12-2021)

Features:

- Adding unpaginated query to resource proxy with preloaded records. This will help in getting count on API.

## 0.1.15 (21-06-2022)

Features:

- Relationships mentioned in sparse field param (and not in include), will now be returned in relationship block of response

## 0.1.20

Features:

- With graphiti config variable "allow_sidepost" you can allow/disallow sideposting, by default it is allowed.

## 0.1.21

Fixes:

- Runner#proxy keyword arguments

## 0.1.22

Fixes:

- when rendering preloaded resources, we were not applying scoping. Now we are skipping around_scoping callback too.

## 0.1.23 (29-04-2024)

Features:

- Added support for UUID

## 0.1.24 (18-06-2024)

Features:

- Added preliminary support for Sideload backed by function instead of model association

## 0.1.25 (04-12-2024)

Features:

- Added support to preload extra_fields for the main resource, replacing N+1 queries with a single query. This does not apply to sideloaded resources.

## 0.1.25 (01-24-2025)

Features:

- Added MRI support
- Added support for rails 8

Breaking changes:

- Removed support for graphiti <= 1.6.3

<!-- ### [version (DD-MM-YYYY)] -->
<!-- Breaking changes:-->
<!-- Features:-->
<!-- Fixes:-->
<!-- Misc:-->
