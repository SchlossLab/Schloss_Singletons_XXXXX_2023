DIST=$1
DESIGN=$2

mothur "#amova(phylip=$DIST, design=$DESIGN)"

OUTPUT=`echo $DIST | sed -e "s/.beta_matrix/amova/"`
AMOVA=`echo $DIST | sed -e "s/beta_matrix/amova/"`

mv $OUTPUT $AMOVA
