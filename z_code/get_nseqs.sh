SHARED=$1

mothur "#count.groups(shared=$SHARED)"

NSEQS=`echo $SHARED | sed -e "s/shared/n_seqs/"`

echo -e 'group\tcount' > $NSEQS
COUNT=`echo $SHARED | sed -e "s/.shared/count.summary/"`
cat $COUNT >> $NSEQS

rm $COUNT
