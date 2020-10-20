library(tidyverse)
library(cowplot)

studies <- c("bioethanol", "human", "lake", "marine", "mice", "peromyscus",
							"rainforest", "rice", "seagrass", "sediment", "soil",
							"stream")

nice_studies <- studies %>% stringr::str_to_title()


loss <- read_tsv("data/process/rintra_analysis.tsv",
  	col_types = cols(.default=col_double(),
      dataset = col_character(),
      method=col_character(),
      group=col_character()
    )
  ) %>%
  group_by(dataset, method, min_class) %>%
  summarize(mean_s_drop = 100*(1-mean(s_yes / s_no)),
    mean_h_drop = 100*(1-mean(h_yes / h_no)),
    mean_kl_drop = mean(kl),
    .groups="drop"
  )


subset_data <- loss %>%
  pivot_longer(starts_with("mean"), names_to="metric", values_to="value") %>%
  filter(is.finite(value)) %>%
  mutate(dataset = factor(dataset, levels=studies, labels=nice_studies)) %>%
  mutate(metric = factor(metric,
    levels=c("mean_s_drop", "mean_h_drop", "mean_kl_drop"),
    labels=c(
      paste0("Reduction in\nrichness (%)"),
      paste0("Reduction in\nShannon diversity (%)"),
      paste0("Kullbac-Leibler\ndivergence"))
    )
  ) %>%
  mutate(method = factor(method,
    levels=c("pc", "otu"),
    labels=c("ASVs", "OTUs")
    )
  )

subset_data_points <- subset_data %>%
    filter(min_class %in% c(2, 5, 8, 11))

ggplot(
		subset_data,
		aes(x=min_class, y=value, group=dataset, color=dataset)
	) +
  geom_line() +
  geom_point(
    data=subset_data_points,
    mapping=aes(x=min_class, y=value, color=dataset, shape=dataset, fill=dataset)
  ) +
  facet_grid(metric~method, scales="free_y", switch="y") +
  labs(y=NULL, x="Smallest number of sequences per ASV") +
  scale_y_continuous(limits=c(0, NA)) +
  scale_x_continuous(breaks=2:11) +
  scale_color_manual(name=NULL,
    values = rep(c('#1b9e77','#d95f02','#7570b3'), 4)
  ) +
  scale_fill_manual(name=NULL,
    values = rep(c('#1b9e77','#d95f02','#7570b3'), 4)
  ) +
  scale_shape_manual(name=NULL,
    values = rep(c(15, 17, 19, 25), 3)
  ) +
  theme_classic() +
  theme(
    strip.placement="outside",
    strip.background=element_rect(color=NA),
    legend.key.height=unit(11, "pt"),
		line=element_line(lineend="round"),
		plot.margin=margin(t=10, l=0, r=0, b=0)
  )

ggsave(
  paste0(
		"results/figures/loss_of_information_random.tiff"
	),
  width=6.87,
  height=6,
  compression = "lzw"
)
