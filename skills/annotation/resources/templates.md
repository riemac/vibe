# Annotation Templates

## Function / Method (Google-style)

```text
<Summary line: imperative mood>

Args:
    <name>: <meaning>. Constraints: <range/shape/units/conventions>. Optionality: <...>.

Returns:
    <name or description>: <meaning>. Shape/units/conventions: <...>.

Raises:
    <ErrorType>: <when/why>.

Notes:
    Goal:
        <why this exists>

    Definitions:
        - <symbols/units/conventions>
        - $$...$$

    Algorithm (pseudocode):
        1) ...
        2) ...
        3) ...

    Edge cases:
        - ...
```

## Class / Component

```text
<Summary: role in system>

Contracts:
    - <invariant 1>
    - <invariant 2>

Attributes:
    <name>: <meaning>. Units/conventions: <...>. Lifecycle: <...>.
```

## Config Object

```text
Configuration for <what>.

Attributes:
    <name>: <meaning>. Default: <value>. Constraints: <range/valid values>.

Notes:
    Contract:
        - <invariant or cross-field constraint>
```
