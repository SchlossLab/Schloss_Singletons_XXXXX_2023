#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)

input <- commandArgs(trailingOnly = TRUE)

obs_pc_tidy_file <- input[1]
n_replicates <- input[2]

set.seed(19760620)

output_filename <- str_replace(obs_pc_tidy_file, 
                               "observed\\..*",
                               "random.design")

groups <- fread(obs_pc_tidy_file) %>% 
  select(group = Group) %>%
  distinct()


random_design <- function() {

  groups %>%
    mutate(treatment = sample(rep_len(c("A", "B"), length.out = nrow(.))))

}


map_dfr(1:n_replicates, ~random_design(), .id = "label") %>%
  write_tsv(output_filename)
