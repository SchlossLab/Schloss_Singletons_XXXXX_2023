#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)

obs_pc_shared_file <- input[1]
rng_seed <- input[2]

set.seed(rng_seed)

output_filename <- str_replace(obs_pc_shared_file,
                               "observed.*",
                               glue("random.{rng_seed}.design"))

fread(obs_pc_shared_file) %>%
  select(group = Group) %>%
  mutate(treatment = sample(rep_len(c("A", "B"), length.out = nrow(.)))) %>%
  write_tsv(output_filename)
