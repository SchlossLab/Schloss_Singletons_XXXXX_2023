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
