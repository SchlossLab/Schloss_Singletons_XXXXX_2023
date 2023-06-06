#!/usr/bin/env Rscript

# This script takes the directory where the data are located along with an
# indication of whether the data are from preclustering or OTUs and whether the
# data have been pruned or randomized and then pruned. Then it will read in the
# alpha diversity files and calculate summary statistics of a variety of
# diversity metrics to quantify how those metrics change with pruning.

library(tidyverse)
library(broom)
library(glue)


# read in the mothur-formatted output from summary.single and provide summary
# statistics across all of the samples in the dataset. Also output the seed and
# prune values
read_alpha_diversity <- function(x) {

	parsed_file_name <- str_replace(x, "observed", "observed.1") %>%
		str_split(., "[\\.\\/]") %>%
		unlist()

	read_tsv(x,
					col_types = cols(label = col_character(),
											 		group = col_character(),
													method = col_character())) %>%
		filter(method == "ave") %>%
		group_by(label) %>%
		summarize(
			n_seqs = mean(nseqs),
			mean_sobs = mean(sobs), sd_sobs = sd(sobs),
				cv_sobs = sd_sobs / mean_sobs,
			mean_shannon = mean(shannon), sd_shannon = sd(shannon),
				cv_shannon = sd_shannon / mean_shannon,
			mean_invsimpson = mean(invsimpson), sd_invsimpson = sd(invsimpson),
				cv_invsimpson = sd_invsimpson / mean_invsimpson,
			.groups = "drop"
		) %>%
		mutate(dataset = parsed_file_name[2],
			distribution = parsed_file_name[3],
			seed = parsed_file_name[4],
			pruning_method = parsed_file_name[5],
			pruning_level = parsed_file_name[6],
			resolution = parsed_file_name[7], .before = "label") %>%
		select(-label)

}


input <- commandArgs(trailingOnly = TRUE)
alpha_files <- input[-length(input)]
#alpha_files <- scan("random.txt",  what = character(), quiet = TRUE)
#take outputfile name from command line

output_file_name <- input[length(input)]

alpha_files %>%
 	map_df(~read_alpha_diversity(.)) %>%	# get the files
	group_by(dataset, distribution, pruning_method, pruning_level, resolution) %>%
	summarize(
		mean_n_seqs = mean(n_seqs),
		mean_sobs = mean(mean_sobs), sd_sobs = mean(sd_sobs),
			cv_sobs = mean(cv_sobs),
		mean_shannon = mean(mean_shannon), sd_shannon = mean(sd_shannon),
			cv_shannon = mean(cv_shannon),
		mean_invsimpson = mean(mean_invsimpson), sd_invsimpson = mean(sd_invsimpson),
		 cv_invsimpson = mean(cv_invsimpson),
		.groups = "drop"
	) %>%
	write_tsv(output_file_name)