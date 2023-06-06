#!/bin/bash

# Should come in as a directory to dataset like data/marine
DATA=$1
PROCESSORS=$2

# Run data through standard mothur pipeline through the steps prior to clustering
mothur "#set.dir(seed=19760620, output=$DATA, input=$DATA);
	make.contigs(file=data.files, processors=$PROCESSORS);
	unique.seqs(fasta=current, count=current);
	screen.seqs(fasta=current, count=current, maxambig=0, maxlength=275, maxhomop=8);
	align.seqs(fasta=current, reference=data/references/silva.v4.align);
	screen.seqs(fasta=current, count=current, start=8, end=9582);
	filter.seqs(fasta=current, vertical=T, trump=.);
	unique.seqs(fasta=current, count=current);
	pre.cluster(fasta=current, count=current, diffs=2);
	chimera.vsearch(fasta=current, count=current, dereplicate=T);
	classify.seqs(fasta=current, count=current, reference=data/references/trainset18_062020.pds.fasta, taxonomy=data/references/trainset18_062020.pds.tax, cutoff=80);
	remove.lineage(fasta=current, count=current, taxonomy=current, taxon=Chloroplast-Mitochondria-unknown-Archaea-Eukaryota);"


# Clean up the output data files
# We want to keep $DATA/data.fasta, $DATA/data.count_table, $DATA/data.taxonomy for future steps
mv $DATA/data.trim.contigs.unique.good.good.filter.unique.precluster.denovo.vsearch.pick.fasta $DATA/data.fasta
mv $DATA/data.trim.contigs.unique.good.good.filter.unique.precluster.denovo.vsearch.pick.count_table $DATA/data.count_table
mv $DATA/data.trim.contigs.unique.good.good.filter.unique.precluster.denovo.vsearch.pds.wang.pick.taxonomy $DATA/data.taxonomy



# Remove fastq files and all intermediate mothur files to keep things organized
rm -f $DATA/*.contigs.*
rm -f $DATA/data.filter $DATA/data.contigs_report
