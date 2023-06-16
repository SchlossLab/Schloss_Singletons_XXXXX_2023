#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)

frac_asvs <- 0.10
increase <- 1.05

input <- commandArgs(trailingOnly = TRUE)

obs_pc_tidy_file <- input[1]
n_replicates <- input[2]

# obs_pc_tidy_file <- "data/marine/observed.pc.tidy"
# n_replicates <- 1

set.seed(19760620)

output_tidy_file <- str_replace(obs_pc_tidy_file,
                                  "observed.*",
                                  "effect.pc.tidy")

output_design_file <- str_replace(obs_pc_tidy_file,
                                  "observed.*",
                                  "effect.design")

observed_tidy <- fread(obs_pc_tidy_file)

sample_counts_treatment <- observed_tidy %>%
  group_by(Group) %>%
  summarize(n = sum(n))

null_distro <- observed_tidy %>%
  group_by(asvs) %>%
  summarize(n = sum(n)) %>%
  mutate(probability = n / sum(n)) %>%
  select(asvs, probability)

n_asvs <- nrow(null_distro)
n_change <- floor(frac_asvs * n_asvs)

effect_distro <- null_distro %>%
  mutate(change = c(rep(TRUE, n_change), rep(FALSE, n_asvs - n_change)),
         change = sample(change),
         probability = if_else(change, probability * increase, probability)) %>%
  select(asvs, probability)

simulate_data <- function() {

  sample_counts_treatment %>%
    mutate(treatment = sample(rep(c("A", "B"), length.out = nrow(.)))) %>%
    nest(data = -Group) %>%
    mutate(asvs = map(.x = data,
                        ~if (.x$treatment == "A") {
                          sample(null_distro$asvs, .x$n, replace = TRUE,
                                prob = null_distro$probability)
                        } else {
                          sample(effect_distro$asvs, .x$n, replace = TRUE,
                                prob = effect_distro$probability)
                        }
                      ))    %>%
    unnest(c(data, data, asvs)) %>%
    count(Group, treatment, asvs) %>%
    select(treatment, Group, everything())

}

simulated_data <- map_dfr(1:n_replicates, ~simulate_data(), .id = "label")

simulated_data %>%
  select(-treatment) %>%
  write_tsv(output_tidy_file)

simulated_data %>%
  select(label, group = Group, treatment) %>%
  distinct() %>%
  write_tsv(output_design_file)
