import os
os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)\FACS analysis')

import FlowCal
s = FlowCal.io.FCSData('../guava/E1.4a_Vmax-Ribozyme-1_8-12-20.fcs')
plt.hist(s[:, 'FSC-HLin'], bins=100)
plt.show()
