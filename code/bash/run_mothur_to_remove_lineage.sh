#!/bin/bash

################################################################################
#
# run_mothur_to_remove_lineage.sh
#
# Dependencies...
# * The *.fastq files out of the data/raw/ directory
#	* The Kozich run number (RUN)
# * The sample name (SAMPE: mock, mouse, human, soil)
# * The deltaq to use in make.contigs (DELTAQ)
#
# Produces the fasta, count_table, and taxonomy files where the sequences have
# had the chimeras and obvious contaminants removed.
#
################################################################################

RUN=$1
SAMPLE=$2
DELTAQ=$3

REFS=data/references
RAW=data/raw/${RUN}
PROCESS=data/process/${RUN}

mkdir -p ${PROCESS}
cp "data/references/${SAMPLE}.files" "${PROCESS}/${SAMPLE}_${DELTAQ}.files"

mothur "#make.contigs(file=${PROCESS}/${SAMPLE}_${DELTAQ}.files, deltaq=${DELTAQ}, processors=8, rename=T, inputdir=${RAW}/, outputdir=${PROCESS}/);
screen.seqs(fasta=current, group=current, maxambig=0, minlength=225, maxlength=275, maxhomop=8, inputdir=${PROCESS}/, outputdir=${PROCESS}/);
unique.seqs(fasta=current);
count.seqs(name=current, group=current);
align.seqs(fasta=current, reference=${REFS}/silva.v4.align);
screen.seqs(fasta=current, count=current, start=1968, end=11550);
filter.seqs(fasta=current, vertical=T, trump=.);
unique.seqs(fasta=current, count=current);
pre.cluster(fasta=current, count=current);
chimera.uchime(fasta=current, count=current, dereplicate=t);
remove.seqs(fasta=current, accnos=current);
classify.seqs(fasta=current, count=current, reference=${REFS}/trainset9_032012.pds.fasta, taxonomy=${REFS}/trainset9_032012.pds.tax, cutoff=80);
remove.lineage(fasta=current, count=current, taxonomy=current, taxon=Chloroplast-Mitochondria-unknown-Archaea-Eukaryota);"

STUB=${PROCESS}/${SAMPLE}_${DELTAQ}
#rename...
mv ${STUB}.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table ${STUB}.count_table
mv ${STUB}.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta ${STUB}.fasta
mv ${STUB}.trim.contigs.good.unique.good.filter.unique.precluster.pick.pds.wang.pick.taxonomy ${STUB}.taxonomy

rm ${STUB}.*contigs*
rm ${STUB}.filter
rm ${STUB}.files
