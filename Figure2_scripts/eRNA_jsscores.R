library(foreach)
library(doParallel)
args = commandArgs(trailingOnly=TRUE)

expValNormalization <- function(expVec){
  expVec <- log2(expVec+1)/sum(log2(expVec+1))
  return(expVec)
}

scaleNorm <- function(x){
  x <- as.numeric(x)
  return((x-mean(x))/(sd(x)))
}

maxvalue <- function(x){
  max_value <- max(x)
  return(max_value)
}

JSscoreCal <- function(probVec,stdMat,stageNames){
  HscoreVec <- c()
  probVec[which(probVec < 2e-100)] <- runif(length(which(probVec < 2e-100)),min=1e-100,max=2e-100)
  for(colIndex in seq(1,ncol(stdMat))){
    meanProb <- (probVec+stdMat[,colIndex])/2
    meanH <- -sum(meanProb*log2(meanProb))
    pop1H <- -sum(probVec*log2(probVec))
    pop2H <- -sum(stdMat[,colIndex]*log2(stdMat[,colIndex]))
    HscoreVec <- c(HscoreVec,(1-sqrt(meanH-(pop1H+pop2H)/2)))
  }
  JSscore <- max(HscoreVec)
  stageName <- stageNames[which(HscoreVec==max(HscoreVec))]
  return(c(JSscore,stageName))
}

cl <- makeCluster(20)
registerDoParallel(cl)
enhExpData <- read.table(file=args[1],sep="\t",header=TRUE,stringsAsFactors=FALSE,,row.names=1)

stageNames <- c("MIIOocyte","X2cell","X4cell","X8cell","Morula","ICM")
matchIndexes <- match(stageNames,colnames(enhExpData))
matchIndexes <- matchIndexes[which(!is.na(matchIndexes))]
enhExpData <- enhExpData[,matchIndexes]

bgMatrix <- matrix(0,nrow=length(stageNames),ncol=length(stageNames))
cat("The stage number:",length(stageNames),"\n")
for(stageIter in seq(1,length(stageNames))){
  randomNum <- runif(length(stageNames),min=1e-100,max=2e-100)
  bgMatrix[stageIter,stageIter] <- 1
  bgMatrix[,stageIter] <- bgMatrix[,stageIter] + randomNum
}

# JS score calculation
enhExpData <- enhExpData[rowSums(enhExpData)> 0,]
enhExpDataNorm <- t(apply(enhExpData,1,expValNormalization))
enhJSscoreVec <- foreach(iter=1:nrow(enhExpDataNorm),.combine=rbind,.multicombine=TRUE,.verbose=TRUE) %dopar% JSscoreCal(enhExpDataNorm[iter,],bgMatrix,stageNames)
rownames(enhJSscoreVec) <- rownames(enhExpDataNorm)
enhnonaIndexes <- which(!is.na(enhJSscoreVec[,1]))
enhJSscoreVec <- enhJSscoreVec[enhnonaIndexes,]
enhJSscoreVec <- as.data.frame(enhJSscoreVec)
colnames(enhJSscoreVec) <- c("JSscore","StageName")
enhJSscoreVec[,2] <- factor(enhJSscoreVec[,2],levels=rev(c("MIIOocyte","X2cell","X4cell","X8cell","Morula","ICM")),ordered=TRUE)
enhJSscoreVec <- enhJSscoreVec[order(enhJSscoreVec[,2],enhJSscoreVec[,1],decreasing=TRUE),]
write.table(enhJSscoreVec,file=args[2],row.names=T,col.names=F,quote=F)

