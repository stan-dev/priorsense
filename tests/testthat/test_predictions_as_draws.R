testthat::test_that(
  "predictions_as_draws_multivariate handles multivariate brms models",
  {
    testthat::skip_if_not_installed("brms")

    suppressWarnings({
      fit <- brms::brm(
        brms::bf(mpg ~ wt) + brms::bf(disp ~ wt) + brms::set_rescor(TRUE),
        data = mtcars,
        chains = 1,
        iter = 10,
        refresh = 0)
    })

    result <- priorsense::predictions_as_draws(fit,  brms::posterior_epred)

    testthat::expect_s3_class(result, "draws")
  }
)
