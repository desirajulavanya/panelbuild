example_panel <- data.frame(
  id = c(1, 1, 1, 2, 2, 3, 3, 3, 3),
  year = c(2020, 2021, 2021, 2020, 2022, 2020, 2021, 2022, 2023),
  outcome = c(10, 12, 13, 20, 25, 30, 31, 32, 33),
  treatment = c(0, 1, 1, 0, 1, 0, 0, 1, 1)
)

usethis::use_data(example_panel, overwrite = TRUE)
