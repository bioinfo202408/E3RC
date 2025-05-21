library(ggplot2)
library(dplyr)

# Command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: Rscript plot_eRNA_differential_expression.R <input_file> <output_file>", call. = FALSE)
}
input_file <- args[1]
output_file <- args[2]

# Read data
data <- read.table(input_file, header = TRUE, row.names = 1, sep = "\t", stringsAsFactors = FALSE)

# Filter columns
morula_columns <- grep("Morula", colnames(data), value = TRUE)
x8cell_columns <- grep("X8cell", colnames(data), value = TRUE)
morula_x8cell_columns <- c(morula_columns, x8cell_columns)

x2cell_columns <- grep("X2cell", colnames(data), value = TRUE)
x4cell_columns <- grep("X4cell", colnames(data), value = TRUE)
x2cell_x4cell_columns <- c(x2cell_columns, x4cell_columns)

# Remove rows with all zeros
data <- data[rowSums(data) > 0, ]

# Subset data
subset_data_morula_x8cell <- data[, morula_x8cell_columns]
subset_data_x2cell_x4cell <- data[, x2cell_x4cell_columns]

# Calculate mean TPM
mean_morula_x8cell <- rowMeans(subset_data_morula_x8cell, na.rm = TRUE)
mean_x2cell_x4cell <- rowMeans(subset_data_x2cell_x4cell, na.rm = TRUE)

# Prepare data for plotting
plot_data <- data.frame(
  MeanMorula_X8cell = mean_morula_x8cell,
  MeanX2cell_X4cell = mean_x2cell_x4cell,
  Log2FC = log2((mean_x2cell_x4cell + 1) / (mean_morula_x8cell + 1))
)

# Add significance labels
cut_off_logFC <- 0.5
plot_data$Significance <- ifelse(plot_data$Log2FC > cut_off_logFC, "Up",
                                 ifelse(plot_data$Log2FC < -cut_off_logFC, "Down", "No"))

# Filter significant genes
significant_genes <- plot_data %>%
  filter(Log2FC > 2 | Log2FC < -1.5)

# Create scatter plot
p <- ggplot(plot_data, aes(x = MeanMorula_X8cell, y = MeanX2cell_X4cell, color = Significance)) +
  geom_point(alpha = 0.6) +
  scale_color_manual(values = c("Up" = "red", "Down" = "blue", "No" = "grey")) +
  labs(x = "Mean Morula/X8cell TPM", y = "Mean X2cell/X4cell TPM",
       title = "Gene Expression Comparison (Morula/X8cell vs. X2cell/X4cell)") +
  theme_minimal() +
  theme(
    legend.title = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.line = element_line(color = "black"),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14)
  ) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
  xlim(0, 8) +
  ylim(0, 8) +
  geom_text(data = significant_genes, aes(label = rownames(significant_genes)),
            vjust = -0.5, hjust = 0.5, size = 3, color = "black")

# Save plot
ggsave(output_file, plot = p, width = 8, height = 6)

cat("Plot saved as:", output_file, "\n")

