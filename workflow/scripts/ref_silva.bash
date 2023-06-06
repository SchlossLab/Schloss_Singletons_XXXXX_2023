#!/usr/bin/env bash

# generates silva.v4.align silva.v4.tax

wget -N -P data/references/ https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.seed_v132.tgz
tar xvzf data/references/Silva.seed_v132.tgz -C data/references
mothur "#get.lineage(fasta=data/references/silva.seed_v132.align, taxonomy=data/references/silva.seed_v132.tax, taxon=Bacteria);pcr.seqs(start=13862, end=23445, keepdots=F, processors=1);degap.seqs();unique.seqs()"
cut -f 1 data/references/silva.seed_v132.pick.pcr.ng.count_table | tail +2 > data/references/silva.seed_v132.pick.pcr.ng.accnos
mothur "#get.seqs(fasta=data/references/silva.seed_v132.pick.pcr.align, accnos=data/references/silva.seed_v132.pick.pcr.ng.accnos);screen.seqs(minlength=240, maxlength=275, maxambig=0, maxhomop=8, processors=1)"
mv data/references/silva.seed_v132.pick.pcr.pick.good.align data/references/silva.v4.align
grep "^>" data/references/silva.v4.align | cut -c 2- > data/references/silva.v4.accnos
mothur "#get.seqs(taxonomy=data/references/silva.seed_v132.pick.tax, accnos=data/references/silva.v4.accnos)"
mv data/references/silva.seed_v132.pick.pick.tax  data/references/silva.v4.tax
rm data/references/?ilva.seed_v132* data/references/silva.v4.accnos
