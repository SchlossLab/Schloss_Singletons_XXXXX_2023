library(tidyverse)
library(cowplot)

studies <- c("bioethanol", "human", "lake", "marine", "mice", "peromyscus",
							"rainforest", "rice", "seagrass", "sediment", "soil",
							"stream")

nice_studies <- studies %>% stringr::str_to_title()


r_cov_alpha <- read_tsv("data/process/ralpha_analysis.tsv",
		col_types = cols(.default=col_double(),
      dataset=col_character(), method=col_character())
    ) %>%
    select(dataset, method, prune, cv_sobs, cv_shannon)

r_cov_bc <- read_tsv("data/process/rbeta_analysis.tsv",
		col_types = cols(.default=col_double(),
					dataset=col_character(), method=col_character())) %>%
    select(dataset, method, prune, sd_mean) %>%
    rename(cv_braycurtis = sd_mean)

cov_data <- inner_join(r_cov_alpha, r_cov_bc, by=c("dataset", "method", "prune")) %>%
  pivot_longer(
    starts_with("cv_"),
    names_to="metric",
    names_prefix="cv_",
    values_to="cv"
  ) %>%
  rename(min_class = prune) %>%
  mutate(cv = 100 * cv)


plot_data <- function(subset_method, subset_string) {

  subset_data <- cov_data %>%
    filter(method == subset_method) %>%
    mutate(metric = factor(
      metric,
      levels=c("sobs", "shannon", "braycurtis"),
      labels=c(paste0("Richness"),
          paste0("Shannon diversity"),
          paste0("Bray-Curtis distances")
        )
      )
    ) %>%
    mutate(dataset = factor(dataset, levels=studies, labels=nice_studies))


  subset_data_points <- subset_data %>%
      filter(min_class %in% c(1, 3, 5, 7, 9, 11))

  figure <- ggplot(
        data=subset_data,
        aes(x=min_class, y=cv, group=dataset, color=dataset)
      ) +
      geom_line() +
      geom_point(
        data=subset_data_points,
        mapping=aes(x=min_class, y=cv, color=dataset, shape=dataset, fill=dataset)
      ) +
      facet_wrap(facet="metric", ncol=1, strip.position = "left", scales="free_y") +
      scale_x_continuous(breaks=1:11) +
      scale_color_manual(name=NULL,
        values = rep(c('#1b9e77','#d95f02','#7570b3'), 4)
      ) +
      scale_fill_manual(name=NULL,
        values = rep(c('#1b9e77','#d95f02','#7570b3'), 4)
      ) +
      scale_shape_manual(name=NULL,
        values = rep(c(15, 17, 19, 25), 3)
      ) +
      labs(
        x="Smallest number of sequences per ASV",
        y="Coefficients of variation (%)"
      ) +
      theme_classic() +
      theme(
        strip.placement="outside",
        strip.background=element_rect(color=NA),
        legend.key.height=unit(11, "pt"),
  			line=element_line(lineend="round"),
  			plot.margin=margin(t=10, l=0, r=0, b=0),
        axis.title.y = element_text(margin = margin(r=8))
      )

  ggdraw(figure) +
  	draw_plot_label(
  		label=c("C", "B", "A"),
  		x=c(0.03, 0.03, 0.03),
  		y=c(0.39, 0.69, 1.01),
  		size = 20,
  		fontface="bold"
  	)

  ggsave(
    paste0(
  		"results/figures/",
  		tolower(subset_string),
  		"_coefficient_of_variation.tiff"
  	),
    width=6.87,
    height=6,
    compression = "lzw"
  )
}

plot_data("pc", "ASV")
plot_data("otu", "OTU")
