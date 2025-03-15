#!/usr/bin/env Rscript


library(ggplot2)


args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Please provide the input file path as the first argument.")
}


input_file <- args[1]


output_file <- ifelse(length(args) >= 2, args[2], "expressed_eRNA_barplot.png")


eRNA_data <- read.table(input_file, header = TRUE, row.names = 1, sep = "\t", stringsAsFactors = FALSE)


print(head(eRNA_data))


expressed_counts <- apply(eRNA_data, 2, function(x) sum(x > 0))


print(expressed_counts)


output_counts_file <- gsub("\\.txt$", "_expressed_counts.txt", input_file)
write.table(expressed_counts, file = output_counts_file, quote = FALSE, col.names = NA, sep = "\t")
cat("Counts saved to:", output_counts_file, "\n")


plot_data <- data.frame(Sample = factor(names(expressed_counts), levels = names(expressed_counts)),
                        Expressed_eRNA_Count = expressed_counts)



p <- ggplot(plot_data, aes(x = Sample, y = Expressed_eRNA_Count, fill = Sample)) +
  geom_bar(stat = "identity", width = 0.5) +
  labs(title = " ",
       x = "Sample",
       y = "Number of Expressed eRNAs") +
  scale_fill_manual(values = c("#0072B5FF", "#a82d06", "#d38219", "#74a764", "#8ca2b4", "#8D75AF", "#593202")) +  # 自定义颜色
  theme(
    panel.background = element_blank(),                
    panel.grid.major = element_blank(),                
    panel.grid.minor = element_blank(),                
    axis.line = element_line(colour = "black"),        
    axis.text.x = element_text(angle = 45, hjust = 1), 
    legend.position = "none"                           
  )

print(p)


ggsave(output_file, plot = p, width = 8, height = 6)
cat("Bar plot saved to:", output_file, "\n")

##Rscript PanelA.R /home/zmzhang/protocol/E3RC/scripts_2/eRNA_TPM_2.txt /home/zmzhang/protocol/E3RC/scripts/output_barplot.pdf
