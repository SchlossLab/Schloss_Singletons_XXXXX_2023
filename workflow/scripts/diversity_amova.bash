#!/usr/bin/env bash

DIST=$1 #DIST=data/marine/random.indiv_count.2.pc.beta_matrix
DESIGN=$2 #DESIGN=data/marine/random.design

DIST_STUB=`echo $DIST | sed -e "s/beta_matrix//"`
N_SAMPLES=`head -n 1 $DIST`
let "N_LINES=$N_SAMPLES+1"

split -l $N_LINES --additional-suffix=.beta_matrix $DIST $DIST_STUB #good

HEADER=`head -n 1 $DESIGN | cut -f 2,3`

cut -f 2,3 $DESIGN | tail -n +2 | split -l $N_SAMPLES --additional-suffix=.design - $DIST_STUB

for file in $DIST_STUB??.design
do
 sed -i '' $'1i\
group\ttreatment\n' $file
done

  
for design in $DIST_STUB??.design
do
  matrix=`echo $design | sed -e "s/design/beta_matrix/"`
  mothur "#amova(phylip=$matrix, design=$design)"
done

AMOVA_FILES="${DIST_STUB}??.amova"
grep "p-value" $AMOVA_FILES ${DIST_STUB}amova | cut -f 1,3 -d ":" | sed "s/[:*<]//g" > "${DIST_STUB}amova"

rm -f mothur*logfile $AMOVA_FILES $DIST_STUB??.design $DIST_STUB??.beta_matrix
