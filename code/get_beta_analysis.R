# This script takes the directory where the data are located along with an indication of whether
# the data are from preclustering or OTUs and whether the data have been pruned or randomized and
# then pruned. Then it will read in the beta diversity files and calculate summary statistics by a
# variety of methods to quantify how beta diversity changes with pruning.
#
# Expected input: The path and file name of the output file that should be in the form of
#   data/bioethanol/data.#.[otu|pc].obeta_analysis or data/bioethanol/data.#.#.[otu|pc].rbeta_analysis
#   The directory (e.g. data/bioethanol/) should contain files named like data.[1..11].[pc|otu].obeta_diversity
#   or data.[1..100].[1.,11].[pc|otu].rbeta_diversity.
#	Output: A file named data.[otu|pc].[ro]beta_analysis

library(tidyverse)
library(data.table)


# read in the mothur-formatted output from dist.shared and provide summary statistics across all
# of the samples in the dataset. Also output the seed and prune values
get_indiv_beta_diversity <- function(x) {

	fread(x,
				col.names=c("A", "B", "distance"),
				colClasses=c("character", "character", "double")) %>%
		as_tibble() %>%
		mutate(seed = ifelse(str_detect(x, "obeta_diversity"),
												 1L,
												 str_replace(x, ".*\\.(\\d*)\\.\\d*\\.\\D*", "\\1") %>% as.integer()),
					prune = str_replace(x, ".*\\.(\\d*)\\.\\D*", "\\1") %>% as.integer()) %>%
		select(seed, prune, A, B, distance) %>%
		group_by(seed, prune) %>%
		summarize(
			mean = mean(distance), sd = sd(distance), sd_mean = sd/mean,
			median = median(distance), iqr = IQR(distance), iqr_median = iqr/median,
			lci = quantile(distance, probs=0.25), uci = quantile(distance, probs=0.75)
		) %>%
		ungroup()

}


input <- commandArgs(trailingOnly=TRUE)
output <- input[1] # e.g. output <- 'data/soil/data.otu.obeta_analysis'

# get all of the beta_diversity files that correspond to the desired output file name
path <- str_replace(output, "(.*)\\/.*", "\\1")
pattern <- str_replace(output, ".*\\.(\\w{2,3}\\..)beta_analysis", "\\1beta_diversity")

list.files(path, pattern=pattern, full.names = TRUE) %>%
	map_df(~get_indiv_beta_diversity(.)) %>%			# get the files
	group_by(prune) %>%														# summarize the metrics across all of the seeds
	summarize(
		mean = mean(mean), sd = mean(sd), sd_mean = mean(sd_mean),
		median = mean(median), iqr = mean(iqr), iqr_median = mean(iqr_median),
		lci = mean(lci), uci = mean(uci),				# leaving these in here, but didn't really see a
	) %>%																			# difference between mean/sd and median/iqr
	arrange(prune) %>%
	write_tsv(output)
