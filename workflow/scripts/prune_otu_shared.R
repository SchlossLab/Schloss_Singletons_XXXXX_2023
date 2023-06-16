#!/usr/bin/env Rscript


library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)


pc_shared_file <- input[1]
asv_seq_map_file <- input[2]
otu_seq_map_file <- input[3]

# pc_shared_file <- "data/marine/random.indiv_count.2.pc.shared"
# asv_seq_map_file <- "data/marine/data.pc_seq.map"
# otu_seq_map_file <- "data/marine/data.otu_seq.map"

otu_shared_file <- str_replace(pc_shared_file, "\\.pc\\.", ".otu.")

pc_tidy <- fread(pc_shared_file) %>%
  select(label, Group, starts_with("ASV")) %>%
  pivot_longer(-c(label, Group), names_to = "asvs", values_to = "count")


asv_seq_map <- read_tsv(asv_seq_map_file) %>%
  rename(asvs = otus)

otu_seq_map <- read_tsv(otu_seq_map_file)

otu_tidy <- left_join(pc_tidy, asv_seq_map, by = "asvs") %>%
  left_join(., otu_seq_map, by = "sequences") %>%
  group_by(label, Group, otus) %>%
  summarize(count = sum(count), .groups = "drop")

pc_n <- pc_tidy %>%
  group_by(label, Group) %>%
  summarize(n = sum(count), .groups = "drop")
  
otu_n <- otu_tidy %>%
  group_by(label, Group) %>%
  summarize(n = sum(count), .groups = "drop")

stopifnot(all(pc_n == otu_n))

otu_tidy %>%
  pivot_wider(names_from = otus, values_from = count, values_fill = 0) %>%
  mutate(numOtus = ncol(.) - 2, .after = Group) %>%
  write_tsv(otu_shared_file)
