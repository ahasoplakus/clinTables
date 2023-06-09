#' setup_filters UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_setup_filters_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      accordion(
        id = ns("acc_study_setup"),
        accordionItem(
          title = "ADSL Filters",
          selectizeInput(
            ns("adsl_var"),
            "",
            choices = NULL,
            selected = NULL,
            options = list(maxItems = 8)
          )
        ),
        accordionItem(
          title = "ADAE Filters",
          selectizeInput(
            ns("adae_var"),
            "",
            choices = NULL,
            selected = NULL,
            options = list(maxItems = 4)
          )
        ),
        accordionItem(
          title = "ADMH Filters",
          selectizeInput(
            ns("admh_var"),
            "",
            choices = NULL,
            selected = NULL,
            options = list(maxItems = 4)
          )
        ),
        accordionItem(
          title = "ADCM Filters",
          selectizeInput(
            ns("adcm_var"),
            "",
            choices = NULL,
            selected = NULL,
            options = list(maxItems = 4)
          )
        ),
        accordionItem(
          title = "ADVS Filters",
          selectizeInput(
            ns("advs_var"),
            "",
            choices = NULL,
            selected = NULL,
            options = list(maxItems = 4)
          )
        ),
        accordionItem(
          title = "ADLB Filters",
          selectizeInput(
            ns("adlb_var"),
            "",
            choices = NULL,
            selected = NULL,
            options = list(maxItems = 4)
          )
        ),
        accordionItem(
          title = "ADEG Filters",
          selectizeInput(
            ns("adeg_var"),
            "",
            choices = NULL,
            selected = NULL,
            options = list(maxItems = 4)
          )
        )
      )
    )
  )
}

#' setup_filters Server Functions
#'
#' @noRd
mod_setup_filters_server <- function(id, load_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observe({
      req(load_data()$cadsl)

      logger::log_info(
        "mod_setup_filters_server: setup adsl filters"
      )

      choices <-
        names(select(load_data()$cadsl, !ends_with("FL")))
      choice_list <-
        named_choice_list(choices, load_data()[["cadsl"]])

      selected <-
        intersect(
          c("SEX", "RACE", "ETHNIC", "COUNTRY", "AGE", "SITEID", "USUBJID"),
          choices
        )

      updateSelectizeInput(
        session,
        "adsl_var",
        "",
        choices = choice_list,
        selected = selected,
        options = list(maxItems = 8)
      )
    })

    observe({
      req(load_data()$cadsl)
      req(load_data()$cadae)

      logger::log_info(
        "mod_setup_filters_server: setup adae filters"
      )

      choices <- setdiff(
        names(select(
          load_data()$cadae,
          !ends_with("FL")
        )),
        names(load_data()$cadsl)
      )
      choice_list <-
        named_choice_list(choices, load_data()[["cadae"]])
      selected <- NULL

      updateSelectizeInput(
        session,
        "adae_var",
        "",
        choices = choice_list,
        selected = selected,
        options = list(maxItems = 4)
      )
    })

    observe({
      req(load_data()$cadsl)
      req(load_data()$cadmh)

      logger::log_info(
        "mod_setup_filters_server: setup admh filters"
      )

      choices <- setdiff(
        names(select(load_data()$cadmh, !ends_with("FL"))),
        names(load_data()$cadsl)
      )
      choice_list <-
        named_choice_list(choices, load_data()[["cadmh"]])
      selected <- NULL

      updateSelectizeInput(
        session,
        "admh_var",
        "",
        choices = choice_list,
        selected = selected,
        options = list(maxItems = 4)
      )
    })

    observe({
      req(load_data()$cadsl)
      req(load_data()$cadcm)

      logger::log_info(
        "mod_setup_filters_server: setup adcm filters"
      )

      choices <- setdiff(
        names(select(load_data()$cadcm, !ends_with("FL"))),
        names(load_data()$cadsl)
      )
      choice_list <-
        named_choice_list(choices, load_data()[["cadcm"]])
      selected <- NULL

      updateSelectizeInput(
        session,
        "adcm_var",
        "",
        choices = choice_list,
        selected = selected,
        options = list(maxItems = 4)
      )
    })

    observe({
      req(load_data()$cadsl)
      req(load_data()$cadvs)

      logger::log_info(
        "mod_setup_filters_server: setup advs filters"
      )

      choices <- setdiff(
        names(select(load_data()$cadvs, !ends_with(c("FL", "AVAL", "AVALU", "SEQ")))),
        names(load_data()$cadsl)
      )
      exclude_vars <- names(select(load_data()$cadvs, !contains("CHG")))
      choices <- intersect(exclude_vars, choices)
      choice_list <-
        named_choice_list(choices, load_data()[["cadvs"]])
      selected <- NULL

      updateSelectizeInput(
        session,
        "advs_var",
        "",
        choices = choice_list,
        selected = selected,
        options = list(maxItems = 4)
      )
    })

    observe({
      req(load_data()$cadsl)
      req(load_data()$cadlb)

      logger::log_info(
        "mod_setup_filters_server: setup adlb filters"
      )

      choices <- setdiff(
        names(select(load_data()$cadlb, !ends_with(c("FL", "AVAL", "AVALU", "SEQ")))),
        names(load_data()$cadsl)
      )
      exclude_vars <- names(select(load_data()$cadlb, !contains("CHG")))
      choices <- intersect(choices, exclude_vars)
      choice_list <-
        named_choice_list(choices, load_data()[["cadlb"]])
      selected <- NULL

      updateSelectizeInput(
        session,
        "adlb_var",
        "",
        choices = choice_list,
        selected = selected,
        options = list(maxItems = 4)
      )
    })

    observe({
      req(load_data()$cadsl)
      req(load_data()$cadeg)

      logger::log_info(
        "mod_setup_filters_server: setup adeg filters"
      )

      choices <- setdiff(
        names(select(load_data()$cadeg, !ends_with(c("FL", "AVAL", "AVALU", "SEQ")))),
        names(load_data()$cadsl)
      )
      exclude_vars <- names(select(load_data()$cadeg, !contains("CHG")))
      choices <- intersect(choices, exclude_vars)
      choice_list <-
        named_choice_list(choices, load_data()[["cadeg"]])
      selected <- NULL

      updateSelectizeInput(
        session,
        "adeg_var",
        "",
        choices = choice_list,
        selected = selected,
        options = list(maxItems = 4)
      )
    })

    return(list(
      adsl_filt = reactive(input$adsl_var),
      adae_filt = reactive(input$adae_var),
      admh_filt = reactive(input$admh_var),
      adcm_filt = reactive(input$adcm_var),
      advs_filt = reactive(input$advs_var),
      adlb_filt = reactive(input$adlb_var),
      adeg_filt = reactive(input$adeg_var)
    ))
  })
}
