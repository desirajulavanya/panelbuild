#' Flag row-level panel data issues
#'
#' `flag_panel_issues()` adds row-level audit flags to a panel dataset. It
#' identifies duplicate unit-time observations while preserving the original
#' data structure.
#'
#' @details
#' This function is useful when users want to inspect problematic rows directly
#' rather than only receiving a summary table. It adds diagnostic columns that
#' indicate how many times each unit-time cell appears and whether the row is
#' part of a duplicate cell.
#'
#' `flag_panel_issues()` does not add rows, remove rows, complete the panel, or
#' impute missing values.
#'
#' @param data A data frame or tibble.
#' @param id Unquoted column name identifying the panel unit, such as a person,
#'   firm, district, county, or country.
#' @param time Unquoted column name identifying the time period, such as a year,
#'   month, quarter, or date.
#'
#' @return
#' A tibble containing the original data plus row-level audit columns:
#'
#' \describe{
#'   \item{`unfiy_row_id`}{Integer row identifier based on the original row order.}
#'   \item{`unfiy_id_time_n`}{Number of rows with the same unit-time combination.}
#'   \item{`unfiy_duplicate_cell`}{Logical indicator for rows that belong to a
#'   duplicate unit-time cell.}
#' }
#'
#' The returned tibble also includes attributes documenting the panel identifier,
#' time variable, and audit note.
#'
#' @seealso
#' [audit_panel()], [duplicate_summary()], [duplicate_cells()],
#' [complete_panel()]
#'
#' @examples
#' flag_panel_issues(example_panel, id = id, time = year)
#'
#' @export

flag_panel_issues <- function(data, id, time) {
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

  flagged <- data |>
    tibble::as_tibble() |>
    dplyr::mutate(unfiy_row_id = dplyr::row_number()) |>
    dplyr::group_by(!!id_quo, !!time_quo) |>
    dplyr::mutate(
      unfiy_id_time_n = dplyr::n(),
      unfiy_duplicate_cell = .data$unfiy_id_time_n > 1
    ) |>
    dplyr::ungroup()

  attr(flagged, "unfiy_id") <- id_name
  attr(flagged, "unfiy_time") <- time_name
  attr(flagged, "unfiy_audit_note") <- paste0(
    "Rows were flagged by `flag_panel_issues()` using id = ",
    id_name,
    " and time = ",
    time_name,
    ". No rows were added, removed, completed, or imputed."
  )

  flagged
}
