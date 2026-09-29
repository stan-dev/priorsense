library(nimble)
library(priorsense)

model <- example_powerscale_model(language = "nimble")

inits <- list(
    mu = 0,
    sigma = 1
)

model <- nimbleModel(
    model$model_code, # the nimble model code
    data = model$data,
    inits = inits,
    constants = list(N = model$data$N)
)

cmodel <- compileNimble(model)

mcmc <- buildMCMC(
    cmodel,
    monitors = c(
        "mu",
        "sigma",
        "lprior",
        "lprior_mu",
        "lprior_sigma",
        "log_lik"
    )
)

cmcmc <- compileNimble(mcmc, project = cmodel)

fit <- runMCMC(
    cmcmc,
    niter = 20000,
    nburnin = 5000,
    nchains = 4,
    thin = 5,
    setSeed = c(123, 456, 789, 101112),
    samplesAsCodaMCMC = FALSE
)

draws <- posterior::as_draws(fit)

saveRDS(draws, "inst/extdata/univariate_normal_nimble.RDS")
