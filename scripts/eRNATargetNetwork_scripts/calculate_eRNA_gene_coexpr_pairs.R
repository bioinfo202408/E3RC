args = commandArgs(trailingOnly=TRUE)
load(args[1])
load(args[2])
enhexpData <- read.table(file=args[3],sep="\t",header=TRUE,stringsAsFactors=FALSE)
target.stages <- read.table(file=args[4],header=FALSE,stringsAsFactors=FALSE)

pvalueMatrix[which(is.na(pvalueMatrix),arr.ind=TRUE)] <- 1
corrMatrix[which(is.na(corrMatrix),arr.ind=TRUE)] <- 0  
row.col.indexes <- which(corrMatrix > 0.3, arr.ind=TRUE)
matchIndexes <- match(colnames(corrMatrix)[row.col.indexes[,2]],target.stages[,1])
matchIndexes <- match(target.stages[matchIndexes,3],colnames(enhexpData))

sign.pairs <- cbind(rownames(corrMatrix)[row.col.indexes[,1]],colnames(corrMatrix)[row.col.indexes[,2]],corrMatrix[row.col.indexes],pvalueMatrix[row.col.indexes],as.numeric(corrMatrix[row.col.indexes])*(-log10(as.numeric(pvalueMatrix[row.col.indexes])+1e-100)),as.numeric(corrMatrix[row.col.indexes])*enhexpData[cbind(row.col.indexes[,1],matchIndexes)])
sign.pairs <- sign.pairs[order(as.numeric(sign.pairs[,5]),decreasing=TRUE),]
sign.pairs <- sign.pairs[1:round((nrow(pvalueMatrix)*ncol(pvalueMatrix))*0.05),]
sign.pairs[,2] <- gsub("\\.\\d+","",sign.pairs[,2])
write.table(sign.pairs,file=args[5],row.names=FALSE,col.names=FALSE,quote=FALSE)
