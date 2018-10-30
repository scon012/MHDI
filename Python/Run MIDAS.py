########################################################################################################################
# Setup the Environment
########################################################################################################################

from midas import Midas
import importlib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import tensorflow as tf
from sklearn.metrics import mean_squared_error as mse
from sklearn.preprocessing import MinMaxScaler
from datetime import datetime as dt
from sklearn.preprocessing import LabelBinarizer, LabelEncoder
import scipy as sp
from scipy import stats
import time

########################################################################################################################
# Housekeeping tasks
########################################################################################################################

#################################
# Declare "constants"

dataFilePath = "G:\\Team Drives\\PDH Data\\MoH\\Datasets for Imputation\\SourceFilesV1.4\\"
resultsFile = "c:\\temp\\results.midas.csv"
variancesFile = "c:\\temp\\results.midas.variances.midas.csv"

m = 20  # This is the number of imputed datasets created, using 20 when running for real (50 takes too long to analyse)
epochs = 200  # This should be set to 200 when it is run for real. (200 takes too long to run)
doVerbose = False  # This should be set to False for the real run.

#################################
# Write Results

def writeResults(df, doHeaders=True):
    df.to_csv(resultsFile, header=doHeaders, index=False, encoding="ascii", mode='a')

#################################
# Initialise Results Dataframe

def initResultsDF(dataset="", size="s", rows=0, missingness=0, start="", end="", duration=0, algorithm="", runNum=0,
                  NRMSE=0, PFC=0, normalisedDuration=0):
    # resultsDf = pd.DataFrame(runNum = runNum, dataset = dataset, size = size, rows = rows, missingness = missingness, algorithm = algorithm, m = 0, start = start, end = end, duration = duration, normalisedDuration = normalisedDuration, NRMSE = NRMSE, PFC = PFC)
    return pd.DataFrame(data=[
        (runNum, dataset, size, rows, missingness, algorithm, 0, start, end, duration, normalisedDuration, NRMSE, PFC)]
                        , columns=["runNum", "dataset", "size", "rows", "missingness", "algorithm", "m", "start", "end",
                                   "duration", "normalisedDuration", "NRMSE", "PFC"])

#################################
# Append Results Row

def appendResultsRow(df, dataset, size, rows, missingness, start, end, duration, algorithm, m, runNum, NRMSE, PFC):
    duration = end - start
    normalisedDuration = duration / rows
    # resultsDf.append(dataset = dataset, size = size, rows = rows, missingness = missingness, start = start, end = end, duration = duration, normalisedDuration = normalisedDuration, algorithm = algorithm, m = m, runNum = runNum, NRMSE = NRMSE, PFC = PFC)
    newDf = pd.DataFrame(data=[
        (dataset, size, rows, missingness, start, end, duration.total_seconds(), normalisedDuration.total_seconds(), algorithm, m, runNum, NRMSE, PFC)]
                         , columns=["dataset", "size", "rows", "missingness", "start", "end", "duration",
                                    "normalisedDuration", "algorithm", "m", "runNum", "NRMSE", "PFC"])
    return df.append(newDf, ignore_index=True, sort=False)

# Declare Global variables
resultsDF = initResultsDF()

########################################################################################################################
# Categorical functions
########################################################################################################################

# def getmode(v):
#     uniqv = unique(v)
#     return (as.character(uniqv[which.max(tabulate(match(v, uniqv)))][[1]]))

# def getMin(v):
#     uniqv = unique(v)
#     return(as.character(uniqv[which.min(tabulate(match(v, uniqv)))][[1]]))

# def getCategoricalVariance(v):
#     uniqv = unique(v)
#     return (sum(abs((length(v)/length(uniqv)) - tabulate(match(v, uniqv)))))

########################################################################################################################
# Load the data
########################################################################################################################

# Now done below during the iteration

##############################
# Mini test - setup which is used below.
# print(mdDf.head())
# original_value = mdDf.at[0, 'eventMonth']
# mdDf.at[0, 'eventMonth'] = np.NaN
# print(mdDf.head())

########################################################################################################################
# Prepare the data
########################################################################################################################

# For the large dataset
#               , 'opChapNum', 'op02ChapNum', 'op03ChapNum'
categoricalLarge = ['ethnicGroup', 'domicileCode', 'DHB', 'eventType', 'endType', 'facility', 'diag01Chapter', 'diag02Chapter', 'diag03Chapter', 'AdmissionType']
binaryLarge = ['gender', 'IsCancer', 'IsSmoker', 'WasSmoker', 'HasDiabetesT1', 'HasDiabetesT2', 'IsNeuroTrauma', 'DiedDuringThisEvent']
roundLarge = ['eventDuration', 'EventYear', 'eventMonth', 'EventDayOfWeek', 'Drugs1m', 'Drugs6m', 'Drugs9m', 'Drugs12m', 'Drugs18m', 'Drugs24m', 'Drugs36m',
                'Drugs60m', 'DrugsTotal', 'Labs1m', 'Labs6m', 'Labs9m', 'Labs12m', 'Labs18m', 'Labs24m', 'Labs36m', 'Labs60m', 'LabsTotal', 'OPVisits1m', 'OPVisits6m',
                'OPVisits9m', 'OPVisits12m', 'OPVisits18m', 'OPVisits24m', 'OPVisits36m', 'OPVisits60m', 'OPVisitsTotal', 'IPVisits1m', 'IPVisits6m', 'IPVisits9m',
                'IPVisits12m', 'IPVisits18m', 'IPVisits24m', 'IPVisits36m', 'IPVisits60m', 'IPVisitsTotal']

# For the small dataset
# categoricalSmall = ['gender', 'ethnicGroup', 'endType', 'diag01Chapter', 'AdmissionType', 'IsCancer', 'IsSmoker', 'WasSmoker', 'HasDiabetesT1', 'HasDiabetesT2']
categoricalSmall = ['ethnicGroup', 'endType', 'diag01Chapter', 'AdmissionType']
binarySmall = ['gender', 'IsCancer', 'IsSmoker', 'WasSmoker', 'HasDiabetesT1', 'HasDiabetesT2']
roundSmall = ['eventDuration', 'EventYear', 'eventMonth', 'Drugs6m', 'Labs6m', 'OPVisits6m', 'IPVisits6m']

##############################
# Flip binary categories - makes text based binary categories 0 or 1

def flipBinaries(df, datasetSize):
    if datasetSize == 's':
        binaries = binarySmall
    else:
        binaries = binaryLarge

    for col in binaries:
        if col == "gender":
            df[col] = df[col].map({'F': 0, 'M': 1})
        elif col == "DiedDuringThisEvent":
            # Do nothing, the value is already 1/0
            df[col] = df[col]
        else:
            df[col] = df[col].map({'N': 0, 'Y': 1})

    return df

def unFlipBinaries(df, datasetSize):
    if datasetSize == 's':
        binaries = binarySmall
    else:
        binaries = binaryLarge

    for col in binaries:
        # Because the imputed values are not all 0 or 1, these have to be rounded to the nearest number
        df[col] = df[col].round()

        if col == "gender":
            df[col] = df[col].map({0:'F', 1:'M'})
        else:
            df[col] = df[col].map({0:'N', 1:'Y'})

    return df

##############################
# One-hot the categorical data and then add it back in again

def oneHot(mdDf, datasetSize):
    if datasetSize == 's':
        categorical = categoricalSmall
    else:
        categorical = categoricalLarge

    # Strip whitespace from left and right sides of the text values in each field
    mdDf.columns.str.strip()

    # Create a dataframe of just the categorical columns
    mdDfCategorical = mdDf[categorical]

    # Remove the categorical columns from the original dataset
    mdDf.drop(categorical, axis=1, inplace=True)

    # Get a list of dataframes. One for the numerics and then one for each of the categorical variables 
    constructor_list = [mdDf]
    columns_list = []

    for column in mdDfCategorical.columns:
        # Find which values in the categorical columns are null
        na_temp = mdDfCategorical[column].isnull()

        # Add the column name as a prefix to the value
        mdDfCategorical[column] = mdDfCategorical[column].name + mdDfCategorical[column].astype(str)

        # Put back the nulls
        mdDfCategorical[column][na_temp] = np.nan

        # Convert categorical variables into dummy/indicator variables
        temp = pd.get_dummies(mdDfCategorical[column])

        # Find out which values are NaN
        temp[na_temp] = np.nan

        # Add this list to the constructor_list
        constructor_list.append(temp)

        # Create a list of lists that has the new columns that are created
        columns_list.append(list(temp.columns.values))

    # Add the dataframes back to the original dataframe in the new pivoted (One-Hot) format
    mdDf = pd.concat(constructor_list, axis=1)

    return columns_list, mdDf

def unOneHot(df, datasetSize, cols_list):
    if datasetSize == 's':
        categorical = categoricalSmall
    else:
        categorical = categoricalLarge

    for i in range(0, len(categorical)):
        # For each group of columns get the list of column names
        onehot_cols = [col for col in df if col.startswith(categorical[i])]

        # For each category column group use idxmax to find the value
        vals = df[onehot_cols].idxmax(1)

        # Find out the index of the first onehotted column with this name
        #### UGLY HACK ####
        for j in range(0, len(np.array(df.columns))):
            if df.columns[j].startswith(categorical[i]):
                col_index = j
                break

        # Remove all the onehotted columns from the dataframe
        df.drop(onehot_cols, axis=1, inplace=True)

        # Add the column at the correct location
        # Remove the name of the column from the front of the value in the column and add it to the dataframe
        df.insert(col_index, categorical[i], [x[len(categorical[i]):len(x)] for x in vals])

    return pd.DataFrame(df)

def doMinMaxScaler(df, size):
    #############################
    # Scale the variables so that all are between 0 and 1

    scaler = MinMaxScaler()

    # Find out which values have nulls
    na_loc = df.isnull()

    # For each column, fill the Nulls with the min value
    for col in df:
        df[col].fillna(df[col].min(), inplace=True)

    #################### - This does not work. It bases each column at zero. Think year which has only values from 2013 - 2017. Zero distorts this.
    #  Fill the null values with zero (0)
    # df.fillna(0, axis = 1, inplace = True)
    ####################

    # Transform the values in the columns to be a value between 0 and 1
    df = pd.DataFrame(scaler.fit_transform(df), columns=df.columns)

    # Put the null values back
    df[na_loc] = np.nan

    return df, scaler

def prepareDataForImputation(df, size, doMinMax=True, doFlipBinaries=True, doOneHot=True):
    columns_list = np.nan
    if doFlipBinaries:
        new_df = flipBinaries(df, size)

    if doOneHot:
        oneHotOut = oneHot(new_df, size)
        columns_list = oneHotOut[0]
        new_df = oneHotOut[1]

    if doMinMax:
        new_df, scaler = doMinMaxScaler(new_df, size)

    return new_df, columns_list, scaler

def doImputation(df, cols_list, layers, epochs, softmax_adj, savePath, m):
    imputer = Midas(layer_structure=layers, train_batch=64, vae_layer=False, seed=42, softmax_adj=softmax_adj,savepath=savePath)
    imputer.build_model(df, softmax_columns=cols_list)
    imputer.train_model(training_epochs=epochs, verbosity_ival=1, verbose=doVerbose)

    # Test for convergence
    # imputer.overimpute(training_epochs = 10, report_ival = 1, report_samples = 5, plot_all = False, verbose = False)

    # Generate the 'm' number of datasets
    imputer.batch_generate_samples(m=m)

    return imputer

def roundToIntegers(df, datasetSize):
    if datasetSize == 's':
        integerFields = roundSmall
    else:
        integerFields = roundLarge

    for col in integerFields:
        df[col] = df[col].round()

    return df

def removeNegatives(df):
    # Relies on the fact that this dataframe has no negative numbers ion any columns
    # Will have to make this more complicated if negatives have to be catered for in any columns
    df[df < 0] = 0
    return df

def reOrderColumns(df, xtrue):
    first = True
    for name in xtrue.columns:
        if first:
            new_df = pd.DataFrame(df[name])
            first = False
        else:
            new_df = new_df.join(df[name])

    return new_df

def revertDataFromImputation(imputedDatasetAsList, cols_list, scaler, size, xtrue, doMinMax=True, doFlipBinaries=True, doOneHot=True):

    imputedDatasets = []
    for df in imputedDatasetAsList:

        # Remove Negatives
        df_out = removeNegatives(df)

        # Undo the MinMax scaling
        df_out = pd.DataFrame(scaler.inverse_transform(df_out), columns=df_out.columns)

        # Reverse the OneHot encoding
        df_out = unOneHot(df_out, size, columns_list)

        # Unflip the binaries
        df_out = unFlipBinaries(df_out, size)

        # Round the integer columns. For example 'Year' or 'Month'
        df_out = roundToIntegers(df_out, size)

        #Re-order the columns
        df_out = reOrderColumns(df_out, xtrue)

        # This grows a list to size 'm' of datasets
        imputedDatasets.append(df_out)

    return imputedDatasets

####################################################################
  # Generate the imputed dataset from the m number of imputed datasets

def getValues(dses, dsCount, x, y):
    v = np.array([])
    for i in range(0, dsCount):
        v = np.append(v, dses[i].ix[x, y])
    return (v)

def generateBestDataset(dfs, xtrue, xmis, rows, missingness, datasetSize):
    numberOfDatasets = len(dfs)

    # Initialise the results dataframe
    data = [(0, 0, "ToDrop", "DropMe", "", "", "", 0, 0, np.nan, np.nan, False)]
    columns = ['x', 'y', 'type', 'imputed', 'min', 'max', 'variance', 'proportionCorrect', 'isModeCorrect', 'isTrueInRange', 'isTrueChosen', 'stringsAsFactors']
    mergeds = pd.DataFrame(data, columns=columns)
    types = xtrue.dtypes
    misMatrix = xmis.isnull()

    if datasetSize == 's':
        binaryFields = binarySmall
        categoricalFields = categoricalSmall
    else:
        binaryFields = binaryLarge
        categoricalFields = categoricalLarge

    for y in range(0, len(xtrue.columns)):
        for x in range(0, rows):
            trueValue = xtrue.ix[x, y]
            # Only do the calculations if the value was imputed.
            if misMatrix.ix[x, y]:
                values = getValues(dfs, numberOfDatasets, x, y)

                # Using the vector of values, calculate the various measures - the categorical data uses counts instead of values
                #if types[y].name == "int64" or types[y].name == "float64":
                if xtrue.columns[y] not in binaryFields and xtrue.columns[y] not in categoricalFields:
                    if types[y].name == "int64":
                        values = values.astype(float).astype(int)
                        imputed_val = np.mean(values).astype(int)
                    else:
                        values = values.astype(float)
                        imputed_val = np.mean(values)
                    min = np.min(values)
                    max = np.max(values)
                    variance = np.var(values)
                    isTrueInRange = False
                    if min <= imputed_val and imputed_val <= max: isTrueInRange = True

                    # Tidy up Categorical variables
                    proportionCorrect = np.nan
                    modeCorrect = np.nan
                    isTrueChosen = np.nan
                else:
                    # Do stuff for categorical
                    imputed_val = sp.stats.stats.mode(values, axis=None)[0][0]
                    min = np.nan #getMin(values)
                    max = imputed_val
                    variance = np.nan #getCategoricalVariance(values)

                    ##############################
                    # Number of correct across all imputed datasets - proportion of imputations correct. This will be used to calculated the rollup of this value.
                    numberCorrect = list(values).count(trueValue)
                    proportionCorrect = numberCorrect / numberOfDatasets

                    isTrueInRange = np.nan
                    if numberCorrect > 0: isTrueChosen = True

                    ##############################
                    # Is the mode correct? - To be used for calculating proportion of modes correct
                    modeValue = imputed_val
                    isModeCorrect = False
                    if trueValue == modeValue: isModeCorrect = True

                    # Tidy up numeric variables
                    min = np.nan
                    max = np.nan
                    variance = np.nan
            else:
                imputed_val = trueValue
                min = np.nan
                max = np.nan
                variance = np.nan
                proportionCorrect = np.nan
                isModeCorrect = np.nan
                isTrueChosen = np.nan
                isTrueInRange = np.nan

            data = [(x, y, types[y], imputed_val, min, max, variance, proportionCorrect, isModeCorrect, isTrueInRange, isTrueChosen, False)]
            new_row = pd.DataFrame(data, columns=columns)
            mergeds = mergeds.append(new_row)

    # Drop the first row from the dataset. It was a dummy just to create the dataframe
    mergeds = mergeds[mergeds.type != 'ToDrop']

    # Create the imputed dataset from the mergeds
    step = rows
    for y in range(0, len(xtrue.columns)):
        data = mergeds.iloc[y * step: (y+1) * step, 3]
        column = xtrue.columns[y]
        data = data.rename(column)
        if y == 0:
            new_df = pd.DataFrame(data)
        else:
            new_df[column] = pd.DataFrame(data)

    new_df.reset_index(inplace=True)
    return new_df

def nrmse(imputed_df, xmis, xtrue, datasetSize):

    if datasetSize == 's':
        binaryFields = binarySmall
        categoricalFields = categoricalSmall
    else:
        binaryFields = binaryLarge
        categoricalFields = categoricalLarge

    misMatrix = xmis.isnull()
    types = xtrue.dtypes
    nrmse_vals = []
    nrmse_val = 0
    for col in xtrue.columns:
        if col not in binaryFields and col not in categoricalFields:
            nrmse_vals.append(np.sqrt(np.mean(imputed_df[col][misMatrix[col]] - xtrue[col][misMatrix[col]]) ** 2) / np.var(xtrue[col][misMatrix[col]]))
    nrmse_val = np.mean(nrmse_vals)
    return nrmse_val

def pfc(imputed_df, xmis, xtrue, datasetSize):

    if datasetSize == 's':
        binaryFields = binarySmall
        categoricalFields = categoricalSmall
    else:
        binaryFields = binaryLarge
        categoricalFields = categoricalLarge

    misMatrix = xmis.isnull()
    types = xtrue.dtypes
    pfc_vals = []
    pfc_val = 0
    for col in xtrue.columns:
        if col in binaryFields or col in categoricalFields:
            num_diffs = xtrue[col].count().sum() - (imputed_df[col] == xtrue[col]).astype(int).sum().sum()
            potential_missing = misMatrix[col].loc[misMatrix[col] == True].count()
            pfc_vals.append(num_diffs / potential_missing)

    pfc_val = np.mean(pfc_vals)
    return pfc_val

########################################################################################################################
# Perform the imputation
########################################################################################################################

##############################################
# Set up the imputation combinations

datasets = ["df100p","df1kp","df10kp"]
rows = [100, 1000, 10000]
trueDatasets = ["df100p0","df1kp0","df10kp0"]
missingnesses = [10, 20, 30, 40, 50, 60, 70, 80, 90]
algorithms = ["MIDAS"]
sizes = ["s", "L"]

# Savepath for the models
savePath = "G:\\Team Drives\\Project - PDH Dissertation\\Dissertations\\SC Workings\\Python Components\\tmp\\"
doHeader = True
resultsDF = initResultsDF()
for run in range(1, 5):
    for dataset in datasets:
        instanceIndex = datasets.index(dataset)
        for size in sizes:
            dfp0 = pd.read_csv(dataFilePath + trueDatasets[instanceIndex] + str(size) + ".csv", encoding="ansi",header=0)

            # Set the softmax adjustment (which should be 10% of the categorical columns) and layers correctly
            if size == 's':
                softmax_adj = 1.0 / len(categoricalSmall)
                if dataset == "df100p":
                    layers = [64, 64]
                elif dataset == "df1kp":
                    layers = [64, 64, 64]
                elif dataset == "df10kp":
                    layers = [64, 64, 64, 64]
                elif dataset == "df100kp":
                    layers = [64, 64, 64, 64, 64]
            else:
                softmax_adj = 1.0 / len(categoricalLarge)
                if dataset == "df100p":
                    layers = [128, 64]
                elif dataset == "df1kp":
                    layers = [256, 128, 64]
                elif dataset == "df10kp":
                    layers = [256, 256, 128, 64]
                elif dataset == "df100kp":
                    layers = [256, 256, 256, 128, 64]

            for missingness in missingnesses:
                for algorithm in algorithms:
                    # Create the dataset name
                    datasetName = dataset + str(missingness) + str(size)

                    # Load the dataset
                    mdDfOriginal = pd.read_csv(dataFilePath + datasetName + ".csv", encoding="ansi", header=0)
                    mdDf = mdDfOriginal.copy()

                    mdDf, columns_list, scaler = prepareDataForImputation(mdDf, size, True, True, True)

                    # Perform the imputation - including building the model
                    startTime = dt.now()
                    imputer = doImputation(mdDf, columns_list, layers, epochs, softmax_adj, savePath + datasetName, m)
                    endTime = dt.now()
                    print("Runtime for " + datasetName + ": ", endTime - startTime)

                    # Get the data from the "m" datasets and merge into one "best" one
                    startTime2 = dt.now()
                    mdDfs = revertDataFromImputation(imputer.output_list, columns_list, scaler, size, dfp0, True, True, True)
                    final_df = generateBestDataset(mdDfs, dfp0, mdDfOriginal, rows[instanceIndex], missingness, size)

                    # Calculate how good the imputation has been
                    NRMSE = nrmse(final_df, mdDfOriginal, dfp0, size)
                    PFC = pfc(final_df, mdDfOriginal, dfp0, size)
                    endTime2 = dt.now()
                    print("Runtime for analysis of " + datasetName + ": ", endTime2 - startTime2)

                    # Write to the log dataframe
                    resultsDF = appendResultsRow(resultsDF, datasetName, size, rows[instanceIndex], missingness,
                                                 startTime, endTime, 0, algorithm, m, run, NRMSE, PFC)

            # Write the log file to disk
            writeResults(resultsDF, doHeader)
            doHeader = False
            resultsDF = initResultsDF()