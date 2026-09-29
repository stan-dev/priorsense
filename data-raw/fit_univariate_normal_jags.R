library(R2jags)
library(priorsense)

set.seed(123)

model <- example_powerscale_model("univariate_normal", language = "jags")

model_con <- textConnection(model$model_code)
data <- model$data

# monitor parameters of interest along with log-likelihood and log-prior
variables <- c("mu", "sigma", "log_lik", "lprior", "lprior_mu", "lprior_sigma")

fit <- R2jags::jags(
    data = data,
    model.file = model_con,
    parameters.to.save = variables,
    n.chains = 4,
    DIC = FALSE,
    quiet = TRUE,
    progress.bar = "none",
    jags.seed = 123
)

draws <- posterior::as_draws(fit$BUGSoutput$sims.array)

saveRDS(draws, "inst/extdata/univariate_normal_jags.RDS")
