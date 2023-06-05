# This script reads in a pruned shared file that was generated from preclustered data (e.g.
# data.1.pc.prune_shared), the mapping file between the OTU and sequence names generated from the
# pc shared file, and the mapping file between the OTU assignments and their constituent sequences
# as generated from cluster.split. It then takes the pruned pc data and figures out which sequences
# and abundances go in each OTU according to the cluster.split clustering. The output is a mothur
# compatible shared file.
#
# Expected input:
#		* A pruned shared file based on output from preclustered data
#		* A mapping file between the OTUs generated from pre.cluster data and the sequence names
#		* A mapping file between the OTUs generated from cluster.split and the sequence names
#	Output: A file named data.min_class.otu.prune_shared that is deposited in the same directory
# 	as the input files


library(data.table) # for fast reads of wide files
library(tidyverse)

input <- commandArgs(trailingOnly=TRUE)
pc_shared_file <- input[1] # e.g. pc_shared_file <- 'data/bioethanol/data.1.pc.oshared'
pc_mapping_file <- input[2] # e.g. pc_mapping_file <- 'data/bioethanol/data.pc_seq.map'
otu_mapping_file <- input[3] # e.g. otu_mapping_file <- 'data/bioethanol/data.otu_seq.map'

otu_shared_file <- str_replace(pc_shared_file, "pc", "otu")

if(str_detect(pc_shared_file, "data.1.pc")){

	file.copy(str_replace(otu_shared_file, "data.1.otu.oshared", "data.otu.shared"), otu_shared_file, overwrite=TRUE)

} else {
	# load the shared file generated using output from pre.cluster and make it tidy
	group_seq_counts <- fread(pc_shared_file) %>%
												as_tibble() %>% select(-label, -numOtus) %>%
												gather(-Group, key="otus", value="counts") %>%
												filter(counts != 0)

	# load the mapping file that indicates which sequence goes with each OTU from the pre.cluster output
	pc_seq_otu_mapping <- read_tsv(pc_mapping_file,
																col_names=c("sequences", "otus"),
																col_types=cols(.default=col_character()))

	# load the mapping file that indicates which sequence goes with each OTU from cluster.split output
	otu_seq_otu_mapping <- read_tsv(otu_mapping_file,
																	col_types=cols(.default=col_character()))


	# Here we do a series of joins to prune the cluster.split OTU assignments and generate a shared
	# file. First we convert the pre.clustered OTU names back to their original sequence names. Second,
	# we do an inner join to identify which OTUs the remaining sequence names belong to. Third, we
	# format the tibble to look like a mothur shared file. Finally, we output the pruned shared file.
	inner_join(group_seq_counts, pc_seq_otu_mapping, by="otus") %>%
		select(-otus) %>%
		inner_join(., otu_seq_otu_mapping, by="sequences") %>%
		group_by(otus, Group) %>%
		summarize(counts = sum(counts)) %>%
		ungroup() %>%
		spread(otus, counts, fill=0) %>%
		mutate(numOtus = ncol(.)-1, label=0.03) %>%
		select(label, Group, numOtus, everything()) %>%
		write_tsv(otu_shared_file)
}
