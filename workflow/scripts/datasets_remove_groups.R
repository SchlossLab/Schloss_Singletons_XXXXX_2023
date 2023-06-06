#!/usr/bin/env Rscript

# this will generate the remove_accnos file when provided with the sequence
# count file

library(tidyverse)

thresholds <- tibble(data_sets = c("bioethanol", "human", "lake", "marine",
                                   "mice", "rainforest", "rice", "seagrass",
                                   "sediment", "soil", "stream"),
                      minimum = c(3600, 10000, 10000, 3600,
                                  1800, 3600, 2500, 1800,
                                  7000, 3600, 3600)
                )


find_small_samples <- function(count_summary) {

  d <- str_replace(count_summary, "data/(.*)/data.*", "\\1")

  threshold <- thresholds %>% filter(data_sets == d) %>% pull(minimum)
  remove_accnos <- str_replace(count_summary, "count.summary", "remove_accnos")

  read_tsv(count_summary, col_names = c("group", "n_seqs")) %>%
    filter(n_seqs < threshold) %>%
    pull(group) %>%
    paste(., sep = "", collapse = "-") %>%
    write(remove_accnos)

}

input <- commandArgs(trailingOnly = TRUE)
count_summary_file <- input[1]

find_small_samples(count_summary_file)
