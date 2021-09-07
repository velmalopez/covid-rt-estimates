import os
import sys
import rpy2
import rpy2.robjects.packages as rpackages
from rpy2.robjects.vectors import StrVector
from rpy2.robjects.packages import importr
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
from rpy2.robjects.conversion import localconverter
import pandas as pd
import pyreadr


# Install packages
#packnames = ('data.table', 'lubridate', 'future', 'optparse', 'covidregionaldata', 'EpiNow2')
#utils.install_packages(StrVector(packnames))


# Load packages

dtable = importr('data.table')
#lubridate = importr('lubridate')
#future = importr('future')
#optparse = importr('optparse')
coviddata = importr('covidregionaldata')
epinow2 = importr('EpiNow2')


# Exploring datasets
#print(DATASETS[12])
#print(COLLATED_DERIVATIVES[0]["region_scale"])



def rru_filter_datasets(dataset, region):
    # Returns the filtered dataset
    for data in dataset:
        if data["name"][0] == region:
              dataset = data
    print(dataset)

    return dataset



#def clean_regional_data(cases, truncation, data_window):
#
#
#
#
#   return cases

def update_regional(datasets, region):
    data = coviddata.get_regional_data(country = 'canada', localise = False)
    #print(data)
    cases = dtable.setDT(data)
    # data should be coverted to panda dataframe using local convertors.
    #df = pd.DataFrame(data)
    #print(df.T)
    # rename columns
    print(cases)
    cases = dtable.setnames(cases, datasets[0]["cases_subregion_source"][0], "region", skip_absent=True)

    #print(cases)
    # converting rpy object to pandas dataframe
    with localconverter(robjects.default_converter + pandas2ri.converter):
        df = robjects.conversion.rpy2py(cases)

    #print(type(df))
    print(df.columns)
    df=df.rename(columns = {'region_level_1':'region'})
    print(df.columns)
    print(type(datasets[0]["cases_subregion_source"][0]))
    # Extracting information from datasets is a bit traicky
    #print(datasets[0]["target_folder"][0])

    # coverting pandas dataframe back to rpy object
    with localconverter(robjects.default_converter + pandas2ri.converter):
        rdf = robjects.conversion.py2rpy(df)
    #print(rdf)
    print(type(rdf))
    #cases = clean_regional_data(cases, 3, 12)

    # Extracting parameters for EpiNow
    #gtime = datasets[0]["generation_time"][0]
    iperiod = datasets[0]["incubation_period"][0]
    rdelay = datasets[0]["reporting_delay"][0]
    target = datasets[0]["target_folder"][0]
    epinow_opts = datasets[0]["regional_epinow_opts"][0]

    #gtime = pyreadr.read_r('data', '../data/generation_time.rds')
    readRDS = robjects.r['readRDS']
    gendf = readRDS('../data/generation_time.rds')
    gtime = pandas2ri.rpy2py_dataframe(gendf)

    print(gtime)

    # Calling EpiNow
    #out = epinow2.regional_epinow(reported_cases = rdf,
    #                                generation_time = gtime,
    #                                delays = epinow2.delay_opts(iperiod, rdelay),
    #                                target_folder = target)




    return datasets


def rru_process_locations(datasets, region):

    outcome = []
    outcome = update_regional(datasets, region)

    return outcome


def run_regional_updates(datasets, derivatives, region):
    print("run region updates")
    if(len(region) == 0):
        sys.exit('region list is empty')

    dataset = rru_filter_datasets(datasets,region)
    outcome = rru_process_locations(datasets, region)

def main():
    print("main")

    # loading datasets from list/dataset-list.R
    dataobj = robjects.r
    dataobj['source']('/home/covid/R/lists/dataset-list.R')
    DATASETS = robjects.globalenv['DATASETS']


    # loading collated derivatives from lists/collated-derivative-list.R
    collobj = robjects.r
    collobj['source']('/home/covid/R/lists/collated-derivative-list.R')
    COLLATED_DERIVATIVES = robjects.globalenv['COLLATED_DERIVATIVES']


    # input region (TODO: args)
    region = 'Belgium'
    run_regional_updates(DATASETS, "derivative", region)




if __name__ == "__main__":
        main()
