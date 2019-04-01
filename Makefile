MAXTIME = $$((60*60*50)) # 50 hours in seconds
MAXMEM = $$((45 * 1000 * 1000)) #(45gb = 47.9 x 1,000,000 kb)

REFS = data/references

print-%:
	@echo '$*=$($*)'


$(REFS)/silva.bact_archaea.% :
	wget -N -P $(REFS)/ http://www.mothur.org/w/images/b/be/Silva.nr_v123.tgz
	tar xvzf $(REFS)/Silva.nr_v123.tgz -C $(REFS)/;
	mothur "#get.lineage(fasta=$(REFS)/silva.nr_v123.align, taxonomy=$(REFS)/silva.nr_v123.tax, taxon=Bacteria-Archaea)";
	mv $(REFS)/silva.nr_v123.pick.align $(REFS)/silva.bact_archaea.align
	mv $(REFS)/silva.nr_v123.pick.tax $(REFS)/silva.bact_archaea.tax; \
	rm $(REFS)/README.Rmd $(REFS)/README.html
	rm $(REFS)/?ilva.nr_v123.*

$(REFS)/silva.bacteria.% : $(REFS)/silva.bact_archaea.align $(REFS)/silva.bact_archaea.tax
	mothur "#get.lineage(fasta=$(REFS)/silva.bact_archaea.align, taxonomy=$(REFS)/silva.bact_archaea.tax, taxon=Bacteria)";
	mv $(REFS)/silva.bact_archaea.pick.align $(REFS)/silva.bacteria.align
	mv $(REFS)/silva.bact_archaea.pick.tax $(REFS)/silva.bacteria.tax

$(REFS)/silva.v4.% : $(REFS)/silva.bacteria.align
	mothur "#pcr.seqs(fasta=$^, start=13862, end=23445, keepdots=F, processors=8);degap.seqs();unique.seqs()"
	cut -f 1 $(REFS)/silva.bacteria.pcr.ng.names > $(REFS)/silva.bacteria.pcr.ng.accnos
	mothur "#get.seqs(fasta=$(REFS)/silva.bacteria.pcr.align, accnos=$(REFS)/silva.bacteria.pcr.ng.accnos);screen.seqs(minlength=240, maxlength=275, maxambig=0, maxhomop=8, processors=8); filter.seqs(vertical=T)"
	mv $(REFS)/silva.bacteria.pcr.pick.good.filter.fasta $(REFS)/silva.v4.align
	grep "^>" $(REFS)/silva.v4.align | cut -c 2- > $(REFS)/silva.v4.accnos
	mothur "#get.seqs(taxonomy=$(REFS)/silva.bacteria.tax, accnos=$(REFS)/silva.v4.accnos)"
	mv data/references/silva.bacteria.pick.tax data/references/silva.v4.tax
	rm $(REFS)/silva.bacteria.pcr.*
	rm $(REFS)/silva.filter

$(REFS)/trainset14_032015.pds.% :
	mkdir -p $(REFS)/rdp
	wget -N -P $(REFS)/ http://www.mothur.org/w/images/8/88/Trainset14_032015.pds.tgz; \
	tar xvzf $(REFS)/Trainset14_032015.pds.tgz -C $(REFS)/rdp;\
	mv $(REFS)/rdp/trainset14_032015.pds/trainset14_032015.* $(REFS);\
	rm -rf $(REFS)/rdp $(REFS)/Trainset*


.SECONDEXPANSION:
data/%.fasta data/%.count_table data/%.taxonomy : code/$$(notdir $$*).batch code/$$(notdir $$*).R\
			$(REFS)/silva.v4.align\
			$(REFS)/trainset14_032015.pds.fasta\
			$(REFS)/trainset14_032015.pds.tax
	bash $<



SAMPLES = mice human soil marine even staggered
FRACTIONS = 0_2 0_4 0_6 0_8 1_0
REPLICATE = 01 02 03 04 05 06 07 08 09 10
DATAPATH = $(foreach S,$(SAMPLES),$(foreach F,$(FRACTIONS), $(foreach R, $(REPLICATE), data/$S/$S.$F.$R)))
SUB_FASTA = $(foreach D,$(DATAPATH),$D.fasta)
SUB_TAX = $(foreach D,$(DATAPATH),$D.taxonomy)
SUB_COUNT = $(foreach D,$(DATAPATH),$D.count_table)
SUB_FILES = $(SUB_FASTA) $(SUB_TAX) $(SUB_COUNT)


.SECONDEXPANSION:
$(SUB_FILES) : code/subsample.R $$(basename $$(basename $$(basename $$@))).fasta $$(basename $$(basename $$(basename $$@))).taxonomy $$(basename $$(basename $$(basename $$@))).count_table
	$(eval SAMPLE=$(basename $(basename $(basename $(notdir $@)))))
	$(eval REP=$(subst .,,$(suffix $(basename $@))))
	$(eval FRAC=$(subst .,,$(suffix $(basename $(basename $@)))))
	R -e "source('code/subsample.R'); subsample('$(SAMPLE)', '$(FRAC)', '$(REP)')"

SUB_SM_DIST = $(subst fasta,sm.dist,$(SUB_FASTA))
$(SUB_SM_DIST) : $$(subst sm.dist,fasta,$$@)
	$(eval STATS=$(subst dist,stats, $@))
	/usr/bin/time -o $(STATS) mothur "#dist.seqs(fasta=$^, cutoff=0.03, processors=8)"
	$(eval FULL_NAME=$(subst sm.dist,dist,$@))
	mv $(FULL_NAME) $@

SUB_LG_DIST = $(subst fasta,lg.dist,$(SUB_FASTA))
$(SUB_LG_DIST) : $$(subst lg.dist,fasta,$$@)
	$(eval STATS=$(subst dist,stats, $@))
	/usr/bin/time -o $(STATS) mothur "#dist.seqs(fasta=$^, cutoff=0.15, processors=8)"
	$(eval FULL_NAME=$(subst lg.dist,dist,$@))
	mv $(FULL_NAME) $@




NN_LIST = $(subst sm.dist,nn.list,$(SUB_SM_DIST))
FN_LIST = $(subst sm.dist,fn.list,$(SUB_SM_DIST))
AN_LIST = $(subst lg.dist,an.list,$(SUB_LG_DIST))
VAGC1_LIST = $(subst sm.dist,vagc_1.list,$(SUB_SM_DIST))
VDGC1_LIST = $(subst sm.dist,vdgc_1.list,$(SUB_SM_DIST))
VAGC8_LIST = $(subst sm.dist,vagc_8.list,$(SUB_SM_DIST))
VDGC8_LIST = $(subst sm.dist,vdgc_8.list,$(SUB_SM_DIST))
MCC_LIST = $(subst sm.dist,mcc.list,$(SUB_SM_DIST))
F1SCORE_LIST = $(subst sm.dist,f1score.list,$(SUB_SM_DIST))
ACCURACY_LIST = $(subst sm.dist,accuracy.list,$(SUB_SM_DIST))
SENS_LIST = $(subst sm.dist,sens.list,$(SUB_SM_DIST))
TPTN_LIST = $(subst sm.dist,tptn.list,$(SUB_SM_DIST))
FPFN_LIST = $(subst sm.dist,fpfn.list,$(SUB_SM_DIST))
TP_LIST = $(subst sm.dist,tp.list,$(SUB_SM_DIST))
OPTIFN_LIST = $(subst sm.dist,opti_fn.list,$(SUB_SM_DIST))
NPV_LIST = $(subst sm.dist,npv.list,$(SUB_SM_DIST))



SPLIT=$(basename $(SUB_FASTA))
AN_SPLT_LIST = $(foreach L,2 3 4 5 6,$(foreach B,$(SPLIT),$B.an_split$L_8.list))
MCC_SPLT_LIST = $(foreach L,2 3 4 5 6,$(foreach B,$(SPLIT),$B.mcc_split$L_8.list))
VDGC_SPLT_LIST = $(foreach L,2 3 4 5 6,$(foreach B,$(SPLIT),$B.vdgc_split$L_8.list))

UAGC_LIST = $(subst fasta,uagc.list,$(SUB_FASTA))
UDGC_LIST = $(subst fasta,udgc.list,$(SUB_FASTA))
OTUCLUST_LIST = $(subst fasta,otuclust.list,$(SUB_FASTA))
SUMACLUST_LIST = $(subst fasta,sumaclust.list,$(SUB_FASTA))
SWARM_LIST = $(subst fasta,swarm.list,$(SUB_FASTA))

MCC_AGG_LIST = $(subst sm.dist,mcc_agg.list,$(SUB_SM_DIST))

LIST = $(NN_LIST) $(FN_LIST) $(AN_LIST) $(VAGC1_LIST) $(VDGC1_LIST) $(VAGC8_LIST) $(VDGC8_LIST) $(MCC_LIST) $(F1SCORE_LIST) $(ACCURACY_LIST) $(AN_SPLT_LIST) $(MCC_SPLT_LIST) $(VDGC_SPLT_LIST) $(SWARM_LIST)  $(UAGC_LIST) $(UDGC_LIST) $(OTUCLUST_LIST) $(SUMACLUST_LIST) $(MCC_AGG_LIST) $(SENS_LIST) $(TPTN_LIST) $(FPFN_LIST) $(TP_LIST) $(OPTIFN_LIST) $(NPV_LIST)

SENSSPEC = $(subst list,sensspec,$(LIST))
STEPS = $(subst list,steps,$(MCC_LIST) $(MCC_AGG))

LIST_% :
	$(eval FILES=$(filter data/$*/%,$(LIST)))
	@echo '$(FILES)'

.SECONDEXPANSION:
$(NN_LIST) : $$(subst .nn.list,.sm.dist, $$@) $$(subst nn.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst nn.list,sm.nn.unique_list.list,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=nearest)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(FN_LIST) : $$(subst .fn.list,.sm.dist, $$@) $$(subst fn.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst fn.list,sm.fn.unique_list.list,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=furthest)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(AN_LIST) : $$(subst .an.list,.lg.dist, $$@) $$(subst an.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst an.list,lg.an.unique_list.list,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=average)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)




.SECONDEXPANSION:
$(VAGC1_LIST) : $$(subst vagc_1.list,fasta, $$@) $$(subst vagc_1.list,count_table, $$@)
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst vagc_1.list,agc.unique_list.list,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(fasta=$(FASTA), count=$(COUNT), method=agc, cutoff=0.03, processors=1)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(VDGC1_LIST) : $$(subst vdgc_1.list,fasta, $$@) $$(subst vdgc_1.list,count_table, $$@)
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst vdgc_1.list,dgc.unique_list.list,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(fasta=$(FASTA), count=$(COUNT), method=dgc, cutoff=0.03, processors=1)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(VAGC8_LIST) : $$(subst vagc_8.list,fasta, $$@) $$(subst vagc_8.list,count_table, $$@)
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst vagc_8.list,agc.unique_list.list,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(fasta=$(FASTA), count=$(COUNT), method=agc, cutoff=0.03, processors=8)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(VDGC8_LIST) : $$(subst vdgc_8.list,fasta, $$@) $$(subst vdgc_8.list,count_table, $$@)
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst vdgc_8.list,dgc.unique_list.list,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(fasta=$(FASTA), count=$(COUNT), method=dgc, cutoff=0.03, processors=8)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)




.SECONDEXPANSION:
$(MCC_LIST) : $$(subst .mcc.list,.sm.dist, $$@) $$(subst mcc.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst mcc.list,sm.opti_mcc.list,$@))
	$(eval TEMP1=$(subst mcc.list,sm.opti_mcc.sensspec,$@))
	$(eval TEMP2=$(subst mcc.list,mcc.sensspec,$@))
	$(eval TEMP3=$(subst mcc.list,sm.opti_mcc.steps,$@))
	$(eval TEMP4=$(subst mcc.list,mcc.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=mcc, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	touch $(TEMP3)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(F1SCORE_LIST) : $$(subst .f1score.list,.sm.dist, $$@) $$(subst f1score.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst f1score.list,sm.opti_f1score.list,$@))
	$(eval TEMP1=$(subst f1score.list,sm.opti_f1score.sensspec,$@))
	$(eval TEMP2=$(subst f1score.list,f1score.sensspec,$@))
	$(eval TEMP3=$(subst f1score.list,sm.opti_f1score.steps,$@))
	$(eval TEMP4=$(subst f1score.list,f1score.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=f1score, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	touch $(TEMP3)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(ACCURACY_LIST) : $$(subst .accuracy.list,.sm.dist, $$@) $$(subst accuracy.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst accuracy.list,sm.opti_accuracy.list,$@))
	$(eval TEMP1=$(subst accuracy.list,sm.opti_accuracy.sensspec,$@))
	$(eval TEMP2=$(subst accuracy.list,accuracy.sensspec,$@))
	$(eval TEMP3=$(subst accuracy.list,sm.opti_accuracy.steps,$@))
	$(eval TEMP4=$(subst accuracy.list,accuracy.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=accuracy, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(FPFN_LIST) : $$(subst .fpfn.list,.sm.dist, $$@) $$(subst fpfn.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst fpfn.list,sm.opti_fpfn.list,$@))
	$(eval TEMP1=$(subst fpfn.list,sm.opti_fpfn.sensspec,$@))
	$(eval TEMP2=$(subst fpfn.list,fpfn.sensspec,$@))
	$(eval TEMP3=$(subst fpfn.list,sm.opti_fpfn.steps,$@))
	$(eval TEMP4=$(subst fpfn.list,fpfn.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=fpfn, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)


.SECONDEXPANSION:
$(TPTN_LIST) : $$(subst .tptn.list,.sm.dist, $$@) $$(subst tptn.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst tptn.list,sm.opti_tptn.list,$@))
	$(eval TEMP1=$(subst tptn.list,sm.opti_tptn.sensspec,$@))
	$(eval TEMP2=$(subst tptn.list,tptn.sensspec,$@))
	$(eval TEMP3=$(subst tptn.list,sm.opti_tptn.steps,$@))
	$(eval TEMP4=$(subst tptn.list,tptn.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=tptn, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(NPV_LIST) : $$(subst .npv.list,.sm.dist, $$@) $$(subst npv.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst npv.list,sm.opti_npv.list,$@))
	$(eval TEMP1=$(subst npv.list,sm.opti_npv.sensspec,$@))
	$(eval TEMP2=$(subst npv.list,npv.sensspec,$@))
	$(eval TEMP3=$(subst npv.list,sm.opti_npv.steps,$@))
	$(eval TEMP4=$(subst npv.list,npv.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=npv, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(TP_LIST) : $$(subst .tp.list,.sm.dist, $$@) $$(subst tp.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst tp.list,sm.opti_tp.list,$@))
	$(eval TEMP1=$(subst tp.list,sm.opti_tp.sensspec,$@))
	$(eval TEMP2=$(subst tp.list,tp.sensspec,$@))
	$(eval TEMP3=$(subst tp.list,sm.opti_tp.steps,$@))
	$(eval TEMP4=$(subst tp.list,tp.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=tp, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(SENS_LIST) : $$(subst .sens.list,.sm.dist, $$@) $$(subst sens.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst sens.list,sm.opti_sens.list,$@))
	$(eval TEMP1=$(subst sens.list,sm.opti_sens.sensspec,$@))
	$(eval TEMP2=$(subst sens.list,sens.sensspec,$@))
	$(eval TEMP3=$(subst sens.list,sm.opti_sens.steps,$@))
	$(eval TEMP4=$(subst sens.list,sens.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=sens, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(OPTIFN_LIST) : $$(subst .opti_fn.list,.sm.dist, $$@) $$(subst opti_fn.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst opti_fn.list,sm.opti_fn.list,$@))
	$(eval TEMP1=$(subst opti_fn.list,sm.opti_fn.sensspec,$@))
	$(eval TEMP2=$(subst opti_fn.list,opti_fn.sensspec,$@))
	$(eval TEMP3=$(subst opti_fn.list,sm.opti_fn.steps,$@))
	$(eval TEMP4=$(subst opti_fn.list,opti_fn.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=fn, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)


.SECONDEXPANSION:
$(AN_SPLT_LIST) : $$(addsuffix .fasta,$$(basename $$(basename $$@)))\
										$$(addsuffix .taxonomy,$$(basename $$(basename $$@)))\
										$$(addsuffix .count_table,$$(basename $$(basename $$@)))
	$(eval FASTA=$(word 1,$^))
	$(eval TAXONOMY=$(word 2,$^))
	$(eval COUNT=$(word 3,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval LEVEL=$(subst .split,,$(suffix $(basename $(subst _,.,$(suffix $(basename $@)))))))
	$(eval TEMP=$(addsuffix .an.unique_list.list, $(basename $(basename $@))))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster.split(fasta=$(FASTA), count=$(COUNT), taxonomy=$(TAXONOMY), taxlevel=$(LEVEL), processors=8, cutoff=0.15)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)
	rm -f $(addsuffix .dist,$(basename $(basename $@)))


.SECONDEXPANSION:
$(MCC_SPLT_LIST) : $$(addsuffix .fasta,$$(basename $$(basename $$@)))\
		$$(addsuffix .taxonomy,$$(basename $$(basename $$@)))\
		$$(addsuffix .count_table,$$(basename $$(basename $$@)))
	$(eval FASTA=$(word 1,$^))
	$(eval TAXONOMY=$(word 2,$^))
	$(eval COUNT=$(word 3,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval LEVEL=$(subst .split,,$(suffix $(basename $(subst _,.,$(suffix $(basename $@)))))))
	$(eval TEMP=$(addsuffix .opti_mcc.unique_list.list, $(basename $(basename $@))))
	$(eval TEMP1=$(subst .list,.sensspec,$(TEMP)))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster.split(fasta=$(FASTA), taxonomy=$(TAXONOMY), count=$(COUNT), method=opti, metric=mcc, taxlevel=$(LEVEL), cutoff=0.03, delta=0, processors=8)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	touch $(TEMP1)
	rm $(TEMP1)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)
	rm -f $(addsuffix .dist,$(basename $(basename $@)))

.SECONDEXPANSION:
$(VDGC_SPLT_LIST) : $$(addsuffix .fasta,$$(basename $$(basename $$@)))\
		$$(addsuffix .taxonomy,$$(basename $$(basename $$@)))\
		$$(addsuffix .count_table,$$(basename $$(basename $$@)))
	$(eval FASTA=$(word 1,$^))
	$(eval TAXONOMY=$(word 2,$^))
	$(eval COUNT=$(word 3,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval LEVEL=$(subst .split,,$(suffix $(basename $(subst _,.,$(suffix $(basename $@)))))))
	$(eval TEMP=$(addsuffix .dgc.unique_list.list, $(basename $(basename $@))))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster.split(fasta=$(FASTA), count=$(COUNT), taxonomy=$(TAXONOMY), method=dgc, taxlevel=$(LEVEL), processors=8, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	mv $(TEMP) $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(UDGC_LIST) : $$(subst .udgc.list,.fasta, $$@) $$(subst .udgc.list,.count_table, $$@) code/run_udgc.sh code/uc_to_list.R
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) code/run_udgc.sh $(FASTA) $(COUNT) 2> $(TIMEOUT)
	touch $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(UAGC_LIST) : $$(subst .uagc.list,.fasta, $$@) $$(subst .uagc.list,.count_table, $$@) code/run_uagc.sh code/uc_to_list.R
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) code/run_uagc.sh $(FASTA) $(COUNT) 2> $(TIMEOUT)
	touch $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(OTUCLUST_LIST) : $$(subst .otuclust.list,.fasta, $$@) $$(subst .otuclust.list,.count_table, $$@) code/run_otuclust.sh code/run_otuclust.R
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) ./code/run_otuclust.sh $(FASTA) $(COUNT) 2> $(TIMEOUT)
	touch $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(SUMACLUST_LIST) : $$(subst .sumaclust.list,.fasta, $$@) $$(subst .sumaclust.list,.count_table, $$@) code/run_sumaclust.sh code/run_sumaclust.R
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) ./code/run_sumaclust.sh $(FASTA) $(COUNT) 2> $(TIMEOUT)
	touch $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)

.SECONDEXPANSION:
$(SWARM_LIST) : $$(subst swarm.list,fasta, $$@) $$(subst swarm.list,count_table, $$@) code/run_swarm.R
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) R -e 'source("code/run_swarm.R"); get_mothur_list("$(FASTA)", "$(COUNT)")' 2> $(TIMEOUT)
	touch $@
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)



.SECONDEXPANSION:
$(MCC_AGG_LIST) : $$(subst .mcc_agg.list,.sm.dist, $$@) $$(subst mcc_agg.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TIMEOUT=$(subst list,timeout, $@))
	$(eval TEMP=$(subst mcc_agg.list,sm.opti_mcc.list,$@))
	$(eval TEMP1=$(subst mcc_agg.list,sm.opti_mcc.sensspec,$@))
	$(eval TEMP2=$(subst mcc_agg.list,mcc_agg.sensspec,$@))
	$(eval TEMP3=$(subst mcc_agg.list,sm.opti_mcc.steps,$@))
	$(eval TEMP4=$(subst mcc_agg.list,mcc_agg.steps,$@))
	/usr/bin/time -o $(STATS) code/timeout -t $(MAXTIME) -s $(MAXMEM) mothur "#cluster(column=$(DIST), count=$(COUNT), method=opti, metric=mcc, initialize=oneotu, delta=0, cutoff=0.03)" 2> $(TIMEOUT)
	touch $(TEMP)
	touch $(TEMP1)
	touch $(TEMP3)
	mv $(TEMP) $@
	mv $(TEMP1) $(TEMP2)
	mv $(TEMP3) $(TEMP4)
	cat $(TIMEOUT) >> $(STATS)
	rm $(TIMEOUT)


%.sm.stats :
	rm $*.sm.dist
	$(MAKE) $*.sm.dist

%.lg.stats :
	rm $*.lg.dist
	$(MAKE) $*.lg.dist

%.stats :
	rm $*.list
	$(MAKE) $*.list

%.steps :
	rm $*.list
	$(MAKE) $*.list



.SECONDEXPANSION:
$(SENSSPEC) : $$(subst sensspec,list, $$@) $$(addsuffix .sm.dist, $$(basename $$(basename $$@))) $$(addsuffix .count_table,$$(basename $$(basename $$@)))
	$(eval LIST=$(word 1,$^))
	$(eval DIST=$(word 2,$^))
	$(eval COUNT=$(word 3,$^))
	touch $@
	mothur "#sens.spec(list=$(LIST), column=$(DIST), count=$(COUNT), cutoff=0.03, label=0.03)"


# Generate files that summarize all of the above analyses
data/processed/distance_counts.tsv : $(SUB_SM_DIST)
	wc -l data/*/*.1_0.01.sm.dist | grep "data" | sed "s/^ *//g" | sed "s/ /\t/" > data/processed/distance_counts.tsv

data/processed/sobs_counts.tsv : $(LIST)
	> $@
	find data/*/*list -type f -print0 | xargs -0 grep '^0\.03\|user' | cut -f 1,2 | sed 's/:/\t/' >> $@

data/processed/cluster_data.summary : data/processed/sobs_counts.tsv $(STATS) $(SUB_SM_DIST) $(SUB_LG_DIST) $(SENSSPEC) code/aggregate_stats.R
	R -e "source('code/aggregate_stats.R')"

data/processed/mcc_steps.summary: $(STEPS) data/processed/cluster_data.summary code/aggregate_steps.R
	R -e "source('code/aggregate_steps.R')"


COUNT_FILES=$(foreach S,$(SAMPLES),data/$S/$S.count_table)

data/processed/datasets.summary: code/summarize_datasets.R $(COUNT_FILES) data/processed/distance_counts.tsv data/processed/sobs_counts.tsv
	R -e "source('code/summarize_datasets.R')"



# Build figures...

results/figures/performance.% :\
																	code/build_performance_figure.R\
																	data/processed/cluster_data.summary
	R -e "source('code/build_performance_figure.R')"

results/figures/performance_other.% :\
																	code/build_performance_other_figure.R\
																	data/processed/cluster_data.summary
	R -e "source('code/build_performance_other_figure.R')"

results/figures/optimization.% : code/build_optimization_figure.R\
																	$(STEPS)
	R -e "source('code/build_optimization_figure.R')"

results/figures/speed_memory.% : code/build_scaling_figure.R\
																		data/processed/mcc_steps.summary\
																		data/processed/cluster_data.summary
	R -e "source('code/build_scaling_figure.R')"

results/figures/split_mcc.% : code/build_split_figure.R\
																data/processed/cluster_data.summary
	R -e "source('code/build_split_figure.R')"

results/tables/table_s1.pdf : results/tables/table_s1.Rmd data/processed/cluster_data.summary
	R -e 'render("$<")'

submission/supplemental_text.pdf : submission/supplemental_text.Rmd
	R -e 'render("$<")'

# Build manuscript...

write.paper : submission/msphere.csl\
							submission/header.tex\
							data/processed/mcc_steps.summary\
							data/processed/cluster_data.summary\
							results/figures/performance.eps results/figures/performance.png\
							results/figures/optimization.eps results/figures/optimization.png\
							results/figures/performance_other.eps results/figures/performance_other.png\
							results/figures/speed_memory.eps results/figures/speed_memory.png\
							results/figures/split_mcc.eps results/figures/split_mcc.png\
							submission/supplemental_text.pdf\
							results/tables/table_s1.pdf
	R -e "render('submission/Westcott_OptiClust_mSphere_2016.Rmd', clean=FALSE)"
	mv submission/Westcott_OptiClust_mSphere_2016.utf8.md submission/Westcott_OptiClust_mSphere_2016.md
	rm submission/Westcott_OptiClust_mSphere_2016.knit.md


submission/track_changes.pdf: submission/Westcott_OptiClust_mSphere_2016_orig.tex\
															submission/Westcott_OptiClust_mSphere_2016.tex
	latexdiff submission/Westcott_OptiClust_mSphere_2016_orig.tex submission/Westcott_OptiClust_mSphere_2016.tex > diff.tex
	pdflatex diff.tex
	mv diff.pdf submission/track_changes.pdf
	rm diff.*

submission/response_to_reviewers.pdf : submission/response_to_reviewers.md submission/header.tex
	pandoc $< -o $@ --include-in-header=submission/header.tex
