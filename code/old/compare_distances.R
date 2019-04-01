read_phylip <- function(dist_file){

	dist_file_vector <- scan(dist_file, what="")

	n_seqs <- as.integer(dist_file_vector[1])
	dist_file_vector <- dist_file_vector[-1]

	name_indices <- c(1, cumsum(1:(n_seqs-1)) + 1)
	group_names <- dist_file_vector[name_indices]
	distances <- as.numeric(dist_file_vector[-name_indices])

	a <- rep(group_names, c(1:n_seqs)-1)

	b <- character()
	for(i in 1:(n_seqs-1)){
		b <- c(b, group_names[1:i])
	}

	composite <- tibble(a=a, b=b, dist=distances) %>%
									mutate(a_new = ifelse(a<b, a, b), b_new = ifelse(a<b, b, a)) %>%
									select(-a,-b) %>%
									select(a = a_new, b = b_new, dist)
}


dist_file <- "random.thetayc.0.03.lt.ave.dist"
all <- read_phylip(dist_file)

dist_file <- "random_no_rare.thetayc.0.03.lt.ave.dist"
no_sing <- read_phylip(dist_file)

joined <- inner_join(all, no_sing, by=c("a"="a","b"="b")) %>%
						rename(all_dist = dist.x, no_sing_dist = dist.y)
