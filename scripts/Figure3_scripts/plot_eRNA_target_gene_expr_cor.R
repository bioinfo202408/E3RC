library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 5) {
  stop("Usage: Rscript script_name.R <target_gene_file> <erna_file> <gene_name> <erna_name> <output_file>", call. = FALSE)
}

target_gene_file <- args[1]
erna_file <- args[2]
gene_name <- args[3]
erna_name <- args[4]
output_file <- args[5]

target_gene <- read.delim(target_gene_file, header = FALSE, stringsAsFactors = FALSE)
colnames(target_gene) <- c("gene_name", as.character(target_gene[1, -1]))
target_gene <- target_gene[-1, ]

erna_data <- read.delim(erna_file, header = TRUE, stringsAsFactors = FALSE)

target_gene$gene_name <- gsub("\\.\\d+$", "", target_gene$gene_name)

gene_expression <- as.numeric(target_gene[target_gene$gene_name == gene_name, -1])
erna_expression <- as.numeric(erna_data[erna_name, ])

if (length(gene_expression) != ncol(erna_data)) {
  stop("Sample count mismatch. Please check input files.")
}

expression_matrix <- data.frame(
  Sample = colnames(erna_data),
  gene_expression = gene_expression,
  eRNA_Expression = erna_expression
)

correlation <- cor(gene_expression, erna_expression, method = "pearson")
p_value <- cor.test(gene_expression, erna_expression, method = "pearson")$p.value

plot <- ggplot(expression_matrix, aes(x = gene_expression, y = eRNA_Expression)) +
  geom_point(color = "blue", alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = paste("Correlation between", gene_name, "and", erna_name),
       subtitle = paste("Pearson r =", round(correlation, 2),
                        ", p =", format(p_value, scientific = TRUE)),
       x = paste(gene_name, "Expression (TPM)"),
       y = paste(erna_name, "Expression (TPM)")) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  ylim(0, 12)

ggsave(output_file, plot = plot, width = 8, height = 6)
                                                           
