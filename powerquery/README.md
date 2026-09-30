# Power Query M

An ANTLR4 grammar for the Power Query M formula language: the language of Power Query in
Excel and Power BI, and of Power Query custom connectors (`.pq`, `.pqm`).

The entry rule is `document`. It accepts a section document (`section Section1; shared A = ...;`,
the form Excel stores queries in) or a single expression.

## Source

Written from the specification's
[M Language Consolidated Grammar](https://learn.microsoft.com/powerquery-m/m-spec-consolidated-grammar).
Rule names follow its productions, with `-` written as `_`.

Where the Power Query product accepts more than the specification, this grammar follows the
product, as documented by Microsoft's reference parser
([specification.md](https://github.com/microsoft/powerquery-parser/blob/master/specification.md)):

- after a `.`, an identifier continues with any identifier-part character (`Column1.1`);
- a generalized identifier (a record field name or field selector such as `[Sales Amount]`,
  `[1st Quarter]` or `[if]`) may start with a digit and may contain keywords;
- `try ... catch (e) => ...`;
- `??` (null coalescing) binds looser than `or`;
- `type table (expression)` takes the row type from an expression.

`catch`, `optional`, `nullable` and the primitive type names (`number`, `text`, `table`, ...) are
contextual keywords and remain usable as identifiers. M is case-sensitive.

## Known approximations

The grammar has no target-specific code, so two lexical rules are approximated:

- A generalized identifier's parts must be "separated only by blanks". A comment between the
  parts is accepted.
- A malformed character escape such as `"#(bogus)"` is accepted as plain text.

In a type position, `number`, `{number}` and `[a = text]` can be read as either a type or an
expression. `primary_type` is tried first.

## Examples

- `spec_*.pq` exercise each production of the specification.
- `msdc_*.pq` are Microsoft's Power Query connector samples, taken from
  [microsoft/DataConnectors](https://github.com/microsoft/DataConnectors) (MIT) through the test
  resources of [microsoft/powerquery-parser](https://github.com/microsoft/powerquery-parser)
  (MIT, commit 1e49dd1). Duplicate files are removed, and paths are flattened into file names.
  See `THIRD_PARTY_NOTICES.md`.

## License

MIT; see the header of each `.g4` file.
