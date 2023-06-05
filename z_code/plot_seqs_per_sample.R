library(tidyverse)

set.seed(19760620)

get_removed_samples <- function(environment) {

	paste0("data/", environment, "/data.remove_accnos") %>%
		read_lines(.) %>%
		str_split("-") %>%
		unlist() %>%
		enframe(., name=NULL, value="sample") %>%
		mutate(study = environment)

}


studies <- c("bioethanol", "human", "lake", "marine", "mice", "peromyscus",
							"rainforest", "rice", "seagrass", "sediment", "soil", "stream")

nice_studies <- c("Bioethanol", "Human", "Lake", "Marine", "Mice", "Peromyscus",
									"Rainforest", "Rice", "Seagrass", "Sediment", "Soil", "Stream")
names(nice_studies) <- studies

removed_samples <- studies %>%
	map_df(., get_removed_samples) %>%
	filter(sample != "") %>%
	mutate(status = "removed")


counts_data <- tibble(study=studies,
			file_name=paste0("data/", study, "/data.count.summary")) %>%
	group_by(file_name) %>%
	nest() %>%
	mutate(count_data = map(file_name, ~read_tsv(file=.x, col_names=c("sample", "n_seqs"), col_types=cols(sample=col_character(), n_seqs=col_integer())))) %>%
	ungroup() %>%
	select(-file_name) %>%
	unnest(cols=c("data", "count_data")) %>%
	full_join(., removed_samples, by=c("study", "sample")) %>%
	mutate(status = replace_na(status, "kept")) %>%
	mutate(study = factor(study, sort(studies, decreasing=T)))

ggplot(counts_data, aes(y=n_seqs, x=study)) +
	geom_vline(xintercept=seq(1:12), col="gray") +
	geom_jitter(width=0.2, pch=19, alpha=0.33, aes(color=status)) +
	scale_y_log10(limits=c(0.9, 1e6), breaks=c(1, 10, 100, 1000, 10000, 100000, 1e6), labels=c("1", "10", "100", "1,000", "10,000", "100,000", "1,000,000")) +
	scale_x_discrete(breaks=studies, labels=nice_studies[studies]) +
	scale_color_manual(name=NULL, values=c("black", "red"), breaks=c("kept", "removed"), labels=c("Kept", "Removed"))+
	coord_flip() +
	labs(y="Number of sequences per sample", x=NULL) +
	theme_classic()

ggsave("results/figures/seqs_per_sample.tiff", width=7, height=4, compression="lzw")
