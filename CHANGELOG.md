# Table of Contents

- [v0.6.0](#v060)
- [v0.5.12](#v0512)
- [v0.5.11](#v0511)
- [v0.5.10](#v0510)
- [v0.5.9](#v059)

## [v0.6.0]

> Released 2026/10/29

### Features
- Add `get_parts()`. It returns every part of the body in body order, including parts that have no `name`. It keeps duplicate headers.

### Fixes
- Read a part name that contains a colon, for example `name="a:b"`.
- Read quoted `name` and `boundary` values that contain `;`, spaces, or an escaped quote.
- Read the `boundary` parameter in any letter case, and stop at `;`.
- Match a delimiter line exactly. A line that only starts with the boundary is no longer a delimiter.
- Ignore the text before the first delimiter and the text after the closing delimiter.
- Keep every part when the closing delimiter is missing. Before, the last part replaced earlier parts with the same name.
- Do not merge a part that has no `name` into the next part.
- Read a part that has no headers.

## [v0.5.12]

> Released 2026/03/31

### Fixes
- fix(decode): handle unquoted Content-Disposition name parameter

## [v0.5.11]

> Released 2025/08/05

### Fixes
- fix: remove parts from `get_all_include_headers_with_arrays()` headers

## [v0.5.10]

> Released 2025/07/28

### Features
- Add `get_all_include_headers_with_arrays()` function to get struct headers informations.

## [v0.5.9]

> Released 2020/07/23

### Fixes

- Fix issue where header matching pattern could take an indeterminate amount
of time on long strings.

[v0.5.9]: https://github.com/Kong/lua-multipart/compare/v0.5.8..v0.5.9
