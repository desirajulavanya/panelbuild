#' Identify duplicate unit-time cells
#'
#' `panel_duplicates()` returns unit-time combinations that appear more than
#' once in a panel dataset.
#'
#' @details
#' Duplicate unit-time cells occur when the same panel unit appears more than
#' once in the same time period. These duplicates can create problems for panel
#' completion, fixed effects models, difference-in-differences designs, and
#' other longitudinal-data workflows.
#'
#' The function does not modify, drop, aggregate, or impute the data.
#'
#' @param data A data frame or tibble.
#' @param id Unquoted column name identifying the panel unit.
#' @param time Unquoted column name identifying the time period.
#'
#' @return
#' A tibble containing duplicate unit-time combinations and a count column `n`.
#'
#' @seealso
#' [audit_panel()], [duplicate_summary()], [duplicate_cells()],
#' [flag_panel_issues()]
#'
#' @examples
#' panel_duplicates(example_panel, id = id, time = year)
#'
#' @export
panel_duplicates <- function(data, id, time) {
  if (!inherits(data, "data.frame")) {
    stop("`data` must be a data frame or tibble.", call. = FALSE)
  }

  id_quo <- rlang::enquo(id)
  time_quo <- rlang::enquo(time)

  audit <- audit_panel(data, id = !!id_quo, time = !!time_quo)

  duplicate_cells(audit)
}

#' Summarize duplicate unit-time cells by panel unit
#'
#' `duplicate_summary()` reports how many duplicate unit-time cells each panel
#' unit has.
#'
#' @details
#' This function summarizes duplicate cells at the panel-unit level. It is useful
#' when users want to identify which units contribute most to duplicate
#' unit-time observations.
#'
#' The output reports both the number of duplicated cells and the number of
#' extra rows implied by those duplicates. For example, if one unit-time cell
#' appears three times, it counts as one duplicate cell and two extra rows.
#'
#' The function does not modify, drop, aggregate, or impute the data.
#'
#' @param data A data frame or tibble.
#' @param id Unquoted column name identifying the panel unit.
#' @param time Unquoted column name identifying the time period.
#'
#' @return
#' A tibble with one row per panel unit that has duplicate cells. The output
#' includes:
#'
#' \describe{
#'   \item{`unfiy_duplicate_cells`}{Number of duplicated unit-time cells for the unit.}
#'   \item{`unfiy_duplicate_extra_rows`}{Number of extra rows caused by duplicates.}
#' }
#'
#' If no duplicates are present, the function returns all units with zero
#' duplicate cells and zero extra rows.
#'
#' @seealso
#' [audit_panel()], [panel_duplicates()], [duplicate_cells()],
#' [flag_panel_issues()]
#'
#' @examples
#' duplicate_summary(example_panel, id = id, time = year)
#'
#' @export#' Summarize duplicate unit-time cells by panel unit
#'
#' `duplicate_summary()` reports how many duplicate unit-time cells each panel
#' unit has.
#'
#' @details
#' This function summarizes duplicate cells at the panel-unit level. It is useful
#' when users want to identify which units contribute most to duplicate
#' unit-time observations.
#'
#' The output reports both the number of duplicated cells and the number of
#' extra rows implied by those duplicates. For example, if one unit-time cell
#' appears three times, it counts as one duplicate cell and two extra rows.
#'
#' The function does not modify, drop, aggregate, or impute the data.
#'
#' @param data A data frame or tibble.
#' @param id Unquoted column name identifying the panel unit.
#' @param time Unquoted column name identifying the time period.
#'
#' @return
#' A tibble with one row per panel unit that has duplicate cells. The output
#' includes:
#'
#' \describe{
#'   \item{`unfiy_duplicate_cells`}{Number of duplicated unit-time cells for the unit.}
#'   \item{`unfiy_duplicate_extra_rows`}{Number of extra rows caused by duplicates.}
#' }
#'
#' If no duplicates are present, the function returns all units with zero
#' duplicate cells and zero extra rows.
#'
#' @seealso
#' [audit_panel()], [panel_duplicates()], [duplicate_cells()],
#' [flag_panel_issues()]
#'
#' @examples
#' duplicate_summary(example_panel, id = id, time = year)
#'
#' @export


duplicate_summary <- function(data, id, time) {
  if (!inherits(data, "data.frame")) {
    stop("`data` must be a data frame or tibble.", call. = FALSE)
  }

  id_quo <- rlang::enquo(id)
  time_quo <- rlang::enquo(time)

  id_name <- rlang::as_name(id_quo)

  duplicates <- panel_duplicates(data, id = !!id_quo, time = !!time_quo)

  if (nrow(duplicates) == 0) {
    return(
      data |>
        dplyr::distinct(!!id_quo) |>
        dplyr::mutate(
          unfiy_duplicate_cells = 0L,
          unfiy_duplicate_extra_rows = 0L
        ) |>
        dplyr::arrange(!!id_quo)
    )
  }

  duplicates |>
    dplyr::mutate(unfiy_extra_rows = .data$n - 1L) |>
    dplyr::group_by(!!id_quo) |>
    dplyr::summarise(
      unfiy_duplicate_cells = dplyr::n(),
      unfiy_duplicate_extra_rows = sum(.data$unfiy_extra_rows),
      .groups = "drop"
    ) |>
    dplyr::arrange(
      dplyr::desc(.data$unfiy_duplicate_cells),
      !!id_quo
    )
}
