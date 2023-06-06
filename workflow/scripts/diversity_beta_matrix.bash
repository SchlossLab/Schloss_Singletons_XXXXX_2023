SHARED=$1

mothur "#set.seed(seed=19760620);
        dist.shared(shared=$SHARED, calc=braycurtis,subsample=T,
                    iters=100, processors=1)"

INDIST=`echo $SHARED | sed -e "s/shared/braycurtis*.ave.dist/"`
OUTDIST=`echo $SHARED | sed -e "s/shared/beta_matrix/"`

mv $INDIST $OUTDIST
rm -f `echo $INDIST | sed -e "s/ave/std/"`
