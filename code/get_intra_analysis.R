# This script takes the directory where the data are located along with an indication of whether
# the data are from preclustering or OTUs and whether the data have been pruned or randomized and
# then pruned. Then it will read in the shared files and compare the data to see how the diversity,
# number of sequences, amount of information, and abundances comapre to the unpruned dataset.
#
# Expected input: The path and file name of the output file that should be in the form of
#   data/bioethanol/data.#.[otu|pc].ointra_analysis or data/bioethanol/data.#.#.[otu|pc].rintra_analysis
#   The directory (e.g. data/bioethanol/) should contain files named like data.[1..11].[pc|otu].oshared
#   or data.[1..100].[1.,11].[pc|otu].rshared.
#	Output: A file named data.[otu|pc].[ro]intra_analysis

library(data.table)
library(tidyverse)
library(broom)


# Read in a mothur-formatted shared file and convert it to a tidy data frame with all zeroes removed
read_shared <- function(file_name){

	fread(file_name) %>%
		melt(id.vars = c("label", "numOtus", "Group"), variable.name="otu", value.name = "count", variable.factor=FALSE) %>%
		select(-label, -numOtus) %>%
		rename(group=Group) %>%
		filter(count > 0)

}


# Calculate the Kullback-Leiler divergence value
# See: https://en.wikipedia.org/wiki/Kullback–Leibler_divergence
# D_KL(P || Q) = assumes P is observed and Q is what we are fitting the observed data to. The value
# indicates the amount of information lost when Q is used to approximate P. It is also called the
# relative entropy of P with respect to Q. In our case we will use P to represent the value of the
# pruned dataset and Q will be the full dataset
get_kl_divergence <- function(p, q){

	remove_p <- p != 0

	p_nozero <- p[remove_p]
	q_nozero <- q[remove_p]

	sum(p_nozero * log(p_nozero/q_nozero))
}


# Calculate the Shannon diversity index
get_shannon <- function(x) {
	non_zero <- x %>% subset(. > 0)
	-sum(non_zero * log(non_zero))
}


# This is the driver function, which takes in a file name for a pruned and non-pruned data frame,
# which was generated from a mothur-formatted shared file. This function outputs a tibble that
# includes the RNG seed, the level of pruning, the number of sequences with and without pruning,
# the Shannon diversity index with and without pruning, the D_kl divergence between the pruned and
# non-pruned data, the Spearman correlation coefficient between the pruned and non-pruned data, and
# the number of sequences removed by pruning
compare_pruning <- function(no_pruned_shared_tbl, pruned_shared_file){
# do full_join because assumes arguement of summation is 0 if P(x) = 0
  full_join(no_pruned_shared_tbl, read_shared(pruned_shared_file),
  							by=c("group", "otu"),
                suffix=c(".no", ".yes")) %>%
    mutate(count.no = replace_na(count.no, 0),
						count.yes = replace_na(count.yes, 0)) %>%
   	group_by(group) %>%
    mutate(rel_abund.no = count.no / sum(count.no),
           rel_abund.yes = count.yes / sum(count.yes)) %>%
  	nest() %>%
  	mutate(n_seqs.no = map(data, ~sum(.x$count.no)),
  	      n_seqs.yes = map(data, ~sum(.x$count.yes)),
  				h.no = map(data, ~get_shannon(.x$rel_abund.no)),
  				h.yes = map(data, ~get_shannon(.x$rel_abund.yes)),
  				d_kl = map(data, ~get_kl_divergence(.x$rel_abund.yes, .x$rel_abund.no)),
  				spearman = map(data, ~cor(.x$rel_abund.no, .x$rel_abund.yes, method="spearman"))) %>%
  	select(-data) %>%
    unnest() %>%
    mutate(count_diff = n_seqs.no - n_seqs.yes,
           min_class = str_replace(pruned_shared_file, ".*\\.(\\d{1,2})\\.\\D*", "\\1"),
           seed = ifelse(str_detect(pruned_shared_file, "oshared"), NA, str_replace(pruned_shared_file, "\\D*\\.(\\d{1,2})\\..*", "\\1"))) %>%
    select(group, seed, min_class, everything())
}




# Stuff that runs the script. We take in the directory, the stub that indicates whether the data
# come from PC or OTU data and whether this was a pruned dataset or a randomized and pruded dataset.
# The output is a concatenated set of tibbles for each seed/pruning level.

input <- commandArgs(trailingOnly=TRUE)
output <- input[1] # e.g. output <- 'data/bioethanol/data.otu.rintra_analysis'

path <- str_replace(output, "(.*)\\/.*", "\\1")
pattern <- str_replace(output, ".*\\.(\\w{2,3}\\..)intra_analysis", "\\1shared")
shared_files <- list.files(path, pattern=pattern, full.names = TRUE)

# we'll read in the reference shared files first and then come back to read in the pruned shared
# data as needed
no_pruned_tbl <- str_replace(shared_files, "(.*)\\.\\d*\\.(\\D*)", "\\1.1.\\2") %>%
  unique() %>%
  map(., read_shared)

# The initial tibble that we generate indicates the name of the pruned and corresponding non-pruned
# mothur-formatted shared files and an index that we can use for grouping the files to run the
# analysis. The concatenated tibble is outputted as a file whose name ends in 'intra_analysis'

tibble(pruned=str_subset(shared_files, ".*\\.1\\.\\D+", negate=T),
       no_pruned_index=ifelse(str_detect(pruned, "oshared"),
                              1,
                              str_replace(pruned, ".*\\.(\\d*)\\.\\d*\\.\\D*", "\\1") %>% as.integer()),
       index=seq(1,length(pruned))) %>%
  group_by(index) %>%
  nest() %>%
  mutate(consolidated = map(data, ~compare_pruning(no_pruned_tbl[[.x$no_pruned_index]], .x$pruned))) %>%
  select(consolidated) %>%
  unnest() %>%
  write_tsv(output)
