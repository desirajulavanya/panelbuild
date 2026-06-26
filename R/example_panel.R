#' Example Panel Dataset
#'
#' A small example panel dataset for demonstrating panel-data auditing.
#'
#' The dataset intentionally includes one duplicate unit-time observation
#' and missing unit-time cells so that users can test `unifyr` diagnostics.
#'
#' @format A data frame with 9 rows and 4 variables:
#' \describe{
#'   \item{id}{Panel unit identifier.}
#'   \item{year}{Time period.}
#'   \item{outcome}{Example outcome variable.}
#'   \item{treatment}{Example treatment indicator.}
#' }
#'
#' @examples
#' data(example_panel)
#' audit_panel(example_panel, id = id, time = year)
"example_panel"

example_panel <- data.frame(
  id = c(1, 1, 1, 2, 2, 3, 3, 3, 3),
  year = c(2020, 2021, 2021, 2020, 2022, 2020, 2021, 2022, 2023),
  outcome = c(10, 12, 13, 20, 25, 30, 31, 32, 33),
  treatment = c(0, 1, 1, 0, 1, 0, 0, 1, 1)
)

usethis::use_data(example_panel, overwrite = TRUE)
