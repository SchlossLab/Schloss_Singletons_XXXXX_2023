# This script takes the directory where the data are located along with an indication of whether
# the data are from preclustering or OTUs and whether the data have been pruned or randomized and
# then pruned. Then it will read in the alpha diversity files and calculate summary statistics of a
# variety of diversity metrics to quantify how those metrics change with pruning.
#
# Expected input: The path and file name of the output file that should be in the form of
#   data/bioethanol/data.#.[otu|pc].oalpha_analysis or data/bioethanol/data.#.#.[otu|pc].ralpha_analysis
#   The directory (e.g. data/bioethanol/) should contain files named like data.[1..11].[pc|otu].oalpha_diversity
#   or data.[1..100].[1.,11].[pc|otu].ralpha_diversity.
#	Output: A file named data.[otu|pc].[ro]alpha_analysis

library(tidyverse)

# read in the mothur-formatted output from summary.single and provide summary statistics across all
# of the samples in the dataset. Also output the seed and prune values
read_alpha_diversity <- function(x) {

	read_tsv(x,
					col_types=cols(label=col_character(), group=col_character(), method=col_character())) %>%
		filter(method=="ave") %>%
		mutate(seed = ifelse(str_detect(x, "oalpha_diversity"),
												 1L,
												 str_replace(x, ".*\\.(\\d*)\\.\\d*\\.\\D*", "\\1") %>% as.integer()),
					prune = str_replace(x, ".*\\.(\\d*)\\.\\D*", "\\1") %>% as.integer()) %>%
		group_by(seed, prune) %>%
		summarize(
			n_seqs = mean(nseqs),
			mean_sobs = mean(sobs), sd_sobs = sd(sobs), cv_sobs = sd_sobs/mean_sobs,
			mean_shannon = mean(shannon), sd_shannon = sd(shannon), cv_shannon = sd_shannon/mean_shannon,
			mean_invsimpson = mean(invsimpson), sd_invsimpson = sd(invsimpson), cv_invsimpson=sd_invsimpson/mean_invsimpson
		) %>%
		ungroup()

}


input <- commandArgs(trailingOnly=TRUE)
output <- input[1] # e.g. output <- 'data/rainforest/data.pc.ralpha_analysis'


# get all of the alpha_diversity files that correspond to the desired output file name
path <- str_replace(output, "(.*)\\/.*", "\\1")
pattern <- str_replace(output, ".*\\.(\\w{2,3}\\..)alpha_analysis", "\\1alpha_diversity")


list.files(path, pattern=pattern, full.names = TRUE) %>%
 	map_df(~read_alpha_diversity(.)) %>%			# get the files
	group_by(prune) %>%												# summarize the metrics across all of the seeds
	summarize(
		mean_n_seqs = mean(n_seqs),
		mean_sobs = mean(mean_sobs), sd_sobs = mean(sd_sobs), cv_sobs=mean(cv_sobs),
		mean_shannon=mean(mean_shannon), sd_shannon=mean(sd_shannon), cv_shannon=mean(cv_shannon),
		mean_invsimpson=mean(mean_invsimpson), sd_invsimpson=mean(sd_invsimpson), cv_invsimpson=mean(cv_invsimpson)
	) %>%
	arrange(prune) %>%
	write_tsv(output)
