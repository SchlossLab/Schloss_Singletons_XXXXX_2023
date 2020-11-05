Stop removing singletons from your analysis
=======

[ Abstract goes here]

Overview
--------

```
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
```


### bioethanol: Bacterial Community Structure and Dynamics During Corn-Based Bioethanol Fermentation.
* https://doi.org/10.1007/s00248-015-0673-9
* https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=SRP055545

### human: Microbiota-based model improves the sensitivity of fecal immunochemical test for detecting colonic lesions
* https://doi.org/10.1186/s13073-016-0290-3
* https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=SRP062005

### lake: Freshwater and sediment microbial communities from dead zone in Lake Erie, Canada - itags
* https://doi.org/10.1111/1462-2920.12819 (?)
* https://www.ncbi.nlm.nih.gov//bioproject/PRJNA255432
* https://gold.jgi.doe.gov/biosamples?id=Gb0056776

### marine (possibly remove): Artificial seawater media facilitate cultivating members of the microbial majority from the Gulf of Mexico
* https://doi.org/10.1128/mSphere.00028-16
* https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=SRP068101

### mice: Development of a dual-index sequencing strategy and curation pipeline for analyzing amplicon sequence data on the MiSeq Illumina sequencing platform
* https://doi.org/10.1128/AEM.01043-13
* https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=SRP192323

### peromyscus: Intra- and interindividual variations mask interspecies variation in the microbiota of sympatric peromyscus populations
* http://doi.org/10.1128/AEM.02303-14
* http://www.ncbi.nlm.nih.gov/sra/?term=SRP044050

### rainforest: Seasonal and ecohydrological regulation of active microbial populations involved in DOC, CO2, and CH4 fluxes in temperate rainforest soil
* https://doi.org/10.1038/s41396-018-0334-3
* https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=ERP023747

### rice: Eisen Rice root microbiome study
* https://doi.org/10.1073/pnas.1414592112
* https://www.ncbi.nlm.nih.gov/bioproject/PRJNA255789

### seagrass: Seagrass/marine sediment
* https://doi.org/10.7717/peerj.3674
* https://www.ncbi.nlm.nih.gov/bioproject/PRJNA350672

### sediment: Energy Gradients Structure Microbial Communities Across Sediment Horizons in Deep Marine Sediments of the South China Sea
* https://doi.org/10.3389/fmicb.2018.00729
* https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=SRP097192

### soil (possibly remove): Metagenomics reveals pervasive bacterial populations and reduced community diversity across the Alaska tundra ecosystem
* https://doi.org/10.3389/fmicb.2016.00579
* https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=ERP012016

### stream: Temporal and spatial dynamics in microbial community composition within a temperate stream network
* https://doi.org/10.1111/1462-2920.14311
* https://www.ncbi.nlm.nih.gov/bioproject/PRJNA323602
