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



# 美化热图，修改配色和字体大小
pdf(file = output_heatmap, width = 12, height = 13)
pheatmap(plotData, 
         scale = "row", 
         cluster_rows = FALSE,  # 按行聚类
         cluster_cols = FALSE,  # 按列聚类
         show_rownames = FALSE,  # 显示行名
         show_colnames = TRUE,  # 显示列名
         color = colorRampPalette(c("#d9e6c9", "white", "#183f7f"))(100),  # 更柔和的配色方案
         fontsize = 8,  # 增加字体大小
         fontsize_row = 6,  # 行名字体
         fontsize_col = 8,  # 列名字体
         #annotation_col = data.frame(Stage = factor(colnames(plotData), levels = stageNames)),  # 添加列注释
         #annotation_colors = list(Stage = c("MIIOocyte" = "#FF6347", "X2cell" = "#FF8C00", 
         #                                   "X4cell" = "#FFD700", "X8cell" = "#32CD32", 
         #                                   "Morula" = "#1E90FF", "ICM" = "#800080")),  # 设置注释颜色
         border_color = "gray90",  # 设置边框颜色
         legend = TRUE  # 显示图例
)
dev.off()


stopCluster(cl)


cat("JS scores saved to:", output_scores, "\n")
cat("Heatmap saved to:", output_heatmap, "\n")


####Rscript PanelF.R /home/zmzhang/protocol/E3RC/scripts_2/eRNA_TPM_2.txt  /home/zmzhang/protocol/E3RC/scripts_2/eRNA_JSscores.txt /home/zmzhang/protocol/E3RC/scripts_2/eRNA_heatmap.pdf 20
