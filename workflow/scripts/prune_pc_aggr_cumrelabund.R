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
                           glue("\\.aggr_cumrelabund.{min_class}\\.pc.shared"))

# remove cumulative relative abundances below threshold for each group
# and including ties in abundance

fread(tidy_file) %>%
  group_by(label, asvs) %>%
  mutate(rel_abund = sum(n)) %>%
  group_by(label) %>%
  mutate(rel_abund = rel_abund / sum(rel_abund)) %>%
  arrange(rel_abund) %>%
  mutate(cum_relabund = cumsum(rel_abund),
          keep = cum_relabund >= min_threshold) %>%
  group_by(label, rel_abund) %>%
  mutate(keep = all(keep)) %>%
  filter(keep) %>%
  ungroup() %>%
  select(label, Group, asvs, n) %>%
  arrange(label, Group, asvs) %>%
  pivot_wider(names_from = asvs, values_from = n, values_fill = 0) %>%
  mutate(numASVs = ncol(.) - 2, .after = Group) %>%
  write_tsv(output_file)
