# Description

The python script `name.py` here is a wrapper for quickly processing Flow cytometry data using 
FlowCal repository : https://github.com/taborlab/FlowCal/ in a standard workflow

Briefly, the code
- Opens all .fcs files within the directory
- Attaches sample names from a google sheet 
    (could change to local .csv file too)
- Run standard processes, uses sample named as beads for MEFLing
- Saves standard plots and outputs summary statistics data in .csv

# How to run

It is recommended that you create a spyder project in the folder containing this file and run the script form it, or otherwise ensure that the directory containing this script is python's working directory (use `spyder -p .`)

 Also if you clone the repository, the subdirectories should appear properly and the data reading and saving outputs should happen smoothly; since the paths used are relative to the working directory


