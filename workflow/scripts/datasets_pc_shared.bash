#!/usr/bin/env bash

DATA=$1

read REMOVE < $DATA/data.remove_accnos

if [ -z $REMOVE ]
then
	mothur "#make.shared(count=$DATA/data.count_table, label=1)"

	mv $DATA/data.asv.shared $DATA/observed.pc.shared
	mv $DATA/data.asv.list $DATA/data.pc.list
else
	mothur "#remove.groups(count=$DATA/data.count_table, groups=$REMOVE);
					make.shared(count=current, label=pc)"

	mv $DATA/data.pick.asv.shared $DATA/observed.pc.shared
	mv $DATA/data.pick.asv.list $DATA/data.pc.list
	rm -f $DATA/data.pick.count_table
fi
