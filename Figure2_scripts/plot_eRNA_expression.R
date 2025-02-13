#!/usr/bin/env Rscript


library(ggplot2)


args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: Rscript script_name.R <file_path> <eRNA_ID>")
}


file_path <- args[1]
eRNA_ID <- args[2]


eRNA_data <- read.table(file_path, header = TRUE, row.names = 1, sep = "\t", stringsAsFactors = FALSE)


if (!(eRNA_ID %in% rownames(eRNA_data))) {
  stop(paste("The eRNA ID", eRNA_ID, "is not found in the data."))
}

eRNA_expression <- eRNA_data[eRNA_ID, ]

plot_data <- data.frame(Sample = colnames(eRNA_data),
                        Expression = as.numeric(eRNA_expression))

p <- ggplot(plot_data, aes(x = Sample, y = Expression, fill = Sample)) +
  geom_bar(stat = "identity", width = 0.7) +
  labs(title = paste("Expression of eRNA", eRNA_ID, "in Samples"),
       x = "Sample",
       y = "Expression Level") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p)

output_file <- paste("eRNA_", eRNA_ID, "_expression_barplot.png", sep = "")
ggsave(output_file, plot = p, width = 8, height = 6)

cat("Barplot saved to", output_file, "\n")

#Rscript plot_eRNA.R /path/to/eRNA_TPM.txt eRNA_ID