library(tidyverse)

data_sets <- c("bioethanol", "human", "lake", "marine", "mice", "rainforest", "rice", "seagrass", "sediment", "soil", "stream")

dataset <- "bioethanol"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 3600) %>% pull(group) %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "human"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 10000) %>% pull(group) %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "lake"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 10000) %>% pull(group) %>% paste0(., collapse='-') %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "marine"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 3600) %>% pull(group) %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "mice"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 1800) %>% pull(group) %>% paste0(., collapse='-') %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "rainforest"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 3600) %>% pull(group) %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "rice"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 2500) %>% pull(group) %>% paste0(., collapse='-') %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "seagrass"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 1800) %>% pull(group) %>% paste0(., collapse='-') %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "sediment"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 7000) %>% pull(group) %>% paste0(., collapse='-') %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "soil"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 3600) %>% pull(group) %>% write(paste0("data/", dataset, "/data.remove_accnos"))

dataset <- "stream"
read_tsv(paste0("data/", dataset, "/data.count.summary"), col_names=c("group", "n_seqs")) %>% filter(n_seqs < 3600) %>% pull(group) %>% write(paste0("data/", dataset, "/data.remove_accnos"))
