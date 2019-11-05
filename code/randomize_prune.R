# This script reads in data.count_table from the user specified directory set in 'path'. It then
# randomizes the order of the groups that each sequence belongs to so that every sample still has
# the same number of sequences. The randomization is fiexd by the seed value provided as 'seed'.
# This randomization will effectively build a null distribution of sequences across samples. It
# then applies a pruning step by removing those reads whose frequency is below the user specified
# value set as 'min_class'. Finally, it outputs a three column random_mapping file that indicates
# the sample name, the sequence name, and the number of times that sequence is seen in that sample.
#
# Expected input: A directory (e.g. data/bioethanol/) that contains a file named data.count_table
#   and one named data.remove_accnos
#	Output: A file named data.seed.min_class.random_mapping that is deposited in the directory
#   indicated by path


library(tidyverse)
library(data.table)

input <- commandArgs(trailingOnly=TRUE)
path <- input[1] # e.g. path <- 'data/mice/'
seed <- as.numeric(input[2]) # e.g. seed <- 1
min_class <- as.numeric(input[3]) # e.g. min_class <- 2


set.seed(seed)	#	set the random number generator seed so multiple runs generate the same
								#	randomization


#	Here we read in the count_table, clean it up a bit, gather it, and remove those sequence/samples
# combinations that are zero.
orig_count <- fread(paste0(path, "/data.count_table"),
 										colClasses=c(Representative_Sequence="character")) %>%
  as_tibble() %>%
  select(-total) %>%
	rename(sequences=Representative_Sequence) %>%
	gather(-sequences, key="group", value="n_seqs") %>%
	filter(n_seqs != 0)


# If there are groups that need to be removed (see data.remove_accnos) then let's remove them...
remove_groups <- scan(paste0(path, "/data.remove_accnos"), what="character", sep="-", quiet=TRUE)

if(length(remove_groups) > 0){
  orig_count <- orig_count %>% filter(!group %in% remove_groups)
}


# Here we unroll the sample and sequence names according to the value in n_seqs. We then shuffle
# the order of the groups and reaggregate the sequences by groups and count their frequency in the
# randomized grouping. This is outputted as a three column matrix that can later be converted into
# a shared file
randomize_prune_count <-
	tibble(group = rep(orig_count$group, orig_count$n_seqs),
		sequences = rep(orig_count$sequences, orig_count$n_seqs)) %>%
	mutate(group = sample(group)) %>%
	group_by(group, sequences) %>%
	summarize(n_seqs = n()) %>%
	ungroup() %>%
	filter(n_seqs >= min_class) %>%
	write_tsv(paste0(path, "/data.", seed, ".", min_class, ".rand_pruned_groups"))


# Output randomized design file
orig_count %>%
	select(group) %>%
	unique() %>%
	mutate(grouping = sample(rep(c("A", "B"), length.out=nrow(.)))) %>%
	write_tsv(paste0(path, "/data.", seed, ".", min_class, ".rdesign"), col_names=F)
