#!/usr/bin/env Rscript


# This script reads in data.pc.shared from the user specified directory set in
# 'path'. It then applies a pruning step by removing those reads whose frequency
# is below the user specified value set as 'min_class'. Finally, it outputs a
# mothur-formatted shared file with the extension prune_shared to indicate that
# it is a shared file that has been pruned.
#
# Expected input: An ASV shared file (e.g. data/marine/data.1.pc.oshared)
#	Output: A file named data.{min_class}.pc.{model}shared that is deposited in
# the same directory

library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)
full_shared <- input[1] # e.g. full_shared <- 'data/marine/observed.pc.shared'
min_class <- as.numeric(input[2]) # e.g. min_class <- 2

output_file <- str_replace(full_shared,
													 ".pc",
													 glue("\\.indiv_count.{min_class}\\.pc"))

# Here we read in the data.1.pc.{effect}shared file using fread (for speed) and
# we make the data frame tidy so that we can easily filter the group/otu
# combinations for those otus that are at or above the value of min_class.
# Finally, we spread the data back out and format it to be a mothur-compatible
# shared file

if (min_class == 1) {
	
	file.copy(full_shared, output_file, overwrite = TRUE)

} else {
	
	fread(full_shared) %>%
		as_tibble() %>%
		select(-label, -numASVs) %>%
		pivot_longer(-Group, names_to = "otus", values_to = "counts") %>%
		filter(counts >= min_class) %>%
		pivot_wider(names_from = "otus", values_from = counts, values_fill = 0) %>%
		mutate(numASVs = ncol(.) - 1,
						label = "pc") %>%
		select(label, Group, numASVs, everything()) %>%
		write_tsv(output_file)
		
}