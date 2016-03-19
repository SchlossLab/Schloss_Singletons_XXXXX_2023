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
# Produces a shared file
#
################################################################################

FASTA=$1
COUNT=$2
MOCK=$3

mothur "#seq.error(fasta=$FASTA, count=$COUNT, reference=$MOCK, processors=8, aligned=F)"
