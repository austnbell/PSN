# -*- coding: utf-8 -*-
"""
Created on Mon Apr  6 11:27:10 2020

Generate our Patient DataFrame for Shiny

@author: Austin Bell
"""
import os
import re
import pandas as pd
import numpy as np

from dfGenUtils import convertCategorical, genPatientDF, dropMissings

input_dir = "../data/heorData/"
graph_dir = "../data/graphs/"
patient_dir = "../data/patientData/"
output_dir = "../shiny/data/"

cluster_df = pd.read_csv(graph_dir + "cosine_cluster5.csv")
cluster_df.head()

mortality = pd.read_csv(patient_dir + "mortality.csv")
mortality.head()

# generate our patient dataframe and drop missings. But, do not impute
files = os.listdir(patient_dir)
files = [f for f in files if re.search("chart events|cross sect", f)]

patient_df = genPatientDF(patient_dir, files, cluster_df, mortality, time2event = True)
#patient_df = dropMissings(patient_df, .75)
patient_df.to_csv(output_dir + "Patient Level Dataset.csv", index = False)
