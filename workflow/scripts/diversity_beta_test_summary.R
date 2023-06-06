#!/usr/bin/env Rscript

library(tidyverse)

input <- commandArgs(trailingOnly = TRUE)

amova_files <- input[-length(input)]
output_file_name <- input[length(input)]

#amova_files <- scan("hold.txt", what = character(), quiet = TRUE)
#print(amova_files)

get_summary <- function(amova_file) {

	parsed_file_name <- unlist(str_split(amova_file, pattern = "[\\.\\/]"))

	dataset <- parsed_file_name[2]
	distribution <- parsed_file_name[3]
	seed <- parsed_file_name[4]
	pruning_method <- parsed_file_name[5]
	pruning_level <- parsed_file_name[6]
	resolution <- parsed_file_name[7]
	
	p_value <- scan(amova_file, what = character(), sep = "\n", quiet = TRUE) %>%
		str_subset(., pattern = "p-value: ") %>%
		str_replace(., "p-value: ", "") %>%
		str_replace(., "\\*", "")

	p_value <- ifelse(str_detect(p_value, "<"), 0.000, as.numeric(p_value))

	tibble(dataset = dataset, distribution = distribution, seed = seed,
				 pruning_method = pruning_method, pruning_level = pruning_level,
				 resolution = resolution, p_value = p_value)

}


map_df(amova_files, get_summary) %>%
  mutate(sig = p_value < 0.05) %>%
	group_by(dataset, distribution, pruning_method, pruning_level, resolution) %>%
	summarize(frac_sig = mean(sig), .groups = "drop") %>%
	write_tsv(output_file_name)
