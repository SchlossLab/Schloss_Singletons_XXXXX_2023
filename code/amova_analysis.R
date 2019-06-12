library(tidyverse)

input <- commandArgs(trailingOnly=TRUE)

amova_files <- input[-length(input)]
output_file_name <- input[length(input)]

print(amova_files)

get_summary <- function(amova_file){

	seed <- str_replace(amova_file, ".*/data\\.(\\d*)\\..*", "\\1") %>% as.integer()
	prune <- str_replace(amova_file, ".*/data\\.\\d*\\.(\\d*).*", "\\1") %>% as.integer()
	clustering <- str_replace(amova_file, ".*/data\\.\\d*\\.\\d*\\.(.*)\\..amova", "\\1")

	p_value <- scan(amova_file, what=character(), sep="\n", quiet=TRUE) %>% str_subset(., pattern="p-value: ") %>% str_replace(., "p-value: ", "") %>% str_replace(., "\\*", "")

	p_value <- ifelse(str_detect(p_value, "<"), 0.000, as.numeric(p_value))

	tibble(prune=prune, seed=seed, clustering=clustering, p_value = p_value)

}


map_df(amova_files, get_summary) %>%
	mutate(sig = p_value < 0.05) %>%
	group_by(clustering, prune) %>%
	summarize(frac_sig = mean(sig)) %>%
	ungroup() %>%
	write_tsv(output_file_name)
