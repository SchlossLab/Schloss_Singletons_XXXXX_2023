#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)

obs_pc_shared_file <- input[1]
rng_seed <- input[2] #dummy variable

output_filename <- str_replace(obs_pc_shared_file,
                               "observed.*",
                               glue("staggered.{rng_seed}.design"))

fread(obs_pc_shared_file) %>%
  select(Group, starts_with("ASV")) %>%
  pivot_longer(-Group, names_to = "asvs", values_to = "count") %>%
  group_by(Group) %>%
  summarize(count = sum(count)) %>%
  mutate(treatment = if_else(count < median(count), "A", "B")) %>%
  select(group = Group, treatment) %>%
  write_tsv(output_filename)
