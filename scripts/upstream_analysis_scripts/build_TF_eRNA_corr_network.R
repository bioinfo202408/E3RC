library(foreach)
library(doParallel)
args = commandArgs(trailingOnly=TRUE)

cl <- makeCluster(as.numeric(20))
registerDoParallel(cl)

getPvalue <- function(x,y){
	res <- cor.test(x,y,method="pearson")
	return(res$p.value)
}

getCorrValue <- function(x,y){
	res <- cor.test(x,y,method="pearson")
	return(res$estimate)
}

evalPvalue <- function(vec, mat){
	return(apply(mat,1,getPvalue,vec))
}

evalCorr <- function(vec, mat){
	return(apply(mat,1,getCorrValue,vec))
}

geneExprData <- read.table(file=args[1],sep="\t",header=TRUE,row.names=1,stringsAsFactors=FALSE)
eRNAExprData <- read.table(file=args[2],sep="\t",header=TRUE,row.names=1,stringsAsFactors=FALSE)
geneExprData <- geneExprData[complete.cases(geneExprData), ]
eRNAExprData <- eRNAExprData[apply(eRNAExprData, 1, sd) > 0, ]
geneExprData <- geneExprData[apply(geneExprData, 1, sd) > 0, ]
apply(eRNAExprData, 1, sd)
apply(geneExprData, 1, sd)


pvalueMatrix <- foreach(iterer=1:nrow(eRNAExprData),.combine=rbind,.multicombine=TRUE,.verbose=TRUE) %dopar% evalPvalue(as.numeric(eRNAExprData[iterer,]),geneExprData)
corrMatrix <- foreach(iterer=1:nrow(eRNAExprData),.combine=rbind,.multicombine=TRUE,.verbose=TRUE) %dopar% evalCorr(as.numeric(eRNAExprData[iterer,]),geneExprData)
rownames(pvalueMatrix) <- rownames(eRNAExprData)
rownames(corrMatrix) <- rownames(eRNAExprData)

pvalueMatrix[which(is.na(pvalueMatrix),arr.ind=TRUE)] <- 1
pvalueMatrix <- t(apply(pvalueMatrix,1,p.adjust,"fdr"))
corrMatrix[which(is.na(corrMatrix),arr.ind=TRUE)] <- 0  
row.col.indexes <- which(corrMatrix > 0.7, arr.ind=TRUE)
sign.pairs <- cbind(rownames(corrMatrix)[row.col.indexes[,1]],colnames(corrMatrix)[row.col.indexes[,2]],corrMatrix[row.col.indexes],pvalueMatrix[row.col.indexes])
sign.pairs <- sign.pairs[which(sign.pairs[,4] < 0.01),]
sign.pairs[,2] <- gsub("\\.\\d+","",sign.pairs[,2])

tf.genes <- read.table(file=args[3],sep="\t",header=TRUE,stringsAsFactors=FALSE)
match.indexes <- match(sign.pairs[,2],tf.genes[,3])
sign.tf.enh.pairs <- sign.pairs[which(!is.na(match.indexes)),]
sign.tf.enh.pairs <- cbind(sign.tf.enh.pairs,tf.genes[match.indexes[which(!is.na(match.indexes))],2])
write.table(sign.tf.enh.pairs,file=args[4],row.names=FALSE,col.names=FALSE,quote=FALSE)

row.col.indexes <- which(corrMatrix > 0, arr.ind=TRUE)
sign.pairs <- cbind(rownames(corrMatrix)[row.col.indexes[,1]],colnames(corrMatrix)[row.col.indexes[,2]],corrMatrix[row.col.indexes],pvalueMatrix[row.col.indexes])
sign.pairs[,2] <- gsub("\\.\\d+","",sign.pairs[,2])

tf.genes <- read.table(file=args[3],sep="\t",header=TRUE,stringsAsFactors=FALSE)
match.indexes <- match(sign.pairs[,2],tf.genes[,3])
tf.enh.pairs <- sign.pairs[which(!is.na(match.indexes)),]
tf.enh.pairs <- cbind(tf.enh.pairs,tf.genes[match.indexes[which(!is.na(match.indexes))],2])
write.table(tf.enh.pairs,file=args[5],row.names=FALSE,col.names=FALSE,quote=FALSE)
