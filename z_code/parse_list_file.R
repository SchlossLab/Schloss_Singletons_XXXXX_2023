library(tidyverse)

input <- commandArgs(trailingOnly=TRUE)
path <- input[1] # e.g. path <- 'data/bioethanol/'

list_file_name <- paste0(path, "/data.otu.list")  # generate input list file name
list_file <- scan(list_file_name, what="character", quiet=TRUE) # read in the list file

# This pipeline parses the long list_file vector into a data frame where the first column is the
# OTU name and the seond column contains the names of the sequences in each OTU separated by commas
list_data <- tibble(otus = list_file[1:(length(list_file) / 2)],
                    seq_list = list_file[((length(list_file) / 2)+1):length(list_file)]) %>%
              filter(str_detect(otus, "^Otu")) %>%
							group_by(otus) %>%
							nest() %>%
							mutate(sequences = map(data, ~as.vector(str_split(.x$seq_list, ",", simplify=TRUE)))) %>%
 							select(otus, sequences) %>% unnest() %>%
							write_tsv(paste0(path, "/data.otu_seq.map"))

