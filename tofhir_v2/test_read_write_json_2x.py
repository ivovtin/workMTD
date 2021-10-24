import json
import copy
from collections import OrderedDict


with open('config_tofhir_2x_newRicardo.json') as jsonFile:
  data = json.load(jsonFile, object_pairs_hook=OrderedDict)

#print(data)

##reg32 = data[0]['Chip_00010101_reg32'][0]
##reg32 = data[0]['Chip_00010101_reg33'][0]
#reg32 = data[1]['Chip_00010101_reg00'][0]
##reg32 = data[0]['Chip_00010101_reg32']
#mapLink = data['mapLink']
#print(reg32)

packet = 'Chip_00010101_reg01' 
#print data[0].keys()
#i=0

#for key, value in data[0].items():
#    print key, value

length = len(data)
print length

#for key in data:
#	print key

k=0

for i in range(0, length):
	for key0, value0 in data[i].iteritems():
		#print key0
		if key0 == packet:
			k=i
print k


