DATA=$1

PROCESSORSSPLIT=8
PROCESSORSCLUSTER=1


read REMOVE < $DATA/data.remove_accnos

if [ -z $REMOVE ]
then
	mothur "#set.seed(seed=19760620);set.dir(input=$DATA); cluster.split(fasta=data.fasta, count=data.count_table, taxonomy=data.taxonomy, taxlevel=4, processors=$PROCESSORSSPLIT, runsensspec=FALSE, cluster=FALSE); cluster.split(file=current, processors=$PROCESSORSCLUSTER, runsensspec=FALSE);make.shared()"

	mv $DATA/data.opti_mcc.shared $DATA/data.otu.shared
	mv $DATA/data.opti_mcc.list $DATA/data.otu.list
	rm -f $DATA/data.file
else
	mothur "#set.seed(seed=19760620);set.dir(input=$DATA); remove.groups(fasta=data.fasta, count=data.count_table, taxonomy=data.taxonomy, groups=$REMOVE);cluster.split(fasta=current, count=current, taxonomy=current, taxlevel=4, processors=$PROCESSORSSPLIT, runsensspec=FALSE, cluster=FALSE); cluster.split(file=current, processors=$PROCESSORSCLUSTER, runsensspec=FALSE);make.shared()"

	mv $DATA/data.pick.opti_mcc.shared $DATA/data.otu.shared
	mv $DATA/data.pick.opti_mcc.list $DATA/data.otu.list

	rm -f $DATA/data.pick.fasta $DATA/data.pick.count_table $DATA/data.pick.taxonomy $DATA/data.pick.file
fi
