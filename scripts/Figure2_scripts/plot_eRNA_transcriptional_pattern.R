library(ggplot2)
library(wesanderson)
library(reshape2)
library(dplyr)
library(stringr)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Please provide the input file path and output file path", call. = FALSE)
}
input_file <- args[1]
output_file <- args[2]

data <- read.table(file=input_file, header=TRUE, stringsAsFactors=FALSE, skip=2)

long_data <- melt(data, variable.name = "Sample_Bin", value.name = "Signal")

long_data$Group <- sub("\\..*", "", long_data$Sample_Bin)
long_data$Bin <- ifelse(grepl("\\.", long_data$Sample_Bin),
                        as.numeric(str_extract(long_data$Sample_Bin, "\\d+$")),
                        0)

group_summary <- long_data %>%
  group_by(Group, Bin) %>%
  summarize(Mean_Signal = quantile(Signal, probs=0.72))

ggplot(group_summary, aes(x = Bin, y = Mean_Signal, color = Group)) +
  geom_smooth(method = "loess", span = 0.3) +
  scale_color_manual(values = c(rev(wes_palette("Zissou1", 6, type = "continuous")))) +
  labs(title = "eRNA Signal Profile", x = "Bin Position", y = "Signal Intensity") +
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(color = "black", fill = NA))

ggsave(output_file)

