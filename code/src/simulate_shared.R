
# read in a mothur shared file and convert it to a data frame
# where the rows are the samples and the columns are the otus.
# the values are the number of times each otu was seen in a
# sample
read_shared <- function(shared_file_name){
	raw_shared <- read.table(file=shared_file_name, header=T, row.names=2)
	raw_shared[,-c(1,2)]
}


# get a vector of counts that indicates the number of times each
# otu was seen across all samples
pool_samples <- function(shared_data){
	unname(apply(shared_data, 2, sum))
}


# get a vector that indicates the number of observations that
# were generated for each sample
get_sample_frequencies <- function(shared_data){
	unname(apply(shared_data, 1, sum))
}


# given a vector of otu counts, unroll the vector and shuffle
# the order that the sequences were observed. shuffling is done
# without replacement
shuffle_seqs <- function(otu_counts){
	n_otus <- length(otu_counts)
	otu_vector <- rep(1:n_otus, otu_counts)
	n_seqs <- length(otu_vector)
	sample(otu_vector, n_seqs)
}


# generate a null matrix where the number of observations
# (smaple_counts) and a model distribution (otu_counts) are
# specified by the user
shuffle_seqs_samples <- function(otu_counts, sample_counts){
	n_samples <- length(sample_counts)
	shuffled <- factor(shuffle_seqs(otu_counts))
	sample_ids <- factor(rep(1:n_samples, sample_counts))
	assigned_to_samples <- split(shuffled, sample_ids)
	sequence_list <- lapply(assigned_to_samples, table)
	list(matrix(unlist(sequence_list), nrow=n_samples, byrow=T))
}


# this pretty much puts everything together. given a shared file
# generate N (iterations) randomly shuffled matrices that have
# the same row and column sums
shuffle_shared_file <- function(shared_file_name, iterations=1){
	shared <- read_shared(shared_file_name)
	sample_counts <- get_sample_frequencies(shared)
	otu_counts <- pool_samples(shared)

	shared_shuffle <- replicate(iterations, shuffle_seqs_samples(otu_counts, sample_counts))

	if(length(shared_shuffle) == 1){
		shared_shuffle <- shared_shuffle[[1]]
	}
	shared_shuffle
}


# given a vector of OTU counts, subsample the vector to a desired
# number of sequences. Keeps zero-ton OTUs in place. If the desired
# number of sequences is less than the total number of sequences a
# NA is returned
subsample_counts <- function(rabund, subsample_to){
	n_seqs <- sum(rabund)

	if(n_seqs < subsample_to){
		return(NA)
	}

	n_otus <- length(rabund)
	unrolled_otus <- factor(rep(1:n_otus, rabund), levels=1:n_otus)
	table(sample(unrolled_otus, subsample_to))
}


# given a shared file, subsample each sample to a given level of
# sampling depth. if subsmaple_to is greater than the number of
# sequences for that sample, warn and toss the sample.
subsample_table <- function(shared, subsample_to){
	subsampling <- apply(shared, 1, subsample_counts, subsample_to)
	if(class(subsampling) == "list"){
		subsampling <- subsampling[!is.na(subsampling)]
		n_samples <- length(subsampling)
		subsampling <- matrix(unlist(subsampling), nrow=n_samples, byrow=T)
	} else {
		subsampling <- t(subsampling)
	}
	subsampling
}


# given a shared file remove any OTUs where their total abundance
# across all samples is less than a threshold (min_nton)
remove_rare <- function(shared, min_nton){
	counts <- pool_samples(shared)
	shared[, counts >= min_nton]
}


#Alpha and Beta diversity calculations

# Calculate shannon diversity index from rank-abundance data
get_shannon <- function(x){
	x <- x[x!=0]
	rel_abund <- x / sum(x)
	-1 * sum(rel_abund * log(rel_abund))
}


# Given two vectors that are the same length return the Bray-Curtis
# distance between them
get_bray_curtis <- function(x,y){
	x <- unlist(x)
	y <- unlist(y)
	stopifnot(length(x) == length(y))
	numerator <- sum(pmin(x,y))
	denominator <- sum(x,y)
	1 - 2 * numerator / denominator
}


# Given a shared file, calculate the average distance between samples
# and their standard deviation. Will only get unique sample comparisons
get_bc_summary <- function(shared){
	n_samples <- nrow(shared)

	comparisons <- expand.grid(x=1:n_samples, y=1:n_samples)
	comparisons <- comparisons[comparisons$x < comparisons$y, ]
	n_comparisons <- nrow(comparisons)

	bc <- apply(comparisons, 1, function(x)get_bray_curtis(shared[x[1],],shared[x[2],]))

	c(mean=mean(bc), sd=sd(bc))
}


# Given a shared file, calculate the average and sd for the number of
# observed OTUs
get_sobs_summary <- function(shared){
	present <- shared > 0
	sobs <- apply(present, 1, sum)
	c(mean=mean(sobs), sd=sd(sobs))
}


# Given a shared file, calculate the average and sd for the Shannon
# diversity index
get_shannon_summary <- function(shared){
	shannon <- apply(shared, 1, get_shannon)
	c(mean=mean(shannon), sd=sd(shannon))
}
