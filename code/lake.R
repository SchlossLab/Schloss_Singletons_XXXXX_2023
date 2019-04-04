# Taken from https://github.com/SchlossLab/Westcott_OptiClust_mSphere_2017/tree/master/code

make_files_file <- function(){

	mimarks <- read.table(file="data/lake/SRP050963_info.csv", header=T,
	 											stringsAsFactors=FALSE, sep='\t')

	sample_map <- mimarks$Run
	names(sample_map) <- mimarks$Run

	read_1 <- list.files(path="data/lake/", pattern="*1.fastq.gz")
	read_2 <- gsub("_1", "_2", read_1)

	stub <- gsub("_1.*", "", read_1)
	sample <- gsub("-", "_", sample_map[stub])

	files <- data.frame(sample, read_1, read_2)
	write.table(files, "data/lake/lake.files", row.names=F, col.names=F, quote=F, sep='\t')

}
