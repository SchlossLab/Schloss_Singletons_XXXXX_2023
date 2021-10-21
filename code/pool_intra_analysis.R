library(tidyverse)
library(purrr)

arguments <- commandArgs(trailingOnly=TRUE)
intra_analysis_files <- arguments[1:(length(arguments)-1)]
output_file <- arguments[length(arguments)]


read_intra_analysis_file <- function(intra_analysis_file){

	read_tsv(intra_analysis_file, col_type=cols(group=col_character(), d_kl=col_double())) %>%
		group_by(group, min_class) %>%
		summarize(n_seqs_no=median(n_seqs.no),
			n_seqs_yes=median(n_seqs.yes), n_seqs_yes_l=quantile(n_seqs.yes, 0.025),
				n_seqs_yes_u=quantile(n_seqs.yes, 0.975),
			s_no=median(sobs.no), s_no_l=quantile(sobs.no, 0.025), s_no_u=quantile(sobs.no, 0.975),
			s_yes=median(sobs.yes), s_yes_l=quantile(sobs.yes, 0.025), s_yes_u=quantile(sobs.yes, 0.975),
			h_no=median(h.no), h_no_l=quantile(h.no, 0.025), h_no_u=quantile(h.no, 0.975),
			h_yes=median(h.yes), h_yes_l=quantile(h.yes, 0.025), h_yes_u=quantile(h.yes, 0.975),
			j_no=median(even.no), j_no_l=quantile(even.no, 0.025), j_no_u=quantile(even.no, 0.975),
			j_yes=median(even.yes), j_yes_l=quantile(even.yes, 0.025), j_yes_u=quantile(even.yes, 0.975),
			kl=median(d_kl, na.rm=T), kl_l=quantile(d_kl, 0.025, na.rm=T), kl_u=quantile(d_kl, 0.975, na.rm=T),
			rho=median(spearman), rho_l=quantile(spearman, 0.025), rho_u=quantile(spearman, 0.975),
			diff=median(count_diff), diff_l=quantile(count_diff, 0.025), diff_u=quantile(count_diff, 0.975)
			) %>%
		ungroup() %>%
		arrange(min_class) %>%
		mutate(dataset = str_replace(intra_analysis_file, "data/(.*)/data..*..intra_analysis", "\\1"),
					method =  str_replace(intra_analysis_file, "data/.*/data.(.*)..intra_analysis", "\\1"))

}


map_dfr(intra_analysis_files, read_intra_analysis_file) %>%
	select(dataset, method, everything()) %>%
	write_tsv(output_file)
