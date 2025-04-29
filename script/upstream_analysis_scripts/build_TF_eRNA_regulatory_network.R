args = commandArgs(trailingOnly=TRUE)
mapData <- read.table(file=args[1],header=FALSE,stringsAsFactors=FALSE,sep="\t")
tf.eRNA.motif.pairs <- read.table(file=args[2],header=FALSE,stringsAsFactors=FALSE)
matchIndexes <- match(tf.eRNA.motif.pairs[,1],mapData[,1])
tf.eRNA.motif.pairs <- cbind(mapData[matchIndexes[which(!is.na(matchIndexes))],2],tf.eRNA.motif.pairs[which(!is.na(matchIndexes)),2:ncol(tf.eRNA.motif.pairs)])
tf.eRNA.motif.pairs.yes <- tf.eRNA.motif.pairs[which(tf.eRNA.motif.pairs[,6]=="Yes"),]
tf.eRNA.motif.pairs.no <- tf.eRNA.motif.pairs[which(tf.eRNA.motif.pairs[,6]=="No"),]  

tf.eRNA.co.signif.pairs <- read.table(file=args[3],header=FALSE,stringsAsFactors=FALSE)
matchIndexes <- match(paste(toupper(tf.eRNA.co.signif.pairs[,5]),tf.eRNA.co.signif.pairs[,1],sep="\t"),paste(toupper(tf.eRNA.motif.pairs.no[,2]),tf.eRNA.motif.pairs.no[,3],sep="\t"))
tf.eRNA.motif.pairs.no <- tf.eRNA.motif.pairs.no[matchIndexes[which(!is.na(matchIndexes))],]
tf.eRNA.motif.pairs <- rbind(tf.eRNA.motif.pairs.yes,tf.eRNA.motif.pairs.no)

tf.eRNA.co.all.pairs <- read.table(file=args[4],header=FALSE,stringsAsFactors=FALSE)
matchIndexes <- match(paste(toupper(tf.eRNA.co.all.pairs[,5]),tf.eRNA.co.all.pairs[,1],sep="\t"),paste(toupper(tf.eRNA.motif.pairs[,2]),tf.eRNA.motif.pairs[,3],sep="\t"))
tf.eRNA.co.all.pairs <- tf.eRNA.co.all.pairs[which(!is.na(matchIndexes)),]
tf.eRNA.motif.pairs <- tf.eRNA.motif.pairs[matchIndexes[which(!is.na(matchIndexes))],]
tf.eRNA.co.all.pairs[which(tf.eRNA.co.all.pairs[,4]==0),4] <- min(tf.eRNA.co.all.pairs[which(tf.eRNA.co.all.pairs[,4]>0),4])
tf.eRNA.motif.pairs <- cbind(tf.eRNA.motif.pairs[,c(3,2,4,6,7,5)])
tf.eRNA.motif.pairs <- cbind(tf.eRNA.motif.pairs, tf.eRNA.co.all.pairs[,2:4])
tf.eRNA.motif.pairs <- cbind(tf.eRNA.motif.pairs[,c(1,2,7,3,4,5,8,9,6)])

row.indexes <- c()
geneexpData <- read.table(file=args[5],sep="\t",header=TRUE,row.names=1,stringsAsFactors=FALSE)
tf.eRNA.motif.pairs <- cbind(tf.eRNA.motif.pairs, NA) 
last_col <- ncol(tf.eRNA.motif.pairs)  

row.indexes <- c()
for (rowindex in seq(1, nrow(tf.eRNA.motif.pairs))) {
   rownum <- match(tf.eRNA.motif.pairs[rowindex, 3], rownames(geneexpData))
   colnum <- match(tf.eRNA.motif.pairs[rowindex, 9], colnames(geneexpData))
   
   if (geneexpData[tf.eRNA.motif.pairs[rowindex, 3], tf.eRNA.motif.pairs[rowindex, 9]] > 0) {
      tf.eRNA.motif.pairs[rowindex, last_col] <- tf.eRNA.motif.pairs[rowindex, 4] * geneexpData[tf.eRNA.motif.pairs[rowindex, 3], tf.eRNA.motif.pairs[rowindex, 9]]
      row.indexes <- c(row.indexes, rowindex)
   }
}

tf.eRNA.motif.pairs <- tf.eRNA.motif.pairs[row.indexes,]
write.csv(tf.eRNA.motif.pairs,file=args[6],row.names=FALSE,quote=FALSE)