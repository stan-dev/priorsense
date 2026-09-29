skip_on_cran()

library(nimble)

#' @srrstats {G5.0} eight schools is a well-established example for
#'   Bayesian models
set.seed(123)

model <- example_powerscale_model("eight_schools", language = "nimble")

inits <- list(
  mu = 0,
  tau = 1
)

nmodel <- nimbleModel(
  model$model_code, # the nimble model code
  data = model$data,
  inits = inits,
  constants = list(J = model$data$J)
)

cmodel <- compileNimble(nmodel)

mcmc <- buildMCMC(
  cmodel,
  monitors = c(
    "mu",
    "sigma",
    "lprior",
    "lprior_mu",
    "lprior_tau",
    "log_lik"
  )
)

cmcmc <- compileNimble(mcmc, project = cmodel)

nfit <- runMCMC(
  cmcmc,
  niter = 1000,
  nburnin = 500,
  nchains = 4,
  thin = 5,
  setSeed = c(123, 456, 789, 101112),
  samplesAsCodaMCMC = TRUE # alternatively, coerce the output using `posterior::as_draws_df`
)

test_that("priorsense_data is created", {
  expect_s3_class(
    create_priorsense_data(
      nfit
    ),
    "priorsense_data"
  )
})

test_that("powerscale returns powerscaled_draws", {
  expect_s3_class(
    powerscale(
      x = nfit,
      component = "prior",
      alpha = 0.8
    ),
    "powerscaled_draws"
  )
  expect_s3_class(
    powerscale(
      x = nfit,
      component = "likelihood",
      alpha = 0.8
    ),
    "powerscaled_draws"
  )
})

test_that("powerscale_seqence returns powerscaled_sequence", {
  expect_s3_class(
    powerscale_sequence(
      x = nfit
    ),
    "powerscaled_sequence"
  )
})

test_that("powerscale_sensitivity returns powerscaled_sensitivity_summary", {
  expect_s3_class(
    powerscale_sensitivity(
      x = nfit
    ),
    "powerscaled_sensitivity_summary"
  )
})
