library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
  stop("Usage: Rscript script_name.R <tf_file> <erna_file> <tf_name> <erna_name>", call. = FALSE)
}
tf_file <- args[1]
erna_file <- args[2]
tf_name <- args[3]
erna_name <- args[4]

tf_data <- read.delim(tf_file, header = FALSE, stringsAsFactors = FALSE)
colnames(tf_data) <- c("TF_Name", as.character(tf_data[1, -1]))
tf_data <- tf_data[-1, ]

erna_data <- read.delim(erna_file, header = TRUE, stringsAsFactors = FALSE)

tf_data$TF_Name <- gsub("\\.\\d+$", "", tf_data$TF_Name)

tf_expression <- as.numeric(tf_data[tf_data$TF_Name == tf_name, -1])
erna_expression <- as.numeric(erna_data[erna_name, ])

if (length(tf_expression) != ncol(erna_data)) {
  stop("Sample count mismatch. Please check input files.")
}

expression_matrix <- data.frame(Sample = colnames(erna_data), 
                                TF_Expression = tf_expression, 
                                eRNA_Expression = erna_expression)

correlation <- cor(tf_expression, erna_expression, method = "pearson")
p_value <- cor.test(tf_expression, erna_expression, method = "pearson")$p.value

ggplot(expression_matrix, aes(x = TF_Expression, y = eRNA_Expression)) +
  geom_point(color = "blue", alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = paste("Correlation between", tf_name, "and", erna_name),
       subtitle = paste("Pearson r =", round(correlation, 2), 
                        ", p =", format(p_value, scientific = TRUE)),
       x = paste(tf_name, "Expression (TPM)"),
       y = paste(erna_name, "Expression (TPM)")) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

ggsave(paste0(tf_name, "_vs_", erna_name, "_correlation.png"), width = 8, height = 6)


##Rscript Panel3E.R /home/zmzhang/protocol/E3RC/figure2/gencode_single_stage_sample_TPM.txt /home/zmzhang/protocol/E3RC/figure2/eRNA_single_sample_TPM.txt ENSMUSG00000030678 ENH000021