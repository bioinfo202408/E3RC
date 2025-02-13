args<-commandArgs(trailingOnly = TRUE)
geneID<-args[1]
stage<-args[2]
data<-read.csv(args[3])
subset_data<-data[data[,3]==geneID & data[,8]==stage,]
sorted_data<-subset_data[order(subset_data[,6],decreasing = TRUE),]
sorted_data <- head(sorted_data, 10)
write.csv(sorted_data,file=args[4],row.names=FALSE,col.names=FALSE,quote=FALSE)
