library(priorsense)
library(brms)
library(posterior)

normal_model <- example_powerscale_model(model = "univariate_normal")

priors <- c(
    prior(coef = "Intercept", normal(0, 1), tag = "intercept"),
    prior(class = "sigma", normal(0, 2.5), tag = "sigma")
)

fit <- brm(
    bf(y ~ 1, center = FALSE),
    data = data.frame(y = normal_model$data$y),
    prior = priors,
    seed = 123,
    backend = "cmdstanr"
)

ll <- log_lik_draws(fit)

draws <- as_draws(fit) |>
    bind_draws(ll)


saveRDS(draws, "inst/extdata/univariate_normal_brms.RDS")
