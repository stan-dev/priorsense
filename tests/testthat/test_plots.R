options(priorsense.plot_help_text = FALSE)

eight_schools_example <- example_powerscale_model("eight_schools")

ps <- powerscale_sequence(eight_schools_example$draws, length = 3)

test_that("diagnostic plots give no errors", {
  expect_error(
    powerscale_plot_ecdf(
      ps,
      variable = c("mu", "tau")
    ),
    NA
  )
  expect_error(
    powerscale_plot_dens(
      x = ps,
      variable = c("mu", "tau")
    ),
    NA
  )
  expect_error(
    powerscale_plot_quantities(
      ps,
      variable = c("mu", "tau")
    ),
    NA
  )
})

test_that("plots contain expected data", {
  psq <- powerscale_plot_quantities(
    ps,
    variable = c("mu"),
    quantity = c("quantile", "mean"),
    quantity_args = list(probs = c(0.1, 0.9))
  )
  expect_equal(
    colnames(psq$data),
    c(
      "variable",
      ".powerscale_alpha",
      "pareto_k_threshold",
      "pareto_k",
      "component",
      "quantity",
      "value",
      "id",
      "pareto_k_value"
    )
  )

  expect_equal(
    unique(psq$data$quantity),
    c("q10", "q90", "mean", "cjs_dist")
  )
})

test_that("density plots accept named distributional priors", {
  priors <- c(
    mu = distributional::dist_normal(0, 5),
    tau = distributional::dist_gamma(2, 1),
    not_plotted = distributional::dist_normal(0, 1)
  )

  p <- powerscale_plot_dens(
    ps,
    variable = c("mu", "tau", "theta[1]"),
    prior = priors
  )

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))

  prior_layer <- p$layers[[1]]$data
  expect_setequal(unique(prior_layer$variable), c("mu", "tau"))
  expect_setequal(
    unique(prior_layer$component),
    c("prior", "likelihood")
  )
  expect_true(distributional::is_distribution(prior_layer$prior))
  expect_null(p$scales$get_scales("thickness"))

  expect_true(all(prior_layer$.slab_scale > 0))
  expect_true(all(prior_layer$.slab_scale <= 1))
  expect_true(all(p$data$.slab_scale > 0))
  expect_true(all(p$data$.slab_scale <= 0.9))
  expect_s3_class(p$scales$get_scales("slab_fill"), "ScaleDiscrete")
  expect_identical(
    p$layers[[1]]$mapping$slab_fill,
    "Prior distribution"
  )
})

test_that("density plots silently skip priors with no matching variables", {
  p <- powerscale_plot_dens(
    ps,
    variable = "mu",
    prior = c(tau = distributional::dist_gamma(2, 1))
  )

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_null(p$scales$get_scales("thickness"))
})


test_that("pagination of plots works as expected", {
  expect_length(
    powerscale_plot_quantities(
      ps,
      variables_per_page = 1
    ),
    18
  )

  expect_length(
    powerscale_plot_quantities(
      ps,
      variables_per_page = 2
    ),
    9
  )

  expect_length(
    powerscale_plot_quantities(
      ps,
      variables_per_page = Inf
    ),
    1
  )
})


#' @srrstats {EA6.1} vdiffr used for all types of plots
ps_normal <- powerscale_sequence(example_powerscale_model()$draws)

vdiffr::expect_doppelganger(
  "Normal model density plot",
  powerscale_plot_dens(ps_normal)
)


vdiffr::expect_doppelganger(
  "Normal model ecdf plot",
  powerscale_plot_ecdf(ps_normal)
)

vdiffr::expect_doppelganger(
  "Normal model quantities plot",
  powerscale_plot_quantities(ps_normal)
)
