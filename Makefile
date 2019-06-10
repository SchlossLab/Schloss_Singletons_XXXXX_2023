####################################################################################################
#
# Helper functions and definitions
#
####################################################################################################

print-%:
	@echo '$*=$($*)'

SEED := $(shell seq 100)
PRUNE := $(shell seq 11)


####################################################################################################
#
# Obtain the necessary reference files
#
####################################################################################################

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


####################################################################################################
#
# Generate pruned versions of datasets based on the original assignments of sequences to each sample
#
####################################################################################################

# Run datasets { mice human soil marine etc. } through mothur pipeline through remove.lineage
%/data.fasta %/data.count_table %/data.taxonomy : code/datasets_process.sh\
			code/datasets_download.sh\
			code/datasets_make_files.R\
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


####################################################################################################
#
# Generate pruned versions of datasets based on random assignments of sequences to each sample
#
####################################################################################################

.SECONDEXPANSION:
%.rand_pruned_groups : code/randomize_prune.R\
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




####################################################################################################
#
# Generate diversity files
#
####################################################################################################

%n_seqs : %shared code/get_nseqs.sh
	bash code/get_nseqs.sh $<


%alpha_diversity : %shared code/get_alpha_diversity_data.sh
	bash code/get_alpha_diversity_data.sh $<


%beta_diversity : %shared code/get_beta_diversity_data.sh
	bash code/get_beta_diversity_data.sh $<


####################################################################################################
#
# Synthesize diversity files
#
####################################################################################################

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


####################################################################################################
#
# Build figures
#
####################################################################################################




####################################################################################################
#
#	Build manuscript
#
####################################################################################################

submission/manuscript.pdf submission/manuscript.md submission/manuscript.tex : submission/mbio.csl\
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
