#!/bin/bash

################################################################################
#
# run_mothur_to_shared.sh
#
# Dependencies...
#	* the fasta file
#	* the count_table
# * the reference mock community fasta file
#
# Produces an error_summary file
#
################################################################################

FASTA=$1
COUNT=$2
MOCK=$3

mothur "#seq.error(fasta=$FASTA, count=$COUNT, reference=$MOCK, processors=8, aligned=F)"

STUB=$(echo $FASTA | sed -E 's/.fasta//')

rm ${STUB}.error.ref
rm ${STUB}.error.matrix
rm ${STUB}.error.count
rm ${STUB}.error.seq.reverse
rm ${STUB}.error.seq.forward
rm ${STUB}.error.chimera
rm ${STUB}.error.seq

#keep:
mv ${STUB}.error.summary ${STUB}.error_summary
