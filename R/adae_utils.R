#' Add Flags to ADAE
#'
#' @param df `ADAE` dataset
#'
#' @return `ADAE` dataset with added flags
#'
#' @family adae_utils
#' @keywords adae_utils
#'
#' @export
#' @examples
#' library(dplyr)
#' adsl <- random.cdisc.data::cadsl
#' adae <- random.cdisc.data::cadae
#' adae_ <- add_adae_flags(adae)
#' select(adae_, c("USUBJID", setdiff(names(adae_), names(adae))))
#'
add_adae_flags <- function(df) {
  df <- df |>
    mutate(
      FATAL = AESDTH == "Y",
      SER = AESER == "Y",
      SERWD = AESER == "Y" & AEACN == "DRUG WITHDRAWN",
      SERDSM = AESER == "Y" & AEACN %in% c(
        "DRUG INTERRUPTED",
        "DOSE INCREASED", "DOSE REDUCED"
      ),
      RELSER = AESER == "Y" & AEREL == "Y",
      WD = AEACN == "DRUG WITHDRAWN",
      DSM = AEACN %in% c("DRUG INTERRUPTED", "DOSE INCREASED", "DOSE REDUCED"),
      REL = AEREL == "Y",
      RELWD = AEREL == "Y" & AEACN == "DRUG WITHDRAWN",
      RELDSM = AEREL == "Y" & AEACN %in% c(
        "DRUG INTERRUPTED",
        "DOSE INCREASED", "DOSE REDUCED"
      ),
      CTC35 = AETOXGR %in% c("3", "4", "5"),
      CTC45 = AETOXGR %in% c("4", "5")
    ) |>
    var_relabel(
      FATAL = "AE with fatal outcome",
      SER = "Serious AE",
      SERWD = "Serious AE leading to withdrawal from treatment",
      SERDSM = "Serious AE leading to dose modification/interruption",
      RELSER = "Related Serious AE",
      WD = "AE leading to withdrawal from treatment",
      DSM = "AE leading to dose modification/interruption",
      REL = "Related AE",
      RELWD = "Related AE leading to withdrawal from treatment",
      RELDSM = "Related AE leading to dose modification/interruption",
      CTC35 = "Grade 3-5 AE",
      CTC45 = "Grade 4/5 AE"
    )
}


#' Create ADAE Summary Table
#'
#' @param adae Input `ADAE` dataset
#' @param filter_cond filter condition
#' @param event_vars Variables added to source `ADAE` by `add_adae_flags()`
#' @param trt_var Treatment Variable eg. `ARM`
#'
#' @return List containing layout object of ADAE Summary Table and filtered ADAE data
#' @export
#'
#' @family adae_utils
#' @keywords adae_utils
#'
#' @examples
#'
#' library(rtables)
#' adsl <- random.cdisc.data::cadsl
#' adae <- random.cdisc.data::cadae
#' adae_ <- add_adae_flags(adae)
#' lyt <- build_adae_summary(
#'   adae = adae_,
#'   filter_cond = NULL,
#'   event_vars = setdiff(names(adae_), names(adae)),
#'   trt_var = "ARM"
#' )
#' build_table(lyt = lyt$lyt, df = lyt$df_out, alt_counts_df = adsl)
#'
build_adae_summary <-
  function(adae, filter_cond = NULL, event_vars, trt_var) {
    df <- adae
    if (!is.null(filter_cond)) {
      df <- adae |>
        filter(!!!parse_exprs(filter_cond))
    }

    lyt <- basic_table(show_colcounts = TRUE) |>
      split_cols_by(var = trt_var) |>
      add_overall_col(label = "All Patients") |>
      count_patients_with_event(
        vars = "USUBJID",
        filters = c("STUDYID" = as.character(unique(adae[["STUDYID"]]))),
        denom = "N_col",
        .labels = c(count_fraction = "Total number of patients with at least one adverse event")
      ) |>
      count_values(
        "STUDYID",
        values = as.character(unique(adae[["STUDYID"]])),
        .stats = "count",
        .labels = c(count = "Total AEs"),
        table_names = "total_aes"
      ) |>
      count_patients_with_flags(
        "USUBJID",
        flag_variables = var_labels(adae[, event_vars]),
        denom = "N_col",
        var_labels = "Total number of patients with at least one",
        show_labels = "visible"
      )
    return(list(lyt = lyt, df_out = df))
  }

#' Adverse Events Table by Body System and Severity/Toxicity
#'
#' @param adsl Input `ADSL` data
#' @param df_adae Input `ADAE` data
#' @param colsby Column Variable (default: `ARM`)
#' @param grade_val AE Severity or AE Toxicity Grade i.e. `AESEV` or `AETOXGR`
#' @param class_val Sytem Organ Class/Body System Class i.e. `AESOC` or `AEBODSYS`
#' @param term_val Dictionary Derived Term i.e. `AEDECOD` or `AETERM`
#' @param default_view Logical `TRUE` or `FALSE`
#'
#' @return An rtable object
#' @family adae_utils
#' @keywords adae_utils
#' @export
#'
#' @examples
#'
#' adsl <- random.cdisc.data::cadsl
#' adae <- random.cdisc.data::cadae
#'
#' build_adae_by_sev_tox(
#'   adsl = adsl,
#'   df_adae = adae,
#'   colsby = "ARM",
#'   grade_val = "AESEV",
#'   class_val = "AESOC",
#'   term_val = "AEDECOD",
#'   default_view = TRUE
#' )
#'
#'
build_adae_by_sev_tox <- function(adsl,
                            df_adae,
                            colsby = "ARM",
                            grade_val = "AESEV",
                            class_val = "AESOC",
                            term_val = "AEDECOD",
                            default_view = TRUE) {
  if (isTRUE(default_view)) {
    adsl <- adsl |>
      add_count(.data[[colsby]]) |>
      mutate(colsby_lab = paste0(.data[[colsby]], " (N = ", n, ")")) |>
      select(all_of(c("USUBJID", colsby)), colsby_lab)

    if (grade_val == "AESEV") {
      adae <- df_adae |>
        mutate(
          AESEVN =
            case_when(
              .data[[grade_val]] == "MILD" ~ 1,
              .data[[grade_val]] == "MODERATE" ~ 2,
              TRUE ~ 3
            )
        )
    } else {
      adae <- df_adae |>
        mutate(AESEVN = as.numeric(AETOXGR))
    }

    adae <- adae |>
      group_by(USUBJID, .data[[colsby]], .data[[class_val]], .data[[term_val]]) |>
      filter(AESEVN == max(AESEVN)) |>
      ungroup()

    pre_ae <- df_adae |>
      select(all_of(c(class_val, term_val))) |>
      distinct_all() |>
      arrange(.data[[class_val]])

    pre_ae1 <-
      cross_join(select(df_adae, all_of(c(
        "USUBJID", colsby
      ))), pre_ae) |>
      distinct_all()

    adae <-
      full_join(adae, pre_ae1, by = c("USUBJID", colsby, class_val, term_val)) |>
      modify_if(is.factor, as.character) |>
      mutate(!!grade_val := replace_na(!!sym(grade_val), "Missing")) |>
      left_join(adsl, by = c("USUBJID", colsby)) |>
      modify_if(is.character, as.factor)

    dummy_sev <- data.frame(x = unique(adae[[grade_val]]))
    names(dummy_sev) <- grade_val

    l1 <- levels(adsl[[colsby]]) |>
      map(~ {
        df <- adae |>
          filter(.data[[colsby]] == .x) |>
          mutate(sp_labs = "N") |>
          mutate(!!colsby := as.character(!!sym(colsby)))

        df_adsl1 <- adsl |>
          filter(.data[[colsby]] == .x) |>
          mutate(!!colsby := as.character(!!sym(colsby)))

        df_adsl <- df_adsl1 |>
          select(all_of(c("USUBJID", colsby))) |>
          distinct_all() |>
          cross_join(dummy_sev)

        lyt1 <- basic_table() |>
          split_cols_by(colsby,
                        labels_var = "sp_labs",
                        split_fun = remove_split_levels("Missing")
          ) |>
          split_rows_by(class_val) |>
          count_occurrences(term_val) |>
          build_table(
            mutate(
              df,
              !!colsby := ifelse(.data[[grade_val]] == "Missing", "Missing", !!sym(colsby)),
              sp_labs = ifelse(.data[[grade_val]] == "Missing", "Missing", sp_labs)
            ),
            alt_counts_df = df_adsl1
          )


        lyt <- basic_table() |>
          split_cols_by(colsby, labels_var = "colsby_lab") |>
          split_rows_by(class_val,
                        indent_mod = 1L,
                        label_pos = "topleft",
                        split_label = obj_label(df_adae[[class_val]])
          ) |>
          split_cols_by(grade_val, split_fun = remove_split_levels("Missing")) |>
          count_occurrences(term_val) |>
          append_varlabels(df_adae, term_val, indent = 2L) |>
          build_table(df, alt_counts_df = df_adsl)
        cbind_rtables(lyt1, lyt)
      })

    tab <- reduce(l1, cbind_rtables)
  } else {
    lyt <- basic_table() |>
      split_cols_by(var = colsby) |>
      add_colcounts() |>
      add_overall_col(label = "All Patients") |>
      add_colcounts() |>
      summarize_num_patients("USUBJID") |>
      split_rows_by(
        class_val,
        child_labels = "visible",
        nested = TRUE,
        label_pos = "topleft",
        split_label = obj_label(df_adae[[class_val]]),
        split_fun = drop_split_levels
      ) |>
      split_rows_by(
        term_val,
        child_labels = "visible",
        nested = TRUE,
        label_pos = "topleft",
        split_label = obj_label(df_adae[[term_val]]),
        split_fun = drop_split_levels
      ) |>
      summarize_occurrences_by_grade(grade_val)

    tab <-
      build_table(
        df = df_adae,
        alt_counts_df = adsl,
        lyt = lyt
      )
  }
  return(tab)
}
