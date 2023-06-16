#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)

input <- commandArgs(trailingOnly = TRUE)

obs_pc_shared_file <- input[1]

# obs_pc_shared_file <- "data/marine/observed.pc.shared"

output_tidy_file <- str_replace(obs_pc_shared_file,
                                  "shared",
                                  "tidy")

fread(obs_pc_shared_file) %>%
  select(Group, starts_with("ASV")) %>%
  pivot_longer(-Group, names_to = "asvs", values_to = "n") %>%
  filter(n != 0) %>%
  mutate(label = 1, .before = "Group") %>%
  write_tsv(output_tidy_file)
