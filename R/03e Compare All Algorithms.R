########################################################################################################################
# Set up the environment
########################################################################################################################

library(missForest)
library(mice)
library(lattice)
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

mfColInfoSmall = c("factor", "factor", "factor", "factor", "integer"
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
resultsFile = "c:\\temp\\results.large.csv"
variancesFile = "c:\\temp\\results.variances.large.csv"

#################################
# Write Results

writeResults = function (doHeaders = TRUE){
  write.table(results.mf, resultsFile, sep = ",", append = TRUE, row.names = FALSE, col.names = doHeaders)
  write.table(variances.df, variancesFile, sep = ",", append = TRUE, row.names = FALSE, col.names = doHeaders)
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
  uniqv = unique(v)
  return (as.character(uniqv[which.max(tabulate(match(v, uniqv)))][[1]]))
}

getMin = function(v) {
  uniqv = unique(v)
  return(as.character(uniqv[which.min(tabulate(match(v, uniqv)))][[1]]))
}

getCategoricalVariance = function (v) {
  uniqv = unique(v)
  #tabulate(match(v, uniqv))
  return (sum(abs((length(v)/length(uniqv)) - tabulate(match(v, uniqv)))))
}

########################################################################################################################
# Imputation methods
########################################################################################################################

#################################
# Mice Aggregation

miceAggregate = function(miceOutput, xtrue, rows, missingness) {
  
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
  # Generate the imputed dataset from the x number of imputed datasets
  
  # Get the number of datasets
  numberOfDatasets = length(miceOutput[["imp"]]$gender)
  datasets = list()
  
  # Get the datasets
  for (i in 1:numberOfDatasets) {
    datasets[[i]] = complete(miceOutput, i)
  }
  
  # Initialise the results dataframe
  mergeds = data.frame(x = 0, y = 0, type = "ToDrop", imputed = "DropMe", min = "", max = "", variance = "", proportionCorrect = 0, isModeCorrect = 0, isTrueInRange = NA, isTrueChosen = NA, stringsAsFactors=FALSE)
  
  # Get a matrix of T/F for the imputed values
  mis = is.na(miceOutput$data)
  
  types = sapply(datasets[[1]], class)
  for (y in 1:length(datasets[[1]])) {
    for (x in 1:nrow(datasets[[1]])) {
      
      trueValue = xtrue[x, y]
      
      # Only do the calculations if the value was imputed.
      if (mis[x, y]) {
      
        values = getValues(datasets, numberOfDatasets, x, y, types[y], trueValue)
        
        # Using the vector of values, calculate the various measures - the categorical data uses counts instead of values
        if (types[y] == "factor") {
          
          imputed = getmode(values)
          min = getMin(values)
          max = imputed
          variance = getCategoricalVariance (values)
          isTrueInRange = NA
          isTrueChosen = is.element(trueValue, values)
          
          ##############################
          # Number of correct across all imputed datasets - proportion of imputations correct. This will be used to calculated the rollup of this value.
          numberCorrect = length(which(values == trueValue))
          proportionCorrect = numberCorrect / numberOfDatasets
          
          ##############################
          # Is the mode correct? - To be used for calculating proportion of modes correct
          modeValue = imputed
          isModeCorrect = FALSE
          if (trueValue == modeValue) {isModeCorrect = TRUE}
          
        } else {
          
          if (types[y] == "integer") {
            imputed = round(mean(as.numeric(values)))
          } else {
            imputed = mean(as.numeric(values))
          }
          min = min(as.numeric(values))
          max = max (as.numeric(values))
          variance = var(as.numeric(values))
          proportionCorrect = NA
          modeCorrect = NA
          isTrueInRange = FALSE
          if (min <= imputed & imputed <= max) {isTrueInRange = TRUE}
          isTrueChosen = NA
        } 
      } else {
        imputed = trueValue
        min = NA
        max = NA
        variance = NA
        proportionCorrect = NA
        isModeCorrect = NA
        isTrueChosen = NA
        isTrueInRange = NA
      }
      mergeds = rbind(mergeds, data.frame(x = x, y= y, type = types[y], imputed = imputed, min = min, max = max, variance = variance, proportionCorrect = proportionCorrect, isModeCorrect = isModeCorrect, isTrueInRange = isTrueInRange, isTrueChosen = isTrueChosen))
    }
  }
  
  # Drop the first row from the dataset. It was a dummy just to create the dataframe
  mergeds = mergeds[-1, ]
  
  # Remove the row headings
  rownames(mergeds) = c()
  
  # Create the imputed dataset from the mergeds - this is just pulling the imputed values out of the data set and putting in the right place.
  imputed = miceOutput$data[-c(1:length(miceOutput$data))] # done to get the structure
  step = nrow(miceOutput$data)
  
  for (i in 1:length(miceOutput$data)) {
    start = ((i - 1 ) * step) + 1
    finish = ((i - 1 ) * step) + step
    col = mergeds[start:finish, 4]
    if (types[i] == "factor") {
      imputed = cbind(imputed, data.frame(col))
    } else {
      if (types[i] == "integer") {
        imputed = cbind(imputed, data.frame(as.integer(col)))
      } else {
        imputed = cbind(imputed, data.frame(as.numeric(col)))
      }
    }
  }
  colnames(imputed) = colnames(miceOutput$data)
  
  # Fix HasDiabetesT1 - MICE doesn't like the fact that there is only one value so doesn't fix the NAs
  imputed$HasDiabetesT1[is.na(imputed$HasDiabetesT1)] = getmode(imputed$HasDiabetesT1)
  for (i in 1:numberOfDatasets) {
    datasets[i][[1]]$HasDiabetesT1[is.na(datasets[i][[1]]$HasDiabetesT1)] = getmode(datasets[i][[1]]$HasDiabetesT1)
  }
  
  ####################################
  # Build summary of variances. There should be only one value for every variable in the dataset
  mergedsSummary = data.frame(rows = 0, missingness = 0, type = "Type", field = "field", value = 0.0)
  for (y in 1:length(datasets[[1]])) {
    
    field = colnames(datasets[[1]][y])
    
    if (types[y] == "factor") {
      
      ##############################
      # Number of correct across all imputed datasets and all values for one variable - proportion of imputations correct.
      ds = mergeds[mergeds$y == y, "proportionCorrect"]
      mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "proportionCorrect", field = field, value = sum(ds, na.rm = TRUE) / sum(!is.na(ds))))
      
      ##############################
      # What is the proportion of correct Modes?
      ds = mergeds[mergeds$y == y, "isModeCorrect"]
      mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "isModeCorrect", field = field, value = sum(ds, na.rm = TRUE) / sum(!is.na(ds))))
      
      ##############################
      # What is the proportion of True chosen?
      ds = mergeds[mergeds$y == y, "isTrueChosen"]
      mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "isTrueChosen", field = field, value = sum(ds, na.rm = TRUE) / sum(!is.na(ds))))
      
    } else {
      
      ##############################
      # Average Variance
      # Get the mean for the individual variance values in the column - only want to calculate the average variance of the imputed values, not all values. Not imputed values will obviously have a zero variance so will lower the mean.
      ds = mergeds[mergeds$y == y, "variance"]
      mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "variance", field = field, value = mean(as.numeric(ds[which(mis[,y], TRUE)]), na.rm = TRUE)))
      
      ##############################
      # MSE
      miceImputed = unlist(lapply(datasets, function(val) val[which(mis[,y], TRUE), y])) #as.numeric((mergeds[mergeds$y == y, "imputed"])[which(mis[,y], TRUE)])
      mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "mse", field = field, value = mean((miceImputed - xtrue[which(mis[,y], TRUE), y])^2, na.rm = TRUE)))
      
      ##############################
      # Proportion of IsTrueInRange
      ds = mergeds[mergeds$y == y, "isTrueInRange"]
      mergedsSummary = rbind(mergedsSummary, data.frame(rows = rows, missingness = missingness, type = "isTrueInRange", field = field, value = sum(ds, na.rm = TRUE) / sum(!is.na(ds))))
    }
  }
  # Drop the first row
  mergedsSummary = mergedsSummary[-1, ]
  
  # Add the variables to the return list
  resultList[["imputed"]] = imputed
  resultList[["ms"]] = datasets
  resultList[["minMaxVar"]] = mergeds
  resultList[["minMaxVarSummary"]] = mergedsSummary
  
  return (resultList)
}

#################################
# Generic Imputation


########################################################################################################################
# call the imputation methods
########################################################################################################################

datasets = c("df100p10L","df100p20L","df100p30L","df100p40L","df100p50L","df100p60L","df100p70L","df100p80L","df100p90L","df1kp10L","df1kp20L","df1kp30L","df1kp40L","df1kp50L","df1kp60L","df1kp70L","df1kp80L","df1kp90L","df10kp10L","df10kp20L","df10kp30L","df10kp40L","df10kp50L","df10kp60L","df10kp70L","df10kp80L","df10kp90L")
true.datasets = c("df100p0L","df100p0L","df100p0L","df100p0L","df100p0L","df100p0L","df100p0L","df100p0L","df100p0L","df1kp0L","df1kp0L","df1kp0L","df1kp0L","df1kp0L","df1kp0L","df1kp0L","df1kp0L","df1kp0L","df10kp0L","df10kp0L","df10kp0L","df10kp0L","df10kp0L","df10kp0L","df10kp0L","df10kp0L","df10kp0L")
missingnesses = c(10,20,30,40,50,60,70,80,90,10,20,30,40,50,60,70,80,90,10,20,30,40,50,60,70,80,90)
algorithms = c("MeanMode", "MissForest", "Mice")
size = "L"

#################################
# Call the algorithms - The function to do the imputation was removed because it did not work with parlmice (Parallel MICE)

for (iter in 1 : 5) {
  
  for (params in 1:length(datasets)) {
    dataset = datasets[params]
    true.dataset = true.datasets[params]
    missingness = missingnesses[params]
    
    # Load the datafiles
    if (size == "s") {
      initialMissing.df = read.csv(paste(datafilepath, dataset, ".csv", sep = ""), header=TRUE, colClasses = mfColInfoSmall, encoding = "ascii")
      initialp0.df = read.csv(paste(datafilepath, true.dataset, ".csv", sep = ""), header=TRUE, colClasses = mfColInfoSmall, encoding = "ascii")
    } else {
      initialMissing.df = read.csv(paste(datafilepath, dataset, ".csv", sep = ""), header=TRUE, colClasses = mfColInfoLarge, encoding = "ascii")
      initialp0.df = read.csv(paste(datafilepath, true.dataset, ".csv", sep = ""), header=TRUE, colClasses = mfColInfoLarge, encoding = "ascii")
    }
    
    if (nrow(initialMissing.df) > 1000) {
      # Remove the Diagnosis Chapter numbers because Random Forest cannot handle more than 53 factor levels
      initialMissing.df = initialMissing.df[, -which(names(initialMissing.df) %in% c('diag01Chapter'))]
      initialp0.df = initialp0.df[, -which(names(initialp0.df) %in% c('diag01Chapter'))]
    }
    
    # Initialise the dataframes
    missing.df = initialMissing.df
    p0.df = initialp0.df
    
    initResultsDF(dataset = dataset, size = "", start = Sys.time(), end = Sys.time(), runNum = iter)
    
    for (method in algorithms) {
      
      print(paste("Iteration: #", iter, " ", dataset, " ", method, " Start: ", Sys.time(), sep = ""))
      
      if (method == "MissForest") {
        
        #########################################################
        # MissForest
        #########################################################
        
        start = Sys.time()
        output.mf = missForest(missing.df, parallelize = "forest")
        
        # Remove the fields with real missingness eg. the death columns. They were left in to help with imputation, but they should not impact the comparison results
        imputed = output.mf$ximp
        end = Sys.time()
        
      } else if (method == "Mice") {
        
        #########################################################
        # Mice
        #########################################################
        
        start = Sys.time()
        output.mice = parlmice(missing.df, printFlag = FALSE, m = 20, maxit = 20, nnet.MaxNWts = 5000) # Upped the Neural Net weights because with 1k rows it errored out.
        end = Sys.time()
        
        miceAggregates = miceAggregate(output.mice, p0.df, rows = nrow(initialMissing.df), missingness = missingness)
        imputed = miceAggregates[["imputed"]]
        #variances.df = cbind(data.frame(runNum = iter, dataset = dataset, size = size, rows = nrow(initialMissing.df), missingness = missingness, m = 20), miceAggregates[["minMaxVarSummary"]])
        variances.df = miceAggregates[["minMaxVarSummary"]]
        
        # Test all the imputed data sets before handing combined dataset to the outer loop
        for (i in 1:length(miceAggregates[["ms"]])) {
          mydiff = mixError(miceAggregates[["ms"]][i][[1]], missing.df, p0.df)
          appendResultsRow(dataset, size, nrow(missing.df), missingness, start, end, 0, method, i, iter, mydiff["NRMSE"], mydiff["PFC"])
        }
        
      } else if (method == "MeanMode") {
        
        #########################################################
        # MeanMode
        #########################################################
        
        types = sapply(missing.df, class)
        start = Sys.time()
        imputed = missing.df
        for (i in 1:ncol(imputed)) {
          if (types[i] == "factor") {
            imputed[is.na(imputed[, i]), i] = getmode(imputed[, i])
          } else {
            imputed[, i] = na.mean(imputed[, i], option = "mean")
            if (size == "s" & types[i] == "integer") { #EventAgeYearsFractional doesn't get truncated. All other numbers are integers.
              imputed[, i] = round(imputed[, i])
            }
          }
        }
        end = Sys.time()
      }
      
      #########################################
      # Compare with the "true" dataset
      #########################################
      
      # This function is provided by MissForest and is called if an "xtrue" parameter is used. We use it separately because we want to remove some columns before doing the comparison
      mydiff = mixError(imputed, missing.df, p0.df)
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

#############################################################################
# Tidy Up
#############################################################################
#rm()