# -*- coding: utf-8 -*-
"""
Created on Wed Feb 26 15:30:06 2020

Do I need to get it into matrix form? 
- if I want to do tensor factorization then yes
- if I just want to do nearest neighbors then no

@author: Austin Bell
"""

import pandas as pd
import copy




class simMatrix(object):
    def __init__(self, filename,):
        self.filename = filename
        self.similarities = None
        
    def insertRow(self, cosine):
        if self.similarities is None:
            self.similarities = cosine
            
        else:
            self.similarities = pd.concat([self.similarities, cosine])
        
    # TODO: I do not know if I need this yet 
    # methodology will end up depending on its purpose 
    # i.e., if for tensor factorization then I need to ensure that the patient rows / columns includes all patients in specific order
    # to allow comparison with other matrices
    def pairwiseMatrix(self):
        sim1 = pd.DataFrame(self.similarities, columns = ["patient_1", "patient_2", "similarity"])
        # need to add "pt_" to subject_ids since columsn cannot be numbers
        sim2 = copy.deepcopy(sim1)
        sim2.columns = ["patient_2", "patient_1", "similarity"]
        sim = pd.concat([sim1, sim2], axis = 0)
        sim.pivot(index='patient_1', columns='patient_2', values='similarity')      

        pass
        
        
    def export(self, directory):
        self.similarities.to_csv(directory + self.filename + ".csv", index = False)
        
        