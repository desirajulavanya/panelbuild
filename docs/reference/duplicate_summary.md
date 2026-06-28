# Summarize duplicate unit-time cells by panel unit

`duplicate_summary()` reports how many duplicate unit-time cells each
panel unit has.

## Usage

``` r
duplicate_summary(data, id, time)
```

## Arguments

- data:

  A data frame or tibble.

- id:

  Unquoted column name identifying the panel unit.

- time:

  Unquoted column name identifying the time period.

## Value

A tibble with one row per panel unit that has duplicate cells. The
output includes:

- `panelbuild_duplicate_cells`:

  Number of duplicated unit-time cells for the unit.

- `panelbuild_duplicate_extra_rows`:

  Number of extra rows caused by duplicates.

If no duplicates are present, the function returns all units with zero
duplicate cells and zero extra rows.

## Details

This function summarizes duplicate cells at the panel-unit level. It is
useful when users want to identify which units contribute most to
duplicate unit-time observations.

The output reports both the number of duplicated cells and the number of
extra rows implied by those duplicates. For example, if one unit-time
cell appears three times, it counts as one duplicate cell and two extra
rows.

The function does not modify, drop, aggregate, or impute the data.

## See also

[`audit_panel()`](https://desirajulavanya.github.io/panelbuild/reference/audit_panel.md),
[`panel_duplicates()`](https://desirajulavanya.github.io/panelbuild/reference/panel_duplicates.md),
[`duplicate_cells()`](https://desirajulavanya.github.io/panelbuild/reference/duplicate_cells.md),
[`flag_panel_issues()`](https://desirajulavanya.github.io/panelbuild/reference/flag_panel_issues.md)

## Examples

``` r
duplicate_summary(example_panel, id = id, time = year)
#> # A tibble: 1 × 3
#>      id panelbuild_duplicate_cells panelbuild_duplicate_extra_rows
#>   <dbl>                      <int>                           <int>
#> 1     1                          1                               1
```
