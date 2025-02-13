#add_stage
args = commandArgs(trailingOnly=TRUE)
enhancer.stages <- read.table(file=args[1],header=FALSE,stringsAsFactors=FALSE)

netData <- read.table(file=args[2],header=FALSE,stringsAsFactors=FALSE)
matchIndexes <- match(netData[,1],enhancer.stages[,1])
netData <- cbind(netData[,c(1,2,3,4,6,7)],enhancer.stages[matchIndexes,3])
write.table(netData,file=args[3],row.names=FALSE,col.names=FALSE,quote=FALSE)

#add_geneName
mapData <- read.table(file=args[4],header=FALSE,stringsAsFactors=FALSE)
mapData[,1] <- gsub("\\.\\d+","",mapData[,1])

netDataGSR <- netData
matchIndexes <- match(netDataGSR[,2],mapData[,1])
netDataGSR <- cbind(netDataGSR[,1],mapData[matchIndexes,3],netDataGSR[,2],netDataGSR[,c(3,4,5,6,7)])
write.csv(netDataGSR,file=args[5],row.names=FALSE,col.names=TRUE,quote=FALSE)
