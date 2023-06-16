#!/usr/bin/env bash

# Should come in as a directory to dataset like data/marine
DATA=$1

mothur "#count.groups(count=$DATA/data.count_table)"
