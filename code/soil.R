make_files_file <- function(){

	mimarks <- read.table(file="data/soil/soil.metadata", header=T,
	 											stringsAsFactors=FALSE, sep='\t')

	sample_map <- mimarks$Sample_Name_s
	names(sample_map) <- mimarks$Run_s

	read_1 <- list.files(path="data/soil/", pattern="*1.fastq.gz")
	read_2 <- gsub("_1", "_2", read_1)

	stub <- gsub("_1.*", "", read_1)
	sample <- sample_map[stub]

	files <- data.frame(sample, read_1, read_2)
	write.table(files, "data/soil/soil.files", row.names=F, col.names=F, quote=F, sep='\t')

}
