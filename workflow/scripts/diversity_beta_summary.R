#!/usr/bin/env Rscript

# This script takes the directory where the data are located along with an
# indication of whether the data are from preclustering or OTUs and whether the
# data have been pruned or randomized and then pruned. Then it will read in the
# beta diversity files and calculate summary statistics by a variety of methods
# to quantify how beta diversity changes with pruning.

library(tidyverse)

get_columns <- function(d_matrix_filename) {

  d_matrix <- scan(d_matrix_filename, sep = "",
                   what = character(),
                   quiet = TRUE)

  n_seqs <- as.numeric(d_matrix[1])
  d_matrix <- d_matrix[-1]

  sample_indices <- c(1, rep(0, (n_seqs - 1)))

  for (i in 1:(n_seqs - 1)){
    sample_indices[i + 1] <- sample_indices[i] + i
  }

  samples <- d_matrix[sample_indices]
  d_matrix <- d_matrix[-sample_indices]
  d_columns <- data.frame(row = NA, column = NA, distance = NA)

  counter <- 1
  for (i in 2:n_seqs){
    for (j in 1:(i - 1)){
      d_columns[counter, ] <- c(row = samples[i],
                                column = samples[j],
                                distance = d_matrix[counter])
      counter <- counter + 1
    }
  }

  return(d_columns)

}

# read in the mothur-formatted output from dist.shared and provide summary
# statistics across all of the samples in the dataset. Also output the seed and
# prune values

get_indiv_beta_diversity <- function(x) {

  parsed_file_name <- str_replace(x, "observed", "observed.1") %>%
    str_split(., "[\\.\\/]") %>%
    unlist()

  get_columns(x) %>%
    mutate(distance = as.numeric(distance)) %>%
    summarize(
      mean = mean(distance), sd = sd(distance), sd_mean = sd/mean,
      median = median(distance), iqr = IQR(distance), iqr_median = iqr/median,
      lci = quantile(distance, probs=0.25), uci = quantile(distance, probs=0.75)
    ) %>%
    mutate(dataset = parsed_file_name[2],
      distribution = parsed_file_name[3],
      seed = parsed_file_name[4],
      pruning_method = parsed_file_name[5],
      pruning_level = parsed_file_name[6],
      resolution = parsed_file_name[7], .before = "mean")

}


input <- commandArgs(trailingOnly = TRUE)
beta_files <- input[-length(input)]

#take outputfile name from command line
output_file_name <- input[length(input)]


beta_files %>%
  map_df(., ~get_indiv_beta_diversity(.)) %>%
  group_by(dataset, distribution, pruning_method, pruning_level, resolution) %>%
  summarize(
    mean = mean(mean), sd = mean(sd), sd_mean = mean(sd_mean),
    median = mean(median), iqr = mean(iqr), iqr_median = mean(iqr_median),
    lci = mean(lci), uci = mean(uci),
    .groups = "drop"
  ) %>%
  write_tsv(output_file_name)
