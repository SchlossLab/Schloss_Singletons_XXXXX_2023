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
													 glue("\\.indiv_cumrelabund.{min_class}\\.pc"))

if (min_class == 0) {
	
	file.copy(full_shared, output_file, overwrite = TRUE)

} else {
	
	# remove cumulative relative abundances below threshold for each group
	# and including ties in abundance
	
	fread(full_shared) %>%
		as_tibble() %>%
		select(-label, -numASVs) %>%
		pivot_longer(-Group, names_to = "otus", values_to = "counts") %>%
    group_by(Group) %>% 
    mutate(rel_abund = counts / sum(counts)) %>%
		arrange(rel_abund) %>%
		mutate(cum_relabund = cumsum(rel_abund),
					 keep = cum_relabund >= min_threshold) %>%
    ungroup() %>%
		group_by(Group, counts) %>%
		mutate(keep = all(keep)) %>%
		ungroup() %>%
		filter(keep) %>%
    select(Group, otus, counts) %>%
		arrange(Group, otus) %>%
		pivot_wider(names_from = "otus", values_from = counts, values_fill = 0) %>%
		mutate(numASVs = ncol(.) - 1,
						label = "pc") %>%
		select(label, Group, numASVs, everything()) %>%
		write_tsv(output_file)

}