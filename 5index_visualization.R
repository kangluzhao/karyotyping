# construct the function of slide window analysis
calcValueByWindow <- function(pos, value,
                              window_size = 10000000,
                              step_size = 50000){
  # get the max position
  max_pos <- max(pos)
  
  # construct the window
  window_start <- seq(0, max_pos, step_size)
  window_end <- window_start + window_size
  mean_value <- vector(mode = "numeric", length = length(window_start))
  
  # select the value inside the window
  for (j in seq_along(window_start)){
    
    pos_in_window <- which(pos > window_start[j] & pos < window_end[j])
	
    value_in_window <- value[pos_in_window]
    
    mean_value[j] <- mean(value_in_window)
  }
  
  # remove the NaN position
  nan_pos <- is.nan(mean_value)
  mean_value <- mean_value[!nan_pos]
  window_pos <- window_start[!nan_pos]
  df <- data.frame(pos   = window_pos,
                   value = mean_value)
  return(df)
}

library(tidyverse)
Sample <- read.table("EA49index.txt",header = T,sep = "\t")
Sample$Chromosome <- factor(Sample$Chromosome, levels = unique(Sample$Chromosome))

# calculate the length of each chromosome
chr_len <- Sample %>%
 group_by(Chromosome) %>%
 summarise(chr_len=max(Position))

# calculate the initial position of each chromosome
chr_pos <- chr_len %>%
 mutate(total = cumsum(chr_len) - chr_len) %>%
 select(-chr_len)

# calculate accumulated position
Samplenew <- chr_pos %>%
 left_join(Sample, ., by="Chromosome") %>%
 arrange(Chromosome, Position) %>%
 mutate(Positioncum = Position + total)

# calculate the X-axis label position
chrnum <- Samplenew %>% group_by(Chromosome) %>% summarize(center=(max(Positioncum)+min(Positioncum))/2)

# sliding window analysis
df <- calcValueByWindow(pos = Samplenew$Positioncum, value = Samplenew$AC142_EA49)

library(ggplot2)
library(RColorBrewer)
ggplot(Samplenew, aes(Positioncum,AC142_EA49)) + theme(panel.grid = element_blank(), axis.line = element_line(color = 'black'), panel.background = element_rect(fill = 'transparent')) + geom_point(aes(color = Chromosome),size = 0.3, show.legend = FALSE) + scale_color_manual(values = brewer.pal(12,"Set3")) + ylim(0,1) + labs(x = 'Chromosome', y = 'index', title = 'AC142_EA49') + scale_x_continuous(breaks = chrnum$center, labels = chrnum$Chromosome, expand = c(0, 0)) + geom_line(data = df, aes(x = pos, y = value), color = 'black', size = 0.5, show.legend = FALSE) + geom_hline(yintercept = c(0.2, 0.8), color = 'red', linetype = 2, size = 0.4)
ggsave('AC142_EA49.png',width = 9.6, height = 1.64)