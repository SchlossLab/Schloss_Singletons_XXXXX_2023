library(tidyverse)
library(data.table)

input <- commandArgs(trailingOnly=TRUE)
pc_mapping_file <- input[1] # e.g. pc_mapping_file <- 'data/bioethanol/data.1.1.effect_pruned_groups'
count_file <- str_replace(pc_mapping_file, "([^.])[^.]*_pruned_groups", "pc.\\1temp_count")

# read in the mapping file and generate column names that are formatted like Otu0001, Otu0002, etc.
# and then join these back into the original dataframe and spread the columns and format to be
# mothur compatible

shared <- fread(pc_mapping_file)
shared <- dcast(shared, sequences~group, value.var="n_seqs", fill = 0)
shared$total <- apply(shared[,-1], 1, sum)
setcolorder(shared, c("sequences", "total"))
write_tsv(shared, count_file)

system(paste0("mothur '#make.shared(count=", count_file, ", label=pc)'"))

unlink(str_replace(count_file, "temp_count", "map"))
unlink(count_file)
file.rename(str_replace(count_file, ".temp_count", "shared"), str_replace(count_file, "temp_count", "shared"))
