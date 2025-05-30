library(foreach)
library(doParallel)
args = commandArgs(trailingOnly=TRUE)
cl <- makeCluster(as.numeric(15))
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

geneexpData <- read.table(file=args[1],sep="\t",header=TRUE,row.names=1,stringsAsFactors=FALSE)
enhexpData <- read.table(file=args[2],sep="\t",header=TRUE,stringsAsFactors=FALSE)
geneexpData <- geneexpData[complete.cases(geneexpData), ]
enhexpData <- enhexpData[apply(enhexpData, 1, sd) > 0, ]
geneexpData <- geneexpData[apply(geneexpData, 1, sd) > 0, ]

pvalueMatrix <- foreach(iterer=1:nrow(enhexpData),.combine=rbind,.multicombine=TRUE,.verbose=TRUE) %dopar% evalPvalue(as.numeric(enhexpData[iterer,]),geneexpData)
corrMatrix <- foreach(iterer=1:nrow(enhexpData),.combine=rbind,.multicombine=TRUE,.verbose=TRUE) %dopar% evalCorr(as.numeric(enhexpData[iterer,]),geneexpData)
rownames(pvalueMatrix) <- rownames(enhexpData)
rownames(corrMatrix) <- rownames(enhexpData)
colnames(pvalueMatrix) <- rownames(geneexpData)
colnames(corrMatrix) <- rownames(geneexpData)
save(pvalueMatrix,file=args[3])
save(corrMatrix,file=args[4])
 