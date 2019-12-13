library(tidyverse)
library(data.table)

datasets <- c("bioethanol", "human", "lake", "marine", "mice", "peromyscus", "rainforest", "rice",
	"seagrass", "sediment", "soil", "stream")

get_shannon <- function(x) {

	r_abund <- x / sum(x)

	-1 * sum(r_abund * log(r_abund))

}


get_coverage <- function(test_sample, all_counts, min_freq = 1){

	sample_ntons <- all_counts %>%
		filter(sample == test_sample, n_seqs == min_freq) %>%
		select(sequences)

	all_counts %>%
		filter(sample != test_sample) %>%
		anti_join(sample_ntons, ., by="sequences") %>%
		summarize(coverage = ifelse(nrow(sample_ntons) != 0, 1 - nrow(.) / nrow(sample_ntons), 0))

}


get_singleton_coverage <- function(dataset){

	print(dataset)

	count_data <- paste0("data/", dataset, "/data.count_table") %>%
		fread(., colClasses=c(Representative_Sequence="character")) %>%
		melt(id.vars=c("Representative_Sequence"), variable.name="sample", variable.factor=F, value.name="n_seqs") %>%
		filter(sample != "total") %>%
		rename(sequences=Representative_Sequence) %>%
		filter(n_seqs != 0)

	count_data %>%
		group_by(sample) %>%
		nest() %>%
		mutate(coverage_1 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=1)),
					coverage_2 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=2)),
					coverage_3 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=3)),
					coverage_4 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=4)),
					coverage_5 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=5)),
					coverage_6 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=6)),
					coverage_7 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=7)),
					coverage_8 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=8)),
					coverage_9 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=9)),
					coverage_10 = map(sample, ~get_coverage(., all_counts = count_data, min_freq=10)),
					shannon = map(data, ~get_shannon(.x$n_seqs)),
					n = map(data, ~sum(.x$n_seqs))) %>%
		select(sample, starts_with("coverage"), n, shannon) %>%
		ungroup() %>%
		pivot_longer(starts_with("coverage"), names_to="min_freq", values_to="coverage") %>%
		unnest(cols=c(n, shannon, coverage)) %>%
		mutate(dataset = dataset,
					min_freq = str_replace(min_freq, "coverage_", "")) %>%
		select(dataset, sample, everything())
}

map_df(datasets, get_singleton_coverage) %>%
	write_tsv('data/process/sequence_coverage_table_raw.tsv')
