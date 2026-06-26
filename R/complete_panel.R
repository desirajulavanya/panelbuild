#' Complete a panel dataset with an audit trail
#'
#' `complete_panel()` expands a panel dataset so that every observed panel unit
#' appears in every observed time period. Newly created unit-time cells are
#' flagged with audit columns, and substantive variables are left missing.
#'
#' @details
#' The function first audits the panel using [audit_panel()]. If duplicate
#' unit-time cells are present, the function stops with an error. This is
#' intentional: completing a panel with duplicate unit-time observations can
#' produce ambiguous results.
#'
#' `complete_panel()` does not impute outcomes, covariates, treatment variables,
#' or any other substantive variables. It only creates the missing unit-time
#' rows implied by the full unit-by-time grid. Newly created rows are flagged
#' using audit columns.
#'
#' @param data A data frame or tibble.
#' @param id Unquoted column name identifying the panel unit, such as a person,
#'   firm, district, county, or country.
#' @param time Unquoted column name identifying the time period, such as a year,
#'   month, quarter, or date.
#'
#' @return
#' A tibble containing the completed panel grid. The returned data include the
#' original columns plus the following audit columns:
#'
#' \describe{
#'   \item{`unfiy_original_row`}{Logical indicator for rows present in the
#'   original data.}
#'   \item{`unfiy_completed_cell`}{Logical indicator for rows created by
#'   `complete_panel()`.}
#'   \item{`unfiy_audit_action`}{Character label describing whether a row was
#'   original or added during panel completion.}
#' }
#'
#' The returned tibble also includes attributes documenting the panel identifier,
#' time variable, number of completed cells, and audit note.
#'
#' @seealso
#' [audit_panel()], [missing_cells()], [gap_summary()], [duplicate_summary()]
#'
#' @examples
#' panel_unique <- example_panel |>
#'   dplyr::distinct(id, year, .keep_all = TRUE)
#'
#' complete_panel(panel_unique, id = id, time = year)
#'
#' @export

complete_panel <- function(data, id, time) {
  if (!inherits(data, "data.frame")) {
    stop("`data` must be a data frame or tibble.", call. = FALSE)
  }

  id_quo <- rlang::enquo(id)
  time_quo <- rlang::enquo(time)

  id_name <- rlang::as_name(id_quo)
  time_name <- rlang::as_name(time_quo)

  if (!id_name %in% names(data)) {
    stop("`id` column not found in `data`.", call. = FALSE)
  }

  if (!time_name %in% names(data)) {
    stop("`time` column not found in `data`.", call. = FALSE)
  }

  audit <- audit_panel(data, id = !!id_quo, time = !!time_quo)

  if (audit$duplicate_cells > 0) {
    stop(
      paste0(
        "`complete_panel()` cannot complete a panel with duplicate id-time cells.\n",
        "Resolve duplicates first. Use `duplicate_cells(audit_panel(data, id, time))` ",
        "to inspect them."
      ),
      call. = FALSE
    )
  }

  original <- data |>
    tibble::as_tibble() |>
    dplyr::mutate(
      unfiy_original_row = TRUE
    )

  completed <- original |>
    tidyr::complete(
      !!id_quo,
      !!time_quo
    ) |>
    dplyr::mutate(
      unfiy_original_row = dplyr::coalesce(.data$unfiy_original_row, FALSE),
      unfiy_completed_cell = !.data$unfiy_original_row,
      unfiy_audit_action = dplyr::if_else(
        .data$unfiy_completed_cell,
        "added_missing_id_time_cell_no_imputation",
        "original_observation"
      )
    )

  attr(completed, "unfiy_id") <- id_name
  attr(completed, "unfiy_time") <- time_name
  attr(completed, "unfiy_completed_cells") <- sum(completed$unfiy_completed_cell)
  attr(completed, "unfiy_audit_note") <- paste0(
    "`complete_panel()` completed the id-time grid using id = ",
    id_name,
    " and time = ",
    time_name,
    ". Newly created rows are flagged with `unfiy_completed_cell = TRUE`. ",
    "No substantive variables were imputed."
  )

  completed
}
