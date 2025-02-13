# 加载必要的R包
library(ggplot2)
library(dplyr)

# 读取数据
data <- read.table("/home/zmzhang/protocol/E3RC/scripts/eRNA_single_sample_TPM.txt", 
                   header = TRUE, row.names = 1, sep = "\t", stringsAsFactors = FALSE)

# 筛选含 "Morula" 和 "X8cell" 的列
morula_columns <- grep("Morula", colnames(data), value = TRUE)
x8cell_columns <- grep("X8cell", colnames(data), value = TRUE)
morula_x8cell_columns <- c(morula_columns, x8cell_columns)

# 筛选含 "X2cell" 和 "X4cell" 的列
x2cell_columns <- grep("X2cell", colnames(data), value = TRUE)
x4cell_columns <- grep("X4cell", colnames(data), value = TRUE)
x2cell_x4cell_columns <- c(x2cell_columns, x4cell_columns)

# 去除所有表达为0的行
data <- data[rowSums(data) > 0, ]

# 提取两组数据子集
subset_data_morula_x8cell <- data[, morula_x8cell_columns]
subset_data_x2cell_x4cell <- data[, x2cell_x4cell_columns]

# 计算两组的平均TPM值
mean_morula_x8cell <- rowMeans(subset_data_morula_x8cell, na.rm = TRUE)
mean_x2cell_x4cell <- rowMeans(subset_data_x2cell_x4cell, na.rm = TRUE)

# 整理成数据框
plot_data <- data.frame(
  MeanMorula_X8cell = mean_morula_x8cell,
  MeanX2cell_X4cell = mean_x2cell_x4cell,
  Log2FC = log2((mean_x2cell_x4cell + 1) / (mean_morula_x8cell + 1)) # 计算log2FoldChange
)

# 添加显著性标注
cut_off_logFC <- 0.5  # Log2 Fold Change 阈值
plot_data$Significance <- ifelse(plot_data$Log2FC > cut_off_logFC, "Up",
                                 ifelse(plot_data$Log2FC < -cut_off_logFC, "Down", "No"))

# 筛选出显著的基因（log2FC > 0.5 或 log2FC < -0.5）
significant_genes <- plot_data %>%
  filter(Log2FC > 1.5 | Log2FC < -1.5)

# 绘制散点图，并标注显著基因名称
p <- ggplot(plot_data, aes(x = MeanMorula_X8cell, y = MeanX2cell_X4cell, color = Significance)) +
  geom_point(alpha = 0.6) +
  scale_color_manual(values = c("Up" = "red", "Down" = "blue", "No" = "grey")) +
  labs(x = "Mean Morula/X8cell TPM", y = "Mean X2cell/X4cell TPM", 
       title = "Gene Expression Comparison (Morula/X8cell vs. X2cell/X4cell)") +
  theme_minimal() +
  theme(
    legend.title = element_blank(),
    panel.grid.major = element_blank(),  # 去掉主网格线
    panel.grid.minor = element_blank(),  # 去掉次网格线
    panel.background = element_blank(),  # 去掉面板背景
    axis.line = element_line(color = "black"),  # 显示坐标轴线
    axis.text = element_text(size = 12),  # 设置坐标轴刻度字体大小
    axis.title = element_text(size = 14)   # 设置坐标轴标签字体大小
  ) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +  # 添加对角线
  xlim(0, 8) +  # 限制横坐标范围
  ylim(0, 8) +  # 限制纵坐标范围
  # 添加基因名称标签
  geom_text(data = significant_genes, aes(label = rownames(significant_genes)), 
            vjust = -0.5, hjust = 0.5, size = 3, color = "black")





print(p)

