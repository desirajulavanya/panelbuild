
#' Identify missing unit-time cells
#'
#' `panel_gaps()` returns the missing unit-time combinations implied by the
#' full panel grid.
#'
#' @details
#' A missing unit-time cell is a combination of an observed panel unit and an
#' observed time period that does not appear in the data. For example, if unit
#' `A` appears in 2020 and 2022, and 2021 is an observed time period elsewhere
#' in the dataset, then `A`-2021 is treated as a missing unit-time cell.
#'
#' This function is a data-frame interface to the missing-cell information
#' produced by [audit_panel()]. It does not modify, complete, or impute the
#' input data.
#'
#' @param data A data frame or tibble.
#' @param id Unquoted column name identifying the panel unit.
#' @param time Unquoted column name identifying the time period.
#'
#' @return
#' A tibble containing missing unit-time combinations.
#'
#' @seealso
#' [audit_panel()], [missing_cells()], [gap_summary()], [complete_panel()]
#'
#' @examples
#' panel_gaps(example_panel, id = id, time = year)
#'
#' @export



panel_gaps <- function(data, id, time) {
  if (!inherits(data, "data.frame")) {
    stop("`data` must be a data frame or tibble.", call. = FALSE)
  }

  id_quo <- rlang::enquo(id)
  time_quo <- rlang::enquo(time)

  audit <- audit_panel(data, id = !!id_quo, time = !!time_quo)

  missing_cells(audit)
}


#' Summarize missing panel periods by unit
#'
#' `gap_summary()` reports how many time periods are missing for each panel
#' unit.
#'
#' @details
#' This function summarizes the missing unit-time cells returned by
#' [panel_gaps()] at the panel-unit level. It is useful for identifying which
#' units contribute most to panel imbalance.
#'
#' The function does not modify, complete, or impute the input data.
#'
#' @param data A data frame or tibble.
#' @param id Unquoted column name identifying the panel unit.
#' @param time Unquoted column name identifying the time period.
#'
#' @return
#' A tibble with one row per panel unit and a column
#' `unfiy_missing_periods` giving the number of missing time periods for that
#' unit. If no gaps are present, all units are returned with zero missing
#' periods.
#'
#' @seealso
#' [audit_panel()], [panel_gaps()], [missing_cells()], [complete_panel()]
#'
#' @examples
#' gap_summary(example_panel, id = id, time = year)
#'
#' @export



gap_summary <- function(data, id, time) {
  if (!inherits(data, "data.frame")) {
    stop("`data` must be a data frame or tibble.", call. = FALSE)
  }

  id_quo <- rlang::enquo(id)

  gaps <- panel_gaps(data, id = !!id_quo, time = {{ time }})

  if (nrow(gaps) == 0) {
    id_name <- rlang::as_name(id_quo)

    ids <- data |>
      dplyr::distinct(!!id_quo)

    return(
      ids |>
        dplyr::mutate(unfiy_missing_periods = 0L) |>
        dplyr::arrange(!!id_quo)
    )
  }

  gaps |>
    dplyr::count(!!id_quo, name = "unfiy_missing_periods") |>
    dplyr::arrange(dplyr::desc(.data$unfiy_missing_periods), !!id_quo)
}
