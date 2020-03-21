# -*- coding: utf-8 -*-
"""
Created on Sun Feb 23 20:38:11 2020

mapping minor fixes for chart events

@author: Austin Bell
"""

chartMap = {
        "Occ. Moist": "Occasionally Moist",
        "Consist. Moist": "Consistently Moist",
        "Intubated/trach": "Intubated/trached",
        "Walks Occasional": "Walks Occasionally",
        "Comp. Immobile": "Completely Immobile",
        "Cough/DeepBreath": "Cough/Deep Breath",
        "Prob. Inadequate": "Probably Inadequate",
        "Clear liquid": "Clear Liquid",
        "House - Regular": "House",
        "NAS/Low Cholest": "NAS/Low Cholesterol",
        "Sl. Limited": "Slight Limitations",
        
        # a lot of changes in the demographic setting
        "Fam Talked to RN": "Family Talked to RN",
        "Fam Talked to MD": "Family Talked to MD",
        "Family Conferenc": "Family Conference",
        "SocServ Involved": "Social Service Involved",
        "S": "Single",
        "M": "Married",
        "W": "Widowed",
        "Partner": "Married",
        "D": "Divorced",
        "s": "Single",
        "White - Other European": "White",
        "White - Russian": "White",
        "White - Brazilian": "White",
        "Portuguese": "White",
        "American Indian / Alaska Native - Federally Recognized Tribe": "American Indian / Alaska Native",
        
        
        "Hispanic / Latino - Salvadoran": "Hispanic or Latino",
        "Hispanic / Latino - Central American (other)": "Hispanic or Latino",
        "Hispanic / Latino - Dominican": "Hispanic or Latino",
        "Hispanic / Latino - Puerto Rican": "Hispanic or Latino",
        "Hispanic / Latino - Cuban": "Hispanic or Latino",
        "Hispanic / Latino - Mexican": "Hispanic or Latino",
        
        "Black / African American": "Black / African",
        "Black / Cape Verdean": "Black / African",
        "Black / Haitian": "Black / African",
        
        "Asian - Korean": "Asian",
        "Asian - Chinese": "Asian",
        "Asian - Asian Indian": "Asian",
        "Asian - Japanese": "Asian",
        "Asian - Vietnamese": "Asian",
        "Asian - Cambodian": "Asian",
        "Asian - Filipino": "Asian",
        
        # heart and lung has a lot of cleanup too
        "1st AV (First degree AV Block) ": "1st Deg AV Block",
        "2nd AV M2 (Second degree AV Block - Mobitz 2) ": "2nd AVB Mobitz 2",
        "2nd AV W-M1 (Second degree AV Block Wenckebach - Mobitz1) ": "2nd AVB/Mobitz I",
        "A Flut (Atrial Flutter) ": "Atrial Flutter",
        "A Paced": "AV Paced",
        "Atrial Fib": "AF (Atrial Fibrillation)",
        "MultFocalAtrTach": "MAT (Multifocal atrial tachycardia)",
        "Parox Atr Tachy": "PAT (Paroxysmal Atrial Tachycardia)",
        "Sinus Arrhythmia": "SA (Sinus Arrhythmia)",
        "Sinus Brady": "SB (Sinus Bradycardia)",
        "Sinus Tachy": "ST (Sinus Tachycardia) ",
        "Supravent Tachy": "SVT (Supra Ventricular Tachycardia)",
        "Vent. Tachy": "VT (Ventricular Tachycardia) ",
        "Ventricular Fib": "VF (Ventricular Fibrillation) ",
        "Wand.Atrial Pace": "WAP (Wandering atrial pacemaker)",
        "Pleural friction": "Pleural Friction",
        "Pleural fricton": "Pleural Friction"
        
}

painLevelMap = {
        'Worst': 10,
        '10-Worst': 10,
        'Mild to Moderate.': 3,
        'Moderate to Severe': 7,
        'Severe': 8,
        '4-Mild to Mod': 4,
        '0-None': 0,
        'Mild to Moderate': 3,
        'Severe to Worse': 9,
        'Moderate to Severe.': 7,
        '9-Severe-Worst': 9,
        '7-Mod to Severe': 7,
        '3-Mild to Mod': 3,
        '2-Mild': 2,
        'Mild ': 2,
        'None to Mild': 1,
        '5-Moderate': 5,
        'None': 0,
        'Unable to Score': -1,
        'Moderate': 5,
        'Unable to score': -1,
        '6-Mod to Severe': 6,
        '8-Severe': 8,
        '1-None to Mild': 1
        }