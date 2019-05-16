# This script reads in data.pc.shared from the user specified directory set in 'path'. It then
# It then applies a pruning step by removing those reads whose frequency is below the user
# specified value set as 'min_class'. Finally, it outputs a mothur-formatted shared file with the
# extension prune_shared to indicate that it is a shared file that has been pruned.
#
# Expected input: A directory (e.g. data/bioethanol/) that contains a file named data.pc.shared
#	Output: A file named data.min_class.pc.prune_shared that is deposited in the directory
# indicated by path

library(data.table) # for fast reads of wide files
library(tidyverse)

input <- commandArgs(trailingOnly=TRUE)
path <- input[1] # e.g. path <- 'data/bioethanol/'
min_class <- as.numeric(input[2]) # e.g. min_class <- 2

input_file <- paste0(path, "/data.pc.shared")
output_file <- paste0(path, "/data.", min_class, ".pc.oshared")

# Here we read in the data.pc.shared file using fread (for speed) and we make the data frame tidy
# so that we can easily filter the group/otu combinations for those otus that are at or above the
# value of min_class. Finally, we spread the data back out and format it to be a mothur-compatible
# shared file with the extension prune_shared

if(min_class == 1){

	file.copy(input_file, output_file)

} else {

	fread(input_file) %>%
		as_tibble() %>%
		select(-label, -numOtus) %>%
		gather(-Group, key="otus", value="counts") %>%
		filter(counts >= min_class) %>%
		spread(otus, counts, fill = 0) %>%
		mutate(numOtus = ncol(.) -1,
						label="pc") %>%
		select(label, Group, numOtus, everything()) %>%
		write_tsv(output_file)
}
