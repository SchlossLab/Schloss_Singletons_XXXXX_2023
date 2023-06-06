#!/usr/bin/env Rscript

library(tidyverse)

input <- commandArgs(trailingOnly = TRUE)
list_file_name <- input[1] # e.g. list_file_name <- 'data/marine/data.pc.list'
map_file_name <- str_replace(list_file_name, "\\.list", "_seq.map")

list_file <- scan(list_file_name, what="character", quiet=TRUE) # read in the list file

# This pipeline parses the long list_file vector into a data frame where the first column is the
# OTU name and the seond column contains the names of the sequences in each OTU separated by commas
tibble(otus = list_file[1:(length(list_file) / 2)],
			seq_list = list_file[((length(list_file) / 2)+1):length(list_file)]) %>%
	filter(str_detect(otus, "^Otu") | str_detect(otus, "^ASV")) %>%
	nest(data = seq_list) %>%
	mutate(sequences = map(data, ~as.vector(str_split(.x$seq_list, ",", simplify=TRUE)))) %>%
	select(otus, sequences) %>%
	unnest(sequences) %>%
	write_tsv(map_file_name)

