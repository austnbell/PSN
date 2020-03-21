# -*- coding: utf-8 -*-
"""
Created on Wed Feb 26 15:08:11 2020

Functions to generate similarity matrices using cosine similarity

@author: Austin Bell
"""

import pandas as pd
import numpy as np
import itertools 

from sklearn import preprocessing
from sklearn.metrics.pairwise import cosine_similarity

# requires that subject_id be apart of the dataframe
def normalizeDF(s_df):
    s_df = s_df.reset_index()
    df_scaled = preprocessing.scale(s_df)
    df_scaled = pd.DataFrame(df_scaled, columns = s_df.columns)
    df_scaled['subject_id'] = s_df.subject_id
    return df_scaled


# identifies the complete set of column combinations to cycle through for a dataset
def columnCombos(df):
    df['non_missing'] = df.apply(lambda row : list(row[~row.isnull()].index), axis = 1)
    non_missing = df.non_missing.tolist()
    unique_cols = list(set(tuple(row) for row in non_missing))

    col_combos = list(itertools.combinations(unique_cols, 2))
    
    if col_combos == []:
        col_combos = list(itertools.combinations(unique_cols*2, 2))
    
    return df, col_combos

# identify all patients that have the correct combination of non-missing columns
def extractPatientCols(df, col_tuple):
    df.loc[:,'match1'] = df.non_missing.apply(lambda x: x == list(col_tuple[0]))
    df.loc[:,'match2'] = df.non_missing.apply(lambda x: x == list(col_tuple[1]))
    col1_pts = df.loc[df['match1'] == True]
    col2_pts = df.loc[df['match2'] == True]
    
    # filter both to the relevant columns
    col1_pts.drop(columns = ['match1', 'match2', 'non_missing'], inplace = True)
    col2_pts.drop(columns = ['match1', 'match2', "non_missing"], inplace = True)
    
    return col1_pts, col2_pts

# Compute our actual cosine similarity
def computeCosine(df, col_tuple):
    # extract samples with matching columns and compute pairwise cosines similarity
    pts_df1, pts_df2 = extractPatientCols(df, col_tuple)
    
    # identify the shared columns 
    shared_cols = list(set(col_tuple[0]) & set(col_tuple[1]))
    shared_cols = [col for col in shared_cols if col.lower() != "subject_id"]

    # compute cosine similarity and format data
    cosine = pd.DataFrame(cosine_similarity(pts_df1.loc[:,shared_cols], pts_df2.loc[:,shared_cols]), 
                 index = pts_df1.subject_id, columns = pts_df2.subject_id).reset_index()

    del cosine.columns.name
    cosine_melted = cosine.melt(id_vars = 'subject_id')
    cosine_melted.columns = ['patient_1', 'patient_2', 'similarity']

    return cosine, cosine_melted



##################################################################
# Old functions
##################################################################

# given a list of potential patients, return the patient-patient combinations
def patientCombos(df):
    subjects = list(df.subject_id)
    return list(itertools.combinations(subjects, 2))



# extract rows related to a patient - patient tuple
def extractPatientRows(df, pt_tuple):
    pt1 = pt_tuple[0]
    pt2 = pt_tuple[1]
    
    # now extract the rows
    pt_row1 = df[df.subject_id == pt1].iloc[0]
    pt_row2 = df[df.subject_id == pt2].iloc[0]    

    return pt_row1, pt_row2





# identify the shared non-missing column
def nonNAcols(pt_row1, pt_row2):
    cols1 = pt_row1[~pt_row1.isnull()].index
    cols2 = pt_row2[~pt_row2.isnull()].index
    
    shared_cols = list(set(cols1) & set(cols2))
    return [col for col in shared_cols if col.lower() != "subject_id"]
