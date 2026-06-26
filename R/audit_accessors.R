#' Extract missing unit-time cells from a panel audit
#'
#' `missing_cells()` extracts the missing unit-time combinations stored in an
#' audit object created by [audit_panel()].
#'
#' @details
#' Missing cells are unit-time combinations that are implied by the full
#' unit-by-time grid but are not present in the original data.
#'
#' This function does not re-audit the original dataset. It simply extracts the
#' missing-cell table already stored in the audit object.
#'
#' @param x An object created by [audit_panel()].
#'
#' @return
#' A tibble containing missing unit-time combinations.
#'
#' @seealso
#' [audit_panel()], [panel_gaps()], [gap_summary()], [complete_panel()]
#'
#' @examples
#' audit <- audit_panel(example_panel, id = id, time = year)
#' missing_cells(audit)
#'
#' @export

missing_cells <- function(x) {
  if (!inherits(x, "unfiy_panel_audit")) {
    stop("`x` must be an object created by `audit_panel()`.", call. = FALSE)
  }

  x$missing_data
}


#' Extract duplicate unit-time cells from a panel audit
#'
#' `duplicate_cells()` extracts duplicate unit-time combinations stored in an
#' audit object created by [audit_panel()].
#'
#' @details
#' Duplicate cells are unit-time combinations that appear more than once in the
#' original data. The returned table includes a count column `n` showing how
#' many rows are present for each duplicated unit-time cell.
#'
#' This function does not re-audit the original dataset. It simply extracts the
#' duplicate-cell table already stored in the audit object.
#'
#' @param x An object created by [audit_panel()].
#'
#' @return
#' A tibble containing duplicate unit-time combinations and a count column `n`.
#'
#' @seealso
#' [audit_panel()], [panel_duplicates()], [duplicate_summary()],
#' [flag_panel_issues()]
#'
#' @examples
#' audit <- audit_panel(example_panel, id = id, time = year)
#' duplicate_cells(audit)
#'
#' @export



duplicate_cells <- function(x) {
  if (!inherits(x, "unfiy_panel_audit")) {
    stop("`x` must be an object created by `audit_panel()`.", call. = FALSE)
  }

  x$duplicate_data
}
