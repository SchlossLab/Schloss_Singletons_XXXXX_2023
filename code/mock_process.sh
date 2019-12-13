#!/bin/bash

# Should come in as a directory to dataset like data/marine
DATA=$1


# Download, split, and compress the sequene read files listed in $DATA/sra_info.tsv. This file is described
# in the script's header comment
bash code/datasets_download.sh $DATA


# Generate $DATA/data.files from downloaded file names and information in $DATA/sra_info.tsv
Rscript code/datasets_make_files.R $DATA


# Run data through standard mothur pipeline through the steps prior to clustering
mothur "#set.seed(seed=19760620);
	set.dir(output=$DATA);
	make.contigs(inputdir=$DATA, file=data.files, processors=6);
	screen.seqs(fasta=current, group=current, maxambig=0, maxlength=275, maxhomop=8);
	unique.seqs();
	count.seqs(name=current, group=current);
	align.seqs(fasta=current, reference=data/references/silva.v4.align);
	screen.seqs(fasta=current, count=current, start=8, end=9582);
	filter.seqs(fasta=current, vertical=T, trump=.);
	unique.seqs(fasta=current, count=current);
	pre.cluster(fasta=current, count=current, diffs=2);
	chimera.uchime(fasta=current, count=current, dereplicate=T);
	remove.seqs(fasta=current, accnos=current);
	classify.seqs(fasta=current, count=current, reference=data/references/trainset16_022016.pds.fasta, taxonomy=data/references/trainset16_022016.pds.tax, cutoff=80)"


# Clean up the output data files

# We want to keep $DATA/data.fasta, $DATA/data.count_table, $DATA/data.taxonomy for future steps
mv $DATA/data.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta $DATA/data.fasta
mv $DATA/data.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.count_table $DATA/data.count_table
mv $DATA/data.trim.contigs.good.unique.good.filter.unique.precluster.pick.pds.wang.taxonomy $DATA/data.taxonomy

# Remove fastq files and all intermediate mothur files to keep things organized
rm $DATA/*fastq*
rm $DATA/*.contigs.*
rm $DATA/*.filter
rm $DATA/*files
