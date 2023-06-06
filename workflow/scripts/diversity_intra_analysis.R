#!/usr/bin/env Rscript

# This script takes the directory where the data are located along with an
# indication of whether the data are from preclustering or OTUs and whether the
# data have been pruned or randomized and then pruned. Then it will read in the
# shared files and compare the data to see how the diversity, number of
# sequences, amount of information, and abundances comapre to the unpruned
# dataset.

library(data.table)
library(tidyverse)
library(broom)


# Read in a mothur-formatted shared file and convert it to a tidy data frame 
# with all zeroes removed
read_shared <- function(file_name) {

  fread(file_name) %>%
    melt(id.vars = c(1, 2, 3),
        variable.name = "otu", value.name = "count",
        variable.factor = FALSE) %>%
    select(group = Group, otu, count) %>%
    filter(count > 0)

}


# Calculate the Kullback-Leiler divergence value
# See: https://en.wikipedia.org/wiki/Kullback–Leibler_divergence
# D_KL(P || Q) = assumes P is observed and Q is what we are fitting the observed data to. The value
# indicates the amount of information lost when Q is used to approximate P. It is also called the
# relative entropy of P with respect to Q. In our case we will use P to represent the value of the
# pruned dataset and Q will be the full dataset
get_kl_divergence <- function(p, q){

  remove_p <- p != 0

  p_nozero <- p[remove_p]
  q_nozero <- q[remove_p]

  sum(p_nozero * log(p_nozero / q_nozero))
}


# Calculate the Shannon diversity index
get_shannon <- function(x) {
  non_zero <- x %>% subset(. > 0)
  -sum(non_zero * log(non_zero))
}

# Calculate the richness
get_sobs <- function(x) {
  sum(x > 0)
}

# Calculate the evenness
get_even <- function(h, sobs) {
  h / log(sobs)
}

# This is the driver function, which takes in a file name for a pruned and
# non-pruned data frame, which was generated from a mothur-formatted shared
# file. This function outputs a tibble that includes the RNG seed, the level of
# pruning, the number of sequences with and without pruning, the Shannon
# diversity index with and without pruning, the D_kl divergence between the
# pruned and non-pruned data, the Spearman correlation coefficient between the
# pruned and non-pruned data, and the number of sequences removed by pruning

compare_pruning <- function(no_pruned_shared_tbl, pruned_shared_file){
# do full_join because assumes arguement of summation is 0 if P(x) = 0

  parsed_file_name <- str_replace(pruned_shared_file, "observed", "observed.1") %>%
    str_split(., "[\\.\\/]") %>%
    unlist()

  full_join(no_pruned_shared_tbl, read_shared(pruned_shared_file),
                by = c("group", "otu"),
                suffix = c(".no", ".yes")) %>%
    mutate(count.no = replace_na(count.no, 0),
            count.yes = replace_na(count.yes, 0)) %>%
     group_by(group) %>%
    mutate(rel_abund.no = count.no / sum(count.no),
           rel_abund.yes = count.yes / sum(count.yes)) %>%
    nest() %>%
    mutate(n_seqs.no = map(data, ~sum(.x$count.no)),
          n_seqs.yes = map(data, ~sum(.x$count.yes)),
          sobs.no = map(data, ~get_sobs(.x$rel_abund.no)),
          sobs.yes = map(data, ~get_sobs(.x$rel_abund.yes)),
          h.no = map(data, ~get_shannon(.x$rel_abund.no)),
          h.yes = map(data, ~get_shannon(.x$rel_abund.yes)),
          d_kl = map(data,
                     ~get_kl_divergence(.x$rel_abund.yes, .x$rel_abund.no)),
          spearman = map(data, ~cor(.x$rel_abund.no,
                                    .x$rel_abund.yes,
                                    method = "spearman"))) %>%
    select(-data) %>%
    unnest(cols = c(n_seqs.no, n_seqs.yes,
                    sobs.no, sobs.yes,
                    h.no, h.yes,
                    d_kl, spearman)) %>%
    mutate(dataset = parsed_file_name[2],
      distribution = parsed_file_name[3],
      seed = parsed_file_name[4],
      pruning_method = parsed_file_name[5],
      pruning_level = parsed_file_name[6],
      resolution = parsed_file_name[7],
      even.no = h.no / log(sobs.no),
      even.yes = h.yes / log(sobs.yes),
      count_diff = n_seqs.no - n_seqs.yes) %>%
    select(dataset, distribution, seed, pruning_method, pruning_level,
           resolution, everything())

}


input <- commandArgs(trailingOnly = TRUE)
shared_files <- input[-length(input)]

#take outputfile name from command line
output_file_name <- input[length(input)]

# we'll read in the reference shared files first and then come back to read in
# the pruned shared data as needed
no_pruned_tbl <- str_subset(shared_files, "\\.1\\.[^\\.]+.shared") %>%
  map(~read_shared(.))

names(no_pruned_tbl) <- str_subset(shared_files, "\\.1\\.[^\\.]+.shared")

# The initial tibble that we generate indicates the name of the pruned and
# corresponding non-pruned mothur-formatted shared files and an index that we
# can use for grouping the files to run the analysis. The concatenated tibble
# is outputted as a file whose name ends in 'intra_analysis'

tibble(pruned_file = str_subset(shared_files,
                           "\\.1\\.[^\\.]+.shared",
                           negate = TRUE),
      no_pruned_file = str_replace(pruned_file,
                                   "\\.\\d*\\.([^\\.]+.shared)",
                                   "\\.1\\.\\1"),
      index = seq_along(pruned_file)) %>%
  nest(data = -index) %>%
  mutate(consolidated = map(data,
                            ~compare_pruning(no_pruned_tbl[[.x$no_pruned_file]],
                                             .x$pruned_file))) %>%
  ungroup() %>%
  select(consolidated) %>%
  unnest(consolidated) %>%
  write_tsv(output_file_name)
