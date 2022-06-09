# -*- coding: utf-8 -*-
"""
Created on Tue May 31 00:45:19 2022

@author: new
"""

# Testing script

def scope_tester():
    print('environment =' + __name__ + '\n Globals =')
    globals().keys()
    
    x = globals()['x']
    print('/n', x)