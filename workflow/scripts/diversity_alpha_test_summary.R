#!/usr/bin/env Rscript

library(tidyverse)
library(broom)
library(glue)

input <- commandArgs(trailingOnly = TRUE)
alpha_files <- input[-length(input)]

#take outputfile name from command line
output_file_name <- input[length(input)]


get_summary <- function(alpha_file) {

	parsed_file_name <- unlist(str_split(alpha_file, pattern = "[\\.\\/]"))

	dataset <- parsed_file_name[2]
	distribution <- parsed_file_name[3]
	seed <- parsed_file_name[4]
	pruning_method <- parsed_file_name[5]
	pruning_level <- parsed_file_name[6]
	resolution <- parsed_file_name[7]

  design_file <- glue("data/{dataset}/{distribution}.{seed}.design")

  read_tsv(alpha_file,
          col_types = cols(label = col_character(),
                           group = col_character(),
                           method = col_character())) %>%
    filter(method == "ave") %>%
    select(group, sobs, shannon, invsimpson) %>%
    inner_join(.,
              read_tsv(design_file,
                       col_types = "cc"),
              by = "group") %>%
    pivot_longer(cols = c(sobs, shannon, invsimpson),
                 names_to = "metric", values_to = "value") %>%
    nest(data = -metric) %>%
    mutate(test = map(data,
                      ~tidy(wilcox.test(.x$value ~ .x$treatment,
                                        exact = FALSE))),
          median_A = map(data, ~.x %>%
                         filter(treatment == "A") %>%
                         summarize(median_A = median(value))),
          median_B = map(data, ~.x %>%
                         filter(treatment == "B") %>%
                         summarize(median_B = median(value))),
        ) %>%
    select(metric, test, median_A, median_B) %>%
    unnest(c(test, median_A, median_B)) %>%
    mutate(dataset = dataset, distribution = distribution, seed = seed,
           pruning_method = pruning_method, pruning_level = pruning_level,
           resolution = resolution, .before = metric) %>%
    select(-statistic, -method, -alternative)

}


map_df(alpha_files, get_summary) %>%
  mutate(sig = p.value < 0.05) %>%
  group_by(dataset, distribution, pruning_method, pruning_level,
           resolution, metric) %>%
  summarize(frac_sig = mean(sig),
            median_A = median(median_A),
            median_B = median(median_B), .groups = "drop") %>%
  write_tsv(output_file_name)
