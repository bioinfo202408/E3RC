args <- commandArgs(trailingOnly = TRUE)
tfName <- args[1]
stage <- args[2]
data <- read.csv(file = args[3], header = TRUE)
subset_data <- data[data[,2] == tfName & data[,9] == stage, ]
sorted_data <- subset_data[order(subset_data[,10], decreasing = TRUE), ]
sorted_data <- head(sorted_data, 10)
write.csv(sorted_data,file=args[4],row.names=FALSE,quote=FALSE)