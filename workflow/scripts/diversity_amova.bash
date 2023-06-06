DIST=$1 #DIST=data/marine/random.1.indiv_count.5.pc.beta_matrix
DESIGN=$2 #DESIGN=data/marine/random.1.design

mothur "#amova(phylip=$DIST, design=$DESIGN)"
