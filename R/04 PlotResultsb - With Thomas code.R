########################################################################################################################
# Set up the environment
########################################################################################################################

library(ggplot2)
library(gridExtra)
library(GGally)
library (methods)
library(corrplot)
library(descr)

setClass("myDateTime")
setAs("character","myDateTime", function(from) as.POSIXct(from, format="%Y-%m-%d %H:%M:%S") )

setClass("quotedNumeric") 
setAs("character", "quotedNumeric", function(from) as.numeric(gsub("\"", "", from)))

setClass("quotedInteger") 
setAs("character", "quotedInteger", function(from) as.integer(gsub("\"", "", from)))

########################################################################################################################
# Prepare the dataframe
########################################################################################################################

mfColInfo = c("factor", "factor", "factor", "quotedInteger", "quotedInteger", "factor", "quotedInteger", "myDateTime", "myDateTime", "quotedNumeric", "quotedNumeric", "quotedNumeric", "quotedNumeric")
mfColInfo02 = c("quotedInteger", "quotedInteger", "factor", "factor", "quotedNumeric")
              
#datafile = "c:\\temp\\resultsSC.csv"
datafile = "G:\\Team Drives\\PDH Data\\MoH\\Final Results\\results.small.csv"
#datafile02 = "G:\\Team Drives\\PDH Data\\MoH\\Final Results\\results.variances.small.csv"
datafileL = "G:\\Team Drives\\PDH Data\\MoH\\Final Results\\results.large.csv"
#datafile02L = "G:\\Team Drives\\PDH Data\\MoH\\Final Results\\results.variances.large.csv"
datafileBIG = "G:\\Team Drives\\PDH Data\\MoH\\Final Results\\results.small.big.csv"


results.df = read.csv(datafile, header=TRUE, colClasses=mfColInfo)
#variances.df = read.csv(datafile02, header=TRUE, colClasses=mfColInfo02)

resultsL.df = read.csv(datafileL, header=TRUE, colClasses=mfColInfo)
#variances.df = read.csv(datafile02, header=TRUE, colClasses=mfColInfo02)

resultsBig.df = read.csv(datafileBIG, header=TRUE, colClasses=mfColInfo)

################################
# Remove the superfluos row and columns & rownames

# Remove the dataset name, duration, start and end datetime
results.df = data.frame(results.df[, c(1, 3, 4, 5, 6, 7)], results.df[, 10:13])
resultsL.df = data.frame(resultsL.df[, c(1, 3, 4, 5, 6, 7)], resultsL.df[, 10:13])
resultsBig.df = data.frame(resultsBig.df[, c(1, 3, 4, 5, 6, 7)], resultsBig.df[, 10:13])

# Remove the rows that are "headers" for the start of a new dataset size
results.df = results.df[results.df$rows != 0, ]
resultsL.df = resultsL.df[resultsL.df$rows != 0, ]
resultsBig.df = resultsBig.df[resultsBig.df$rows != 0, ]

# Remove row headers
rownames(results.df) = c()
rownames(resultsL.df) = c()
rownames(resultsBig.df) = c()

################################
# Create a dataframe that has the means, medians, min and max for each by 

# Remove all the m1-20 that are there for Mice
results.df = results.df[results.df$m == 0, ]
resultsL.df = resultsL.df[resultsL.df$m == 0, ]
resultsBig.df = resultsBig.df[resultsBig.df$m == 0, ]

# Mean
plot.df = aggregate(results.df[, 8:10], list(results.df$missingness, results.df$rows, results.df$algorithm), mean, na.rm=TRUE, na.action=NULL)
colnames(plot.df) = c("missingness", "rows", "algorithm", "normalisedDuration", "NRMSE", "PFC")

plotL.df = aggregate(resultsL.df[, 8:10], list(resultsL.df$missingness, resultsL.df$rows, resultsL.df$algorithm), mean, na.rm=TRUE, na.action=NULL)
colnames(plotL.df) = c("missingness", "rows", "algorithm", "normalisedDuration", "NRMSE", "PFC")
#levels(plotL.df$algorithm) = c('MeanMode', 'MIDAS', 'MissForest', 'MissRanger', 'Mice')
#levels(plot.df$algorithm) = c('MeanMode', 'MIDAS', 'MissForest', 'MissRanger', 'Mice')

plotBig.df = aggregate(resultsBig.df[, 8:10], list(resultsBig.df$missingness, resultsBig.df$rows, resultsBig.df$algorithm), mean, na.rm=TRUE, na.action=NULL)
colnames(plotBig.df) = c("missingness", "rows", "algorithm", "normalisedDuration", "NRMSE", "PFC")



# Max
results2.df = aggregate(results.df[, 8:10], list(results.df$missingness, results.df$rows, results.df$algorithm), max, na.rm=TRUE, na.action=NULL)
plot.df$maxNRMSE = results2.df$NRMSE
plot.df$maxPFC = results2.df$PFC
plot.df$maxNormalisedDuration = results2.df$normalisedDuration

# Min
results2.df = aggregate(results.df[, 8:10], list(results.df$missingness, results.df$rows, results.df$algorithm), min, na.rm=TRUE, na.action=NULL)
plot.df$minNRMSE = results2.df$NRMSE
plot.df$minPFC = results2.df$PFC
plot.df$minNormalisedDuration = results2.df$normalisedDuration

# Create a combined label
#plot.df$fullCase = paste(plot.df$missingness, plot.df$rows, plot.df$algorithm, sep = " ")
plot.df$algRows = paste(plot.df$algorithm, plot.df$rows, sep = " ")
#plot.df$algMissingnessRows = paste(plot.df$algorithm, plot.df$missingness, plot.df$rows, sep = " ")

rm(results2.df)
#rm(results.df)

########################################################################################################################
# Plot the results using R
########################################################################################################################

##########################
# Pairs plot

cols = character(nrow(plot.df))
cols[] = "black"

cols[plot.df$algRows == "Mice 100"] = "red"
cols[plot.df$algRows == "Mice 1000"] = "orange"
cols[plot.df$algRows == "Mice 10000"] = "purple"
cols[plot.df$algRows == "MissForest 100"] = "cyan"
cols[plot.df$algRows == "MissForest 1000"] = "lightgreen"
cols[plot.df$algRows == "MissForest 10000"] = "green"
cols[plot.df$algRows == "MeanMode 100"] = "lightblue"
cols[plot.df$algRows == "MeanMode 1000"] = "blue"
cols[plot.df$algRows == "MeanMode 1000"] = "black"

legendcols = c("lightblue", "blue", "black", "red", "orange", "purple", "cyan", "lightgreen", "green")

pchs = character(nrow(plot.df))
pchs[] = "o"
pchs[plot.df$missingness == 10] = "1"
pchs[plot.df$missingness == 20] = "2"
pchs[plot.df$missingness == 30] = "3"
pchs[plot.df$missingness == 40] = "4"
pchs[plot.df$missingness == 50] = "5"
pchs[plot.df$missingness == 60] = "6"
pchs[plot.df$missingness == 70] = "7"
pchs[plot.df$missingness == 80] = "8"
pchs[plot.df$missingness == 90] = "9"

legends = as.vector(unique(plot.df$algRows))

# pairs(~normalisedDuration+NRMSE+PFC+algorithm, data = plot.df, main="Comparison of performance difference (speed and accuracy) between Multiple Imputation factors", col = cols, pch = pchs, cex = 1.5, lower.panel = NULL)
# par(xpd = TRUE)
# legend(x = 0.055, y = 0.3, legend = legends, fill = legendcols, col = legendcols, bty = "n", ncol = 1)

########################################################################################################################
# Other plots
########################################################################################################################

######################################
# Not used

# par(mfrow=c(4,3), las = 1, mar=c(5.1,4.1,4.1,2.1))
# boxplot(normalisedDuration~rows, data=plot.df, ylim=c(0, 0.7), main = "Normalised Duration", sub = "Rows")
# boxplot(normalisedDuration~algorithm, data=plot.df, ylim=c(0, 0.7), sub = "Algorithm")
# boxplot(normalisedDuration~missingness, data=plot.df, ylim=c(0, 0.7), sub = "Missingness")
# 
# boxplot(NRMSE~rows, data=plot.df, ylim=c(0, 1), main = "NRMSE", sub = "Rows")
# boxplot(NRMSE~algorithm, data=plot.df, ylim=c(0, 1), sub = "Algorithm")
# boxplot(NRMSE~missingness, data=plot.df, ylim=c(0, 1), sub = "Missingness")
# 
# boxplot(PFC~rows, data=plot.df, ylim=c(0, 0.06), main = "PFC", sub = "Rows")
# boxplot(PFC~algorithm, data=plot.df, ylim=c(0, 0.06), sub = "Algorithm")
# boxplot(PFC~missingness, data=plot.df, ylim=c(0, 0.06), sub = "Missingness")
# 
# par(las = 2, mar=c(10.1,4.1,4.1,2.1))
# boxplot(normalisedDuration~algRows, data=plot.df, ylim=c(0, 1), main = "Normalised Duration")
# boxplot(NRMSE~algRows, data=plot.df, ylim=c(0, 1), main = "NRMSE")
# boxplot(PFC~algRows, data=plot.df, ylim=c(0, 0.1), main = "PFC")

# End not used
######################################

########################################################################################################################
# Comparison of algorithms
########################################################################################################################

# Use GGPlot2 to get faceted versions of the graphs
# bp.NRMSE = ggplot(plot.df, aes(x=missingness, y=NRMSE, group=missingness, col = algorithm)) + geom_point(aes(fill=missingness)) + theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") + scale_x_continuous(name ="Missingness", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90))+ scale_y_continuous(limits = c(0.015, 0.045))
# bp.NRMSE = bp.NRMSE + facet_grid(rows ~ algorithm)
# print(bp.NRMSE)
# 
# bp.PFC = ggplot(plot.df, aes(x=missingness, y=PFC, group=missingness)) + geom_point(aes(fill=missingness)) + theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") + scale_x_continuous(name ="Missingness", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) + scale_y_continuous(name ="Proportion Falsely Classified", limits = c(0.15, 0.6))
# bp.PFC = bp.PFC + facet_grid(rows ~ algorithm)
# print(bp.PFC)

# bp.nd = ggplot(plot.df, aes(x=missingness, y=normalisedDuration, group=missingness)) + geom_point(aes(fill = NRMSE)) + theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") + scale_x_continuous(name ="Missingness", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) + scale_y_continuous(name ="Normalised Duration")
# bp.nd = bp.nd + facet_grid(rows ~ algorithm)
# print(bp.nd)

########################################################################################################################
# Comparison of MICE imputation variance vs MSE and Correct Imputations vs Proportion of Mode Correct
#
# The way that the variables are calculated:
#   Continuous:
#     Imputation variance (uncertainty): this is the between imputation differences. Across the "m" datasets, how dispersed are the imputations. The variance is calculated. The mean is taken for all observations for the variable.
#     MSE (bias): The differences between the true value and each of the imputed datasets. The mean is taken for all observations for the variable.
#   Discreet:
#     Proportion of Correct Imputations: The number of imputations that are correct. The mean is taken for all observations for the variable.
#     Proportion of Modes correct: Whether the mode of the "m" datasets for each value is "true". The proportion of correct means is calculated for the variable.
#
########################################################################################################################

# Use GGPlot2 to get faceted versions of the graphs
##########################
# For the  continuous variables

# plot.df = aggregate(variances.df[, 5], list(variances.df$missingness, variances.df$rows, variances.df$type), mean, na.omit = FALSE)
# colnames(plot.df) = c("missingness", "rows", "type", "value")
# 
# mse.df = plot.df[plot.df$type == "mse" | plot.df$type == "variance", ]
# mse.df$value = sqrt(as.numeric(mse.df$value))
# plot.MSE = ggplot(mse.df, aes(x = missingness, y = value)) + geom_point(aes(color = type)) + theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "bottom") + scale_x_discrete(name ="Missingness") + scale_y_continuous(name ="RMSE")
# plot.MSE = plot.MSE + facet_grid(~rows) + ggtitle("RMSE for each level of Missingness") + scale_color_discrete(breaks=c("mse","variance"), labels = c("RMSE", "Variance"), name = "")
# rm(mse.df)
# 
# trueInRange.df = plot.df[plot.df$type == "isTrueInRange", ]
# plot.trueInRange = ggplot(trueInRange.df, aes(x = missingness, y = value)) + geom_point() + theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") + scale_x_discrete(name ="Missingness") + scale_y_continuous(name ="True In Range?", breaks=c(0, 1, 2))
# plot.trueInRange = plot.trueInRange + facet_grid(~rows) + ggtitle("Is the true value included in the range of Imputed values for each level of Missingness?")
# rm(trueInRange.df)

##########################
# For the Categorical variables

# propC.df = plot.df[plot.df$type == "proportionCorrect" | plot.df$type == "isTrueChosen" | plot.df$type == "isModeCorrect", ]
# propC.df$value = sqrt(as.numeric(propC.df$value))
# plot.propC = ggplot(propC.df, aes(x = missingness, y = value)) + geom_point(aes(color = type)) + theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "bottom") + scale_x_discrete(name ="Missingness") + scale_y_continuous(name ="Proportion")
# plot.propC = plot.propC + facet_grid(~rows) + ggtitle("Proportion of Imputed datasets that chose the True value, proportion where the True value was chosen and proportion where the mode is True for each level of Missingness") + scale_color_discrete(breaks=c("isModeCorrect", "proportionCorrect", "isTrueChosen"), labels = c("Proportion Mode Is Correct", "Proportion Correct", "Proportion True is Chosen"), name = "")
# rm(propC.df)
# 
# grid.arrange(plot.propC, plot.MSE, plot.trueInRange, nrow = 3)

##########################
# Line version of the graphs

# a.plot = ggplot(data = plot.df, aes(x = missingness, y = NRMSE, col=algorithm)) +
#       geom_point(aes(col=algorithm)) +
#        facet_wrap(~rows) +
#        ggtitle('Graph 1') +
#        xlab("% of Missing Data") +
#        ylab("Relative Root Mean Square Error") +
#        theme(panel.background=element_rect(fill=rgb(255,250,238,max=255)), panel.grid.major = element_line(size = 0.5, linetype = "solid",colour = rgb(146,208,81,50,max=255))) +
#        geom_smooth(se = FALSE)
# print(a.plot)
# 
# 
# b.plot = ggplot(plot.df, aes(x = missingness, y = normalisedDuration, group=rows)) + 
#   geom_point(aes(col = algorithm)) + 
#   facet_wrap(~rows) + 
#   ggtitle('Graph 2') +
#   xlab("% rows with missing data") + 
#   ylab("Time per row") +
#   scale_y_log10() +
#   theme(panel.background=element_rect(fill=rgb(255,250,238,max=255)),panel.grid.major = element_line(size = 0.5, linetype = "solid",colour = rgb(146,208,81,50,max=255)))
# print(b.plot)

##########################
# Plots for 18 Features


# Exclduing MICE
lp.nd2 = ggplot(plot.df[plot.df$algorithm != 'Mice',], aes(x=missingness, y=normalisedDuration, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  #ggtitle('Comparison of 18 variables for different dataset sizes and Algorithms') +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "bottom", legend.background = element_rect(fill="#F5F5F5", size=0.5, linetype="solid", colour ="gray"), legend.title = element_text(colour="black", size=10, face="bold")) +
  scale_x_continuous(name ="Excluding MICE", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) +
  scale_y_continuous(name ="Normalised Duration") +
  geom_smooth(se = FALSE)

lp.nd = ggplot(plot.df, aes(x = missingness, y = normalisedDuration, color = algorithm)) + 
  geom_point(aes(fill = algorithm)) + 
  facet_wrap(~rows) +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") + 
  scale_x_continuous(name ="Including MICE", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) + 
  scale_y_continuous(name ="Normalised Duration") +
  geom_smooth(se = FALSE)

lp.nrmse = ggplot(plot.df, aes(x = missingness, y = NRMSE, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") +
  scale_x_continuous(name ="", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) +
  scale_y_continuous(name ="Normalised Root Mean Square Error") +
  geom_smooth(se = FALSE)

lp.pfc = ggplot(plot.df, aes(x=missingness, y=PFC, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "bottom", legend.background = element_rect(fill="#F5F5F5", size=0.5, linetype="solid", colour ="gray"), legend.title = element_text(colour="black", size=10, face="bold")) +
  scale_x_continuous(name ="% of Missing Data", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) +
  scale_y_continuous(name ="Proportion Falsely Classified") +
  geom_smooth(se = FALSE) 

grid.arrange(lp.nd2, lp.nd, lp.nrmse, lp.pfc, nrow = 4)

       
##########################
# Plots for 59 Features

# Exclduing MICE
lp.large.nd2 = ggplot(plotL.df[plotL.df$algorithm != 'Mice',], aes(x=missingness, y=normalisedDuration, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  #ggtitle('Comparison of 59 variables for different dataset sizes and Algorithms') +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "bottom", legend.background = element_rect(fill="#F5F5F5", size=0.5, linetype="solid", colour ="gray"), legend.title = element_text(colour="black", size=10, face="bold")) +
  scale_x_continuous(name ="Excluding MICE", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) +
  scale_y_continuous(name ="Normalised Duration") +
  geom_smooth(se = FALSE)

lp.large.nd = ggplot(plotL.df, aes(x=missingness, y=normalisedDuration, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") +
  scale_x_continuous(name ="Including MICE", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) +
  scale_y_continuous(name ="Normalised Duration") +
  geom_smooth(se = FALSE)

lp.large.nrmse = ggplot(plotL.df, aes(x=missingness, y=NRMSE, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") +
  scale_x_continuous(name ="", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) +
  scale_y_continuous(name ="Normalised Root Mean Square Error") +
  geom_smooth(se = FALSE)

lp.large.pfc = ggplot(plotL.df, aes(x=missingness, y=PFC, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "bottom", legend.background = element_rect(fill="#F5F5F5", size=0.5, linetype="solid", colour ="gray"), legend.title = element_text(colour="black", size=10, face="bold")) +
  scale_x_continuous(name ="% of Missing Data", labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90"), breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90), limits = c(10, 90)) +
  scale_y_continuous(name ="Proportion Falsely Classified") +
  geom_smooth(se = FALSE)

grid.arrange(lp.large.nd2, lp.large.nd, lp.large.nrmse, lp.large.pfc, nrow = 4)


##########################
# Plots for BIG 18 Features

# Exclduing MICE
lp.big.nd2 = ggplot(plotBig.df[plotBig.df$algorithm != 'Mice',], aes(x=missingness, y=normalisedDuration, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  #ggtitle('Comparison of 59 variables for different dataset sizes and Algorithms') +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") +
  scale_x_continuous(name ="", labels=c("10", "20"), breaks=c(10, 20), limits = c(10, 20)) +
  scale_y_continuous(name ="Normalised Duration") +
  geom_smooth(se = FALSE)

lp.big.nrmse = ggplot(plotBig.df, aes(x=missingness, y=NRMSE, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "none") +
  scale_x_continuous(name ="% of Missing Data", labels=c("10", "20"), breaks=c(10, 20), limits = c(10, 20)) +
  scale_y_continuous(name ="Normalised Root Mean Square Error") +
  geom_smooth(se = FALSE)

lp.big.pfc = ggplot(plotBig.df, aes(x=missingness, y=PFC, color = algorithm)) +
  geom_point(aes(fill = algorithm)) +
  facet_wrap(~rows) +
  theme(panel.background = element_blank(), panel.border = element_rect(colour="black", fill=NA, size=1, linetype="solid"), legend.position = "bottom", legend.background = element_rect(fill="#F5F5F5", size=0.5, linetype="solid", colour ="gray"), legend.title = element_text(colour="black", size=10, face="bold")) +
  scale_x_continuous(name ="", labels=c("10", "20"), breaks=c(10, 20), limits = c(10, 20)) +
  scale_y_continuous(name ="Proportion Falsely Classified") +
  geom_smooth(se = FALSE)

windows(width = 5, height = 6)
grid.arrange(lp.big.nd2, lp.big.nrmse, lp.big.pfc, nrow = 2, ncol = 3)

