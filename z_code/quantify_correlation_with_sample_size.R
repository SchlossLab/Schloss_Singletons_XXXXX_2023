library(tidyverse)
library(broom)

input <- commandArgs(trailingOnly=TRUE)
input_file <- input[1] # e.g. input_file <- "data/process/sequence_loss_table_raw.tsv"

output_file <- str_replace(input_file, "raw", "cor")

read_tsv(input_file) %>%
	group_by(dataset, freq_removed) %>%
	nest() %>%
	mutate(cor_n = map(data, ~tidy(cor.test(.x$n, .x[[4]], method="spearman", exact=F))),
				cor_shannon = map(data, ~tidy(cor.test(.x$shannon, .x[[4]], method="spearman", exact=F))),
				cor_nshannon = map(data, ~tidy(cor.test(.x$shannon, .x$n, method="spearman", exact=F)))
		) %>%
	select(dataset, freq_removed, cor_n, cor_shannon, cor_nshannon) %>%
	ungroup() %>%
	unnest(c(cor_n, cor_shannon, cor_nshannon), names_sep="_") %>%
	select(dataset, freq_removed,
					cor_n_estimate, cor_n_p.value,
					cor_shannon_estimate, cor_shannon_p.value,
					cor_nshannon_estimate, cor_nshannon_p.value) %>%
	write_tsv(output_file)
