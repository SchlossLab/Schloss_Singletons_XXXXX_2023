library(tidyverse)
library(data.table)

input <- commandArgs(trailingOnly=TRUE)
pc_mapping_file <- input[1] # e.g. pc_mapping_file <- 'data/bioethanol/data.1.10.rand_pruned_groups'
shared_file <- str_replace(pc_mapping_file, "([^.])[^.]*_pruned_groups", "pc.rshared")

# read in the mapping file and generate column names that are formatted like Otu0001, Otu0002, etc.
# and then join these back into the original dataframe and spread the columns and format to be
# mothur compatible

shared <- fread(pc_mapping_file)
shared <- dcast(shared, group~otu, value.var="n_seqs", fill = 0)
shared$numOtus <- ncol(shared) - 1
shared$label <- "pc"
setcolorder(shared, c("label", "group", "numOtus"))
setnames(shared, "group", "Group")

write_tsv(shared, shared_file)
