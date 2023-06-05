library(tidyverse)
library(purrr)

arguments <- commandArgs(trailingOnly=TRUE)
analysis_files <- arguments[1:(length(arguments)-1)]
output_file <- arguments[length(arguments)]

read_analysis_file <- function(analysis_file){

	read_tsv(analysis_file, col_type=cols(.default=col_double())) %>%
		arrange(prune) %>%
		mutate(dataset = str_replace(analysis_file, "data/(.*)/data..{2,3}\\..*_analysis", "\\1"),
					method =  str_replace(analysis_file, "data/.*/data.(.{2,3})\\..*_analysis", "\\1"))

}


map_dfr(analysis_files, read_analysis_file) %>%
	select(dataset, method, everything()) %>%
	write_tsv(output_file)
