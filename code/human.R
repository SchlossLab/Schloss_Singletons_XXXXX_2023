make_files_file <- function(){

	metadata <- read.table(file="data/human/human.metadata", sep='\t', header=T,
													stringsAsFactors=FALSE)

	mocks <- grepl("mock", metadata$Sample_Name_s)
	metadata <- metadata[!mocks,]

	sample_map <- metadata$Sample_Name_s
	names(sample_map) <- metadata$Run_s

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
