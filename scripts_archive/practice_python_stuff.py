# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.14.0
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# %%
# Run the flow cytometry script components from outside 


# prelims - setting working directory is important
{
    "metadata": {
        "jupyter" : {
        "source_hidden": True
        }
    }
}

# check current working directory
import os
os.chdir("..") # set path to the head directory of the project
os.getcwd()

# add project path to sys.path: enables loading local modules in other folders
import sys
module_path = os.getcwd()
# module_path = os.path.abspath(os.path.join('..'))

if module_path not in sys.path:
    sys.path.append(module_path)
sys.path # check that the last entry is the head project path

# enables automatic reloading of local modules when updated
# %load_ext autoreload
# %autoreload 2

# Utilities
from sspipe import p, px

# %%
# testing regex with glob
parent_path = 'flowcyt_data/S043_28-3-22/'

def test(parent_path, pattern_to_match):
    
    """Get fcs files matching regex pattern in all subdirectories """
    
    # recurse this function if supplied with a list for the regex pattern
    if(isinstance(pattern_to_match, list)):
        print("List type detected in regex pattern, function will recurse")
        list_of_outputs = map(lambda x: test(parent_path, x), pattern_to_match)
        return(list_of_outputs)
              
    elif(isinstance(pattern_to_match, str)):   
        import glob # regular expression of filepaths
        from pathlib import PurePath # path manipulation

        # %% get paths : glob
        # get the list of all .fcs files in the experiment
        fcspaths = glob.glob(parent_path + '**/' + pattern_to_match + '*.fcs', 
                  recursive=True) # ** and recursive => includes all subfolders

        # using pathlib to get the parent path
         # fcspaths[0] | p(PurePath).parent | p(str)

        # %% get filenames : pathlib
        # list of fcs file names without path
        fcslist = [PurePath(fl).name for fl in fcspaths]
        # len(fcslist) # check that all files are read

        # %% return
        return ((fcspaths, fcslist))
    else: print("regex pattern is not a string or iterable")'A01 Well - A01 WLSM.fcs''A01 Well - A01 WLSM.fcs''A01 Well - A01 WLSM.fcs'


# %%
ts = test(parent_path, ['a0[2-4]', 'b05'])

# %%
t1 = test(parent_path, 'a0[2-4]')

# %%
t2 = test(parent_path, 'b05')

# %%
tt = list(t1, t2)

# %%
tsl = list(ts)

# %%
import itertools
list(itertools.chain.from_iterable(b) for a,b in tsl)

# %%
a = 6

# %%
s = 'condabola'

# %%
p1 = patterns[1].__class__

# %%
isinstance(patterns[1], str)

# %%
list(itertools.chain.from_iterable([[1,5,3], [8,3,4]]))

# %%
a = 1

# %%
# Testing markdown output through python code
from IPython.display import display, Markdown
a = 5
if a: Markdown("""## Analysis of data {a} times""".format(a = a)) # does not work
Markdown("""## Analysis of data {a} times""".format(a = a+3)) # works

# %%
os.getcwd()

# %%
from importlib import reload
import scripts_general_fns.g3_python_utils_facs as gen_utils
reload(gen_utils)

# %%
# Message about the beads file being read
print('Reading beads from file : ' + 'somefile')

display(Markdown('## Getting calibration data from beads'))
    
print('testing now')

# %%
fcspaths

# %%
print('is this it?')
Markdown('## Analyzing dataset : "{a}"'.format(a = 'gooddata')) | p(display)
print('ues it works')


# %%
# testing conditional arguments in re.search function

def doreg(a, b, ignore_case = False):
    import re
    return [True if re.search(a, b,  re.IGNORECASE if ignore_case else 0) 
            else False]



# %%
doreg('Wen','twenty five', True)

# %%
tuple\
(a 
      for a in range(1,5))
