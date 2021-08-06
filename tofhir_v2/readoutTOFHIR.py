#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
import operator
import datetime
import copy

mapLink = {'A' : [0,1,2,3,4,5] , 'B' : [9,10,11,12,13,14], 'C' : [22,23,24,25,26,27], 'D': [15,16,17,18,19,20]} 

# masking for swapped FE and internal test pulse
# enableLink = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [1,0,1,1,0,1]},
#               1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [1,0,1,1,1,1]}}

# masking for standard FE position and internal test pulse
#enableLink = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,1]},
#              1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,1]}}


#masking for test pulses and different CC ports or FE position
# enableLink = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [1,0,1,1,0,1], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]},
#               1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [1,0,1,1,1,1]}}
# enableLink = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]},
#               1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [1,0,1,1,0,1]}}
# enableLink = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [1,0,1,1,0,1]},
#               1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]}}


# masking for laser runs, standard FE position
#enableLink = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]},
#              1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]}}

enableLink = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,1,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]},
              1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]}}
'''
enableLink = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]},
              1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]}}
'''

readMaskIni = {0 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]},
               1 :{ 'A' : [0,0,0,0,0,0] , 'B' : [0,0,0,0,0,0], 'C' : [0,0,0,0,0,0], 'D': [0,0,0,0,0,0]}}


def readeport(ChID, nWord, TOFHIR_RxBRAMch,linkID, file):
    FrameData = 0
    MEM = []
    xx = 1
    yy = 0
    MEM=TOFHIR_RxBRAMch.readBlock(int(nWord));
    hw.dispatch();
    #print hex(MEM[0])
    # print result
    for x in range(int(nWord)): 
        if yy == 3:
            FrameData = FrameData + ((MEM[x]&0xFFFFFFFF)<<yy*32)
            yy = 0
            file.write( str("{:3d};{:3d};{:3d};".format(linkID, ChID, xx)+ hex(FrameData) + "\n"))
            xx = xx + 1
            FrameData = 0
        else : 
            FrameData = FrameData + ((MEM[x]&0xFFFFFFFF)<<yy*32)
            yy = yy + 1 


def readTimeTag(ChID, nWord, TOFHIR_RxTTch, linkID, file):
    TTData = 0
    MEM = []
    xx = 1
    yy = 0
    MEM=TOFHIR_RxTTch.readBlock(int(nWord*2));
    hw.dispatch();
    for x in range(int(nWord-1)): 
       TTData = (MEM[x*2]&0xFFFFFFFF)+((MEM[x*2+1]&0xFFFFFFFF)<<32)
       file.write( str("{:3d};{:3d};{:3d};".format(linkID, ChID, xx)+ hex(TTData) + "\n"))
      
def readeportwttag(ChID, nWord, tnWord, RxBRAMch, RxTTch, linkID, file):
    FrameData = 0
    portMEM = []
    TTData = 0
    tMEM = []
    tTag = []
    xx = 1
    yy = 0
    portMEM=RxBRAMch.readBlock(int(nWord));
    hw.dispatch();
    tMEM=RxTTch.readBlock(int(tnWord*2));
    hw.dispatch();

    for t in range(int(tnWord)): 
       TTData = (tMEM[t*2]&0xFFFFFFFF)+((tMEM[t*2+1]&0xFFFFFFFF)<<32)
       tTag.append(hex(TTData))


    #print hex(MEM[0])
    # print result
    for x in range(int(nWord)): 
       if yy == 3:
           FrameData = FrameData + ((portMEM[x]&0xFFFFFFFF)<<yy*32)
           yy = 0
           file.write( str("{:3d};{:3d};{:3d};".format(linkID, ChID, xx)+tTag[xx-1]+";"+hex(FrameData) + "\n"))
           xx = xx + 1
           FrameData = 0
       else : 
           FrameData = FrameData + ((portMEM[x]&0xFFFFFFFF)<<yy*32)
           yy = yy + 1 

def readFEB(connectorID, TOFHIR_rxRAM_status, hw, nWord, TTnWord, TOFHIR_RxBRAM, TOFHIR_RxTT, linkID,  channelRead, file): # This many number of inputs indicates that we need a class... Later... 
    #time.sleep(0.01)
    RAM_status = TOFHIR_rxRAM_status.read(); 
    hw.dispatch();                           
    channelIDs  = mapLink[connectorID];
    channelMask = enableLink[linkID][connectorID]
    for index,channel in enumerate(channelIDs) :
        if (RAM_status>>channelIDs[index] & 0x1) == 1 and channelMask[index] == 1 and channelRead[linkID][connectorID][index] == 1:
            print("----------- Read Rx answer e-port {}------------".format(channel))
            readeportwttag(channel, nWord, TTnWord, TOFHIR_RxBRAM[channel], TOFHIR_RxTT[channel], linkID ,file)
            channelRead[linkID][connectorID][index] = 0
#        elif (channelMask[index] == 1): 
#            channelRead[linkID][connectorID][index] = 1

if __name__ == '__main__':
    
    # PART 1: Argument parsing
    if len(sys.argv) < 3:
        print("Incorrect usage!")
        print("usage: readoutTOFHIR_v1.py outFileNamePrefix nCycRead")
        sys.exit(1)
   
        
    # ouput file    
    nameFile = sys.argv[1]+".rawf"
    print("File name: " , nameFile)
    file = open(nameFile,"w") 
    file.write( "Link ID; Channel ID; Line; time tag; Data \n")
    
    nCycRead = int(sys.argv[2])
    
    uhal.disableLogging()

    #connectionFilePath = "/home/software/mtd-daq/btl-kcu105-ipbus/Real_connections_TOFHIR_FULL.xml";
    connectionFilePath = "Real_connections.xml"; 
    deviceId = "KCU105real";
    
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    Init_All_modules0   = hw.getNode("Init_TOFHIR_EC_IC_modules0")
    Init_All_modules1   = hw.getNode("Init_TOFHIR_EC_IC_modules1")
    statusLink0       = hw.getNode("LINK0_RHCnt_status")   #hw.getNode("A3")
    statusLink1       = hw.getNode("LINK1_RHCnt_status")   #hw.getNode("A3")
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

    print("here1")
    
    Tx0_Trig_Freq       = hw.getNode("Tx0_Trig_Freq")
    Tx0_Resync_Freq     = hw.getNode("Tx0_Resync_Freq")
    Tx0_Resync_CMD 	= hw.getNode("Tx0_Resync_CMD")
    Tx0_Trigger_CMD 	= hw.getNode("Tx0_Trigger_CMD")
    Tx0_Config_CMD 	= hw.getNode("Tx0_Config_CMD")
    Tx0_debug_Reg 	= hw.getNode("Tx0_debug_Reg")
    Tx0_debug_RAM 	= hw.getNode("Tx0_debug_RAM")
    Tx0_debug_RAM_start = hw.getNode("Tx0_debug_RAM_start")

    Tx1_Trig_Freq       = hw.getNode("Tx1_Trig_Freq")
    Tx1_Resync_Freq     = hw.getNode("Tx1_Resync_Freq")
    Tx1_Resync_CMD 	= hw.getNode("Tx1_Resync_CMD")
    Tx1_Trigger_CMD 	= hw.getNode("Tx1_Trigger_CMD")
    Tx1_Config_CMD 	= hw.getNode("Tx1_Config_CMD")
    Tx1_debug_Reg 	= hw.getNode("Tx1_debug_Reg")
    Tx1_debug_RAM 	= hw.getNode("Tx1_debug_RAM")
    Tx1_debug_RAM_start = hw.getNode("Tx1_debug_RAM_start")

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
#    resetRxAddressCnts.append(resetRx0AddressCnt)
#    resetRxAddressCnts.append(resetRx1AddressCnt)

    TxValue             = 1  
#    for link in range(nlinks):
#        resetRxAddressCnts[link].write(1); 
#        hw.dispatch();
#        resetRxAddressCnts[link].write(1); 
#    hw.dispatch();

    #Init_All_modules.write(1)
    #hw.dispatch();
    resetTimeTagger.write(1) # common reset TT counters
    hw.dispatch();
    resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
    hw.dispatch();

    wait                = 1
    nWord               = 8
    Value               = []
    MEM                 = []
    MEM_decode          = []
    wait                = 1

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
    
    nCycle              = 0
    TimeOut             = 0
#    LinkID              = 1
    nWord               = 1020 #512  1024   
    TTnWord             = 255 #nWord / 4 
    channelRead         = copy.deepcopy(enableLink)
    Timeout             = 0
    while nCycle < int(nCycRead) and Timeout < 10000:
        print("cycle: %d") % nCycle
        for link in range(nlinks):
            #def readFEB(connectorID, TOFHIR_rxRAM_status, hw, nWord, TTnWord, TOFHIR_RxBRAM, TOFHIR_RxTT, channelRead, file): 
            readFEB('A', rxRAMs_status[link], hw, nWord, TTnWord, rxRAMs[link], RxTTs[link], link, channelRead, file) 
            readFEB('B', rxRAMs_status[link], hw, nWord, TTnWord, rxRAMs[link], RxTTs[link], link, channelRead, file) 
            readFEB('C', rxRAMs_status[link], hw, nWord, TTnWord, rxRAMs[link], RxTTs[link], link, channelRead, file) 
            readFEB('D', rxRAMs_status[link], hw, nWord, TTnWord, rxRAMs[link], RxTTs[link], link, channelRead, file) 
            print(channelRead[link].values())
        if readMaskIni == channelRead:
#        if reduce(operator.or_,channelRead) == 0: # buffer full flag analysis
            nCycle = nCycle + 1;
            #print(nCycle) 
            print("cycle: %d") % nCycle
            print("Total: %d") % nCycRead
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
