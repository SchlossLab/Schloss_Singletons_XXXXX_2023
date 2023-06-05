# This script takes in a phylip-formatted distance matrix and converts it to a three column format,
# which is then outputted as a beta_diversity tsv

library(stringr)

d_matrix_filename <- commandArgs(trailingOnly=TRUE)	#d_matrix_filename <- "data.1.1.otu.rbeta_matrix"
d_diversity_filename <- str_replace(d_matrix_filename, "matrix", "diversity")

d_matrix <- scan(d_matrix_filename, sep="", what=character(), quiet=TRUE)

n_seqs <- as.numeric(d_matrix[1])
d_matrix <- d_matrix[-1]

sample_indices <- c(1, rep(0,(n_seqs-1)))
for(i in 1:(n_seqs-1)){
	sample_indices[i+1] <- sample_indices[i] + i
}

samples <- d_matrix[ sample_indices ]
d_matrix <- d_matrix[-sample_indices ]
d_diversity <- data.frame(row=NA, column=NA, distance=NA)

counter <- 1
for(i in 2:n_seqs){
	for(j in 1:(i-1)){
		d_diversity[counter,] <- c(row=samples[i], column=samples[j], distance=d_matrix[counter])
		counter <- counter+1
	}
}

write.table(d_diversity, file=d_diversity_filename, row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")
