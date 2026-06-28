
# panelbuild

`panelbuild` provides tools for auditing, validating, and preparing
panel datasets before statistical analysis.

<!-- badges: start -->

[![R-CMD-check](https://github.com/desirajulavanya/panelbuild/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/desirajulavanya/panelbuild/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Installation

You can install the development version of `panelbuild` from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("desirajulavanya/panelbuild")
```

## Quick start

``` r
library(panelbuild)

audit <- audit_panel(example_panel, id = id, time = year)

audit
```

    ## Panel audit
    ## 
    ## Data: example_panel
    ## Unit variable: id
    ## Time variable: year
    ## 
    ## Units: 3
    ## Time periods: 4
    ## Observed rows: 9
    ## Observed id-time cells: 8
    ## Expected id-time cells: 12
    ## Missing id-time cells: 4
    ## Duplicate id-time cells: 1
    ## Balanced panel: No

``` r
audit_report(audit)
```

    ## panelbuild Panel Audit Report
    ## ==========================
    ## 
    ## Dataset
    ## -------
    ## Data: example_panel
    ## Unit variable: id
    ## Time variable: year
    ## 
    ## Panel structure
    ## ---------------
    ## Units: 3
    ## Time periods: 4
    ## Observed rows: 9
    ## Observed unit-time cells: 8
    ## Expected unit-time cells: 12
    ## Missing unit-time cells: 4
    ## Duplicate unit-time cells: 1
    ## Balanced panel: No
    ## 
    ## Recommended next steps
    ## ----------------------
    ## * Resolve duplicate unit-time observations before completing the panel.
    ## * Use `duplicate_cells(audit)` or `duplicate_summary()` to inspect duplicates.
    ## * Inspect missing unit-time cells before estimation.
    ## * Use `missing_cells(audit)` or `gap_summary()` to review panel gaps.
    ## * Use `complete_panel()` only after duplicate unit-time cells are resolved.

## Why panelbuild?

Panel datasets often contain missing unit-time cells, duplicate
observations, irregular time gaps, and imbalance. These issues can
affect fixed effects models, difference-in-differences designs, event
studies, and other panel-data methods.

`panelbuild` helps researchers identify and document these problems
before estimation.

## Basic example

``` r
library(panelbuild)

data(example_panel)

example_panel
```

    ##   id year outcome treatment
    ## 1  1 2020      10         0
    ## 2  1 2021      12         1
    ## 3  1 2021      13         1
    ## 4  2 2020      20         0
    ## 5  2 2022      25         1
    ## 6  3 2020      30         0
    ## 7  3 2021      31         0
    ## 8  3 2022      32         1
    ## 9  3 2023      33         1

## Audit a panel dataset

``` r
audit_panel(example_panel, id = id, time = year)
```

    ## Panel audit
    ## 
    ## Data: example_panel
    ## Unit variable: id
    ## Time variable: year
    ## 
    ## Units: 3
    ## Time periods: 4
    ## Observed rows: 9
    ## Observed id-time cells: 8
    ## Expected id-time cells: 12
    ## Missing id-time cells: 4
    ## Duplicate id-time cells: 1
    ## Balanced panel: No

## Find duplicate unit-time observations

``` r
duplicate_summary(example_panel, id = id, time = year)
```

    ## # A tibble: 1 × 3
    ##      id panelbuild_duplicate_cells panelbuild_duplicate_extra_rows
    ##   <dbl>                      <int>                           <int>
    ## 1     1                          1                               1

## Summarize panel gaps

``` r
gap_summary(example_panel, id = id, time = year)
```

    ## # A tibble: 2 × 2
    ##      id panelbuild_missing_periods
    ##   <dbl>                      <int>
    ## 1     1                          2
    ## 2     2                          2

## Flag row-level panel issues

``` r
flag_panel_issues(example_panel, id = id, time = year)
```

    ## # A tibble: 9 × 7
    ##      id  year outcome treatment panelbuild_row_id panelbuild_id_time_n
    ##   <dbl> <dbl>   <dbl>     <dbl>             <int>                <int>
    ## 1     1  2020      10         0                 1                    1
    ## 2     1  2021      12         1                 2                    2
    ## 3     1  2021      13         1                 3                    2
    ## 4     2  2020      20         0                 4                    1
    ## 5     2  2022      25         1                 5                    1
    ## 6     3  2020      30         0                 6                    1
    ## 7     3  2021      31         0                 7                    1
    ## 8     3  2022      32         1                 8                    1
    ## 9     3  2023      33         1                 9                    1
    ## # ℹ 1 more variable: panelbuild_duplicate_cell <lgl>

## Complete the panel grid

`complete_panel()` creates a full unit-time grid while preserving
observed values. It does not impute missing outcomes.

Because `complete_panel()` requires unique id-time cells, we first
create a version of the example data without duplicates.

``` r
example_panel_unique <- example_panel |>
  dplyr::distinct(id, year, .keep_all = TRUE)

complete_panel(example_panel_unique, id = id, time = year)
```

    ## # A tibble: 12 × 7
    ##       id  year outcome treatment panelbuild_original_row panelbuild_completed_…¹
    ##    <dbl> <dbl>   <dbl>     <dbl> <lgl>                   <lgl>                  
    ##  1     1  2020      10         0 TRUE                    FALSE                  
    ##  2     1  2021      12         1 TRUE                    FALSE                  
    ##  3     1  2022      NA        NA FALSE                   TRUE                   
    ##  4     1  2023      NA        NA FALSE                   TRUE                   
    ##  5     2  2020      20         0 TRUE                    FALSE                  
    ##  6     2  2021      NA        NA FALSE                   TRUE                   
    ##  7     2  2022      25         1 TRUE                    FALSE                  
    ##  8     2  2023      NA        NA FALSE                   TRUE                   
    ##  9     3  2020      30         0 TRUE                    FALSE                  
    ## 10     3  2021      31         0 TRUE                    FALSE                  
    ## 11     3  2022      32         1 TRUE                    FALSE                  
    ## 12     3  2023      33         1 TRUE                    FALSE                  
    ## # ℹ abbreviated name: ¹​panelbuild_completed_cell
    ## # ℹ 1 more variable: panelbuild_audit_action <chr>

## Main functions

- `audit_panel()` gives a full panel diagnostic summary.
- `duplicate_summary()` finds duplicate unit-time observations.
- `gap_summary()` summarizes missing time periods by unit.
- `flag_panel_issues()` flags row-level panel problems.
- `complete_panel()` creates a complete panel grid without imputing
  observed variables.

## Package goal

The goal of `panelbuild` is to provide a transparent and reproducible
workflow for panel-data quality assurance before statistical modeling.
