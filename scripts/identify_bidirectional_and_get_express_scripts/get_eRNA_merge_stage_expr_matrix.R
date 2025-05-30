args = commandArgs(trailingOnly=TRUE)

posData <- read.table(file=args[1],header=FALSE,stringsAsFactors=FALSE)
expData_in <- read.table(file=args[2],header=TRUE,sep="\t",stringsAsFactors=FALSE,skip=2)
stageNames <- c("MIIOocyte","2cell","4cell","8cell","Morula","ICM")
expData_out <- c()
for(stageName in stageNames){
    matchIndexes <- grep(stageName,colnames(expData_in))
    if(length(expData_out)==0){
        expData_out <- rowMeans(expData_in[,matchIndexes[91:180]])   
    }else{
        expData_out <- cbind(expData_out,rowMeans(expData_in[,matchIndexes[91:180]]))
    }
}

rownames(expData_out) <- posData[,4]
colnames(expData_out) <- stageNames
write.table(expData_out,file=args[3],sep='\t',quote=FALSE,row.names=T,col.names=T)
