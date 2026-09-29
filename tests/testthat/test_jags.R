skip_on_cran()

#' @srrstats {G5.0} eight schools is a well-established example for
#'   Bayesian models
set.seed(123)

model <- example_powerscale_model("eight_schools", language = "jags")

model_con <- textConnection(model$model_code)
data <- model$data

# monitor parameters of interest along with log-likelihood and log-prior
variables <- c("mu", "tau", "log_lik", "lprior", "lprior_mu", "lprior_tau")

jfit <- R2jags::jags(
  data = data,
  model.file = model_con,
  parameters.to.save = variables,
  n.chains = 4,
  DIC = FALSE,
  quiet = TRUE,
  progress.bar = "none"
)


test_that("priorsense_data is created", {
  expect_s3_class(
    create_priorsense_data(
      jfit
    ),
    "priorsense_data"
  )
})

test_that("powerscale returns powerscaled_draws", {
  expect_s3_class(
    powerscale(
      x = jfit,
      component = "prior",
      alpha = 0.8
    ),
    "powerscaled_draws"
  )
  expect_s3_class(
    powerscale(
      x = jfit,
      component = "likelihood",
      alpha = 0.8
    ),
    "powerscaled_draws"
  )
})

test_that("powerscale_seqence returns powerscaled_sequence", {
  expect_s3_class(
    powerscale_sequence(
      x = jfit
    ),
    "powerscaled_sequence"
  )
})

test_that("powerscale_sensitivity returns powerscaled_sensitivity_summary", {
  expect_s3_class(
    powerscale_sensitivity(
      x = jfit
    ),
    "powerscaled_sensitivity_summary"
  )
})
