# -*- coding: utf-8 -*-
"""
Created on Wed Mar  4 21:47:59 2020

functions for graph analysis 

@author: Austin Bell
"""

import networkx as nx
import pandas as pd
import numpy as np

import scipy
from scipy.sparse import csgraph
from numpy import linalg as LA
import matplotlib.pyplot as plt
from sklearn.cluster import SpectralClustering


#########################################################################################
# Graph Generation and Sampling
#########################################################################################

def genMultiDiGraph(df, included_group = "All"):
    G = nx.MultiDiGraph()   # or DiGraph, MultiGraph, MultiDiGraph, etc

    # once edges are added, we add our attributes via dictionary
    # [(0, 1 ,{'attr1': 20, 'attr2': 'nothing'}), (1, 2, {'attr2': 3})]

    for row in df.to_numpy():
        e_attr = {'weight': row[2],
                  'rank': row[3],
                  'data_group': row[4],
                  'data_type': row[5]
                 }
        
        if included_group == "All":
            G.add_edges_from([(row[0], row[1], e_attr)])
        elif row[4] in included_group:
            G.add_edges_from([(row[0], row[1], e_attr)])
            
    return G






######################################################################################
# Clustering 
######################################################################################

#### Identify the optimal K for Spectral Clustering levering the eigen gap statistic
def eigenDecomposition(A, plot = True, topK = 5):
    """
    :param A: Affinity matrix
    :param plot: plots the sorted eigen values for visual inspection
    :return A tuple containing:
    - the optimal number of clusters by eigengap heuristic
    - all eigen values
    - all eigen vectors
    
    This method performs the eigen decomposition on a given affinity matrix,
    following the steps recommended in the paper:
    1. Construct the normalized affinity matrix: L = D−1/2ADˆ −1/2.
    2. Find the eigenvalues and their associated eigen vectors
    3. Identify the maximum gap which corresponds to the number of clusters
    by eigengap heuristic
    
    References:
    https://papers.nips.cc/paper/2619-self-tuning-spectral-clustering.pdf
    http://www.kyb.mpg.de/fileadmin/user_upload/files/publications/attachments/Luxburg07_tutorial_4488%5b0%5d.pdf
    """
    L = csgraph.laplacian(A, normed=True)
    n_components = A.shape[0]
    
    # LM parameter : Eigenvalues with largest magnitude (eigs, eigsh), that is, largest eigenvalues in 
    # the euclidean norm of complex numbers.
    eigenvalues, eigenvectors = LA.eig(L)
    
    if plot:
        plt.title('Largest eigen values of input matrix')
        plt.scatter(np.arange(len(eigenvalues)), eigenvalues)
        plt.grid()
        
    # Identify the optimal number of clusters as the index corresponding
    # to the larger gap between eigen values
    index_largest_gap = np.argsort(np.diff(eigenvalues))[::-1][:topK]
    nb_clusters = index_largest_gap + 1
        
    return nb_clusters, eigenvalues, eigenvectors

# Given a graph, run spectral clustering
def spectralCluster(G, k):
    
    # generate adjacency matrix
    adj_mat = nx.to_numpy_matrix(G)
    adj_mat /= np.max(np.abs(adj_mat)) # scale between 0 and 1 - since multigraph, similarity can exceed 1 
    
    # cluster
    sc = SpectralClustering(k, affinity='precomputed', n_init=100)
    sc.fit(adj_mat)
    
    return sc, adj_mat