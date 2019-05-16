SHARED=$1

mothur "#set.seed(seed=19760620);
dist.shared(shared=$SHARED, calc=braycurtis, subsample=T, iters=100, processors=1, output=column)"

INDIST=`echo $SHARED | sed -e "s/.shared/braycurtis*.ave.dist/"`
OUTDIST=`echo $SHARED | sed -e "s/shared/beta_diversity/"`

mv $INDIST $OUTDIST
rm -f `echo $INDIST | sed -e "s/ave/std/"`
rm -f `echo $INDIST | sed -e "s/ave.//"`
