args = commandArgs(trailingOnly=TRUE)

enhPosData <- read.table(file=args[1],header=FALSE,stringsAsFactor=FALSE)
signalData <- read.table(file=args[2],header=FALSE,stringsAsFactors=FALSE,skip=3)
signalData[which(is.na(signalData),arr.ind=TRUE)] <- 0
expSignalENH <- c()
PbtENH <- c()
enhIDs <- c()
for (rowi in seq(1,nrow(signalData))){
	N1 <- sum(as.numeric(signalData[rowi,seq(91,120)]))
	N2 <- sum(as.numeric(signalData[rowi,seq(121,150)]))
	N3 <- sum(as.numeric(signalData[rowi,seq(151,180)]))
	if(N2 > 0){
		if((N1+N3) > 0){
			sigVal <- (2*N2)/(N1+N3)
			PbtENH <- c(PbtENH,sigVal)
			expSignalENH <- c(expSignalENH,mean(as.numeric(signalData[rowi,seq(91,180)])))
			enhIDs <- c(enhIDs,enhPosData[rowi,4])
		}else{
			PbtENH <- c(PbtENH,1000000)
			expSignalENH <- c(expSignalENH,mean(as.numeric(signalData[rowi,seq(91,180)])))
			enhIDs <- c(enhIDs,enhPosData[rowi,4])
		}
	}
}

signalData <- read.table(file=args[3],header=TRUE,stringsAsFactors=FALSE,skip=3)
signalData[which(is.na(signalData),arr.ind=TRUE)] <- 0
PbtGENECODE <- c()
for (rowi in seq(1,nrow(signalData))){
	N1 <- sum(as.numeric(signalData[rowi,seq(91,120)]))
	N2 <- sum(as.numeric(signalData[rowi,seq(121,150)]))
	N3 <- sum(as.numeric(signalData[rowi,seq(151,180)]))
	if(N1+N3 > 0){
		sigVal <- (2*N2)/(N1+N3)
		PbtGENECODE <- c(PbtGENECODE,sigVal)
	}else{
		PbtGENECODE <- c(PbtGENECODE,0)
	}
}

q95 <- quantile(PbtGENECODE,probs=0.95)
enhPosData <- enhPosData[match(enhIDs,enhPosData[,4]),]
eRNAPosData <- enhPosData[which(PbtENH > q95 & expSignalENH > 0.001),]

write.table(eRNAPosData,file=args[4],sep="\t",row.names=FALSE,col.names=FALSE,quote=FALSE)
