#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
import operator
import datetime
import copy


def readeport(nWord, TOFHIR_RxBRAMch, outArray):
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
            #file.write( str("{:3d};{:3d};{:3d};".format(linkID, ChID, xx)+ hex(FrameData) + "\n"))
            outArray[xx] = FrameData
            xx = xx + 1
            FrameData = 0
        else : 
            FrameData = FrameData + ((MEM[x]&0xFFFFFFFF)<<yy*32)
            yy = yy + 1 


if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) < 2:
        print "Incorrect usage!"
        print "usage: Read_DebugRAM_2link.py lpGBT_link_Number"
        sys.exit(1)

    if int(sys.argv[1]) < 0 or int(sys.argv[1]) > 1:
    	sys.exit("Bad number for link. Please use 0 or 1")
   
    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);
    
    link = int(sys.argv[1])
    print "Read from lpGBT link =", link

    neports = 28 
    rxRAM = []

    resetTFHRbufAddrCnt = hw.getNode("Common_rst_TFHR_Frame_addr_cnt") 
    if link == 1:
        Init_EC_IC_moduls = hw.getNode("Init_TOFHIR_EC_IC_modules1")
        RHCnt_status      = hw.getNode("LINK1_RHCnt_status")   
        debug_RAM 	  = hw.getNode("Tx1_debug_RAM")
        debug_RAM_start   = hw.getNode("Tx1_debug_RAM_start")
        rst_Rx_addr_cnt   = hw.getNode("rst_Rx1_addr_cnt")
        for xx in range(neports):
            rxRAM.append( hw.getNode("Rx1BRAM_CH"+str(xx)))
        rxRAM_status       = hw.getNode("Rx1RAM_status")
    else:
        Init_EC_IC_moduls = hw.getNode("Init_TOFHIR_EC_IC_modules")
        RHCnt_status      = hw.getNode("LINK0_RHCnt_status")   
        debug_RAM 	  = hw.getNode("Tx0_debug_RAM")
        debug_RAM_start   = hw.getNode("Tx0_debug_RAM_start")
        rst_Rx_addr_cnt   = hw.getNode("rst_Rx0_addr_cnt")
        for xx in range(neports):
            rxRAM.append( hw.getNode("Rx0BRAM_CH"+str(xx)))
        rxRAM_status       = hw.getNode("Rx0RAM_status")
    
    Value = []
    MEM1 = []

    wait = 1
  
    
 
    #******************** Read Rx RAM data *********************
    Nword = 32
    RxDataArray = []
    for xx in range(Nword/4 + 1): # init data array
        RxDataArray.append(0x0)
    #for xx in range(Nword/4):
    #    print "N = ", xx, "Rx Data RAM =", hex(RxDataArray[xx])

    # Reset TOFHIR Rx address pointer counter (by link)
    #rst_Rx_addr_cnt.write(1); 
    #hw.dispatch();
    resetTFHRbufAddrCnt.write(1) # common reset TOFHIR data Rx buffers
    hw.dispatch();
    time.sleep(wait) # wait 1 sec    
 
    RAM_status = rxRAM_status.read(); 
    hw.dispatch();
    print "Rx RAM status =", bin(RAM_status)  
    
    readeport(Nword,rxRAM[13], RxDataArray)
    for xx in range(Nword/4):
        print "N = ", xx, "Rx Data RAM =", hex(RxDataArray[xx])    
    #*********************************************************


    print ""
    print "frequency frames with recognized headers"
    Nword = 28
    FREQ = []
    FREQ=RHCnt_status.readBlock(int(Nword));
    hw.dispatch();
    for x in range(int(Nword)): 
        print "e-port",x, " ", (FREQ[x]), "Hz"

    
    print "************************************************"
    print "End!"  
    print "################################################"


