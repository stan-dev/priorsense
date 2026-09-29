skip_on_cran()

library(brms)

#' @srrstats {G5.0} eight schools is a well-established example for
#'   Bayesian models
set.seed(123)
eight_schools_example <- example_powerscale_model("eight_schools")

dat <- data.frame(
    school = 1:eight_schools_example$data$J,
    y = eight_schools_example$data$y,
    sigma = eight_schools_example$data$sigma
)

bfit <- brm(
    y | se(sigma, sigma = TRUE) ~ 1 + (1 | school),
    data = dat,
    family = gaussian(),
    prior = c(
        prior(normal(0, 5), class = "Intercept"),
        prior(normal(0, 5), class = "sd")
    ),
    chains = 1,
    iter = 200,
    seed = 123,
    backend = "cmdstanr"
)

test_that("priorsense_data is created", {
    expect_s3_class(
        create_priorsense_data(
            bfit
        ),
        "priorsense_data"
    )
})

test_that("powerscale returns powerscaled_draws", {
    expect_s3_class(
        powerscale(
            x = bfit,
            component = "prior",
            alpha = 0.8
        ),
        "powerscaled_draws"
    )
    expect_s3_class(
        powerscale(
            x = bfit,
            component = "likelihood",
            alpha = 0.8
        ),
        "powerscaled_draws"
    )
})

test_that("powerscale_seqence returns powerscaled_sequence", {
    expect_s3_class(
        powerscale_sequence(
            x = bfit
        ),
        "powerscaled_sequence"
    )
})

test_that("powerscale_sensitivity returns powerscaled_sensitivity_summary", {
    expect_s3_class(
        powerscale_sensitivity(
            x = bfit
        ),
        "powerscaled_sensitivity_summary"
    )
})
