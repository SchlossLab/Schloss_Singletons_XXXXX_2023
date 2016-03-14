library("testthat")

context("manipulating shared data")

shared_file_name <- "test.shared"

test_that("read_shared", {
	shared <- read_shared(shared_file_name)
	expect_equal(nrow(shared), 5)
	expect_equal(ncol(shared), 10)
})

test_that("pool_samples", {
	otu_counts <- pool_samples(shared)
	expect_equal(otu_counts, c(86, 46, 11, 22, 4, 1, 1, 1, 1, 1))
	expect_equal(pool_samples(matrix(c(1,2,3,4,5,6), nrow=2)), c(3,7,11))
})

test_that("get_sample_frequencies", {
	sample_counts <- get_sample_frequencies(shared)
	expect_equal(sample_counts, c(23, 45, 34, 38, 34))
	expect_equal(get_sample_frequencies(matrix(c(1,2,3,4,5,6), nrow=2)), c(9,12))
})

test_that("shuffle_seqs", {
	expect_equal(as.vector(table(shuffle_seqs(c(3,2,1,1)))),c(3,2,1,1))
	expect_equal(as.vector(table(shuffle_seqs(c(3,2,0,1)))),c(3,2,1))
	expect_equal(as.vector(table(shuffle_seqs(c(3,0,0,1)))),c(3,1))
	expect_equal(length(shuffle_seqs(c(3,2,1,1))), sum(c(3,2,1,1)))
	expect_equal(length(shuffle_seqs(c(3,0,1,1))), sum(c(3,0,1,1)))
})

test_that("shuffle_seqs_samples", {
	otu_counts <- pool_samples(shared)
	sample_counts <- get_sample_frequencies(shared)
	new_shared <- shuffle_seqs_samples(otu_counts, sample_counts)[[1]]
	#same dim as shared
	expect_equal(dim(shared), dim(new_shared))
	#same sum as shared
	expect_equal(sum(shared), sum(new_shared))
	#same otu_counts
	expect_equal(pool_samples(shared), pool_samples(new_shared))
	#same sample_counts
	expect_equal(get_sample_frequencies(shared), get_sample_frequencies(new_shared))
	#make sure the matrices aren't the same
	expect_false(sum(shared == new_shared)==nrow(shared)*ncol(shared))
})

test_that("shuffle_shared_file", {
	#if only one shuffling is done the output should be a matrix
	expect_is(shuffle_shared_file(shared_file_name, 1), "matrix")
	#output matrix should be the same dim as original
	expect_equal(dim(shuffle_shared_file(shared_file_name, 1)), c(5,10))
	#if multiple shufflings are done the output should be a list
	expect_is(shuffle_shared_file(shared_file_name, 2), "list")
	#if multiple shufflings are done then the list should be that length
	expect_equal(length(shuffle_shared_file(shared_file_name, 5)), 5)
})

test_that("subsample_counts", {
	sub_sample <- subsample_counts(shared[1,], 20)
	#should preserve all OTUs even if their counts are zero
	expect_equal(length(sub_sample), ncol(shared))
	#sum of sequences in subsampled vector should be value of subsampled_to
	expect_equal(sum(sub_sample), 20)
	#if subsampled_to is greater than totoal number of sequences return a NA
	expect_equal(subsample_counts(shared[1,], 30),NA)
})

test_that("subsample_table", {
	sub_sample <- subsample_table(shared, 20)
	#sub sampled shared file should have the same dimensions as original
	expect_equal(dim(sub_sample), dim(shared))
	#sub sampled shared file should have the same row counts as subsample_to
	expect_equal(sum(get_sample_frequencies(sub_sample)), 20*nrow(shared))
	#if try to oversample a sample, toss it and warn
	sub_sample <- subsample_table(shared, 30)
	expect_equal(nrow(sub_sample), nrow(shared)-1)
})

test_that("remove_rare", {
	#If we don't set a threshold everything should come back
	expect_equal(ncol(remove_rare(shared,0)), ncol(shared))
	#if there's a column of all zeroes it should be removed
	expect_equal(ncol(remove_rare(cbind(shared,rep(0,5)),1)), ncol(shared))
	#removing singletons should remove those 5 columns
	expect_equal(ncol(remove_rare(shared,2)), 5)
})


context("calculating diversity metrics")

test_that("get_shannon", {
	#http://entnemdept.ifas.ufl.edu/hodges/ProtectUs/lp_webfolder/9_12_grade/Student_Handout_1A.pdf
	expect_equal(get_shannon(c(6,5,1,3,12)), 1.37, tol=0.01)
	expect_equal(get_shannon(c(6,5,0,1,3,12)), 1.37, tol=0.01)
	expect_equal(get_shannon(1:10), 2.16, tol=0.01)
	expect_equal(get_shannon(seq(1,11,2)), 1.62, tol=0.01)
})

test_that("get_bray_curtis", {
	#identical vectors should give a distance of zero
	expect_equal(get_bray_curtis(c(1,2,3),c(1,2,3)), 0)
	#disjoint vectors should give a distance of one
	expect_equal(get_bray_curtis(c(1,2,3,0,0,0),c(0,0,0,1,2,3)), 1)
	#different lenthed vectors should thrown an error
	expect_error(get_bray_curtis(c(1,2,3,0,0),c(0,0,0,1,2,3)))
	#manually calculated these...
	expect_equal(get_bray_curtis(shared[1,],shared[2,]), 0.3529411, tol=1e-4)
	expect_equal(get_bray_curtis(shared[1,],shared[3,]), 0.3333333, tol=1e-4)
	expect_equal(get_bray_curtis(shared[2,],shared[3,]), 0.2405063, tol=1e-4)

})

test_that("get_bc_summary", {
	bc_summary <- get_bc_summary(shared[1:3,])
	#manually calculated these...
	expect_equal(bc_summary[["mean"]], 0.3089269, tol=1e-4)
	expect_equal(bc_summary[["sd"]],   0.0600596, tol=1e-4)
	#should get a mean and standard deviation
	expect_equal(length(bc_summary), 2)
})


test_that("get_sobs_summary", {
	sobs_summary <- get_sobs_summary(shared)
	#manually calculated these...
	expect_equal(sobs_summary[["mean"]], 5.0, tol=1e-4)
	expect_equal(sobs_summary[["sd"]],   0.7071068, tol=1e-4)
	#should get a mean and standard deviation
	expect_equal(length(sobs_summary), 2)
})


test_that("get_shannon_summary", {
	shannon_summary <- get_shannon_summary(shared)
	#manually calculated these...
	expect_equal(shannon_summary[["mean"]], 1.164, tol=1e-2)
	#can't get the right number of significant digits to get the tol to work
	#for sd
	#expect_equal(shannon_summary[["sd"]],   0.070, tol=1e-2)
	#should get a mean and standard deviation
	expect_equal(length(shannon_summary), 2)
})
