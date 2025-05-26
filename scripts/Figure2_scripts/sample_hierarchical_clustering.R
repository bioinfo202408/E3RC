#!/usr/bin/env Rscript


library(pheatmap)
library(wesanderson)
library(dendextend)


args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Please provide the input eRNA data file path as the first argument.")
}


input_file <- args[1]
output_pdf <- ifelse(length(args) >= 2, args[2], "eRNA_sample_cluster.pdf")


expData <- read.table(file=input_file, sep="\t", header=TRUE, row.names=1, stringsAsFactors=FALSE)


expData <- expData[which(rowSums(expData) > 0),]


seven.colors <- c(rev(wes_palette("Zissou1", 5, type = "continuous")), "darkslateblue")


pdf(file=output_pdf, width=10, height=15)


p <- pheatmap(expData, 
              show_rownames=FALSE, 
              scale="row", 
              cluster_rows=FALSE, 
              cluster_cols=TRUE, 
              clustering_distance_cols="correlation", 
              fontsize=10)

p.dend <- as.dendrogram(p$tree_col)
p.dend <- reorder(p.dend, seq(1, 45, 3), agglo.FUN=mean)
p.dend %>%
  set("labels_color", c(rep(seven.colors[6], 4), rep(seven.colors[5:1], c(2, 4, 4, 3, 2)))) %>%
  set("hang") %>%
  set("branches_k_col", k = 2) %>%
  plot()


dev.off()


cat("map saved to:", output_pdf, "\n")
