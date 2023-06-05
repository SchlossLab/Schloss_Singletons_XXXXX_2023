library(tidyverse)
library(ggtext)
library(glue)
library(broom)

input <- commandArgs(trailingOnly=TRUE)
input_file <- input[1] # e.g. input_file <- "data/process/sequence_coverage_table_raw.tsv"

tag <- case_when(str_detect(input_file, "loss") ~ "loss",
					str_detect(input_file, "coverage") ~ "coverage")

output_file <- glue("results/figures/supp_sequence_{tag}_cor.tiff")

y_axis_label <- if_else(tag == "loss",
		"Fraction of sequences in sample as singletons",
		"Fraction of singletons shared across samples"
)

scientific_10 <- function(x) {
  str_replace(scales::label_scientific(digits=2)(x), "e\\+0", "x10\\^")
}


data <- read_tsv(input_file) %>%
	filter(freq_removed == 1)

name_cor <- data %>%
	nest(subset=-dataset) %>%
	mutate(corr = map(subset,
			~cor.test(.x[[5]], .x$n, method="spearman", exact=FALSE) %>% tidy())
	) %>%
 	unnest(corr) %>%
	mutate(rho = if_else(p.value < 0.05,
						format(round(estimate, 2), nsmall=2L),
						"NA"),
				pretty = glue("{str_to_title(dataset)} (\u03C1={rho})")) %>%
	select(dataset, pretty)

nice_studies <- pull(name_cor, pretty)
names(nice_studies) <- pull(name_cor, dataset)

data %>%
	ggplot(aes(x=n, y=.[[6]])) +
		geom_point(alpha=0.2) +
		geom_smooth(method="lm", se=FALSE, formula="y~log(x)") +
		facet_wrap(~dataset, nrow=3, scales="free", labeller=as_labeller(nice_studies)) +
		scale_x_log10(n.breaks=4, labels=scientific_10) +
		scale_y_continuous(n.breaks=5, lim=c(0,NA)) +
		labs(x = "Number of sequences per sample", y=y_axis_label) +
		theme_classic() +
		theme(
			axis.text.x = element_markdown(size=8),
			strip.background = element_blank()
		)

ggsave(filename=output_file, width=8, height=7, unit="in")
