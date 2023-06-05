library(tidyverse)
library(data.table)

input <- commandArgs(trailingOnly=TRUE)
path <- input[1] # e.g. path <- 'data/mice/'
seed <- as.numeric(input[2]) # e.g. seed <- 1
min_class <- as.numeric(input[3]) # e.g. min_class <- 2
fraction <- as.numeric(input[4]) # e.g. fraction <- 0.9

set.seed(seed)	#	set the random number generator seed so multiple runs generate the same
								#	randomization


#	Here we read in the count_table, clean it up a bit, gather it, and remove those sequence/samples
# combinations that are zero.
orig_count <- fread(paste0(path, "/data.count_table"), colClasses=c(Representative_Sequence="character")) %>%
	melt(id.vars=c("Representative_Sequence"), variable.name="group", variable.factor=F, value.name="n_seqs") %>%
  filter(group != "total") %>%
	rename(sequences=Representative_Sequence) %>%
	filter(n_seqs != 0)

# If there are groups that need to be removed (see data.remove_accnos) then let's remove them...
remove_groups <- scan(paste0(path, "/data.remove_accnos"), what="character", sep="-", quiet=TRUE)

if(length(remove_groups) > 0){
  orig_count <- orig_count %>% filter(!group %in% remove_groups)
}


full_dataset <- orig_count %>% group_by(sequences) %>% summarize(n_seqs = sum(n_seqs))
sub_dataset <- sample_frac(full_dataset, fraction)

# full_join(full_dataset, sub_dataset, by="sequences") %>%
# 	mutate(n_seqs.y = replace_na(n_seqs.y, 0),
# 				rel_abund.x =n_seqs.x/sum(n_seqs.x),
# 				rel_abund.y = n_seqs.y/sum(n_seqs.y)
# 			) %>%
# 	group_by(sequences) %>%
# 	mutate(min_rel_abund = min(rel_abund.x, rel_abund.y)) %>%
# 	ungroup() %>%
# 	summarize(shannon.x = -sum(rel_abund.x * log(rel_abund.x)),
# 						shannon.y = -sum(rel_abund.y * ifelse(rel_abund.y != 0, log(rel_abund.y), 0)),
# 						richness.x = sum(n_seqs.x != 0),
# 						richness.y = sum(n_seqs.y != 0),
# 						bc = 1-sum(min_rel_abund)
# 					)


# Get the number of sequences per group, randomize the order of the groups, and assign each sample
# to a different grouping variable for statistical testing
group_order_count <-
	orig_count %>%
	group_by(group) %>%
	summarize(N=sum(n_seqs)) %>%
	ungroup() %>%
	sample_frac(.) %>%
	mutate(grouping = rep(c("A", "B"), length.out=nrow(.)))


# A will be the full dataset and B will be the reduced diversity dataset
a <- group_order_count %>% filter(grouping == "A")
b <- group_order_count %>% filter(grouping == "B")

a_sequences <- rep(full_dataset$sequences, full_dataset$n_seqs) %>% sample(., sum(a$N), replace=T)
a_groups <- rep(a$group, a$N)

b_sequences <- rep(sub_dataset$sequences, sub_dataset$n_seqs) %>% sample(., sum(b$N), replace=T)
b_groups <- rep(b$group, b$N)


# Here we unroll the sample and sequence names according to the value in n_seqs. We then shuffle
# the order of the groups and reaggregate the sequences by groups and count their frequency in the
# randomized grouping. This is outputted as a three column matrix that can later be converted into
# a shared file
randomize_prune_count <-
	tibble(group = c(a_groups, b_groups),
		sequences = c(a_sequences, b_sequences)) %>%
	group_by(group, sequences) %>%
	summarize(n_seqs = n()) %>%
	ungroup() %>%
	filter(n_seqs >= min_class) %>%
	write_tsv(paste0(path, "/data.", seed, ".", min_class, ".effect_pruned_groups"))


# Output design file
group_order_count %>% select(group, grouping) %>% write_tsv(paste0(path, "/data.", seed, ".", min_class, ".edesign"), col_names=F)
