print-%:
	@echo '$*=$($*)'



data/raw/crc.shared :
	wget --no-check-certificate https://github.com/SchlossLab/Baxter_glne007Modeling_2015/blob/master/data/glne007.final.an.unique_list.shared?raw=true -O $@

data/raw/mouse_time.shared :
	wget --no-check-certificate https://github.com/SchlossLab/Kozich_MiSeqSOP_AEM_2013/blob/master/data/process/no_metag/no_metag.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.an.unique_list.shared?raw=true -O $@
