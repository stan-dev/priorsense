testthat::test_that(
  "predictions_as_draws handles multivariate brms models",
  {
    testthat::skip_if_not_installed("brms")

    data("BTdata", package = "MCMCglmm")
    head(BTdata)

    suppressWarnings({
      bform1 <- brms::bf(mvbind(tarsus, back) ~ sex +  hatchdate + (1|p|fosternest) + (1|q|dam)) + brms::set_rescor(TRUE)
      fit1 <- brms::brm(bform1, data = BTdata, chains = 2, cores = 2, iter = 10)
    })

    result <- priorsense::predictions_as_draws(fit1,  brms::posterior_epred)

    testthat::expect_s3_class(result, "draws")
  }
)
