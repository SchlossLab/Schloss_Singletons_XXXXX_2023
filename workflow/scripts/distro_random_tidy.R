#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)

input <- commandArgs(trailingOnly = TRUE)

obs_pc_tidy_file <- input[1]
n_replicates <- input[2]

# obs_pc_tidy_file <- "data/marine/observed.pc.tidy"
# n_replicates <- 100

set.seed(19760620)

output_filename <- str_replace(obs_pc_tidy_file,
                               "observed\\..*",
                               "random.pc.tidy")


observed_tidy <- fread(obs_pc_tidy_file)


randomize_data <- function() {

  tibble(Group = rep(observed_tidy$Group, observed_tidy$n),
         asvs = rep(observed_tidy$asvs, observed_tidy$n)) %>%
    mutate(asvs = sample(asvs)) %>%
    count(Group, asvs)

}

map_dfr(1:n_replicates, ~randomize_data(), .id = "label") %>%
  write_tsv(output_filename)
