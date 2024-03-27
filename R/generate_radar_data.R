
incise_results <- readr::read_csv(
  "data/incise2019_results.csv"
)

incise_metrics <- readr::read_csv(
  "data/incise2019_metrics.csv"
)

incise_imputation <- readr::read_csv(
  "data/incise2019_imputation.csv"
)

indicator_meta <- readr::read_csv(
  "data/incise2019_indicator_metadata.csv"
)

metrics_meta <- readr::read_csv(
  "data/incise2019_metrics_metadata.csv"
)

source_meta <- readr::read_csv(
  "data/incise2019_source_metadata.csv"
)

results_long <- incise_results |>
  dplyr::select(-cc_name) |>
  dplyr::bind_rows(
    incise_results |>
      dplyr::summarise(across(where(is.numeric), mean)) |>
      dplyr::mutate(cc_iso3c = "InCiSE")
  ) |>
  tidyr::pivot_longer(
    cols = -cc_iso3c, names_to = "metric", values_to = "value"
  ) |>
  dplyr::mutate(
    group = dplyr::if_else(metric == "incise_index", "0_index", "0_indicators")
  ) |>
  dplyr::arrange(cc_iso3c, metric) |>
  dplyr::mutate(
    sort_order = dplyr::row_number(),
    .by = c(group, cc_iso3c)
  ) |>
  dplyr::left_join(
    indicator_meta |>
      dplyr::transmute(
        metric = paste0("ind_", tolower(indicator)),
        label = ind_name
      ),
    by = "metric"
  )

metrics_long <- incise_metrics |>
  dplyr::select(-cc_name) |>
  dplyr::bind_rows(
    incise_metrics |>
      dplyr::summarise(across(where(is.numeric), mean)) |>
      dplyr::mutate(cc_iso3c = "InCiSE")
  ) |>
  tidyr::pivot_longer(
    cols = -cc_iso3c, names_to = "metric", values_to = "value"
  ) |>
  dplyr::mutate(group = substr(metric, 1, 3)) |>
  dplyr::left_join(
    metrics_meta |> dplyr::select(metric, label, sort_order = indord),
    by = "metric"
  )

full_data <- results_long |>
  dplyr::bind_rows(metrics_long) |>
  dplyr::arrange(group, sort_order, cc_iso3c) |>
  dplyr::left_join(incise_imputation, by = c("cc_iso3c", "metric")) |>
  dplyr::mutate(
    sort_order = dplyr::if_else(group == "0_index", NA_integer_, sort_order),
    raw_value = value,
    imputed = value * imputed
  ) |>
  dplyr::add_count(group, metric) |>
  dplyr::mutate(
    offset = 0.5/max(sort_order) * 2 * pi,
    # offset = (180 / n) + 90,
    theta = (sort_order/max(sort_order) * 2 * pi) -
      (1/max(sort_order) * 2 * pi) -
      (pi/2) +
      offset,
    .by = group
  ) |>
  dplyr::mutate(
    radar_x = cos(theta) * value,
    radar_y = sin(theta) * -value,
    value = dplyr::if_else(!is.na(imputed), NA_real_, value),
    label = dplyr::if_else(group == "0_index", "InCiSE Index", label),
    hover_label = dplyr::if_else(
      is.na(value),
      paste0(cc_iso3c, " - ", label, ": ",
             scales::comma(imputed, accuracy = 0.01), " (imputed)"),
      paste0(cc_iso3c, " - ", label, ": ",
             scales::comma(value, accuracy = 0.01))
    ),
    hover_label = stringr::str_wrap(hover_label, 20),
    data_label = scales::comma(raw_value, accuracy = 0.01)
  )

radar_grid <- full_data |>
  dplyr::filter(group != "0_index") |>
  dplyr::distinct(group, metric, theta) |>
  dplyr::mutate(
    value = list(c(0.25, 0.5, 0.75, 1))
  ) |>
  tidyr::unnest(value) |>
  dplyr::mutate(
    radar_x = cos(theta) * value,
    radar_y = sin(theta) * -value,
  ) |>
  dplyr::select(-theta)

radar_axes <- full_data |>
  dplyr::filter(group != "0_index") |>
  dplyr::distinct(group, metric, sort_order, label, theta) |>
  dplyr::mutate(
    label_x = cos(theta) * 1.2,
    label_y = sin(theta) * -1.2,
    axis_x = cos(theta) * 1.05,
    axis_y = sin(theta) * -1.05,
    label = stringr::str_wrap(label, 15)
  ) |>
  dplyr::select(-theta)

radar_data <- full_data |>
  dplyr::select(group, metric, label, cc_iso3c, raw_value, value, imputed,
                radar_x, radar_y, data_label, hover_label)

readr::write_csv(radar_data, "data/radar_data.csv", na = "")
readr::write_csv(radar_grid, "data/radar_grid.csv", na = "")
readr::write_csv(radar_axes, "data/radar_axes.csv", na = "")

metadata <- metrics_meta |>
  dplyr::select(metric, indicator, label, description, sort_order = indord) |>
  dplyr::left_join(
    source_meta |>
      dplyr::summarise(source = paste0(source, collapse = ", "), .by = "metric"),
    by = "metric"
  ) |>
  dplyr::mutate(group = tolower(indicator)) |>
  dplyr::bind_rows(
    indicator_meta |>
      dplyr::select(metric = indicator, label = ind_name) |>
      dplyr::filter(!grepl("^X", metric)) |>
      dplyr::arrange(metric) |>
      dplyr::mutate(
        metric = paste0("ind_", tolower(metric)),
        description = paste0("Composite InCiSE Indicator for ", label),
        label = paste0(label, " (InCiSE Indicator)"),
        group = "0_indicators",
        sort_order = dplyr::row_number(),
        source = "InCiSE 2019"
      )
  ) |>
  dplyr::add_row(
    metric = "incise_index",
    label = "InCiSE Index",
    group = "0_index",
    description = "Overall composite InCiSE Index score",
    source = "InCiSE 2019",
    sort_order = 0
  ) |>
  dplyr::filter(!grepl("^x", group)) |>
  dplyr::arrange(group, sort_order) |>
  dplyr::select(group, sort_order, metric, label, description, source)

incise_data_table <- full_data |>
  dplyr::select(
    cc_iso3c, metric, value = raw_value, imputed
  ) |>
  dplyr::mutate(
    imputed = dplyr::if_else(is.na(imputed), "", "Imputed value")
  ) |>
  dplyr::filter(cc_iso3c != "InCiSE") |>
  dplyr::left_join(metadata, by = "metric") |>
  dplyr::left_join(
    full_data |>
      dplyr::filter(cc_iso3c == "InCiSE") |>
      dplyr::select(metric, incise_average = raw_value),
    by = "metric"
  ) |>
  dplyr::mutate(
    across(c(value, incise_average), ~round(.x, 2))
  ) |>
  dplyr::select(
    cc_iso3c, group, sort_order, metric, label, value, incise_average, imputed, description, source
  )

readr::write_excel_csv(incise_data_table, "data/incise2019_full_output.csv", na = "")
