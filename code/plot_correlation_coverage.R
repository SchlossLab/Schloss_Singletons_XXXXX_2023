library(tidyverse)
library(cowplot)

studies <- c("bioethanol", "human", "lake", "marine", "mice", "peromyscus",
							"rainforest", "rice", "seagrass", "sediment", "soil",
							"stream") %>%
						sort(decreasing=T)

nice_studies <- c("Bioethanol", "Human", "Lake", "Marine", "Mice", "Peromyscus",
									"Rainforest", "Rice", "Seagrass", "Sediment", "Soil",
									"Stream") %>%
								sort(decreasing=T)
names(nice_studies) <- studies

methods <- str_wrap(c(
	"Correlation between the number of sequences and the number of singletons in a sample",
	"Correlation between the number of sequences and the fraction of singletons shared across samples",
	"Fraction of singletons shared across samples"), width=35)
names(methods) <- c("cor_loss", "cor_coverage", "coverage")

correlations <- bind_rows(
		cor_loss=read_tsv('data/process/sequence_loss_table_cor.tsv'),
		cor_coverage=read_tsv('data/process/sequence_coverage_table_cor.tsv'),
		.id="comparison"
	) %>%
 	filter(min_freq == 1) %>%
  mutate(sig = if_else(cor_n_p.value < 0.05, NA_character_, "not\nsignificant"),
    value = if_else(is.na(sig), cor_n_estimate, NA_real_)
	) %>%
	select(comparison, dataset, value, sig)

coverage <- read_tsv('data/process/sequence_coverage_table_raw.tsv') %>%
	filter(min_freq == 1) %>%
	group_by(dataset) %>%
	summarize(
		value=median(coverage),
		lci = quantile(coverage, prob=0.025),
		uci = quantile(coverage, prob=0.975),
		.groups="drop"
	) %>%
	mutate(comparison = "coverage")

limits <- tibble(
	comparison = c("cor_loss", "cor_loss", "cor_coverage", "cor_coverage", "coverage", "coverage"),
	value = c(-1, 0, -1, 0, 0, 1),
	dataset = c("zlower", "zupper", "zlower", "zupper", "zlower", "zupper")
)

panel_label <- tibble(
	comparison = factor(c("cor_loss", "cor_coverage", "coverage"),
		levels=c("cor_loss", "coverage", "cor_coverage")),
	label = c("A", "C", "B"),
	x=c(-1, -1, 0),
	y=c(12.5, 12.5, 12.5)
)

bind_rows(correlations, coverage, limits) %>%
	mutate(comparison = factor(comparison,
 		levels=c("cor_loss", "coverage", "cor_coverage")),
		dataset = factor(dataset, levels=studies)	) %>%
  ggplot(aes(y=dataset, x=value)) +
  geom_hline(aes(yintercept=dataset), color="lightgray", na.rm=T) +
  geom_point(na.rm=T) +
	geom_errorbarh(aes(xmin=lci, xmax=uci), height=0, size=0.75, na.rm=T) +
	geom_label(x=-0.93, aes(label=sig), label.size=0, size=2, na.rm=T) +
	facet_wrap(facet="comparison",
		labeller=labeller(comparison = methods),
		strip.position = "bottom",
		scales="free_x"
	) +
  labs(y=NULL, x=NULL) +
  scale_y_discrete(limits=studies, labels=nice_studies[studies]) +
	coord_cartesian(clip="off") +
  theme_classic() +
	theme(strip.background = element_blank(),
		strip.placement = "outside",
		strip.text=element_text(size=8),
		axis.text.x=element_text(size=7),
		line=element_line(lineend="round"),
		plot.margin=margin(t=10)
	) +
	geom_text(data=panel_label,
		aes(x=x, y=y, label=label),
		fontface="bold",
		size=8,
		nudge_y=0.25, nudge_x=0.02)

ggsave("results/figures/correlation_coverage.tiff", width=7, height=4.25, compression = "lzw")
