########################################################################################################################
# Description
########################################################################################################################

# This is done this way so that the data files are preserved for repeatability

########################################################################################################################
# Set up the environment
########################################################################################################################

# MissForest is used to create the "missingness" of various degrees
library(missForest)

########################################################################################################################
# Load the data for preparation
########################################################################################################################

#datafileSmall = "G:\\Team Drives\\PDH Data\\MoH\\Datasets for Imputation\\SourceFilesv1.4\\01 Initial 100k random rows - small.csv"
datafileLarge = "G:\\Team Drives\\PDH Data\\MoH\\Datasets for Imputation\\SourceFilesv1.4\\01 Initial 100k random rows - large.csv"
#initialSmall.df = read.csv(datafileSmall, header=TRUE, encoding = "ascii")
initialLarge.df = read.csv(datafileLarge, header=TRUE, encoding = "ascii")

# Convert all the "NULL" text values to 'NA'
#initialSmall.df[initialSmall.df == "NULL"] = NA
initialLarge.df[initialLarge.df == "NULL"] = NA

#######################################
# The smaller subsets are the top 100, 1000 and 10,000 rows respectively
# These subsets will be saved and used as the xtrue datasets in MissForest

# df100kFullp0s = initialSmall.df
# df10kp0s = df100kFullp0s[1:10000, ]
# df100p0s = df10kp0s[1:100,]
# df1kp0s = df10kp0s[1:1000,]

df100kFullp0L = initialLarge.df
df10kp0L = df100kFullp0L[1:10000, ]
df100p0L = df10kp0L[1:100,]
df1kp0L = df10kp0L[1:1000,]

#######################################
# These subsets will be saved and used as the xmis datasets in MissForest.
# There is one for each size and level of missingness

# df100p10s = prodNA(df100p0s, noNA = 0.1)
# df100p20s = prodNA(df100p0s, noNA = 0.2)
# df100p30s = prodNA(df100p0s, noNA = 0.3)
# df100p40s = prodNA(df100p0s, noNA = 0.4)
# df100p50s = prodNA(df100p0s, noNA = 0.5)
# df100p60s = prodNA(df100p0s, noNA = 0.6)
# df100p70s = prodNA(df100p0s, noNA = 0.7)
# df100p80s = prodNA(df100p0s, noNA = 0.8)
# df100p90s = prodNA(df100p0s, noNA = 0.9)

df100p10L = prodNA(df100p0L, noNA = 0.1)
df100p20L = prodNA(df100p0L, noNA = 0.2)
df100p30L = prodNA(df100p0L, noNA = 0.3)
df100p40L = prodNA(df100p0L, noNA = 0.4)
df100p50L = prodNA(df100p0L, noNA = 0.5)
df100p60L = prodNA(df100p0L, noNA = 0.6)
df100p70L = prodNA(df100p0L, noNA = 0.7)
df100p80L = prodNA(df100p0L, noNA = 0.8)
df100p90L = prodNA(df100p0L, noNA = 0.9)

# df1kp10s = prodNA(df1kp0s, noNA = 0.1)
# df1kp20s = prodNA(df1kp0s, noNA = 0.2)
# df1kp30s = prodNA(df1kp0s, noNA = 0.3)
# df1kp40s = prodNA(df1kp0s, noNA = 0.4)
# df1kp50s = prodNA(df1kp0s, noNA = 0.5)
# df1kp60s = prodNA(df1kp0s, noNA = 0.6)
# df1kp70s = prodNA(df1kp0s, noNA = 0.7)
# df1kp80s = prodNA(df1kp0s, noNA = 0.8)
# df1kp90s = prodNA(df1kp0s, noNA = 0.9)

df1kp10L = prodNA(df1kp0L, noNA = 0.1)
df1kp20L = prodNA(df1kp0L, noNA = 0.2)
df1kp30L = prodNA(df1kp0L, noNA = 0.3)
df1kp40L = prodNA(df1kp0L, noNA = 0.4)
df1kp50L = prodNA(df1kp0L, noNA = 0.5)
df1kp60L = prodNA(df1kp0L, noNA = 0.6)
df1kp70L = prodNA(df1kp0L, noNA = 0.7)
df1kp80L = prodNA(df1kp0L, noNA = 0.8)
df1kp90L = prodNA(df1kp0L, noNA = 0.9)

# df10kp10s = prodNA(df10kp0s, noNA = 0.1)
# df10kp20s = prodNA(df10kp0s, noNA = 0.2)
# df10kp30s = prodNA(df10kp0s, noNA = 0.3)
# df10kp40s = prodNA(df10kp0s, noNA = 0.4)
# df10kp50s = prodNA(df10kp0s, noNA = 0.5)
# df10kp60s = prodNA(df10kp0s, noNA = 0.6)
# df10kp70s = prodNA(df10kp0s, noNA = 0.7)
# df10kp80s = prodNA(df10kp0s, noNA = 0.8)
# df10kp90s = prodNA(df10kp0s, noNA = 0.9)

df10kp10L = prodNA(df10kp0L, noNA = 0.1)
df10kp20L = prodNA(df10kp0L, noNA = 0.2)
df10kp30L = prodNA(df10kp0L, noNA = 0.3)
df10kp40L = prodNA(df10kp0L, noNA = 0.4)
df10kp50L = prodNA(df10kp0L, noNA = 0.5)
df10kp60L = prodNA(df10kp0L, noNA = 0.6)
df10kp70L = prodNA(df10kp0L, noNA = 0.7)
df10kp80L = prodNA(df10kp0L, noNA = 0.8)
df10kp90L = prodNA(df10kp0L, noNA = 0.9)

# df100kFullp10s = prodNA(df100kFullp0s, noNA = 0.1)
# df100kFullp20s = prodNA(df100kFullp0s, noNA = 0.2)
# df100kFullp30s = prodNA(df100kFullp0s, noNA = 0.3)
# df100kFullp40s = prodNA(df100kFullp0s, noNA = 0.4)
# df100kFullp50s = prodNA(df100kFullp0s, noNA = 0.5)
# df100kFullp60s = prodNA(df100kFullp0s, noNA = 0.6)
# df100kFullp70s = prodNA(df100kFullp0s, noNA = 0.7)
# df100kFullp80s = prodNA(df100kFullp0s, noNA = 0.8)
# df100kFullp90s = prodNA(df100kFullp0s, noNA = 0.9)

df100kFullp10L = prodNA(df100kFullp0L, noNA = 0.1)
df100kFullp20L = prodNA(df100kFullp0L, noNA = 0.2)
df100kFullp30L = prodNA(df100kFullp0L, noNA = 0.3)
df100kFullp40L = prodNA(df100kFullp0L, noNA = 0.4)
df100kFullp50L = prodNA(df100kFullp0L, noNA = 0.5)
df100kFullp60L = prodNA(df100kFullp0L, noNA = 0.6)
df100kFullp70L = prodNA(df100kFullp0L, noNA = 0.7)
df100kFullp80L = prodNA(df100kFullp0L, noNA = 0.8)
df100kFullp90L = prodNA(df100kFullp0L, noNA = 0.9)

#######################################
# Save each of the dataframes as CSV to be collected by the testing code

datafilepath = "G:\\Team Drives\\PDH Data\\MoH\\Datasets for Imputation\\SourceFilesV1.4\\"
writeToCSV = function(df, filename){
  rownames(df) = c()
  df$diag01Chapter = as.character(df$diag01Chapter)
  write.csv(df, file = filename, row.names=FALSE)
}

# Complete files
# writeToCSV(df100p0s, file = paste(datafilepath, "df100p0s.csv", sep = ""))
# writeToCSV(df1kp0s, file = paste(datafilepath, "df1kp0s.csv", sep = ""))
# writeToCSV(df10kp0s, file = paste(datafilepath, "df10kp0s.csv", sep = ""))
# writeToCSV(df100kFullp0s, file = paste(datafilepath, "df100kFullp0s.csv", sep = ""))

writeToCSV(df100p0L, file = paste(datafilepath, "df100p0L.csv", sep = ""))
writeToCSV(df1kp0L, file = paste(datafilepath, "df1kp0L.csv", sep = ""))
writeToCSV(df10kp0L, file = paste(datafilepath, "df10kp0L.csv", sep = ""))
writeToCSV(df100kFullp0L, file = paste(datafilepath, "df100kFullp0L.csv", sep = ""))

# 100 rows
# writeToCSV(df100p10s, file = paste(datafilepath, "df100p10s.csv", sep = ""))
# writeToCSV(df100p20s, file = paste(datafilepath, "df100p20s.csv", sep = ""))
# writeToCSV(df100p30s, file = paste(datafilepath, "df100p30s.csv", sep = ""))
# writeToCSV(df100p40s, file = paste(datafilepath, "df100p40s.csv", sep = ""))
# writeToCSV(df100p50s, file = paste(datafilepath, "df100p50s.csv", sep = ""))
# writeToCSV(df100p60s, file = paste(datafilepath, "df100p60s.csv", sep = ""))
# writeToCSV(df100p70s, file = paste(datafilepath, "df100p70s.csv", sep = ""))
# writeToCSV(df100p80s, file = paste(datafilepath, "df100p80s.csv", sep = ""))
# writeToCSV(df100p90s, file = paste(datafilepath, "df100p90s.csv", sep = ""))

writeToCSV(df100p10L, file = paste(datafilepath, "df100p10L.csv", sep = ""))
writeToCSV(df100p20L, file = paste(datafilepath, "df100p20L.csv", sep = ""))
writeToCSV(df100p30L, file = paste(datafilepath, "df100p30L.csv", sep = ""))
writeToCSV(df100p40L, file = paste(datafilepath, "df100p40L.csv", sep = ""))
writeToCSV(df100p50L, file = paste(datafilepath, "df100p50L.csv", sep = ""))
writeToCSV(df100p60L, file = paste(datafilepath, "df100p60L.csv", sep = ""))
writeToCSV(df100p70L, file = paste(datafilepath, "df100p70L.csv", sep = ""))
writeToCSV(df100p80L, file = paste(datafilepath, "df100p80L.csv", sep = ""))
writeToCSV(df100p90L, file = paste(datafilepath, "df100p90L.csv", sep = ""))

# 1k Rows
# writeToCSV(df1kp10s, file = paste(datafilepath, "df1kp10s.csv", sep = ""))
# writeToCSV(df1kp20s, file = paste(datafilepath, "df1kp20s.csv", sep = ""))
# writeToCSV(df1kp30s, file = paste(datafilepath, "df1kp30s.csv", sep = ""))
# writeToCSV(df1kp40s, file = paste(datafilepath, "df1kp40s.csv", sep = ""))
# writeToCSV(df1kp50s, file = paste(datafilepath, "df1kp50s.csv", sep = ""))
# writeToCSV(df1kp60s, file = paste(datafilepath, "df1kp60s.csv", sep = ""))
# writeToCSV(df1kp70s, file = paste(datafilepath, "df1kp70s.csv", sep = ""))
# writeToCSV(df1kp80s, file = paste(datafilepath, "df1kp80s.csv", sep = ""))
# writeToCSV(df1kp90s, file = paste(datafilepath, "df1kp90s.csv", sep = ""))

writeToCSV(df1kp10L, file = paste(datafilepath, "df1kp10L.csv", sep = ""))
writeToCSV(df1kp20L, file = paste(datafilepath, "df1kp20L.csv", sep = ""))
writeToCSV(df1kp30L, file = paste(datafilepath, "df1kp30L.csv", sep = ""))
writeToCSV(df1kp40L, file = paste(datafilepath, "df1kp40L.csv", sep = ""))
writeToCSV(df1kp50L, file = paste(datafilepath, "df1kp50L.csv", sep = ""))
writeToCSV(df1kp60L, file = paste(datafilepath, "df1kp60L.csv", sep = ""))
writeToCSV(df1kp70L, file = paste(datafilepath, "df1kp70L.csv", sep = ""))
writeToCSV(df1kp80L, file = paste(datafilepath, "df1kp80L.csv", sep = ""))
writeToCSV(df1kp90L, file = paste(datafilepath, "df1kp90L.csv", sep = ""))

# 10k Rows
# writeToCSV(df10kp10s, file = paste(datafilepath, "df10kp10s.csv", sep = ""))
# writeToCSV(df10kp20s, file = paste(datafilepath, "df10kp20s.csv", sep = ""))
# writeToCSV(df10kp30s, file = paste(datafilepath, "df10kp30s.csv", sep = ""))
# writeToCSV(df10kp40s, file = paste(datafilepath, "df10kp40s.csv", sep = ""))
# writeToCSV(df10kp50s, file = paste(datafilepath, "df10kp50s.csv", sep = ""))
# writeToCSV(df10kp60s, file = paste(datafilepath, "df10kp60s.csv", sep = ""))
# writeToCSV(df10kp70s, file = paste(datafilepath, "df10kp70s.csv", sep = ""))
# writeToCSV(df10kp80s, file = paste(datafilepath, "df10kp80s.csv", sep = ""))
# writeToCSV(df10kp90s, file = paste(datafilepath, "df10kp90s.csv", sep = ""))

writeToCSV(df10kp10L, file = paste(datafilepath, "df10kp10L.csv", sep = ""))
writeToCSV(df10kp20L, file = paste(datafilepath, "df10kp20L.csv", sep = ""))
writeToCSV(df10kp30L, file = paste(datafilepath, "df10kp30L.csv", sep = ""))
writeToCSV(df10kp40L, file = paste(datafilepath, "df10kp40L.csv", sep = ""))
writeToCSV(df10kp50L, file = paste(datafilepath, "df10kp50L.csv", sep = ""))
writeToCSV(df10kp60L, file = paste(datafilepath, "df10kp60L.csv", sep = ""))
writeToCSV(df10kp70L, file = paste(datafilepath, "df10kp70L.csv", sep = ""))
writeToCSV(df10kp80L, file = paste(datafilepath, "df10kp80L.csv", sep = ""))
writeToCSV(df10kp90L, file = paste(datafilepath, "df10kp90L.csv", sep = ""))

# 100k Rows
# writeToCSV(df100kFullp10s, file = paste(datafilepath, "df100kFullp10s.csv", sep = ""))
# writeToCSV(df100kFullp20s, file = paste(datafilepath, "df100kFullp20s.csv", sep = ""))
# writeToCSV(df100kFullp30s, file = paste(datafilepath, "df100kFullp30s.csv", sep = ""))
# writeToCSV(df100kFullp40s, file = paste(datafilepath, "df100kFullp40s.csv", sep = ""))
# writeToCSV(df100kFullp50s, file = paste(datafilepath, "df100kFullp50s.csv", sep = ""))
# writeToCSV(df100kFullp60s, file = paste(datafilepath, "df100kFullp60s.csv", sep = ""))
# writeToCSV(df100kFullp70s, file = paste(datafilepath, "df100kFullp70s.csv", sep = ""))
# writeToCSV(df100kFullp80s, file = paste(datafilepath, "df100kFullp80s.csv", sep = ""))
# writeToCSV(df100kFullp90s, file = paste(datafilepath, "df100kFullp90s.csv", sep = ""))

writeToCSV(df100kFullp10L, file = paste(datafilepath, "df100kFullp10L.csv", sep = ""))
writeToCSV(df100kFullp20L, file = paste(datafilepath, "df100kFullp20L.csv", sep = ""))
writeToCSV(df100kFullp30L, file = paste(datafilepath, "df100kFullp30L.csv", sep = ""))
writeToCSV(df100kFullp40L, file = paste(datafilepath, "df100kFullp40L.csv", sep = ""))
writeToCSV(df100kFullp50L, file = paste(datafilepath, "df100kFullp50L.csv", sep = ""))
writeToCSV(df100kFullp60L, file = paste(datafilepath, "df100kFullp60L.csv", sep = ""))
writeToCSV(df100kFullp70L, file = paste(datafilepath, "df100kFullp70L.csv", sep = ""))
writeToCSV(df100kFullp80L, file = paste(datafilepath, "df100kFullp80L.csv", sep = ""))
writeToCSV(df100kFullp90L, file = paste(datafilepath, "df100kFullp90L.csv", sep = ""))

#######################################
# tidy up the environment
rm(list=ls())