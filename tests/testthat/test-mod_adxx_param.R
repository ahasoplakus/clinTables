data(adsl)
data(advs)
data(adlb)

test_that("mod_adxx_param_server works", {
  filt <- reactiveVal()
  testServer(
    mod_adxx_param_server,
    # Add here your module params
    args = list(
      id = "adxx_param_abc",
      dataset = "advs",
      df_out = reactive(
        list(
          adsl = adsl,
          advs = advs
        )
      ),
      adsl = reactive(adsl),
      filters = filt,
      pop_fil = reactive("SAFFL")
    ),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      exp_lyt <- build_generic_bds_table(
        bds_df = df_out()[["advs"]],
        filter_cond = NULL,
        param = "Diastolic Blood Pressure",
        trt_var = "ACTARM",
        visit = "AVISIT",
        disp_vars = c("AVAL", "CHG")
      )

      session$setInputs(split_col = "ACTARM")
      session$setInputs(param = "Diastolic Blood Pressure")
      session$setInputs(visit = "AVISIT")
      session$setInputs(summ_var = c("AVAL", "CHG"))
      session$setInputs(pop = NULL)
      session$setInputs(run = 1)

      expect_identical(xx_param()$lyt, exp_lyt$lyt)
      expect_equal(nrow(xx_param()$out_df), 2800)
      expect_equal(nrow(xx_param()$alt_df), 400)

      filt("AVISIT")
      session$flushReact()

      expect_equal(nrow(xx_param()$out_df), 2800)
      expect_equal(nrow(xx_param()$alt_df), 400)
    }
  )
})

test_that("mod_adxx_param_server works with different dataset", {
  filt <- reactiveVal()
  testServer(
    mod_adxx_param_server,
    # Add here your module params
    args = list(
      id = "adxx_param_abc1",
      dataset = "adlb",
      df_out = reactive(
        list(
          adsl = adsl,
          adlb = adlb
        )
      ),
      adsl = reactive(adsl),
      filters = filt,
      pop_fil = reactive("SAFFL")
    ),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      exp_lyt <- build_generic_bds_table(
        bds_df = df_out()[["adlb"]],
        filter_cond = NULL,
        param = "Alanine Aminotransferase Measurement",
        trt_var = "ACTARM",
        visit = "AVISIT",
        disp_vars = c("AVAL", "CHG")
      )

      session$setInputs(split_col = "ACTARM")
      session$setInputs(param = "Alanine Aminotransferase Measurement")
      session$setInputs(visit = "AVISIT")
      session$setInputs(summ_var = c("AVAL", "CHG"))
      session$setInputs(pop = "ANL01FL")
      session$setInputs(run = 1)

      expect_identical(xx_param()$lyt, exp_lyt$lyt)
      expect_equal(nrow(xx_param()$out_df), 2400)
      expect_equal(nrow(xx_param()$alt_df), 400)

      filt("AVISIT")
      session$flushReact()

      expect_equal(nrow(xx_param()$out_df), 2400)
      expect_equal(nrow(xx_param()$alt_df), 400)
    }
  )
})

test_that("module ui works", {
  ui <- mod_adxx_param_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_adxx_param_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
