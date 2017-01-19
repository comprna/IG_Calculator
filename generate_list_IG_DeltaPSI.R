"
 generate_list_IG_DeltaPSI.R
 
 * Summary    : From the list created with RandomizeMultipleArff.java, we generate the list of events whose difference in IG
 *		between the normal and shuffle IG values is postivie and the DeltaPSI is higher than 0.1
 
 * Usage      : R --silent --vanilla --args <IG_tab_file> <arff_file> < generate_list_IG_DeltaPSI.R
  
 * Parameters : <IG_tab_file>: Tab file with the IG values generated with RandomizeMultipleArff.java
 *              <arff_file>: ARFF file where to extract the instances
"

library(ggplot2)
library(plyr)
library(RWeka)

# 1. Parse command line arguments
CHARACTER_command_args <- commandArgs(trailingOnly=TRUE)
CHARACTER_ig_file <- CHARACTER_command_args[1]
 

# 2. Read input file
DATA.FRAME_ig <- read.table(CHARACTER_ig_file)
colnames(DATA.FRAME_ig) <- c("event", "description", "igain")
DATA.FRAME_ig2 <- as.data.frame(sapply(DATA.FRAME_ig$igain,function(x)as.numeric(as.character(x))))
DATA.FRAME_ig3 <- cbind(DATA.FRAME_ig[,-3],DATA.FRAME_ig2)
colnames(DATA.FRAME_ig3) <- c("event", "description", "igain")


# 3. Collapse data
DATA.FRAME_igsum <- ddply(DATA.FRAME_ig3, .variables = c("event", "description"), summarise, mean = mean(igain))
DATA.FRAME_igsum_normal <- DATA.FRAME_igsum[DATA.FRAME_igsum$description == "Normal",]
DATA.FRAME_igsum_shuffle <- DATA.FRAME_igsum[DATA.FRAME_igsum$description == "Shuffle",]
DATA.FRAME_merged <- merge(DATA.FRAME_igsum_normal, DATA.FRAME_igsum_shuffle, by = "event", suffixes = c(".normal", ".shuffle"))


# 4. Get the difference for each subset between the normal and the shuffle IG value
DATA.FRAME_merged$diff_ig <- DATA.FRAME_merged$mean.normal - DATA.FRAME_merged$mean.shuffle
DATA.FRAME_sorted <- arrange(DATA.FRAME_merged, desc(diff_ig))
events_file <- as.data.frame(unique(DATA.FRAME_sorted$event))
colnames(events_file)[1] <- "event"
events_file2 <- merge(events_file,DATA.FRAME_sorted,by="event")[,c(-2:-5)]
events_file3 <- events_file2


# 5. Get the delta_psi for all the events that are above 0.1
event_final3_f <- read.arff(file=CHARACTER_command_args[2])
classes <- levels(event_final3_f$class)
samples_0 <- event_final3_f[which(event_final3_f$class==classes[1]),]
samples_1 <- event_final3_f[which(event_final3_f$class!=classes[1]),]
mean_0 <- apply(samples_0[,-ncol(samples_0)],2,function(x)mean(x))
mean_1 <- apply(samples_1[,-ncol(samples_1)],2,function(x)mean(x))
deltaPSI <- mean_0 - mean_1
diff_IG <- events_file3$diff_ig
event <- colnames(event_final3_f)[-length(colnames(event_final3_f))]
event_final4 <- as.data.frame(cbind(event,diff_IG,deltaPSI))
event_final5 <- event_final4[which(abs(as.numeric(as.character(event_final4$deltaPSI)))>0.1),]


# 6. Filter those events whose diff_ig is negative
event_final6 <- event_final5[which(as.numeric(as.character(event_final5$diff_IG))>0),]
event_final_filtered <- event_final6
event_final_filtered <- arrange(event_final_filtered, desc(diff_IG))
write.table(event_final_filtered,quote=FALSE,sep="\t",file=paste0(substr(CHARACTER_ig_file,1,nchar(CHARACTER_ig_file)-4),"_IG_DeltaPSI.tab"))


