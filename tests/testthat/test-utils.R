test_that("build_adsl_chars_table works", {
  lyt <- build_adsl_chars_table(
    split_cols_by = "ARM",
    summ_vars = c("AGE", "RACE")
  )

  exp_lyt <- basic_table(
    title = "x.x: Study Subject Data",
    subtitles = c(
      "x.x.x: Demographic Characteristics",
      "Table x.x.x.x: Demographic Characteristics - Full Analysis Set"
    ),
    prov_footer = "Source: ADSL DDMMYYYY hh:mm; Listing x.xx; SDTM package: DDMMYYYY",
    show_colcounts = TRUE
  ) |>
    split_cols_by("ARM", split_fun = drop_split_levels) |>
    add_overall_col("All Patients") |>
    summarize_vars(
      c("AGE", "RACE"),
      .stats = c(
        "n",
        "mean_sd",
        "se",
        "median",
        "range",
        "quantiles",
        "count_fraction"
      ),
      .labels = c(
        n = "n",
        mean_sd = "Mean, SD",
        se = "Standard Error",
        median = "Median",
        range = "Min-Max",
        quantiles = c("IQR")
      )
    ) |>
    append_topleft(c("", "Characteristic"))

  expect_identical(lyt, exp_lyt)
})

test_that("build_generic_occurrence_table works", {
  adsl <- random.cdisc.data::cadsl
  adae <- random.cdisc.data::cadae
  adae <- filter(adae, SAFFL == "Y")

  lyt <- build_generic_occurrence_table(
    occ_df = adae,
    filter_cond = NULL,
    trt_var = "ARM",
    dataset = "cadae",
    class_var = "AESOC",
    term_var = "AEDECOD"
  )

  exp_lyt <- basic_table() |>
    split_cols_by(var = "ARM", split_fun = drop_split_levels) |>
    add_colcounts() |>
    add_overall_col(label = "All Patients") |>
    summarize_num_patients(
      var = "USUBJID",
      .stats = c("unique", "nonunique"),
      .labels = c(
        unique = "Total number of patients with at least one event",
        nonunique = "Total number of events"
      )
    ) |>
    split_rows_by(
      "AESOC",
      label_pos = "topleft",
      split_label = obj_label(adae[["AESOC"]]),
      split_fun = drop_split_levels
    ) |>
    summarize_num_patients(
      var = "USUBJID",
      .stats = "unique",
      .labels = c(unique = NULL)
    ) |>
    count_occurrences(vars = "AEDECOD") |>
    append_topleft(paste(" ", obj_label(adae[["AEDECOD"]])))

  expect_identical(lyt$lyt, exp_lyt)

  lyt_ <- build_generic_occurrence_table(
    occ_df = adae,
    filter_cond = filters_to_cond(list(SEX = c("F"))),
    trt_var = "ARM",
    dataset = "cadae",
    class_var = "AESOC",
    term_var = "AEDECOD"
  )

  adae_ <- filter(adae, SEX == "F")

  exp_lyt_ <- basic_table() |>
    split_cols_by(var = "ARM", split_fun = drop_split_levels) |>
    add_colcounts() |>
    add_overall_col(label = "All Patients") |>
    summarize_num_patients(
      var = "USUBJID",
      .stats = c("unique", "nonunique"),
      .labels = c(
        unique = "Total number of patients with at least one event",
        nonunique = "Total number of events"
      )
    ) |>
    split_rows_by(
      "AESOC",
      label_pos = "topleft",
      split_label = obj_label(adae_[["AESOC"]]),
      split_fun = drop_split_levels
    ) |>
    summarize_num_patients(
      var = "USUBJID",
      .stats = "unique",
      .labels = c(unique = NULL)
    ) |>
    count_occurrences(vars = "AEDECOD") |>
    append_topleft(paste(" ", obj_label(adae_[["AEDECOD"]])))

  expect_identical(lyt_$lyt, exp_lyt_)
  expect_equal(nrow(lyt_$df_out), nrow(adae_))
})

test_that("build_generic_bds_table works", {
  adsl <- random.cdisc.data::cadsl
  advs <- random.cdisc.data::cadvs

  lyt <- build_generic_bds_table(
    bds_df = advs,
    filter_cond = NULL,
    param = "Diastolic Blood Pressure",
    trt_var = "ARM",
    visit = "AVISIT",
    disp_vars = c("AVAL", "CHG")
  )

  df <- advs |>
    filter(PARAM %in% "Diastolic Blood Pressure")

  var_labs <- map_chr(c("AVAL", "CHG"), \(x) obj_label(df[[x]]))

  exp_lyt <- basic_table(
    show_colcounts = TRUE,
    title = str_glue("Summary of Diastolic Blood Pressure w.r.t {paste(var_labs, collapse = ', ')}")
  ) |>
    split_cols_by("ARM", split_fun = drop_split_levels) |>
    split_rows_by(
      "AVISIT",
      split_fun = drop_split_levels,
      label_pos = "topleft",
      split_label = obj_label(df[["AVISIT"]])
    ) |>
    split_cols_by_multivar(
      vars = c("AVAL", "CHG"),
      varlabels = var_labs
    ) |>
    summarize_colvars(.labels = c(range = "Min - Max")) |>
    append_topleft(paste(" ", "Summary Statistic"))

  expect_identical(lyt$lyt, exp_lyt)
})
