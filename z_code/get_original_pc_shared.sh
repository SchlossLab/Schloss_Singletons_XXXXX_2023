DATA=$1

read REMOVE < $DATA/data.remove_accnos

if [ -z $REMOVE ]
then
	mothur "#make.shared(count=$DATA/data.count_table, label=pc)"

	mv $DATA/data.shared $DATA/data.pc.shared
	mv $DATA/data.map $DATA/data.pc_seq.map
else
	mothur "#remove.groups(count=$DATA/data.count_table, groups=$REMOVE); make.shared(count=current, label=pc)"

	mv $DATA/data.pick.shared $DATA/data.pc.shared
	mv $DATA/data.pick.map $DATA/data.pc_seq.map
	rm -f $DATA/data.pick.count_table
fi
