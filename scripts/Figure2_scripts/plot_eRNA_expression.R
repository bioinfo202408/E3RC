library(tidyverse)
library(ggplot2)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: Rscript script_name.R <input_file> <target_eRNA>", call. = FALSE)
}
input_file <- args[1]
target_eRNA <- args[2]
output_file <- args[3]
data <- read.table(input_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)

data_long <- data %>%
  rownames_to_column("eRNA_name") %>%
  pivot_longer(cols = -eRNA_name, names_to = "Sample", values_to = "Expression") %>%
  separate(Sample, into = c("Stage", "Replicate"), sep = "_", remove = FALSE)

data_long$Stage <- factor(data_long$Stage, levels = unique(data_long$Stage))

filtered_data <- data_long %>%
  filter(eRNA_name == target_eRNA)

summary_data <- filtered_data %>%
  group_by(Stage) %>%
  summarise(
    Mean = mean(Expression, na.rm = TRUE),
    SE = sd(Expression, na.rm = TRUE) / sqrt(n())
  )

p <- ggplot(summary_data, aes(x = Stage, y = Mean, group = 1)) +
  geom_line(color = "#1f78b4", size = 1.2) +
  geom_point(size = 4, color = "#1f78b4") +
  geom_errorbar(aes(ymin = Mean - 1.96 * SE, ymax = Mean + 1.96 * SE),
                width = 0.1, color = "#e31a1c", size = 0.8) +
  labs(x = "Stage", y = "Expression (TPM)", title = paste("Expression of", target_eRNA, "Across Stages")) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(color = "black"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.line = element_line(color = "black")
  )


ggsave(output_file, plot = p, width = 8, height = 6)

cat("Plot saved as:", output_file, "\n")

