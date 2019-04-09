# Taken from https://github.com/SchlossLab/Westcott_OptiClust_mSphere_2017/tree/master/code

make_files_file <- function(){

	metadata <- read.table(file="data/human/SRP062005_info.tsv", sep='\t', header=T,
													stringsAsFactors=FALSE)

	sample_map <- metadata$Sample_Name
	names(sample_map) <- metadata$Run

	R1 <- list.files(path="data/human", pattern="*_1.fastq.gz")
	R2 <- gsub("1.fastq", "2.fastq", R1)

	file_stubs <- gsub("_1.fastq.gz", "", R1)
	sample_ids <- sample_map[file_stubs]

	no_mock_sample_ids <- sample_ids[!is.na(sample_ids)]
	no_mock_R1 <- R1[!is.na(sample_ids)]
	no_mock_R2 <- R2[!is.na(sample_ids)]

	files_data <- data.frame(no_mock_sample_ids, no_mock_R1, no_mock_R2)
	write.table(files_data, "data/human/human.files", row.names=F, col.names=F,
							quote=F, sep='\t')
}
