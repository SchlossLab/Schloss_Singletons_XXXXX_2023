# This script reads in a file ending in rand_pruned_groups, which contains three columns indicating
# the sequence name, the group it came from, and the nubmer of sequences that sequence represents
# for that group. It should be a randomized and pruned version of data from original count file.
# It also expects a file that indicates which cluster.split-generated OTU each sequence belongs to.
# It builds a mothur-compatible shared file that indicates the frequency of each OTU in each sample
# from the data that were randomized across samples and then pruned.
#
# Expected input:
#		*	A mapping file that indicates the number of sequences represented by a preclustered sequence
#			in each sample/group
#		* A mapping file that indicates which cluster.split-generated OTU each sequence belongs to
#	Output: A mothur-compatible file ending in otu.shared that is deposited in the same
# directory as the input files

library(tidyverse)

input <- commandArgs(trailingOnly=TRUE)
rand_pruned_file <- input[1] #e.g. rand_pruned_file <-'data/bioethanol/data.1.1.effect_pruned_groups'
otu_mapping_file <- input[2] #e.g. otu_mapping_file <- 'data/bioethanol/data.otu_seq.map'

shared_file <- str_replace(rand_pruned_file, "([^.])[^.]*_pruned_groups", "otu.\\1shared")


# load the mapping file that indicates the number of times each pre-clustered sequence showed up in
# each sample
group_seqs_count_mapping <- read_tsv(rand_pruned_file,
																	col_types=cols(group=col_character(), sequences=col_character()))

#	load the mapping file that indicates which sequence goes with each OTU from cluster.split output
otu_seq_otu_mapping <- read_tsv(otu_mapping_file,
																col_types=cols(.default=col_character()))


# Here we do an inner join to identify which OTUs the shuffled and preclustreed pre.clustered
# sequence names and counts belong to. We then format the tibble to look like a mothur shared file.
# Finally, we output the pruned shared file.
inner_join(group_seqs_count_mapping, otu_seq_otu_mapping, by="sequences") %>%
	group_by(otus, group) %>%
	summarize(counts = sum(n_seqs)) %>%
	ungroup() %>%
	spread(otus, counts, fill=0) %>%
	mutate(numOtus = ncol(.)-1, label=0.03) %>%
	rename(Group=group) %>%
	select(label, Group, numOtus, everything()) %>%
	write_tsv(shared_file)
