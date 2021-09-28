import json
import copy
from collections import OrderedDict

mapLink_v0 = {'A' : [0,1,2,3,4,5] , 'B' : [9,10,11,12,13,14], 'C' : [22,23,24,25,26,27], 'D': [15,16,17,18,19,20]}

#with open('mapLink_test_v0.json', 'w') as json_file:
#  json.dump(mapLink, json_file)

#print(mapLink_v0)

with open('readout_settings_tofhir.json') as jsonFile:
  data = json.load(jsonFile, object_pairs_hook=OrderedDict)

#print(data)

#mapLink = data['mapLink'][0]['A']
mapLink = data['mapLink']
#print(mapLink)

connectorID='B'

channelIDs  = mapLink[connectorID];
#print(channelIDs)
channelIDs_v0  = mapLink_v0[connectorID];
#print(channelIDs_v0)
#for index,channel in enumerate(channelIDs) :
  #print(channelIDs[index])


enableLink = data['enableLink']
print(enableLink)
linkID=0
#channelMask = enableLink[str(linkID)][connectorID]
#channelMask = enableLink[linkID][connectorID]
#channelMask = enableLink['1']['B']
#print(channelMask)

channelRead         = copy.deepcopy(enableLink)
#print(channelRead)
#print(channelRead['0'].values())

#readMaskIni = data['readMaskIni']
#print(readMaskIni)




