library(tidyverse)

rprune_groups_file <- commandArgs(trailingOnly=TRUE)
# rprune_groups_file <- "data/mice/data.1.1.rand_pruned_groups"

skewed_design_file <- str_replace(rprune_groups_file, "rand_pruned_groups", "sdesign")
# design_file <- "data/mice/data.1.1.sdesign"

read_tsv(rprune_groups_file, col_types=cols(.default=col_character(), n_seqs=col_integer())) %>%
	group_by(group) %>%
	summarize(count = sum(n_seqs)) %>%
	mutate(grouping = ifelse(count < median(count), "small", "large")) %>%
	select(group, grouping) %>%
	write_tsv(skewed_design_file, col_names=F)
