#!/usr/bin/env Rscript


library(foreach)
library(doParallel)
library(pheatmap)
library(RColorBrewer)


expValNormalization <- function(expVec) {
  expVec <- log2(expVec + 1) / sum(log2(expVec + 1))
  return(expVec)
}

scaleNorm <- function(x) {
  x <- as.numeric(x)
  return((x - mean(x)) / (sd(x)))
}

JSscoreCal <- function(probVec, stdMat, stageNames) {
  HscoreVec <- c()
  probVec[which(probVec < 2e-100)] <- runif(length(which(probVec < 2e-100)), min = 1e-100, max = 2e-100)
  for (colIndex in seq(1, ncol(stdMat))) {
    meanProb <- (probVec + stdMat[, colIndex]) / 2
    meanH <- -sum(meanProb * log2(meanProb))
    pop1H <- -sum(probVec * log2(probVec))
    pop2H <- -sum(stdMat[, colIndex] * log2(stdMat[, colIndex]))
    HscoreVec <- c(HscoreVec, (1 - sqrt(meanH - (pop1H + pop2H) / 2)))
  }
  JSscore <- max(HscoreVec)
  stageName <- stageNames[which(HscoreVec == max(HscoreVec))]
  return(c(JSscore, stageName))
}


args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
  stop("Usage: script.R <input_file> <output_scores_file> <output_heatmap_file> <num_threads>")
}

input_file <- args[1]
output_scores <- args[2]
output_heatmap <- args[3]
num_threads <- as.numeric(args[4])


cl <- makeCluster(num_threads)
registerDoParallel(cl)


enhExpData <- read.table(file = input_file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
rownames(enhExpData) <- rownames(enhExpData)


stageNames <- c("MIIOocyte", "X2cell", "X4cell", "X8cell", "Morula", "ICM")
matchIndexes <- match(stageNames, colnames(enhExpData))
matchIndexes <- matchIndexes[which(!is.na(matchIndexes))]
enhExpData <- enhExpData[, matchIndexes]


bgMatrix <- matrix(0, nrow = length(stageNames), ncol = length(stageNames))
for (stageIter in seq(1, length(stageNames))) {
  randomNum <- runif(length(stageNames), min = 1e-100, max = 2e-100)
  bgMatrix[stageIter, stageIter] <- 1
  bgMatrix[, stageIter] <- bgMatrix[, stageIter] + randomNum
}


enhExpData <- enhExpData[rowSums(enhExpData) > 0, ]
enhExpDataNorm <- t(apply(enhExpData, 1, expValNormalization))
enhJSscoreVec <- foreach(iter = 1:nrow(enhExpDataNorm), .combine = rbind, .multicombine = TRUE, .verbose = TRUE) %dopar% {
	  JSscoreCal(enhExpDataNorm[iter, ], bgMatrix, stageNames)
}

rownames(enhJSscoreVec) <- rownames(enhExpDataNorm)
enhnonaIndexes <- which(!is.na(enhJSscoreVec[, 1]))
enhJSscoreVec <- enhJSscoreVec[enhnonaIndexes, ]
enhJSscoreVec <- as.data.frame(enhJSscoreVec)
colnames(enhJSscoreVec) <- c("JSscore", "StageName")
enhJSscoreVec[, 2] <- factor(enhJSscoreVec[, 2], levels = rev(c("MIIOocyte", "X2cell", "X4cell", "X8cell", "Morula", "ICM")), ordered = TRUE)
enhJSscoreVec <- enhJSscoreVec[order(enhJSscoreVec[, 2], enhJSscoreVec[, 1], decreasing = TRUE), ]


write.table(enhJSscoreVec, file = output_scores, row.names = TRUE, col.names = FALSE, quote = FALSE)


matchIndexes <- match(rownames(enhJSscoreVec), rownames(enhExpData))
expData <- enhExpData[matchIndexes, ]
plotData <- t(apply(expData, 1, scaleNorm))
colnames(plotData) <- colnames(expData)




pdf(file = output_heatmap, width = 12, height = 13)
pheatmap(plotData,
         scale = "row",
         cluster_rows = FALSE,
         cluster_cols = FALSE,
         show_rownames = FALSE,
         show_colnames = TRUE,
         color = colorRampPalette(c("#d9e6c9", "white", "#183f7f"))(100),
         fontsize = 8,
         fontsize_row = 6,
         fontsize_col = 8,
         border_color = "gray90",
         legend = TRUE
)
dev.off()


stopCluster(cl)


cat("JS scores saved to:", output_scores, "\n")
cat("Heatmap saved to:", output_heatmap, "\n")


