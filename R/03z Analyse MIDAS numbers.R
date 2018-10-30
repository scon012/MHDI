########################################################################################################################
# Set up the environment
########################################################################################################################

library(missForest)
library(doParallel)
library(methods)
library(imputeTS)

# This class is created because some of the numeric columns are quoted ""
setClass("quotedNumeric") 
setAs("character", "quotedNumeric", function(from) as.numeric(gsub("\"", "", from)))

setClass("quotedInteger") 
setAs("character", "quotedInteger", function(from) as.integer(gsub("\"", "", from)))

########################################################################################################################
# Define the types
########################################################################################################################

mfColInfoSmall = c("factor", "quotedInteger", "factor", "factor", "integer"
                   , "integer", "numeric", "integer"
                   , "factor", "factor", "factor"
                   , "factor", "factor", "factor"
                   , "integer", "integer", "integer", "integer"
)

mfColInfoLarge = c("factor", "factor", "quotedInteger", "factor", "factor"
                   , "factor", "quotedInteger", "factor", "factor", "factor"
                   , "integer", "integer", "integer", "integer", "quotedNumeric"
                   , "factor", "factor", "factor", "factor"
                   , "factor", "factor", "factor", "factor"
                   , "integer", "integer", "integer", "integer", "integer", "integer"
                   , "integer", "integer", "integer", "integer", "integer", "integer"
                   , "integer", "integer", "integer", "integer", "integer", "integer"
                   , "integer", "integer", "integer", "integer", "integer", "integer"
                   , "integer", "integer", "integer", "integer", "integer", "integer"
                   , "integer", "integer", "integer", "integer", "integer", "integer"
)

########################################################################################################################
# Housekeeping tasks
########################################################################################################################

#################################
# This is used to allow parallelisation of missForest
require(doParallel)
registerDoParallel(cores=8)
getDoParWorkers()

datafilepath = "G:\\Team Drives\\PDH Data\\MoH\\Datasets for Imputation\\SourceFilesV1.4\\"
resultsFile = "c:\\temp\\results.forMIDAS.csv"
variancesFile = "c:\\temp\\results.forMIDAS.variances.csv"
midasOutputFilePath = "c:\\temp\\MIDASexport\\"

#################################
# Write Results

writeResults = function (doHeaders = TRUE){
  write.table(results.mf, resultsFile, sep = ",", append = TRUE, row.names = FALSE, col.names = doHeaders)
  #write.table(variances.df, variancesFile, sep = ",", append = TRUE, row.names = FALSE, col.names = doHeaders)
}

#################################
# Initialise Results Dataframe

initResultsDF = function (dataset = "", size = "s", rows = 0, missingness = 0, start = NA, end = NA, duration = 0, algorithm = NA, runNum = 0, NRMSE = 0, PFC = 0, normalisedDuration = 0){
  assign("results.mf", data.frame(runNum = runNum, dataset = dataset, size = size, rows = rows, missingness = missingness, algorithm = algorithm, m = 0, start = start, end = end, duration = duration, normalisedDuration = normalisedDuration, NRMSE = NRMSE, PFC = PFC), envir = .GlobalEnv)
}

#################################
# Append Results Row

appendResultsRow = function (dataset, size, rows, missingness, start, end, duration, algorithm, m, runNum, NRMSE, PFC) {
  duration = as.numeric(as.POSIXlt(end)) - as.numeric(as.POSIXlt(start))
  normalisedDuration = duration / rows
  assign("results.mf", rbind(results.mf, data.frame(dataset = dataset, size = size, rows = rows, missingness = missingness, start = start, end = end, duration = duration, normalisedDuration = normalisedDuration, algorithm = algorithm, m = m, runNum = runNum, NRMSE = NRMSE, PFC = PFC)), envir = .GlobalEnv)
}

#################################
# Categorical functions

getmode = function(v) {
  uniqv = na.omit(unique(v))
  mode = as.character(uniqv[which.max(tabulate(match(v, uniqv)))][[1]])
  return (mode)
}

# getMin = function(v) {
#   uniqv = unique(v)
#   return(as.character(uniqv[which.min(tabulate(match(v, uniqv)))][[1]]))
# }
# 
# getCategoricalVariance = function (v) {
#   uniqv = unique(v)
#   #tabulate(match(v, uniqv))
#   return (sum(abs((length(v)/length(uniqv)) - tabulate(match(v, uniqv)))))
# }

########################################################################################################################
# Imputation methods
########################################################################################################################

#################################
# m datasets Aggregation

mDatasetsAggregate = function(filepath, xmis, xtrue, rows, missingness, m, run, colClasses, y) {
  
  getValues = function (ds, dsCount, x, y, type, trueVal) {
    if (type == "factor") {
      v = lapply(datasets, function(val) as.character(val[x, y]))
    } else {
      v = lapply(datasets, function(val) as.numeric(val[x, y]))
    }
    
    # Cope with the fact that MICE doesn't impute if all the values are the same. It leaves them as NA. For example, all DiabetesT1 in 100 rows are N. The missing value in the column does not get imputed to N
    if (sum(is.na(v) > 0)) {
      v = rep(trueVal, dsCount)
    }
    
    return (v)
  }
  
  resultList = list()
  
  ####################################################################
  # Generate the imputed dataset from the m number of imputed datasets
  
  # Get the number of datasets
  numberOfDatasets = m
  datasets = list()
  
  # Get the datasets
  for (i in 1:numberOfDatasets) {
    datasets[[i]] = read.csv(paste(filepath, run, dataset, size, "out", i, ".csv", sep = ""), header=TRUE, colClasses = colClasses, encoding = "ascii")
  }
  
  # Initialise the results dataframe
  mergeds = data.frame(x = 0, y = 0, type = "ToDrop", imputed = "DropMe", min = "", max = "", variance = "", proportionCorrect = 0, isModeCorrect = 0, isTrueInRange = NA, isTrueChosen = NA, stringsAsFactors=FALSE)
  
  # Get a matrix of T/F for the imputed values
  mis = is.na(xmis)
  
  #types = sapply(datasets[[1]], class)
  types = sapply(xtrue, class)
  numCols = length(xtrue)
  #for (y in 1:numCols) {
    print(paste(Sys.time(), "There are", table(mis[, y])[2], "missing values in this dataset of", numCols, "columns and", rows, "rows"))

    for (x in 1:rows) {
      
      trueValue = xtrue[x, y]
      
      # Only do the calculations if the value was imputed.
      if (mis[x, y]) {
        
        #print(paste(Sys.time(), "Get Values"))
        values = getValues(datasets, numberOfDatasets, x, y, types[y], trueValue)
        #print(paste(Sys.time(), "Got Values"))
        
        # Using the vector of values, calculate the various measures - the categorical data uses counts instead of values
        if (types[y] == "factor") {
          
          #print(paste(Sys.time(), "Get Mode"))
          imputed = getmode(values)
          #print(paste(Sys.time(), "Got mode"))
          # min = getMin(values)
          # max = imputed
          # variance = getCategoricalVariance (values)
          # isTrueInRange = NA
          # isTrueChosen = is.element(trueValue, values)
          
          ##############################
          # Number of correct across all imputed datasets - proportion of imputations correct. This will be used to calculated the rollup of this value.
          # numberCorrect = length(which(values == trueValue))
          # proportionCorrect = numberCorrect / numberOfDatasets
          
          ##############################
          # Is the mode correct? - To be used for calculating proportion of modes correct
          # modeValue = imputed
          # isModeCorrect = FALSE
          # if (trueValue == modeValue) {isModeCorrect = TRUE}
          
        } else {
          
          if (types[y] == "integer") {
            imputed = round(mean(as.numeric(values)))
          } else {
            imputed = mean(as.numeric(values))
          }
          # min = min(as.numeric(values))
          # max = max (as.numeric(values))
          # variance = var(as.numeric(values))
          # proportionCorrect = NA
          # modeCorrect = NA
          # isTrueInRange = FALSE
          # if (min <= imputed & imputed <= max) {isTrueInRange = TRUE}
          # isTrueChosen = NA
        } 
      } else {
        imputed = trueValue
      }
      min = NA
      max = NA
      variance = NA
      proportionCorrect = NA
      isModeCorrect = NA
      isTrueChosen = NA
      isTrueInRange = NA
      mergeds = rbind(mergeds, data.frame(x = x, y= y, type = types[y], imputed = imputed, min = min, max = max, variance = variance, proportionCorrect = proportionCorrect, isModeCorrect = isModeCorrect, isTrueInRange = isTrueInRange, isTrueChosen = isTrueChosen))
    }
    print(paste(Sys.time(), "Finished:", y, "of", length(datasets[[1]]), "for", run, rows, missingness))
  #}
  
  # Drop the first row from the dataset. It was a dummy just to create the dataframe
  mergeds = mergeds[-1, ]
  
  # Remove the row headings
  rownames(mergeds) = c()
  
  # Create the imputed dataset from the mergeds - this is just pulling the imputed values out of the data set and putting in the right place.
  imputed.df = xmis[-c(1:length(xmis))] # done to get the structure
  step = nrow(xmis)
  
  for (i in 1:length(xmis)) {
    start = ((i - 1 ) * step) + 1
    finish = ((i - 1 ) * step) + step
    col = mergeds[start:finish, 4]
    if (types[i] == "factor") {
      imputed.df = cbind(imputed.df, data.frame(col))
    } else {
      if (types[i] == "integer") {
        imputed.df = cbind(imputed.df, data.frame(as.integer(col)))
      } else {
        imputed.df = cbind(imputed.df, data.frame(as.numeric(col)))
      }
    }
  }
  colnames(imputed.df) = colnames(xmis)

  ####################################
  # Build summary of variances. There should be only one value for every variable in the dataset
  # mergedsSummary = data.frame(rows = 0, missingness = 0, type = "Type", field = "field", value = 0.0)
  # for (y in 1:length(datasets[[1]])) {
  #   
  #   field = colnames(datasets[[1]][y])
  #   
  #   if (types[y] == "factor") {
  #     
  #     ##############################
  #     # Number of correct across all imputed datasets and all values for one variable - proportion of imputations correct.
  #     ds = mergeds[mergeds$y == y, "proportionCorrect"]
  #     mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "proportionCorrect", field = field, value = sum(ds, na.rm = TRUE) / sum(!is.na(ds))))
  #     
  #     ##############################
  #     # What is the proportion of correct Modes?
  #     ds = mergeds[mergeds$y == y, "isModeCorrect"]
  #     mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "isModeCorrect", field = field, value = sum(ds, na.rm = TRUE) / sum(!is.na(ds))))
  #     
  #     ##############################
  #     # What is the proportion of True chosen?
  #     ds = mergeds[mergeds$y == y, "isTrueChosen"]
  #     mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "isTrueChosen", field = field, value = sum(ds, na.rm = TRUE) / sum(!is.na(ds))))
  #     
  #   } else {
  #     
  #     ##############################
  #     # Average Variance
  #     # Get the mean for the individual variance values in the column - only want to calculate the average variance of the imputed values, not all values. Not imputed values will obviously have a zero variance so will lower the mean.
  #     ds = mergeds[mergeds$y == y, "variance"]
  #     mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "variance", field = field, value = mean(as.numeric(ds[which(mis[,y], TRUE)]), na.rm = TRUE)))
  #     
  #     ##############################
  #     # MSE
  #     midasImputed = unlist(lapply(datasets, function(val) val[which(mis[,y], TRUE), y]))
  #     mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "mse", field = field, value = mean((midasImputed - xtrue[which(mis[,y], TRUE), y])^2, na.rm = TRUE)))
  #     
  #     ##############################
  #     # Proportion of IsTrueInRange
  #     ds = mergeds[mergeds$y == y, "isTrueInRange"]
  #     mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "isTrueInRange", field = field, value = sum(ds, na.rm = TRUE) / sum(!is.na(ds))))
  #   }
  # }
  # # Drop the first row
  # mergedsSummary = mergedsSummary[-1, ]
  
  # Add the variables to the return list
  resultList[["imputed"]] = imputed.df[, 1]
  #resultList[["ms"]] = datasets
  #resultList[["minMaxVar"]] = mergeds
  #resultList[["minMaxVarSummary"]] = mergedsSummary
  
  return (resultList)
}


getImputedValues = function(ximp, xmis) {
  for (j in 1:ncol(ximp)) {
    for (i in 1:nrow(ximp)) {
      if (!is.na(xmis[i, j]))
        ximp[i, j] = NA
    }
  }
  return (ximp)
}



myNRMSE = function (ximp, xmis, xtrue) {
  x.types = varClass(ximp)
  for (t.type in x.types) {
    if (t.type == "numeric") {
      t.ind = which(x.types == t.type)
      # Find the values that have been imputed 
      mis = is.na(xmis)
      
      # Normalise the values before using the nrmse function across all values, not just the imputed ones.
      ximp2 = as.data.frame(apply(ximp[, t.ind], 2, function(x) (x - min(x))/(max(x)-min(x))))
      xtrue2 = as.data.frame(apply(xtrue[, t.ind], 2, function(x) (x - min(x))/(max(x)-min(x))))
      
      # Calculate the nrmse on the two normalised vectors unsing only the imputed values
      #err = nrmse(ximp2[mis], xtrue2[mis], na.rm = T, norm = "sd")
      se = (ximp2[mis] - xtrue2[mis])^2  
      mse = mean(se, na.rm = T)
      rmse = sqrt(mse) / sd(xtrue2[mis], na.rm = T)
      
      # Change the percentage returned to a proportion
      #err = err / 100
    }
  }
  return (rmse)
}


#################################
# Call the analysis for each set of files

#datasets = c("df100p10","df100p20","df100p30","df100p40","df100p50","df100p60","df100p70","df100p80","df100p90")
#rows = c("100", "1k", "10k")
rows = c("1k", "10k")
#rows = c("10k")
#true.datasets = c("df100p0","df100p0","df100p0","df100p0","df100p0","df100p0","df100p0","df100p0","df100p0")
missingnesses = c(10,20,30,40,50,60,70,80,90)
algorithms = c("MIDAS")
#sizes = c("s", "L")
sizes = c("L")
m = 20

for (iter in 1 : 2) {
  for (row in rows) {
    for (size in sizes){
      for (missingness in missingnesses) {
        dataset = paste('df', row, 'p', missingness, sep='')
        true.dataset = paste('df', row, 'p0', sep='')
        if (size == 's') {
          colClasses = mfColInfoSmall
        }
        else {
          colClasses = mfColInfoLarge
        }
        
        # Load the original datafiles - xtrue and xmis
        missing.df = read.csv(paste(datafilepath, dataset, size, ".csv", sep = ""), header=TRUE, colClasses = colClasses, encoding = "ascii")
        p0.df = read.csv(paste(datafilepath, true.dataset, size, ".csv", sep = ""), header=TRUE, colClasses = colClasses, encoding = "ascii")
        
        initResultsDF(dataset = dataset, size = "", start = Sys.time(), end = Sys.time(), runNum = iter)
        
        for (method in algorithms) {
          
          print(paste("Iteration: #", iter, " ", dataset, " ", method, " Start: ", Sys.time(), sep = ""))
          
          if (method == "MIDAS") {
            print(paste("Start: #", iter, " ", dataset, " ", method, " Start: ", Sys.time(), sep = ""))
            start = Sys.time()
            
            #########################################################
            # MIDAS
            #########################################################
            numCols = length(p0.df)
            types = sapply(p0.df, class)
            for (y in 1:numCols) {
              midasAggregates = mDatasetsAggregate(midasOutputFilePath, missing.df, p0.df, rows = nrow(p0.df), missingness = missingness, m, iter, colClasses, y)
              if (y == 1) {
                imputed = data.frame(midasAggregates[["imputed"]])
              } else {
                imputed = cbind(imputed, data.frame(midasAggregates[["imputed"]]))
                if (types[y] == "factor") {
                  # Do nothing
                } else if (types[y] == "integer") {
                  imputed[, y] = as.integer(imputed[,y])
                } else {
                  imputed[, y] = as.numeric(imputed[,y])
                }
              }
            }
            colnames(imputed) = colnames(p0.df)
            
            # This commented out so that we get results for the main datasets first.
            # variances.df = midasAggregates[["minMaxVarSummary"]]
            # 
            # # Test all the imputed data sets before handing combined dataset to the outer loop
            # for (i in 1:length(midasAggregates[["ms"]])) {
            #   littleStart = Sys.time()
            #   mydiff = mixError(midasAggregates[["ms"]][i][[1]], missing.df, p0.df)
            #   littleEnd = Sys.time()
            #   appendResultsRow(dataset, size, nrow(missing.df), missingness, littleStart, littleEnd, 0, method, i, iter, mydiff["NRMSE"], mydiff["PFC"])
            # }
            print(paste("End: #", iter, " ", dataset, " ", method, " End: ", Sys.time(), sep = ""))
          }
          
          #########################################
          # Compare with the "true" dataset
          #########################################
          
          # This function is provided by MissForest and is called if an "xtrue" parameter is used.
          mydiff = mixError(imputed, missing.df, p0.df)
          mydiff["NRMSE"] = myNRMSE(imputed, missing.df, p0.df)
          end = Sys.time()
          appendResultsRow(dataset, size, nrow(missing.df), missingness, start, end, 0, method, 0, iter, mydiff["NRMSE"], mydiff["PFC"])
        }
        
        # Write the results file
        if (iter == 1 & (dataset == "df100p10s" | dataset == "df100p10L")) {
          writeResults(TRUE)
        }
        else {
          writeResults(FALSE)
        }
      }
    }
  }
}

#############################################################################
# Tidy Up
#############################################################################
#rm()

