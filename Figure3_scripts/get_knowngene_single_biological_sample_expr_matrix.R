args = commandArgs(trailingOnly=TRUE)

posData <- read.table(file=args[1],header=FALSE,stringsAsFactors=FALSE)
expData_in <- read.table(file=args[2],header=TRUE,sep="\t",stringsAsFactors=FALSE,skip=2)
stageNames <- c("MIIOocyte_1","MIIOocyte_2","2cell_1","2cell_2","2cell_3","2cell_4","4cell_1","4cell_2","4cell_3","4cell_4","8cell_1","8cell_2","Morula_1","Morula_2","ICM_1","ICM_2","ICM_3","ICM_4")
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
