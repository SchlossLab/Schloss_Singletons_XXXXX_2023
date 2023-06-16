#!/usr/bin/env Rscript


library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)
tidy_file <- input[1] # e.g. full_shared <- 'data/marine/observed.pc.tidy'
min_class <- as.numeric(input[2]) # e.g. min_class <- 10

min_threshold <- min_class / 1e4

output_file <- str_replace(tidy_file,
                           ".pc.tidy",
                           glue("\\.indiv_relabund.{min_class}\\.pc.shared"))

fread(tidy_file) %>%
  group_by(label, Group) %>%
  mutate(rel_abund = n / sum(n)) %>%
  ungroup() %>%
  filter(rel_abund >= min_threshold) %>%
  select(-rel_abund) %>%
  pivot_wider(names_from = asvs, values_from = n, values_fill = 0) %>%
  mutate(numASVs = ncol(.) - 2, .after = Group) %>%
  write_tsv(output_file)
