library(priorsense)
library(posterior)

model <- example_powerscale_model("univariate_normal")

fit <- rstan::stan(
    model_code = model$model_code,
    data = model$data,
    refresh = FALSE,
    seed = 123
)

draws <- posterior::as_draws(fit)

saveRDS(draws, "inst/extdata/univariate_normal_rstan.RDS")
