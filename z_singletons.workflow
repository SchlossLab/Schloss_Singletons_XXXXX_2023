# Generate basic data files that are needed for original, random, and effect pruning
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_otu_seq.slurm
echo "make data/$dir/data.fasta" >> ${dir}_otu_seq.slurm
echo "make data/$dir/data.pc.shared" >> ${dir}_otu_seq.slurm
echo "make data/$dir/data.otu.shared" >> ${dir}_otu_seq.slurm
echo "make data/$dir/data.otu_seq.map" >> ${dir}_otu_seq.slurm
cat slurm/tail.slurm >> ${dir}_otu_seq.slurm
done



# Generate original pruning files - pruning by sample
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/orig_prune_head.slurm ${dir}_orig_prune.slurm
echo "make data/$dir"'/data.$RARE.pc.oshared' >> ${dir}_orig_prune.slurm
echo "make data/$dir"'/data.$RARE.otu.oshared' >> ${dir}_orig_prune.slurm
cat slurm/tail.slurm >> ${dir}_orig_prune.slurm
done

# Generate n_seqs, alpha diversity, and beta diversity files for original pruning files - pruning by sample
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/orig_prune_head.slurm ${dir}_orig_ab.slurm
echo "make data/$dir"'/data.$RARE.pc.on_seqs' >> ${dir}_orig_ab.slurm
echo "make data/$dir"'/data.$RARE.pc.oalpha_diversity' >> ${dir}_orig_ab.slurm
echo "make data/$dir"'/data.$RARE.pc.obeta_matrix' >> ${dir}_orig_ab.slurm
echo "make data/$dir"'/data.$RARE.pc.obeta_diversity' >> ${dir}_orig_ab.slurm

echo "make data/$dir"'/data.$RARE.otu.on_seqs' >> ${dir}_orig_ab.slurm
echo "make data/$dir"'/data.$RARE.otu.oalpha_diversity' >> ${dir}_orig_ab.slurm
echo "make data/$dir"'/data.$RARE.otu.obeta_matrix' >> ${dir}_orig_ab.slurm
echo "make data/$dir"'/data.$RARE.otu.obeta_diversity' >> ${dir}_orig_ab.slurm
cat slurm/tail.slurm >> ${dir}_orig_ab.slurm
done

# Generate original intra_analysis data files - pruning by sample
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_ointra_analysis.slurm
echo "make data/$dir/data.pc.ointra_analysis" >> ${dir}_ointra_analysis.slurm
echo "make data/$dir/data.otu.ointra_analysis" >> ${dir}_ointra_analysis.slurm
cat slurm/tail.slurm >> ${dir}_ointra_analysis.slurm
done

# Aggregate original pruned alpha diversity data - pruning by sample
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_oalpha_analysis.slurm
echo "make data/$dir/data.pc.oalpha_analysis" >> ${dir}_oalpha_analysis.slurm
echo "make data/$dir/data.otu.oalpha_analysis" >> ${dir}_oalpha_analysis.slurm
cat slurm/tail.slurm >> ${dir}_oalpha_analysis.slurm
done

# Aggregate original pruned beta diversity data - pruning by sample
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_obeta_analysis.slurm
echo "make data/$dir/data.pc.obeta_analysis" >> ${dir}_obeta_analysis.slurm
echo "make data/$dir/data.otu.obeta_analysis" >> ${dir}_obeta_analysis.slurm
cat slurm/tail.slurm >> ${dir}_obeta_analysis.slurm
done




################################################################################
################################################################################


# Generate random assignment with pruning files - based on single samples
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/rand_prune_head.slurm ${dir}_rand_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".rand_pruned_groups" >> ${dir}_rand_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.rshared" >> ${dir}_rand_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.rshared" >> ${dir}_rand_prune.slurm
cat slurm/tail.slurm >> ${dir}_rand_prune.slurm
done

# Generate random assignment with pruning files - based on single samples
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/rand_prune_head.slurm ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.rn_seqs" >> ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.ralpha_diversity" >> ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.rbeta_matrix" >> ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.rbeta_diversity" >> ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.ramova" >> ${dir}_rand_ab.slurm

echo "make data/$dir/data."'$SEED.$RARE'".otu.rn_seqs" >> ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.ralpha_diversity" >> ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.rbeta_matrix" >> ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.rbeta_diversity" >> ${dir}_rand_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.ramova" >> ${dir}_rand_ab.slurm
cat slurm/tail.slurm >> ${dir}_rand_ab.slurm
done

# Generate randomized intra_analysis data files
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_rintra_analysis.slurm
echo "make data/$dir/data.pc.rintra_analysis" >> ${dir}_rintra_analysis.slurm
echo "make data/$dir/data.otu.rintra_analysis" >> ${dir}_rintra_analysis.slurm
cat slurm/tail.slurm >> ${dir}_rintra_analysis.slurm
done

# Aggregate random pruned alpha diversity data
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_ralpha_analysis.slurm
echo "make data/$dir/data.pc.ralpha_analysis" >> ${dir}_ralpha_analysis.slurm
echo "make data/$dir/data.otu.ralpha_analysis" >> ${dir}_ralpha_analysis.slurm
cat slurm/tail.slurm >> ${dir}_ralpha_analysis.slurm
done

# Aggregate random pruned beta diversity data
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_rbeta_analysis.slurm
echo "make data/$dir/data.pc.rbeta_analysis" >> ${dir}_rbeta_analysis.slurm
echo "make data/$dir/data.otu.rbeta_analysis" >> ${dir}_rbeta_analysis.slurm
cat slurm/tail.slurm >> ${dir}_rbeta_analysis.slurm
done

# Aggregate random effect size alpha and beta diversity data and run wilcox test on alpha
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_rffect_analysis.slurm
echo "make data/$dir/data.rffect.alpha_summary" >> ${dir}_rffect_analysis.slurm
echo "make data/$dir/data.rffect.beta_summary" >> ${dir}_rffect_analysis.slurm
cat slurm/tail.slurm >> ${dir}_rffect_analysis.slurm
done


################################################################################
################################################################################

# Generate effect size assignment with richness-based pruning files - this allows us to keep/remove
# a specified number of unique sequences
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/rand_prune_head.slurm ${dir}_effect_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".effect_pruned_groups" >> ${dir}_effect_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.eshared" >> ${dir}_effect_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.eshared" >> ${dir}_effect_prune.slurm
cat slurm/tail.slurm >> ${dir}_effect_prune.slurm
done

# Generate effect size alpha and beta diversity files with richness-based effect size
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/rand_prune_head.slurm ${dir}_effect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.ealpha_diversity" >> ${dir}_effect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.ebeta_matrix" >> ${dir}_effect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.ebeta_diversity" >> ${dir}_effect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.eamova" >> ${dir}_effect_ab.slurm

echo "make data/$dir/data."'$SEED.$RARE'".otu.ealpha_diversity" >> ${dir}_effect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.ebeta_matrix" >> ${dir}_effect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.ebeta_diversity" >> ${dir}_effect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.eamova" >> ${dir}_effect_ab.slurm
cat slurm/tail.slurm >> ${dir}_effect_ab.slurm
done

# Aggregate richness-based effect size alpha diversity data and run wilcox test on them
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_ealpha_analysis.slurm
echo "make data/$dir/data.effect.alpha_summary" >> ${dir}_ealpha_analysis.slurm
echo "make data/$dir/data.effect.beta_summary" >> ${dir}_ealpha_analysis.slurm
cat slurm/tail.slurm >> ${dir}_ealpha_analysis.slurm
done


###################################################################################################

# Generate effect size assignment with abundance-based pruning files - this approach allows us to
# perturb a fraction of the unique sequences by a specified percent
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/rand_prune_head.slurm ${dir}_bffect_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".bffect_pruned_groups" >> ${dir}_bffect_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.bshared" >> ${dir}_bffect_prune.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.bshared" >> ${dir}_bffect_prune.slurm
cat slurm/tail.slurm >> ${dir}_bffect_prune.slurm
done

# Generate effect size alpha and beta diversity files with abundance-based effect size
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/rand_prune_head.slurm ${dir}_bffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.balpha_diversity" >> ${dir}_bffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.bbeta_matrix" >> ${dir}_bffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.bbeta_diversity" >> ${dir}_bffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.bamova" >> ${dir}_bffect_ab.slurm

echo "make data/$dir/data."'$SEED.$RARE'".otu.balpha_diversity" >> ${dir}_bffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.bbeta_matrix" >> ${dir}_bffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.bbeta_diversity" >> ${dir}_bffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.bamova" >> ${dir}_bffect_ab.slurm
cat slurm/tail.slurm >> ${dir}_bffect_ab.slurm
done

# Aggregate abundance-based effect size alpha diversity data and run wilcox test on them
# waiting on [bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus]
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_balpha_analysis.slurm
echo "make data/$dir/data.bffect.alpha_summary" >> ${dir}_balpha_analysis.slurm
echo "make data/$dir/data.bffect.beta_summary" >> ${dir}_balpha_analysis.slurm
cat slurm/tail.slurm >> ${dir}_balpha_analysis.slurm
done


###################################################################################################

# Generate skewed abundance assignment with abundance-based pruning files
# waiting on mice bioethanol human lake marine rainforest rice seagrass sediment soil stream peromyscus

for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/rand_prune_head.slurm ${dir}_sffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".sdesign" >> ${dir}_sffect_ab.slurm

echo "make data/$dir/data."'$SEED.$RARE'".pc.salpha_diversity" >> ${dir}_sffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.sbeta_matrix" >> ${dir}_sffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.sbeta_diversity" >> ${dir}_sffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".pc.samova" >> ${dir}_sffect_ab.slurm

echo "make data/$dir/data."'$SEED.$RARE'".otu.salpha_diversity" >> ${dir}_sffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.sbeta_matrix" >> ${dir}_sffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.sbeta_diversity" >> ${dir}_sffect_ab.slurm
echo "make data/$dir/data."'$SEED.$RARE'".otu.samova" >> ${dir}_sffect_ab.slurm
cat slurm/tail.slurm >> ${dir}_sffect_ab.slurm
done


# waiting on bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
for dir in bioethanol human lake marine mice rainforest rice seagrass sediment soil stream peromyscus
do
cp slurm/head.slurm ${dir}_salpha_analysis.slurm
echo "make data/$dir/data.sffect.alpha_summary" >> ${dir}_salpha_analysis.slurm
echo "make data/$dir/data.sffect.beta_summary" >> ${dir}_salpha_analysis.slurm
cat slurm/tail.slurm >> ${dir}_salpha_analysis.slurm
done

#here

