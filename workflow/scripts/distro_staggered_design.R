#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)

obs_pc_tidy_file <- input[1]
n_replicates <- input[2]

output_filename <- str_replace(obs_pc_tidy_file,
                               "observed.*",
                               "staggered.design")

stagger_design <- fread(obs_pc_tidy_file) %>%
    group_by(Group) %>%
    summarize(n = sum(n)) %>%
    mutate(treatment = if_else(n < median(n), "A", "B")) %>%
    select(group = Group, treatment)


map_dfr(1:n_replicates, ~{stagger_design}, .id = "label")  %>%
  write_tsv(output_filename)
