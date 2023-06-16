#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

input <- commandArgs(trailingOnly = TRUE)
tidy_file <- input[1] # e.g. tidy_file <- 'data/marine/random.pc.tidy'
min_class <- as.numeric(input[2]) # e.g. min_class <- 2

output_file <- str_replace(tidy_file,
                           ".pc.tidy",
                           glue("\\.indiv_count.{min_class}\\.pc.shared"))

# Here we read in the data.1.pc.{effect}shared file using fread (for speed) and
# we make the data frame tidy so that we can easily filter the group/otu
# combinations for those otus that are at or above the value of min_class.
# Finally, we spread the data back out and format it to be a mothur-compatible
# shared file

fread(tidy_file) %>%
  filter(n >= min_class) %>%
  pivot_wider(names_from = asvs, values_from = n, values_fill = 0) %>%
  mutate(numASVs = ncol(.) - 2, .after = Group) %>%
  write_tsv(output_file)
