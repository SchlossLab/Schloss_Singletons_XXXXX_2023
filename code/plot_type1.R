library(tidyverse)
library(cowplot)

studies <- c("bioethanol", "human", "lake", "marine", "mice", "peromyscus",
							"rainforest", "rice", "seagrass", "sediment", "soil",
							"stream")

nice_studies <- studies %>% stringr::str_to_title()

null_alpha <- read_tsv("data/process/rffect_alpha_analysis.tsv",
		col_types = cols(.default=col_double(),
					dataset=col_character(), method=col_character(), metric=col_character()
        )
      ) %>%
      filter((metric == "sobs" | metric == "shannon"))

null_beta <- read_tsv("data/process/rffect_beta_analysis.tsv",
		col_types = cols(.default=col_double(),
					dataset=col_character(), clustering=col_character()
        )
      ) %>%
      mutate(metric = "braycurtis") %>%
      rename(method = clustering)

null <- bind_rows(null_alpha, null_beta)

skew_alpha <- read_tsv("data/process/sffect_alpha_analysis.tsv",
		col_types = cols(.default=col_double(),
					dataset=col_character(), method=col_character(), metric=col_character()
        )
      ) %>%
  filter((metric == "sobs" | metric == "shannon"))

skew_beta <- read_tsv("data/process/sffect_beta_analysis.tsv",
		col_types = cols(.default=col_double(),
					dataset=col_character(), clustering=col_character())) %>%
  mutate(metric = "braycurtis") %>%
  rename(method = clustering)

skew <- bind_rows(skew_alpha, skew_beta)

type_one <- bind_rows(null=null, skew=skew, .id="simulation") %>%
  rename(min_class = prune, percent_sig = frac_sig) %>%
  mutate(percent_sig = 100 * percent_sig)

subset_method <- "pc"
subset_string <- "ASV"


plot_data <- function(subset_method, subset_string) {

  subset_data <- type_one %>%
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
    mutate(
      dataset = factor(dataset, levels=studies, labels=nice_studies),
      simulation = factor(simulation, levels=c("null", "skew"),
            labels=c(
              "Samples randomly assignedto groups\nwithout regard for sample size",
              "Samples randomly assigned to groups\nbased on sample size"
            )
          )
    )

  subset_data_points <- subset_data %>%
      filter(min_class %in% c(1, 3, 5, 7, 9, 11))


  figure <- subset_data %>%
    ggplot(aes(x=min_class, y=percent_sig, group=dataset, color=dataset)) +
      geom_line() +
      geom_point(
        data=subset_data_points,
        mapping=aes(x=min_class, y=percent_sig, color=dataset, shape=dataset, fill=dataset)
      ) +
      facet_grid(simulation~metric, switch="y") +
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
        y="Rate of falsely detecting a significant difference between groups (%)"
      ) +
      theme_classic() +
      theme(
        strip.placement="outside",
        strip.background=element_rect(color=NA),
        legend.key.height=unit(11, "pt"),
        line=element_line(lineend="round"),
        plot.margin=margin(t=0, l=0, r=0, b=0),
        axis.title.y = element_text(margin = margin(r=8))
      )

  ggdraw(figure) +
  	draw_plot_label(
  		label=c("B", "A"),
  		x=c(0.035, 0.035),
  		y=c(0.52, 0.97),
  		size = 20,
  		fontface="bold"
  	)

  ggsave(
    paste0(
  		"results/figures/",
  		tolower(subset_string),
  		"_type_one.tiff"
  	),
    width=6.87,
    height=6,
    compression = "lzw"
  )
}

plot_data("pc", "ASV")
plot_data("otu", "OTU")
