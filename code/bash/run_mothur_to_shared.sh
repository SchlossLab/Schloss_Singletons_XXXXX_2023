#!/bin/bash

################################################################################
#
# run_mothur_to_shared.sh
#
# Dependencies...
#	* the fasta file
#	* the count_table
# * the taxonomy file
#
# Produces a shared file
#
################################################################################

FASTA=$1
COUNT=$2
TAXONOMY=$3

mothur "#cluster.split(fasta=${FASTA}, count=${COUNT}, taxonomy=${TAXONOMY}, splitmethod=classify, taxlevel=6, cutoff=0.15, processors=8, cluster=F);
cluster.split(file=current, processors=4);
make.shared(list=current, count=current, label=0.03)"


STUB=$(echo $FASTA | sed -E 's/.fasta//')
mv ${STUB}.*.shared ${STUB}.shared

rm ${STUB}.*.list
rm ${STUB}.file
rm ${STUB}.*.dist
