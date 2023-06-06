#!/usr/bin/env Rscript

library(data.table) # for fast reads of wide files
library(tidyverse)
library(glue)

frac_asvs <- 0.10
increase <- 1.05

input <- commandArgs(trailingOnly = TRUE)

obs_pc_shared_file <- input[1]
rng_seed <- input[2]

# obs_pc_shared_file <- "data/marine/observed.pc.shared"
# rng_seed <- 1

set.seed(rng_seed)

output_shared_file <- str_replace(obs_pc_shared_file, 
                                  "observed",
                                  glue("effect.{rng_seed}"))

output_design_file <- str_replace(output_shared_file, 
                                  "pc.shared",
                                  "design")

observed_tidy <- fread(obs_pc_shared_file) %>%
  select(Group, starts_with("ASV")) %>%
  pivot_longer(-Group, names_to = "asvs", values_to = "count") %>%
  filter(count != 0)

sample_counts_treatment <- observed_tidy %>%
  group_by(Group) %>%
  summarize(count = sum(count)) %>%
  mutate(treatment = sample(rep(c("A", "B"), length.out = nrow(.))))


null_distro <- observed_tidy %>%
  group_by(asvs) %>%
  summarize(count = sum(count)) %>%
  mutate(probability = count / sum(count)) %>%
  select(asvs, probability)

n_asvs <- nrow(null_distro)
n_change <- floor(frac_asvs * n_asvs)

effect_distro <- null_distro %>%
  mutate(change = c(rep(TRUE, n_change), rep(FALSE, n_asvs - n_change)),
         change = sample(change),
         probability = if_else(change, probability * increase, probability)) %>%
  select(asvs, probability)


sample_counts_treatment %>%
  nest(data = -Group) %>%
  mutate(asvs = map(.x = data,
                      ~if (.x$treatment == "A") {
                        sample(null_distro$asvs, .x$count,
                               replace = TRUE, prob = null_distro$probability)
                      } else {
                        sample(effect_distro$asvs, .x$count,
                               replace = TRUE, prob = effect_distro$probability)
                      }
                    ))    %>%
  select(Group, asvs) %>%
  unnest(asvs) %>%
  count(Group, asvs) %>%
  pivot_wider(names_from = asvs, values_from = n, values_fill = 0) %>%
  mutate(label = "pc",
         numASVs = ncol(.) - 1) %>%
  select(label, Group, numASVs, everything()) %>%
  write_tsv(output_shared_file)

sample_counts_treatment %>%
  select(group = Group, treatment) %>%
  write_tsv(output_design_file)