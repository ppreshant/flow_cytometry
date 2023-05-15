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
    
def debug_tester():
    # Doesn't work:( try calling this from a notebook or console and see if it stops at breakpoints
    print('enterted debug tester module')
    
    # place debugger here
    a = 45
    
    print(a)
    print('exiting module')