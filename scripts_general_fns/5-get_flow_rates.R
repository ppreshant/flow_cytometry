# Get flow rates from .fcs files using package flowAI

# 5-get_flow_rate.R
# Reference link - https://www.bioconductor.org/packages/devel/bioc/vignettes/flowAI/inst/doc/flowAI.html

library(flowAI)

res_qc <- flow_auto_qc(fcsfiles = fl.set)
# does not work due to keyword $TOT (= 0) not matching the actual number of  in data section (= 1), both of which are wrong