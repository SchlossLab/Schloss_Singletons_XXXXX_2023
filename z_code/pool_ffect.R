library(tidyverse)
library(purrr)

arguments <- commandArgs(trailingOnly=TRUE)
ffect_summary_files <- arguments[1:(length(arguments)-1)]
output_file <- arguments[length(arguments)]

read_ffect_summary_file <- function(ffect_summary_file){

	read_tsv(ffect_summary_file) %>%
		mutate(dataset = str_replace(ffect_summary_file, "data/(.*)/data\\..*\\..*_summary", "\\1"))

}


map_dfr(ffect_summary_files, read_ffect_summary_file) %>%
	select(dataset, everything()) %>%
	write_tsv(output_file)
