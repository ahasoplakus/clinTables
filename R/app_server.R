#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  Sys.sleep(2)
  load_data <- mod_data_read_server("data_read_1")

  observe({
    req(load_data$df_read())
    domain <- c("cadsl", "cadae", "cadmh", "cadcm", "cadvs", "cadlb", "cadeg")
    walk(seq_along(domain) + 2, function(x) {
      toggleState(
        selector = str_glue("#tab-Tab{x}"),
        condition = all(c(domain[x - 2], domain[1]) %in% names(load_data$df_read()))
      )
    })
    updateNavbarTabs(session, inputId = "navmenu", "Tab3")
  }) |>
    bindEvent(load_data$df_read())

  mod_data_preview_server(
    "data_preview_1",
    load_data$prev_data
  )

  study_filters <-
    mod_global_filters_server("global_filters_1",
      dataset = "cadsl",
      load_data = load_data$df_read,
      filter_list = load_data$study_filters
    )

  processed_adsl <-
    mod_process_adsl_server(
      "process_adsl_1",
      dataset = "cadsl",
      df_out = load_data$df_read,
      global_filters = study_filters$filters,
      apply = study_filters$apply
    )

  mod_adsl_display_server("adsl_display_1",
    adsl = processed_adsl
  )

  mod_adae_global_server(
    "adae_global_1",
    dataset = "cadae",
    df_out = load_data$df_read,
    adsl = processed_adsl,
    filters = reactive(load_data$adae_filters)
  )

  mod_adxx_bodsys_server(
    "admh_bodsys_1",
    dataset = "cadmh",
    df_out = load_data$df_read,
    adsl = processed_adsl,
    filters = load_data$admh_filters
  )

  mod_adxx_bodsys_server(
    "adcm_bodsys_1",
    dataset = "cadcm",
    df_out = load_data$df_read,
    adsl = processed_adsl,
    filters = load_data$adcm_filters
  )

  mod_adxx_param_server(
    "advs_param_1",
    dataset = "cadvs",
    df_out = load_data$df_read,
    adsl = processed_adsl,
    filters = load_data$advs_filters
  )

  mod_adxx_param_server(
    "adlb_param_1",
    dataset = "cadlb",
    df_out = load_data$df_read,
    adsl = processed_adsl,
    filters = load_data$adlb_filters
  )

  mod_adxx_param_server(
    "adeg_param_1",
    dataset = "cadeg",
    df_out = load_data$df_read,
    adsl = processed_adsl,
    filters = load_data$adeg_filters
  )
}
