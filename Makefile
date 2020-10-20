################################################################################
# Helper functions and definitions
#
################################################################################
print-%:
	@echo '$*=$($*)'

SEED := $(shell seq 100)
PRUNE := $(shell seq 11)

samples = bioethanol human lake marine mice peromyscus rainforest rice seagrass sediment soil stream

################################################################################
# Obtain the necessary reference files
#
################################################################################
REFS = data/references

$(REFS)/silva.v4.% :
	wget -N -P $(REFS)/ https://mothur.org/w/images/7/71/Silva.seed_v132.tgz
	tar xvzf $(REFS)/Silva.seed_v132.tgz -C $(REFS)/
	mothur "#get.lineage(fasta=$(REFS)/silva.seed_v132.align, taxonomy=$(REFS)/silva.seed_v132.tax, taxon=Bacteria);pcr.seqs(start=13862, end=23445, keepdots=F, processors=8);degap.seqs();unique.seqs()"
	cut -f 1 $(REFS)/silva.seed_v132.pick.pcr.ng.names > $(REFS)/silva.seed_v132.pick.pcr.ng.accnos
	mothur "#get.seqs(fasta=$(REFS)/silva.seed_v132.pick.pcr.align, accnos=$(REFS)/silva.seed_v132.pick.pcr.ng.accnos);screen.seqs(minlength=240, maxlength=275, maxambig=0, maxhomop=8, processors=8)"
	mv $(REFS)/silva.seed_v132.pick.pcr.pick.good.align $(REFS)/silva.v4.align
	grep "^>" $(REFS)/silva.v4.align | cut -c 2- > $(REFS)/silva.v4.accnos
	mothur "#get.seqs(taxonomy=$(REFS)/silva.seed_v132.pick.tax, accnos=$(REFS)/silva.v4.accnos)"
	mv $(REFS)/silva.seed_v132.pick.pick.tax  $(REFS)/silva.v4.tax
	rm $(REFS)/?ilva.seed_v132* $(REFS)/silva.v4.accnos

$(REFS)/trainset16_022016.pds.% :
	mkdir -p $(REFS)/rdp
	wget -N -P $(REFS)/ https://mothur.org/w/images/c/c3/Trainset16_022016.pds.tgz; \
	tar xvzf $(REFS)/Trainset16_022016.pds.tgz -C $(REFS)/rdp;\
	mv $(REFS)/rdp/trainset16_022016.pds/trainset16_022016.* $(REFS);\
	rm -rf $(REFS)/rdp $(REFS)/Trainset*

$(REFS)/HMP_MOCK.fasta :
	wget -N -P $(REFS)/ https://raw.githubusercontent.com/SchlossLab/Kozich_MiSeqSOP_AEM_2013/master/data/references/HMP_MOCK.fasta

################################################################################
# Generate pruned versions of datasets based on the original assignments of sequences to each sample
#
################################################################################
# Run datasets { mice human soil marine etc. } through mothur pipeline through remove.lineage
%/data.fasta %/data.count_table %/data.taxonomy : code/datasets_process.sh\
			code/datasets_download.sh\
			code/datasets_make_files.R\
			%/sra_info.tsv\
			$(REFS)/silva.v4.align\
			$(REFS)/trainset16_022016.pds.fasta\
			$(REFS)/trainset16_022016.pds.tax
	bash $< $*


%/data.count.summary : %/data.count_table
	mothur "#count.groups(count=$^)"


%/data.pc.shared %/data.pc_seq.map : %/data.count_table %/data.remove_accnos\
			code/get_original_pc_shared.sh
	bash code/get_original_pc_shared.sh $(dir $<)


%/data.otu.shared %/data.otu.list : %/data.fasta %/data.count_table %/data.remove_accnos\
																								code/get_original_otu_shared.sh
	bash code/get_original_otu_shared.sh $(dir $<)


%/data.otu_seq.map : %/data.otu.list code/parse_list_file.R
	Rscript code/parse_list_file.R $(dir $<)


.SECONDEXPANSION:
%.pc.oshared : $$(addsuffix .pc.shared,$$(basename $$(basename $$(basename $$@))))\
										code/prune_orig_pc_shared.R
	$(eval DIR=$(dir $@))
	$(eval MIN_SEQ_COUNT=$(subst .,,$(suffix $(basename $(basename $@)))))
	Rscript code/prune_orig_pc_shared.R $(DIR) $(MIN_SEQ_COUNT)


.SECONDEXPANSION:
%.otu.oshared : %.pc.oshared $$(dir $$@)data.pc_seq.map $$(dir $$@)data.otu_seq.map code/prune_orig_otu_shared.R
	Rscript code/prune_orig_otu_shared.R $^


################################################################################
# Generate pruned versions of datasets based on random assignments of sequences to each sample
#
################################################################################
.SECONDEXPANSION:
%.rand_pruned_groups %.rdesign : code/randomize_prune.R\
			$$(addsuffix .count_table,$$(basename $$(basename $$(basename $$@))))\
			$$(addsuffix .remove_accnos,$$(basename $$(basename $$(basename $$@))))
	$(eval DIR=$(dir $@))
	$(eval SEED=$(subst .,,$(suffix $(basename $(basename $@)))))
	$(eval MIN_SEQ_COUNT=$(subst .,,$(suffix $(basename $@))))
	Rscript code/randomize_prune.R $(DIR) $(SEED) $(MIN_SEQ_COUNT)


%.pc.rshared : code/prune_rand_pc_shared.R %.rand_pruned_groups
	Rscript $^


%otu.rshared : code/prune_rand_otu_shared.R %rand_pruned_groups $$(dir $$@)data.otu_seq.map
	Rscript $^


%.ramova : code/run_amova.sh %.rbeta_matrix $$(addsuffix .rdesign,$$(basename $$(basename $$@)))
	bash $^


.SECONDEXPANSION:
%/data.rffect.alpha_summary : code/run_wilcox.R $$(foreach S, $$(SEED), $$(foreach P, $$(PRUNE), $$(foreach M, otu pc, $$(dir $$@)data.$$S.$$P.$$M.ralpha_diversity)))
	Rscript $^ $@


.SECONDEXPANSION:
%/data.rffect.beta_summary : code/amova_analysis.R $$(foreach S, $$(SEED), $$(foreach P, $$(PRUNE), $$(foreach M, otu pc, $$(dir $$@)data.$$S.$$P.$$M.ramova)))
	Rscript $^ $@


################################################################################
# Generate pruned versions of datasets based on random assignments of sequences to each sample with
# effect size defined by removing 1% of the PC sequences
#
################################################################################
.SECONDEXPANSION:
%.effect_pruned_groups %.edesign : code/effect_prune.R\
			$$(addsuffix .count_table,$$(basename $$(basename $$(basename $$@))))\
			$$(addsuffix .remove_accnos,$$(basename $$(basename $$(basename $$@))))
	$(eval DIR=$(dir $@))
	$(eval SEED=$(subst .,,$(suffix $(basename $(basename $@)))))
	$(eval MIN_SEQ_COUNT=$(subst .,,$(suffix $(basename $@))))
	Rscript code/effect_prune.R $(DIR) $(SEED) $(MIN_SEQ_COUNT) 0.99


%.pc.eshared : code/prune_effect_pc_shared.R %.effect_pruned_groups
	Rscript $^


%otu.eshared : code/prune_rand_otu_shared.R %effect_pruned_groups $$(dir $$@)data.otu_seq.map
	Rscript $^


%.eamova : code/run_amova.sh %.ebeta_matrix $$(addsuffix .edesign,$$(basename $$(basename $$@)))
	bash $^


.SECONDEXPANSION:
%/data.effect.alpha_summary : code/run_wilcox.R $$(foreach S, $$(SEED), $$(foreach P, $$(PRUNE), $$(foreach M, otu pc, $$(dir $$@)data.$$S.$$P.$$M.ealpha_diversity)))
	Rscript $^ $@


.SECONDEXPANSION:
%/data.effect.beta_summary : code/amova_analysis.R $$(foreach S, $$(SEED), $$(foreach P, $$(PRUNE), $$(foreach M, otu pc, $$(dir $$@)data.$$S.$$P.$$M.eamova)))
	Rscript $^ $@


################################################################################
# Generate pruned versions of datasets based on random assignments of sequences to each sample with
# effect size defined by increasing the abundance of 5% of the OTUs by 10%
#
################################################################################
.SECONDEXPANSION:
%.bffect_pruned_groups %.bdesign : code/bffect_prune.R\
			$$(addsuffix .count_table,$$(basename $$(basename $$(basename $$@))))\
			$$(addsuffix .remove_accnos,$$(basename $$(basename $$(basename $$@))))
	$(eval DIR=$(dir $@))
	$(eval SEED=$(subst .,,$(suffix $(basename $(basename $@)))))
	$(eval MIN_SEQ_COUNT=$(subst .,,$(suffix $(basename $@))))
	Rscript code/bffect_prune.R $(DIR) $(SEED) $(MIN_SEQ_COUNT) 0.05 0.10


%.pc.bshared : code/prune_effect_pc_shared.R %.bffect_pruned_groups
	Rscript $^


%otu.bshared : code/prune_rand_otu_shared.R %bffect_pruned_groups $$(dir $$@)data.otu_seq.map
	Rscript $^


%.bamova : code/run_amova.sh %.bbeta_matrix $$(addsuffix .bdesign,$$(basename $$(basename $$@)))
	bash $^


.SECONDEXPANSION:
%/data.bffect.alpha_summary : code/run_wilcox.R $$(foreach S, $$(SEED), $$(foreach P, $$(PRUNE), $$(foreach M, otu pc, $$(dir $$@)data.$$S.$$P.$$M.balpha_diversity)))
	Rscript $^ $@


.SECONDEXPANSION:
%/data.bffect.beta_summary : code/amova_analysis.R $$(foreach S, $$(SEED), $$(foreach P, $$(PRUNE), $$(foreach M, otu pc, $$(dir $$@)data.$$S.$$P.$$M.bamova)))
	Rscript $^ $@


################################################################################
# Generate skewed versions of datasets on assignments of samples to different treatment groups
# depending on whether the number of sequences in the sample is below or above the median
#
################################################################################
.SECONDEXPANSION:
%.sdesign : code/get_skew_design.R\
			$$(addsuffix .rand_pruned_groups,$$(basename $$@))
	Rscript $^

%.sbeta_matrix : %.rbeta_matrix
	cp $^ $@

.SECONDEXPANSION:
%.samova : code/run_amova.sh %.sbeta_matrix $$(addsuffix .sdesign,$$(basename $$(basename $$@)))
	bash $^

%.salpha_diversity : %.ralpha_diversity
	cp $^ $@

%.sbeta_diversity : %.rbeta_diversity
	cp $^ $@

.SECONDEXPANSION:
%/data.sffect.alpha_summary : code/run_wilcox.R $$(foreach S, $$(SEED), $$(foreach P, $$(PRUNE), $$(foreach M, otu pc, $$(dir $$@)data.$$S.$$P.$$M.salpha_diversity)))
	Rscript $^ $@

.SECONDEXPANSION:
%/data.sffect.beta_summary : code/amova_analysis.R $$(foreach S, $$(SEED), $$(foreach P, $$(PRUNE), $$(foreach M, otu pc, $$(dir $$@)data.$$S.$$P.$$M.samova)))
	Rscript $^ $@


################################################################################
# Generate diversity files
#
################################################################################
%n_seqs : code/get_nseqs.sh %shared
	bash $^


%alpha_diversity : code/get_alpha_diversity_data.sh %shared
	bash $^


%beta_matrix : code/get_beta_diversity_matrix.sh %shared
	bash $^


%beta_diversity : code/get_beta_diversity_data.R %beta_matrix
	Rscript $^


################################################################################
# Synthesize diversity files
#
################################################################################
.SECONDEXPANSION:
%.ointra_analysis : $$(addsuffix $$(suffix $$(basename $$@)).oshared,$$(foreach P,$$(PRUNE),$$(basename $$(basename $$@)).$$P))\
		code/get_intra_analysis.R
	Rscript code/get_intra_analysis.R $@

.SECONDEXPANSION:
%.rintra_analysis : $$(addsuffix $$(suffix $$(basename $$@)).rshared,$$(foreach S,$$(SEED),$$(foreach P,$$(PRUNE),$$(basename $$(basename $$@)).$$S.$$P)))\
		code/get_intra_analysis.R
	Rscript code/get_intra_analysis.R $@


.SECONDEXPANSION:
%.oalpha_analysis : $$(addsuffix $$(suffix $$(basename $$@)).oalpha_diversity,$$(foreach P,$$(PRUNE),$$(basename $$(basename $$@)).$$P))\
		code/get_alpha_analysis.R
	Rscript code/get_alpha_analysis.R $@

.SECONDEXPANSION:
%.ralpha_analysis : $$(addsuffix $$(suffix $$(basename $$@)).ralpha_diversity,$$(foreach S,$$(SEED),$$(foreach P,$$(PRUNE),$$(basename $$(basename $$@)).$$S.$$P)))\
		code/get_alpha_analysis.R
	Rscript code/get_alpha_analysis.R $@


.SECONDEXPANSION:
%.obeta_analysis : $$(addsuffix $$(suffix $$(basename $$@)).obeta_diversity,$$(foreach P,$$(PRUNE),$$(basename $$(basename $$@)).$$P))\
		code/get_beta_analysis.R
	Rscript code/get_beta_analysis.R $@

.SECONDEXPANSION:
%.rbeta_analysis : $$(addsuffix $$(suffix $$(basename $$@)).rbeta_diversity,$$(foreach S,$$(SEED),$$(foreach P,$$(PRUNE),$$(basename $$(basename $$@)).$$S.$$P)))\
		code/get_beta_analysis.R
	Rscript code/get_beta_analysis.R $@



################################################################################
# Pool results from different environments
#
################################################################################
data/process/ointra_analysis.tsv : code/pool_intra_analysis.R\
		$(foreach S, $(samples), data/$S/data.pc.ointra_analysis)\
		$(foreach S, $(samples), data/$S/data.otu.ointra_analysis)
	Rscript $^ $@

data/process/rintra_analysis.tsv : code/pool_intra_analysis.R\
		$(foreach S, $(samples), data/$S/data.pc.rintra_analysis)\
		$(foreach S, $(samples), data/$S/data.otu.rintra_analysis)
	Rscript $^ $@


data/process/oalpha_analysis.tsv : code/pool_analysis.R\
		$(foreach S, $(samples), data/$S/data.pc.oalpha_analysis)\
		$(foreach S, $(samples), data/$S/data.otu.oalpha_analysis)
	Rscript $^ $@

data/process/ralpha_analysis.tsv : code/pool_analysis.R\
		$(foreach S, $(samples), data/$S/data.pc.ralpha_analysis)\
		$(foreach S, $(samples), data/$S/data.otu.ralpha_analysis)
	Rscript $^ $@


data/process/obeta_analysis.tsv : code/pool_analysis.R\
		$(foreach S, $(samples), data/$S/data.pc.obeta_analysis)\
		$(foreach S, $(samples), data/$S/data.otu.obeta_analysis)
	Rscript $^ $@

data/process/rbeta_analysis.tsv : code/pool_analysis.R\
		$(foreach S, $(samples), data/$S/data.pc.rbeta_analysis)\
		$(foreach S, $(samples), data/$S/data.otu.rbeta_analysis)
	Rscript $^ $@


data/process/rffect_alpha_analysis.tsv : code/pool_ffect.R\
		$(foreach S, $(samples), data/$S/data.rffect.alpha_summary)
	Rscript $^ $@

data/process/effect_alpha_analysis.tsv : code/pool_ffect.R\
		$(foreach S, $(samples), data/$S/data.effect.alpha_summary)
	Rscript $^ $@

data/process/bffect_alpha_analysis.tsv : code/pool_ffect.R\
		$(foreach S, $(samples), data/$S/data.bffect.alpha_summary)
	Rscript $^ $@

data/process/sffect_alpha_analysis.tsv : code/pool_ffect.R\
		$(foreach S, $(samples), data/$S/data.sffect.alpha_summary)
	Rscript $^ $@



data/process/rffect_beta_analysis.tsv : code/pool_ffect.R\
		$(foreach S, $(samples), data/$S/data.rffect.beta_summary)
	Rscript $^ $@

data/process/effect_beta_analysis.tsv : code/pool_ffect.R\
		$(foreach S, $(samples), data/$S/data.effect.beta_summary)
	Rscript $^ $@

data/process/bffect_beta_analysis.tsv : code/pool_ffect.R\
		$(foreach S, $(samples), data/$S/data.bffect.beta_summary)
	Rscript $^ $@

data/process/sffect_beta_analysis.tsv : code/pool_ffect.R\
		$(foreach S, $(samples), data/$S/data.sffect.beta_summary)
	Rscript $^ $@


################################################################################
#
# Build figures and tables
#
################################################################################


# Find the amount of sequence loss from pruning
data/process/sequence_loss_table_raw.tsv : code/quantify_sequence_loss.R\
			$(foreach S, $(samples), data/$S/data.count_table)
	Rscript code/quantify_sequence_loss.R

data/process/sequence_loss_table_cor.tsv : code/quantify_correlation_with_sample_size.R\
		data/process/sequence_loss_table_raw.tsv
	Rscript code/quantify_correlation_with_sample_size.R data/process/sequence_loss_table_raw.tsv

# Find the amount of sequence coverage
data/process/sequence_coverage_table_raw.tsv : code/quantify_sample_coverage.R\
			$(foreach S, $(samples), data/$S/data.count_table)
	Rscript code/quantify_sample_coverage.R

data/process/sequence_coverage_table_cor.tsv : code/quantify_correlation_with_sample_size.R\
		data/process/sequence_coverage_table_raw.tsv
	Rscript code/quantify_correlation_with_sample_size.R data/process/sequence_coverage_table_raw.tsv



# Table that contains summary statistics about each sample
data/process/study_summary_statistics.tsv: code/get_sample_summary_statistics.R\
		$(foreach S, $(samples), data/$S/data.remove_accnos)\
		$(foreach S, $(samples), data/$S/data.count.summary)
	Rscript $<


# Plot strip chart showing the number of sequences per sample for each study
results/figures/seqs_per_sample.tiff: code/plot_seqs_per_sample.R\
		$(foreach S, $(samples), data/$S/data.remove_accnos)\
		$(foreach S, $(samples), data/$S/data.count.summary)
	Rscript $<

results/figures/correlation_coverage.tiff: code/plot_correlation_coverage.R\
		data/process/sequence_loss_table_cor.tsv\
		data/process/sequence_coverage_table_cor.tsv\
		data/process/sequence_coverage_table_raw.tsv
	Rscript $<

results/figures/%_loss_of_information_obs.tiff: \
		code/plot_loss_of_information_obs.R\
		data/process/ointra_analysis.tsv
	Rscript $<

results/figures/loss_of_information_random.tiff: \
		code/plot_loss_of_information_random.R\
		data/process/rintra_analysis.tsv
	Rscript $<

results/figures/%_coefficient_of_variation.tiff: \
		code/plot_inter_sample_variation.R\
		data/process/ralpha_analysis.tsv\
		data/process/rbeta_analysis.tsv
	Rscript $<

results/figures/%_power.tiff: \
		code/plot_power.R\
		data/process/bffect_alpha_analysis.tsv\
		data/process/bffect_beta_analysis.tsv
	Rscript $<

results/figures/%_type_one.tiff: \
		code/plot_type1.R\
		data/process/rffect_alpha_analysis.tsv\
		data/process/rffect_beta_analysis.tsv\
		data/process/sffect_alpha_analysis.tsv\
		data/process/sffect_beta_analysis.tsv
	Rscript $<


################################################################################
#
#	Build manuscript
#
################################################################################

submission/figure_1.tiff : results/figures/correlation_coverage.tiff
	cp $< $@

submission/figure_2.tiff : results/figures/asv_loss_of_information_obs.tiff
	cp $< $@

submission/figure_3.tiff : results/figures/asv_coefficient_of_variation.tiff
	cp $< $@

submission/figure_4.tiff : results/figures/asv_power.tiff
	cp $< $@

submission/figure_5.tiff : results/figures/asv_type_one.tiff
	cp $< $@


submission/figure_s1.tiff : results/figures/seqs_per_sample.tiff
	cp $< $@

submission/figure_s2.tiff : results/figures/otu_loss_of_information_obs.tiff
	cp $< $@

submission/figure_s3.tiff : results/figures/loss_of_information_random.tiff
	cp $< $@

submission/figure_s4.tiff : results/figures/otu_coefficient_of_variation.tiff
	cp $< $@

submission/figure_s5.tiff : results/figures/otu_power.tiff
	cp $< $@

submission/figure_s6.tiff : results/figures/otu_type_one.tiff
	cp $< $@


submission/manuscript.pdf submission/manuscript.md submission/manuscript.tex : \
		submission/figure_1.tiff\
		submission/figure_2.tiff\
		submission/figure_s1.tiff\
		submission/figure_s2.tiff\
		submission/mbio.csl\
		submission/header.tex\
		submission/manuscript.Rmd
	R -e "library('rmarkdown'); render('submission/manuscript.Rmd', clean=FALSE)"
	mv submission/manuscript.utf8.md submission/manuscript.md
	rm submission/manuscript.knit.md


# module load perl-modules latexdiff/1.2.0
# submission/track_changes.pdf: submission/Schloss_Singletons_XXXXX_2019.tex\
# 															submission/Schloss_Singletons_XXXXX_2019.tex
	# git cat-file -p 6adb4c388158ab59:submission/manuscript.tex > submission/manuscript_old.tex
	# latexdiff submission/manuscript_old.tex submission/manuscript.tex > submission/marked_up.tex
	# pdflatex -output-directory=submission submission/marked_up.tex
	# rm submission/marked_up.aux
	# rm submission/marked_up.log
	# rm submission/marked_up.out
	# rm submission/marked_up.tex
	# rm submission/manuscript_old.tex

# submission/response_to_reviewers.pdf : submission/response_to_reviewers.md submission/header.tex
# 	pandoc $< -o $@ --include-in-header=submission/header.tex
