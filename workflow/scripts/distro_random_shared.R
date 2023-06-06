#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)

obs_pc_shared_file <- input[1]
rng_seed <- input[2]

# obs_pc_shared_file <- "data/marine/observed.pc.shared"
# rng_seed <- 1

set.seed(rng_seed)

output_filename <- str_replace(obs_pc_shared_file, 
                               "observed",
                               glue("random.{rng_seed}"))

observed_tidy <- fread(obs_pc_shared_file) %>%
  select(Group, starts_with("ASV")) %>%
  pivot_longer(-Group, names_to = "asvs", values_to = "count") %>%
  filter(count != 0)


tibble(Group = rep(observed_tidy$Group, observed_tidy$count),
                      asvs = rep(observed_tidy$asvs, observed_tidy$count)) %>%
  mutate(asvs = sample(asvs)) %>%
  count(Group, asvs) %>%
  pivot_wider(names_from = asvs, values_from = n, values_fill = 0) %>%
  mutate(label = "pc",
         numASVs = ncol(.) - 1) %>%
  select(label, Group, numASVs, everything()) %>%
  write_tsv(output_filename)
