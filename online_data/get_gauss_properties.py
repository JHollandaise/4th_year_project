import numpy as np

FILE_NAME = 'underfill_nominal'

profile = np.loadtxt(FILE_NAME+'.csv', delimiter=',')

profile_properties = (np.mean(profile,axis=0),np.std(profile,axis=0))

np.savetxt(FILE_NAME+'_properties.csv', profile_properties,
           delimiter=',')
