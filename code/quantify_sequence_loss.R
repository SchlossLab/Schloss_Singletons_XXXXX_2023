library(tidyverse)
library(data.table)

datasets <- c("bioethanol", "human", "lake", "marine", "mice", "peromyscus", "rainforest", "rice",
	"seagrass", "sediment", "soil", "stream")


frac_n <- function(counts, n){
	sum(counts <= n) / sum(counts)
}

get_shannon <- function(x) {

	r_abund <- x / sum(x)

	-1 * sum(r_abund * log(r_abund))

}


get_loss_table <- function(dataset){

	print(dataset)

	to_remove <- scan(paste0("data/", dataset, "/data.remove_accnos"), what=character(), quiet=TRUE) %>%
		str_split(., pattern="-") %>%
		unlist()

	paste0("data/", dataset, "/data.count_table") %>%
		fread(., colClasses=c(Representative_Sequence="character")) %>%
		melt(id.vars=c("Representative_Sequence"), variable.name="sample", variable.factor=F, value.name="n_seqs") %>%
	  filter(sample != "total") %>%
		rename(sequences=Representative_Sequence) %>%
		filter(n_seqs != 0 & !sample %in% to_remove) %>%
		group_by(sample) %>%
		summarize(n = sum(n_seqs),
			shannon = get_shannon(n_seqs),
			n_1 = frac_n(n_seqs, 1),
			n_2 = frac_n(n_seqs, 2),
			n_3 = frac_n(n_seqs, 3),
			n_4 = frac_n(n_seqs, 4),
			n_5 = frac_n(n_seqs, 5),
			n_6 = frac_n(n_seqs, 6),
			n_7 = frac_n(n_seqs, 7),
			n_8 = frac_n(n_seqs, 8),
			n_9 = frac_n(n_seqs, 9),
			n_10 = frac_n(n_seqs, 10),
			.groups = "drop"
		) %>%
		pivot_longer(starts_with("n_"), names_to="freq_removed", values_to="fraction_lost") %>%
		mutate(dataset = dataset,
					freq_removed = str_replace(freq_removed, "n_", "")) %>%
		select(dataset, sample, everything())

}

map_df(datasets, get_loss_table) %>%
	write_tsv('data/process/sequence_loss_table_raw.tsv')
