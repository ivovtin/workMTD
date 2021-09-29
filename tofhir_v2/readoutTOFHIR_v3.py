#!/bin/env python

import random 
import sys 
import uhal
import time
import operator
import datetime
import copy
import argparse
import json
from collections import OrderedDict
from readTOFHIR_tools import tofhir

parser =  argparse.ArgumentParser(description='Readout TOFHIR')
parser.add_argument('-f', '--outFile', dest="nameFile", type=str, default="test", help="Out file name (default is test.rawf)")
parser.add_argument('-n', '--nCycRead', dest="nCycRead", type=int, default=1, help="Number cycles for read (default is 1)")
parser.add_argument('-j', '--jsonFile', dest="jsonName", type=str, default="readout_settings_tofhir.json", help="Json config file (default is readout_settings_tofhir.json)")

opt = parser.parse_args()


if __name__ == '__main__':
    
    # Creating the HwInterface
    uhal.disableLogging()

    connectionMgr = uhal.ConnectionManager("file://" + "Real_connections.xml");
    hw = connectionMgr.getDevice("KCU105real");

    Init_All_modules0   = hw.getNode("Init_TOFHIR_EC_IC_modules0")
    Init_All_modules1   = hw.getNode("Init_TOFHIR_EC_IC_modules1")
    statusLink0       = hw.getNode("LINK0_RHCnt_status")   
    statusLink1       = hw.getNode("LINK1_RHCnt_status")   
    statusLinks = []
    statusLinks.append(statusLink0)
    statusLinks.append(statusLink1)

    txRAM0           = hw.getNode("Tx0BRAM")
    txRAM1           = hw.getNode("Tx1BRAM")
    txRAMs = []
    txRAMs.append(txRAM0)
    txRAMs.append(txRAM1)

    neports = 28 
    nlinks = 2 
    rxRAMs = [[],[]]
    RxTTs  = [[],[]]
    for link in range(nlinks):
        for eport in range(neports):
            rxRAMs[link].append( hw.getNode("Rx"+str(link)+"BRAM_CH"+str(eport)))
            RxTTs[link].append( hw.getNode("Rx"+str(link)+"TT_CH"+str(eport)))

    Tx0_Trig_Freq       = hw.getNode("Tx0_Trig_Freq")
    Tx0_Resync_Freq     = hw.getNode("Tx0_Resync_Freq")

    Tx1_Trig_Freq       = hw.getNode("Tx1_Trig_Freq")
    Tx1_Resync_Freq     = hw.getNode("Tx1_Resync_Freq")

    Rx0RAM_status       = hw.getNode("Rx0RAM_status")
    Rx1RAM_status       = hw.getNode("Rx1RAM_status")

    rxRAMs_status       = []
    rxRAMs_status.append(Rx0RAM_status)
    rxRAMs_status.append(Rx1RAM_status)

    resetTFHRbufAddrCnt = hw.getNode("Common_rst_TFHR_Frame_addr_cnt") 
    resetTimeTagger     = hw.getNode("Common_rst_TFHR_TT_counter") 
    resetRx0AddressCnt  = hw.getNode("rst_Rx0_addr_cnt")
    resetRx1AddressCnt  = hw.getNode("rst_Rx1_addr_cnt")
    resetRxAddressCnts   = []

    resetTimeTagger.write(1) # common reset TT counters
    hw.dispatch();
    resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
    hw.dispatch();

    # set Resync frequency 
    #TxValue = 4000000 #25ns*4000000=10Hz
    #Tx0_Resync_Freq.write(int(TxValue)); 
    #Tx1_Resync_Freq.write(int(TxValue)); 
    #hw.dispatch();
    # set Trigger frequency
    TxValue = 0 #25ns*40000=1000Hz
    Tx0_Trig_Freq.write(int(TxValue)); 
    Tx1_Trig_Freq.write(int(TxValue)); 
    hw.dispatch();

    # Open JSON file with mapLink, enableLink, readMaskIni
    with open(opt.jsonName) as jsonFile:
       data = json.load(jsonFile, object_pairs_hook=OrderedDict)

    mapLink = data['mapLink']
    enableLink = data['enableLink']
    readMaskIni = data['readMaskIni']

    # ouput file    
    print "File name: "+opt.nameFile+".rawf"
    file = open(opt.nameFile+".rawf","w")
    file.write( "Link ID; Channel ID; Line; time tag; Data \n")
 
    MEM                 = []
    TimeOut             = 0   
    nCycle              = 0
    nWord               = 1020 #512  1024   
    TTnWord             = 255 #nWord / 4 
    channelRead         = copy.deepcopy(enableLink)
    Timeout             = 0
    while nCycle < int(opt.nCycRead) and Timeout < 10000:
        print("cycle: %d") % nCycle
        for link in range(nlinks):
            tofhir.readFEB('A', rxRAMs_status[link], hw, nWord, TTnWord, rxRAMs[link], RxTTs[link], link, channelRead, file) 
            tofhir.readFEB('B', rxRAMs_status[link], hw, nWord, TTnWord, rxRAMs[link], RxTTs[link], link, channelRead, file) 
            tofhir.readFEB('C', rxRAMs_status[link], hw, nWord, TTnWord, rxRAMs[link], RxTTs[link], link, channelRead, file) 
            tofhir.readFEB('D', rxRAMs_status[link], hw, nWord, TTnWord, rxRAMs[link], RxTTs[link], link, channelRead, file) 
            print(channelRead[str(link)].values())
        if readMaskIni == channelRead:
            nCycle = nCycle + 1;
            print("cycle: %d") % nCycle
            print("Total: %d") % opt.nCycRead
            channelRead         = copy.deepcopy(enableLink)
            print(channelRead)
            if (1 ):
                resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
                hw.dispatch();
                print(channelRead)
                TimeOut = 0
        TimeOut = TimeOut + 1 
    print("")
    print("frequency frames with recognized headers")
    nWord = 5
    for link in range(nlinks):
        MEM=statusLinks[link].readBlock(int(nWord))
        hw.dispatch()
        print("link: " , link )
        print("frequency frames with recognized headers")
        Nword = 27
        FREQ = []
        FREQ=statusLinks[link].readBlock(int(Nword))
        hw.dispatch();
        # print result
        for x in range(int(Nword)): 
            print "e-port",x, " ", (FREQ[x]), "Hz"
