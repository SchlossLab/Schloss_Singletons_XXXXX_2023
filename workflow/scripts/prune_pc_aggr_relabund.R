#!/usr/bin/env Rscript


library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)
full_shared <- input[1] # e.g. full_shared <- 'data/marine/observed.pc.shared'
min_class <- as.numeric(input[2]) # e.g. min_class <- 10

min_threshold <- min_class / 1e4

output_file <- str_replace(full_shared,
													 ".pc",
													 glue("\\.aggr_relabund.{min_class}\\.pc"))

if (min_class == 0) {
	
	file.copy(full_shared, output_file, overwrite = TRUE)

} else {
	
	fread(full_shared) %>%
		as_tibble() %>%
		select(-label, -numASVs) %>%
		pivot_longer(-Group, names_to = "otus", values_to = "counts") %>%
    group_by(otus) %>%
    mutate(rel_abund = sum(counts)) %>%
    ungroup() %>%
    mutate(rel_abund = rel_abund / sum(rel_abund)) %>%
		filter(rel_abund >= min_threshold) %>%
    select(-rel_abund) %>%
		pivot_wider(names_from = "otus", values_from = counts, values_fill = 0) %>%
		mutate(numASVs = ncol(.) - 1,
						label = "pc") %>%
		select(label, Group, numASVs, everything()) %>%
		write_tsv(output_file)

}