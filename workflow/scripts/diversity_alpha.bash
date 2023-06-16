#!/usr/bin/env bash

SHARED=$1

LABELS=`cut -f 1 $SHARED | uniq | tail -n +2`

for label in $LABELS
do
  input=`echo $SHARED | sed -E "s/shared/alpha$label.shared/"`
  
  head -n 1 $SHARED > $input
  grep "^$label\t" $SHARED >> $input
  
  mothur "#set.seed(seed=19760620);
          summary.single(shared=$input,
                         calc=nseqs-sobs-shannon-invsimpson, subsample=T,
                         iters=100)"
  
  rm $input
  RABUND=`echo $input | sed -e "s/.shared/*.rabund/"`
  rm -f $RABUND

done

SUMMARY=`echo $SHARED | sed -e "s/shared/alpha*groups.ave-std.summary/"`
ALPHA=`echo $SHARED | sed -e "s/shared/alpha/"`

head -n 1 `echo $SHARED | sed -e "s/shared/alpha1.groups.ave-std.summary/"` | cut -f 1-2,4- > $ALPHA
grep -h "ave" $SUMMARY | cut -f 1-2,4- >> $ALPHA

rm -f $SUMMARY