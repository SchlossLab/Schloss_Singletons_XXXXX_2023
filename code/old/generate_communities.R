library("tidyverse")

shared_file_name <- "data/raw/crc.shared"

# read in a mothur shared file and convert it to a data frame
# where the rows are the samples and the columns are the otus.
# the values are the number of times each otu was seen in a
# sample
read_shared <- function(shared_file_name){
	read_tsv(file=shared_file_name, col_types=cols(Group=col_character())) %>%
								select(Group, starts_with("Otu")) %>%
								rename_all(tolower)
}


get_sampling_depths <- function(shared){

	shared %>%
		gather(-group, key="otu", value="count") %>%
		group_by(group) %>%
		summarize(n_seqs=sum(count)) %>%
		select(group, n_seqs)

}


get_sequence_distribution <- function(shared){

	shared %>%
		gather(-group, key="otu", value="count") %>%
		group_by(otu) %>%
		summarize(n_seqs=sum(count)) %>%
		select(otu, n_seqs)

}


sample_distribution <- function(n, unrolled_distribution, with_replacement=TRUE){
	#table or summary or group_by?
	table(sample(unrolled_distribution, n, replace=with_replacement))

}


generate_null_shared <- function(sequence_distribution){

	unrolled <- factor(rep(sequence_distribution$otu, sequence_distribution$n_seqs))

	sampling_depths %>%
			nest(-group) %>%
			mutate(new_col = map(data, ~
			                      .x %>%
			                        pull(n_seqs) %>%
															sample_distribution(., unrolled_distribution=unrolled) %>%
			                        as.list %>%
			                        as_tibble))  %>%
			select(-data) %>%
			unnest %>%
			mutate(label=rep("0.03", nrow(.)), numOtus=rep(ncol(.)-1, nrow(.))) %>%
			select(label, group, numOtus, everything())
}


remove_rare <- function(shared, threshold=1){

	shared %>%
		gather(starts_with('otu'), key='otu', value='count') %>%
		filter(count > threshold) %>%
		spread(otu, count, fill=0) %>%
		mutate_if(is.numeric, as.integer) %>%
		mutate(numOtus = rep(ncol(.)-3, nrow(.)))

}

shared <- read_shared(shared_file_name)
sampling_depths <- get_sampling_depths(shared)
sequence_distribution <- get_sequence_distribution(shared)
null_shared <- generate_null_shared(sequence_distribution)
no_rare_null_shared <- remove_rare(null_shared)

write_tsv(null_shared, "random.shared")
write_tsv(no_rare_null_shared, "random_no_rare.shared")

mothur "#dist.shared(shared=random.shared, calc=braycurtis, subsample=T, iters=100)"
mothur "#dist.shared(shared=random_no_rare.shared, calc=braycurtis, subsample=T, iters=100)"
mothur "#dist.shared(shared=random.shared, calc=braycurtis, subsample=F)"
mothur "#dist.shared(shared=random_no_rare.shared, calc=braycurtis, subsample=F)"

mothur "#dist.shared(shared=random.shared, calc=thetayc, subsample=T, iters=100)"
mothur "#dist.shared(shared=random_no_rare.shared, calc=thetayc, subsample=T, iters=100)"
mothur "#dist.shared(shared=random.shared, calc=thetayc, subsample=F)"
mothur "#dist.shared(shared=random_no_rare.shared, calc=thetayc, subsample=F)"
