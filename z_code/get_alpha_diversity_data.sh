SHARED=$1

mothur "#set.seed(seed=19760620);
summary.single(shared=$SHARED, calc=nseqs-sobs-shannon-invsimpson, subsample=T, iters=100)"

SUMMARY=`echo $SHARED | sed -e "s/.shared/groups.ave-std.summary/"`
ALPHA=`echo $SHARED | sed -e "s/shared/alpha_diversity/"`
NORARE=`echo $SHARED | sed -e "s/.shared/groups.summary/"`
RABUND=`echo $SHARED | sed -e "s/.shared/*.rabund/"`

mv $SUMMARY $ALPHA
rm -f $NORARE
rm -f $RABUND
