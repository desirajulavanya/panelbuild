#' Summarize a panel audit
#'
#' `audit_summary()` converts an audit object created by [audit_panel()] into a
#' one-row tibble of panel diagnostics.
#'
#' @details
#' This function is useful when users want a compact, tabular summary of a panel
#' audit. The resulting tibble can be printed, saved, joined with other metadata,
#' or combined across multiple datasets.
#'
#' The summary includes the number of units, number of time periods, observed
#' rows, observed unit-time cells, expected unit-time cells, missing cells,
#' duplicate cells, and a logical indicator for whether the panel is balanced.
#'
#' @param x An object created by [audit_panel()].
#'
#' @return
#' A one-row tibble with the following columns:
#'
#' \describe{
#'   \item{`data`}{Name of the audited object.}
#'   \item{`id`}{Name of the panel unit column.}
#'   \item{`time`}{Name of the time column.}
#'   \item{`n_units`}{Number of unique panel units.}
#'   \item{`n_periods`}{Number of unique time periods.}
#'   \item{`observed_rows`}{Number of rows in the original data.}
#'   \item{`observed_id_time_cells`}{Number of unique observed unit-time cells.}
#'   \item{`expected_cells`}{Number of cells in the full unit-by-time grid.}
#'   \item{`missing_cells`}{Number of missing unit-time cells.}
#'   \item{`duplicate_cells`}{Number of duplicate unit-time cells.}
#'   \item{`balanced`}{Logical indicator for whether the panel is balanced.}
#' }
#'
#' @seealso
#' [audit_panel()], [missing_cells()], [duplicate_cells()]
#'
#' @examples
#' audit <- audit_panel(example_panel, id = id, time = year)
#' audit_summary(audit)
#'
#' @export

audit_summary <- function(x) {
  if (!inherits(x, "unfiy_panel_audit")) {
    stop("`x` must be an object created by `audit_panel()`.", call. = FALSE)
  }

  tibble::tibble(
    data = x$data_name,
    id = x$id,
    time = x$time,
    n_units = x$n_units,
    n_periods = x$n_periods,
    observed_rows = x$observed_rows,
    observed_id_time_cells = x$observed_id_time_cells,
    expected_cells = x$expected_cells,
    missing_cells = x$missing_cells,
    duplicate_cells = x$duplicate_cells,
    balanced = x$balanced
  )
}
