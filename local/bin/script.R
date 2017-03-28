args <- commandArgs(trailingOnly = TRUE)

#setwd("/mnt/isilon/aplenc/data/R/")
#getwd()

library(tools)
require(ggplot2)
require(dplyr)

input_file <- args[1]
output_file <- args[2]

info = file.info(input_file)
empty = info$size == 0
#empty = rownames(info[info$size == 0, ])

#rmarkdown::render(input = "report.Rmd", output_file = paste(args[1], "-x", args[2], "-", args[3], ".html", sep = ""))

if(empty) {
  pdf( output_file ) 
} else {
  dat <- read.table(input_file,header=FALSE,sep="\t",na.strings="NA",dec=".",strip.white=TRUE,stringsAsFactors = FALSE)
  colnames(dat) <- c("Chr","locus","depth")

  dat %>% ggplot(aes(x = locus, y = depth)) +
    geom_point() +
    theme_bw() +
    scale_y_log10() +
    ggsave(output_file, width=8, height=6, useDingbats=F)
}

#dev.off()
