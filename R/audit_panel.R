#' Audit a panel dataset
#'
#' `audit_panel()` checks whether a dataset has the expected structure of a
#' panel dataset. It reports the number of panel units, time periods, observed
#' rows, unique unit-time cells, expected unit-time cells, missing unit-time
#' cells, duplicate unit-time cells, and whether the panel is balanced.
#'
#' @details
#' A panel is treated as balanced when every observed panel unit appears in
#' every observed time period exactly once. Missing cells are unit-time
#' combinations that are implied by the full unit-by-time grid but are not
#' present in the data. Duplicate cells are unit-time combinations that appear
#' more than once.
#'
#' `audit_panel()` does not modify the input data. It returns an audit object
#' that can be summarized with `audit_summary()` and inspected with accessor
#' functions such as `missing_cells()` and `duplicate_cells()`.
#'
#' @param data A data frame or tibble.
#' @param id Unquoted column name identifying the panel unit, such as a person,
#'   firm, district, county, or country.
#' @param time Unquoted column name identifying the time period, such as a year,
#'   month, quarter, or date.
#'
#' @return
#' An object of class `unfiy_panel_audit`. The object is a list containing panel
#' metadata, balance information, counts of missing and duplicate unit-time
#' cells, and data frames containing the missing and duplicate cells.
#'
#' @seealso
#' [audit_summary()], [missing_cells()], [duplicate_cells()],
#' [duplicate_summary()], [gap_summary()], [complete_panel()]
#'
#' @examples
#' audit_panel(example_panel, id = id, time = year)
#'
#' @export

audit_panel <- function(data, id, time) {
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

  panel_keys <- data |>
    dplyr::select(!!id_quo, !!time_quo)

  duplicate_cells <- panel_keys |>
    dplyr::count(!!id_quo, !!time_quo, name = "n") |>
    dplyr::filter(.data$n > 1)

  unique_keys <- panel_keys |>
    dplyr::distinct()

  ids <- unique_keys |>
    dplyr::distinct(!!id_quo)

  times <- unique_keys |>
    dplyr::distinct(!!time_quo)

  expected_grid <- tidyr::expand_grid(
    ids,
    times
  )

  missing_cells <- expected_grid |>
    dplyr::anti_join(unique_keys, by = c(id_name, time_name))

  observed_rows <- nrow(data)
  observed_id_time_cells <- nrow(unique_keys)
  n_units <- nrow(ids)
  n_periods <- nrow(times)
  expected_cells <- n_units * n_periods
  n_missing_cells <- nrow(missing_cells)
  n_duplicate_cells <- nrow(duplicate_cells)

  balanced <- n_missing_cells == 0 && n_duplicate_cells == 0

  out <- list(
    data_name = deparse(substitute(data)),
    id = id_name,
    time = time_name,
    n_units = n_units,
    n_periods = n_periods,
    observed_rows = observed_rows,
    observed_id_time_cells = observed_id_time_cells,
    expected_cells = expected_cells,
    missing_cells = n_missing_cells,
    duplicate_cells = n_duplicate_cells,
    balanced = balanced,
    missing_data = missing_cells,
    duplicate_data = duplicate_cells
  )

  class(out) <- "unfiy_panel_audit"

  out
}

#' @export
print.unfiy_panel_audit <- function(x, ...) {
  cat("Panel audit\n")
  cat("\n")
  cat("Data: ", x$data_name, "\n", sep = "")
  cat("Unit variable: ", x$id, "\n", sep = "")
  cat("Time variable: ", x$time, "\n", sep = "")
  cat("\n")
  cat("Units: ", x$n_units, "\n", sep = "")
  cat("Time periods: ", x$n_periods, "\n", sep = "")
  cat("Observed rows: ", x$observed_rows, "\n", sep = "")
  cat("Observed id-time cells: ", x$observed_id_time_cells, "\n", sep = "")
  cat("Expected id-time cells: ", x$expected_cells, "\n", sep = "")
  cat("Missing id-time cells: ", x$missing_cells, "\n", sep = "")
  cat("Duplicate id-time cells: ", x$duplicate_cells, "\n", sep = "")
  cat("Balanced panel: ", ifelse(x$balanced, "Yes", "No"), "\n", sep = "")

  invisible(x)
}

