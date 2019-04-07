Stop removing singletons from your analysis
=======

[ Abstract goes here]

Overview
--------

Schloss_Singletons_XXXXX_2016
	|
  |- README          # the top level description of content (this doc)
  |- CONTRIBUTING    # instructions for how to contribute to your project
	|
  |- doc/            # documentation for the study
  |  |- notebook/    # preliminary analyses (dead branches of analysis)
  |  +- paper/       # manuscript(s), whether generated or not
  |
  |- data            # raw and primary data, are not changed once created
  |  |- references/  # reference files to be used in analysis
  |  |- raw/         # raw data, will not be altered
  |  |- mothur/      # mothur processed data
  |  +- process/     # cleaned data, will not be altered once created;
  |                  # will be committed to repo
  |
  |- code/           # any programmatic code
  |- results         # all output from workflows and analyses
  |  |- tables/      # text version of tables to be rendered with kable in R
  |  |- figures/     # graphs, likely designated for manuscript figures
  |  +- pictures/    # diagrams, images, and other non-graph graphics
  |
  |- scratch/        # temporary files that can be safely deleted or lost
  |
  |- study.Rmd       # executable Rmarkdown for this study, if applicable
  |
  +- Makefile        # executable Makefile for this study, if applicable


Eisen Rice root microbiome study
https://www.pnas.org/content/112/8/E911.long
https://www.ncbi.nlm.nih.gov/bioproject/PRJNA255789

Seagrass/marine sediment???
https://www.ncbi.nlm.nih.gov/pubmed/28828269
https://www.ncbi.nlm.nih.gov/bioproject/PRJNA350672

Temporal and spatial dynamics in microbial community composition within a temperate stream network
https://onlinelibrary.wiley.com/doi/full/10.1111/1462-2920.14311
https://www.ncbi.nlm.nih.gov/bioproject/PRJNA323602

Freshwater and sediment microbial communities from dead zone in Lake Erie, Canada - itags
https://www.ncbi.nlm.nih.gov//bioproject/PRJNA255432
https://gold.jgi.doe.gov/biosamples?id=Gb0056776



Seasonal and ecohydrological regulation of active microbial populations involved in DOC, CO2, and CH4 fluxes in temperate rainforest soil
https://www.nature.com/articles/s41396-018-0334-3
https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=ERP023747
