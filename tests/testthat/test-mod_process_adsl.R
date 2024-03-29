data(adsl)

test_that("mod_process_adsl_server works", {
  trigger <- reactiveVal()
  gf <- reactiveVal()
  testServer(
    mod_process_adsl_server,
    # Add here your module params
    args = list(
      id = "process_adsl_xyz",
      dataset = "adsl",
      df_out = reactive(list(adsl = adsl)),
      global_filters = gf,
      apply = trigger
    ),
    {
      ns <- session$ns
      expect_true(inherits(ns, "function"))
      expect_true(grepl(id, ns("")))
      expect_true(grepl("test", ns("test")))

      # check adsl gets filtered when app loads with default global filters
      trigger(1)
      gf(
        list(
          pop = "SAFFL",
          sex = c("F"),
          race = "ASIAN",
          ethnic = c(
            " NOT REPORTED",
            "HISPANIC OR LATINO",
            "NOT HISPANIC OR LATINO",
            "UNKNOWN"
          ),
          country = levels(adsl[["COUNTRY"]]),
          age = 69,
          siteid = unique(adsl[["SITEID"]]),
          usubjid = unique(adsl[["USUBJID"]])
        )
      )
      session$flushReact()

      expect_equal(nrow(rv$adsl_filtered), 120)
      expect_equal(unique(as.character(rv$adsl_filtered$SEX)), "F")
      expect_equal(unique(as.character(rv$adsl_filtered$RACE)), "ASIAN")

      # check adsl gets filtered when global_filters update and apply is clicked
      trigger(2)
      gf(list_assign(gf(), sex = "M"))
      session$flushReact()

      expect_equal(nrow(rv$adsl_filtered), 88)
      expect_equal(unique(as.character(rv$adsl_filtered$SEX)), "M")

      # check adsl does not update if global filters update but apply is not clicked
      gf(list_assign(gf(), age = 40))
      session$flushReact()

      expect_equal(nrow(rv$adsl_filtered), 88)
      expect_true(max(rv$adsl_filtered$AGE, na.rm = TRUE) > 40)
      expect_equal(unique(as.character(rv$adsl_filtered$SEX)), "M")

      # check adsl updates when apply is clicked with most recent global filters
      trigger(3)
      session$flushReact()

      expect_equal(nrow(rv$adsl_filtered), 65)
      expect_true(max(rv$adsl_filtered$AGE, na.rm = TRUE) <= 40)
      expect_equal(unique(as.character(rv$adsl_filtered$SEX)), "M")
    }
  )
})

test_that("module ui works", {
  ui <- mod_process_adsl_ui(id = "test")
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(mod_process_adsl_ui)
  for (i in c("id")) {
    expect_true(i %in% names(fmls))
  }
})
