library(tidyverse)
library(cowplot)

studies <- c("bioethanol", "human", "lake", "marine", "mice", "peromyscus",
							"rainforest", "rice", "seagrass", "sediment", "soil",
							"stream")

nice_studies <- studies %>% stringr::str_to_title()


loss <- read_tsv("data/process/ointra_analysis.tsv",
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


plot_data <- function(subset_method, subset_string) {

  subset_data <- loss %>%
    filter(method == subset_method) %>%
    pivot_longer(starts_with("mean"), names_to="metric", values_to="value") %>%
    mutate(dataset = factor(dataset, levels=studies, labels=nice_studies)) %>%
    mutate(metric = factor(metric,
      levels=c("mean_s_drop", "mean_h_drop", "mean_kl_drop"),
      labels=c(
        paste0("Reduction in number\nof ", subset_string, "s (%)"),
        paste0("Reduction in Shannon\ndiversity using ", subset_string, "s (%)"),
        paste0("Kullbac-Leibler divergence\nusing ", subset_string, "s"))
      )
    )

  subset_data_points <- subset_data %>%
      filter(min_class %in% c(2, 5, 8, 11))

  figure <- ggplot(
			subset_data,
			aes(x=min_class, y=value, group=dataset, color=dataset)
		) +
    geom_line() +
    geom_point(
      data=subset_data_points,
      mapping=aes(x=min_class, y=value, color=dataset, shape=dataset, fill=dataset)
    ) +
    facet_wrap(facet="metric", ncol=1, scales="free_y", strip.position="left") +
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

	ggdraw(figure) +
		draw_plot_label(
			label=c("C", "B", "A"),
			x=c(0.0, 0.00, 0.00),
			y=c(0.39, 0.69, 1.01),
			size = 20,
			fontface="bold"
		)

  ggsave(
    paste0("results/figures/", tolower(subset_string), "_loss_of_information.tiff"),
    width=6.87,
    height=6,
    compression = "lzw"
  )

}

plot_data("pc", "ASV")
plot_data("otu", "OTU")
