#!/usr/bin/env bash

SHARED=$1

LABELS=`cut -f 1 $SHARED | uniq | tail -n +2`
OUTDIST=`echo $SHARED | sed -e "s/shared/beta_matrix/"`

for label in $LABELS
do

  input=`echo $SHARED | sed -E "s/shared/dist$label.shared/"`
  
  head -n 1 $SHARED > $input
  grep "^$label\t" $SHARED >> $input

  mothur "#set.seed(seed=19760620);
          dist.shared(shared=$input, calc=braycurtis, subsample=T,
                      iters=100, processors=1)"

  rm $input
done


for label in $LABELS
do
  ave=`echo $SHARED | sed -E "s/shared/dist$label.braycurtis.$label.lt.ave.dist/"`
  std=`echo $ave | sed -E "s/ave/std/"`
  
  if [[ $label -eq 1 ]]
  then
    cat $ave > $OUTDIST
  else
      cat $ave >> $OUTDIST
  fi
  
  rm $ave $std
  
done
