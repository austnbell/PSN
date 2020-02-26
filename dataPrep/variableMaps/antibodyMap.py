# -*- coding: utf-8 -*-
"""
Created on Tue Feb 18 12:06:36 2020

Other Antibodies Map

@author: Austin Bell
"""

mitochondrial = {
        'NEGATIVE':0, 
        'POSITIVE':1
        }

nuclear_titer = {
        '1:1280': 6, 
         '1:40 PATTERN-SPECKLED': 1, 
         '1:40': 1, 
         '1:640': 5, 
         '1:160': 3, 
         '1:80': 2, 
         '1:80 PATTERN-DIFFUSE': 2,  
         '1:40 PATTERN-DIFFUSE': 1,  
         '1:640 PATTERN-DIFFUSE': 5, 
         '1:40 PATTERN-NUCLEOLAR': 1,  
         '1:320 PATTERN-DIFFUSE': 4, 
         'GREATER THAN 1:1280': 7, 
         'LESS THAN 1:40': 0, 
         '1:160 PATTERN-SPECKLED': 3,  
         '1:320': 4, 
         '1:320 PATTERN-NUCLEOLAR': 4,  
         '1:160 PATTERN-DIFFUSE': 3
        }

nuclear = {
        'NEGATIVE':0, 'POSITIVE':1
        }

muscle = {
        'POSITIVE':2,
        'NEGATIVE':0, 
        'POSITIVE AT A TITER OF 1:20':1, 
        'POSITIVE -- C/W TITER OF MORE THAN 100 MIU/ML':2, 
        'POSITIVE AT A TITER OF 1:320':3, 
        'POSITIVE AT A TITER OF 1:40':2}