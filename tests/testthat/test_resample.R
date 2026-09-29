set.seed(123)
normal_example <- example_powerscale_model("univariate_normal")

test_that("powerscale with resample actually resamples", {
  ps <- powerscale(
    x = normal_example$draws,
    component = "prior",
    alpha = 0.5,
    resample = TRUE
  )

  expect_equal(
    get_powerscaling_details(ps)$resampled,
    TRUE
  )

  expect_equal(
    stats::weights(ps),
    NULL
  )
})


test_that("powerscale_sequence with resample actually resamples", {
  pss <- suppressWarnings(powerscale_sequence(
    x = normal_example$draws,
    variables = c("mu"),
    resample = TRUE,
  ))
  expect_equal(
    pss$resampled,
    TRUE
  )
  expect_equal(
    stats::weights(pss$prior_scaled$draws_sequence[[1]]),
    NULL
  )
})
