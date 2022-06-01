# -*- coding: utf-8 -*-
"""
Created on Sun May 29 15:16:56 2022

@author: new
"""

# %% fcs loading
# import FlowCal
# import os

# os.chdir('..')

# FlowCal.io.FCSData('processed_data/test/test.fcs')

# module scope test
from debug_module import scope_tester
x = list(range(5))

print('environment =' + __name__ + '\n Globals =')
globals().keys()

scope_tester()
