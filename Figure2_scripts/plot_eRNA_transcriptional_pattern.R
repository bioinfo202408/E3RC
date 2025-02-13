library(ggplot2)
library(wesanderson)

data <- read.table(file="/home/yjliu/E3RC/datasets/mappingfile/hisat2file/eRNAs_total_merged_sample_scaled.tab", header=TRUE, stringsAsFactors=FALSE, skip=2)

library(reshape2)
library(stringr)

long_data <- melt(data, variable.name = "Sample_Bin", value.name = "Signal")


long_data$Group <- sub("\\..*", "", long_data$Sample_Bin)  

long_data$Bin <- ifelse(grepl("\\.", long_data$Sample_Bin),
                        as.numeric(str_extract(long_data$Sample_Bin, "\\d+$")),
                        0)
library(dplyr)


group_summary <- long_data %>%
  group_by(Group, Bin) %>%
  summarize(Mean_Signal = quantile(Signal, probs=0.72))

pdf(file = "/home/yjliu/E3RC/i.pdf")
sp <- ggplot(group_summary, aes(x = Bin, y = Mean_Signal, color = Group)) +
   geom_smooth(method = "loess", span = 0.3) +  
   scale_color_manual(values = wes_palette("Zissou1", 6, type = "continuous")[3]) +  
   labs(title = "eRNA Signal Profile", x = "Bin Position", y = "Signal Intensity") +
   theme_minimal() +
   theme(panel.grid = element_blank(),  
         panel.border = element_rect(color = "black", fill = NA))
# 沿坐标轴添加黑框
# 打印图形
print(sp)

# 关闭 PDF 设备
dev.off()
