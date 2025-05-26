args<-commandArgs(trailingOnly = TRUE)
enhancerID<- args[1]
stage<- args[2]
data<-read.csv(args[3],head = TRUE)
subset_data<-data[data[,1]==enhancerID & data[,8]==stage,]
sorted_data<-subset_data[order(subset_data[,6],decreasing = TRUE),]
sorted_data <- head(sorted_data, 10)
write.csv(sorted_data,file=args[4],row.names=FALSE,quote=FALSE)
