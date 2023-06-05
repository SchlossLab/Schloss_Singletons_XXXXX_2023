library(tidyverse)
library(broom)

input <- commandArgs(trailingOnly=TRUE)
alpha_files <- input[-length(input)]
# source("code/alpha.R")
# alpha_files <- list.files('data/bioethanol', pattern="ealpha_diversity", full.names=T)

#take outputfile name from command line
output_file_name <- input[length(input)]
# output_file_name <- paste0(dirname(alpha_files[1]), "/data.effect.alpha_summary")


get_summary <- function(alpha_file){

  sim_type <- str_replace(alpha_file, ".*\\.(.)alpha_diversity", "\\1")
  design_file <- str_replace(alpha_file, "[^.]*\\..alpha_diversity", paste0(sim_type, "design"))

  seed <- str_replace(alpha_file, ".*/data\\.(\\d*)\\..*", "\\1") %>% as.integer()
  prune <- str_replace(alpha_file, ".*/data\\.\\d*\\.(\\d*).*", "\\1") %>% as.integer()
  clustering <- str_replace(alpha_file, ".*/data\\.\\d*\\.\\d*\\.(.*)\\..alpha_diversity", "\\1")

  read_tsv(alpha_file,
          col_types=cols(label=col_character(), group=col_character(), method=col_character())) %>%
    filter(method == "ave") %>%
    select(group, sobs, shannon, invsimpson) %>%
    inner_join(.,
              read_tsv(design_file, col_names=c("group", "grouping"), col_types="cc"),
              by="group") %>%
    gather(sobs, shannon, invsimpson, key="metric", value="value") %>%
    group_by(metric) %>%
    nest() %>%
    mutate(test = map(data, ~tidy(wilcox.test(.x$value~.x$grouping, exact=FALSE))),
          median_A = map(data, ~.x %>% filter(grouping=="A") %>% summarize(median_A=median(value))),
          median_B = map(data, ~.x %>% filter(grouping=="B") %>% summarize(median_B=median(value))),
        ) %>%
    select(metric, median_A, median_B, test) %>%
    unnest(c(median_A, median_B, test)) %>%
    mutate(seed = seed, prune=prune, method=clustering) %>%
    select(prune, seed, method, metric, median_A, median_B, p.value)

}


map_df(alpha_files, get_summary) %>%
  mutate(sig = p.value < 0.05) %>%
  group_by(method, metric, prune) %>%
  summarize(frac_sig = mean(sig)) %>%
  ungroup() %>%
  write_tsv(output_file_name)

