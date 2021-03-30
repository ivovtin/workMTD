#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
import cfgTOFHIR as cfgTF
import numpy as np

if __name__ == '__main__':
    
    np.set_printoptions(formatter={'int':hex})
    
    # PART 1: Argument parsing
    if len(sys.argv) != 1:
        print "Incorrect usage!"
        print "usage: read_write_single_register.py only"
        sys.exit(1)
   
    uhal.disableLogging()

    connectionFilePath = "/home/software/mtd-daq/btl-kcu105-ipbus/Real_connections_TOFHIR_FULL.xml";
    deviceId = "KCU105real";

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    Init_TOFHIR_EC_IC_moduls   = hw.getNode("A2")
    statusLink0       = hw.getNode("LINK0_status")   #hw.getNode("A3")
    statusLink1       = hw.getNode("LINK1_status")   #hw.getNode("A3")
    statusLinks = []
    statusLinks.append(statusLink0)
    statusLinks.append(statusLink1)

    tx0RAM           = hw.getNode("Tx0BRAM")
    tx1RAM           = hw.getNode("Tx1BRAM")
    txRAMs = []
    txRAMs.append(tx0RAM)
    txRAMs.append(tx1RAM)

    nlinks = 2

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

    resetRx0AddressCnt  = hw.getNode("rst_Rx0_addr_cnt")
    resetRx1AddressCnt  = hw.getNode("rst_Rx1_addr_cnt")
    resetRxAddressCnts   = []
    resetRxAddressCnts.append(resetRx0AddressCnt)
    resetRxAddressCnts.append(resetRx1AddressCnt)

    TxValue             = 1  
    for link in range(nlinks):
        resetRxAddressCnts[link].write(1); 
        hw.dispatch();
        resetRxAddressCnts[link].write(1); 
        hw.dispatch();
   
    wait = 0.01
    Nword = 8
    MEM = []
    MEM_decode = []


    # set Resync frequency 
    TxValue = 0 #25ns*40000=1000Hz
    Tx0_Resync_Freq.write(int(TxValue)); 
    Tx1_Resync_Freq.write(int(TxValue)); 
    hw.dispatch();
    # set Trigger frequency
    TxValue = 0 #25ns*40000=1000Hz
    Tx0_Trig_Freq.write(int(TxValue)); 
    Tx1_Trig_Freq.write(int(TxValue)); 
    hw.dispatch();


    # initialize TOFHIR, IC and EC moduls
    TxValue = 1  
    Init_TOFHIR_EC_IC_moduls.write(int(TxValue)); 
    hw.dispatch();
    
    ############### Send RESET ##########
    cfgValue = []
    cfgValue.append(0x3CBC3CBC); 
    cfgValue.append(0x3CBC3CBC); 
    cfgValue.append(0x3CBC3CBC); 
    cfgValue.append(0x3CBC3CBC); 
    cfgValue.append(0x3CBC3CBC); 
    cfgValue.append(0x3CBC3CBC); 
    cfgValue.append(0x3CBC3CBC); 
    cfgValue.append(0x000000BC); # msb chage command 0 - reset/ 1 - config
    tx0RAM.writeBlock(cfgValue); 
    tx1RAM.writeBlock(cfgValue); 
    hw.dispatch();

    Value = 1;
    print "send Reset to all ASIC!"  
    Tx0_Config_CMD.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait);

    ############### Send global configuration to all ASICs to set all ASICs to 320Mbps mode ##########
    # ..., K28.5, 
    # 0xF0, 0x00, 0x20, 0xF7, 
    # 0x7D, 0x14, 0xBF, 0xF9, 
    # 0x8F, 0x0E, 0x80, 0x1B,
    # 0x66, 0xFB, 0x74, 0xE9, 
    # 0x01, 0xE5, 0x85, 0x5D, 
    # 0x4D, 0xC6, 0x40, 0x1D, <<<<< Freq 
    # 0x00, 0x00, 0x00, 0x04, 
    # 0x4C, 0xCC, 0x00, 0x00, 
    # 0x51, 0xAF, K28.1, K28.5, ...
    
    print "Send global configuration:"
    for nASIC in range(6):
        cfgValue=list(cfgTF.globalc['config'])
        
        temp1 = cfgValue[0]&0xFF000000;
        temp2 = cfgValue[0]&0x00FF0000;
        cfgValue[0] = ((temp1)&0xFF000000)+((temp2)&0x00FF0000)+((00<<8)&0x0000FF00)+((nASIC)&0xFF)
        
        #print(np.array(cfgValue))
    	tx0RAM.writeBlock(cfgValue); 
    	tx1RAM.writeBlock(cfgValue); 
    	hw.dispatch();
    
    	#print "send Global config CMD to chip", nASIC  
        Tx0_Config_CMD.write(int(Value)); 
        Tx1_Config_CMD.write(int(Value)); 
    	hw.dispatch();
    	time.sleep(wait);

    ############### Send channels configuration to all ASICs to prevent the chip from triggering ##########
    # K28.5, 
    # 0x00, 0x00, 0x00, 0x00,    MSB
    # 0x00, 0x00, 0x00, 0x00, 
    # 0x00, 0x00, 0x00, 0x00, 
    # 0x00, 0x00, 0x80, 0xF4, 
    # 0xE4, 0x17, 0xAA, 0xBA, 
    # 0x69, 0x83, 0x7A, 0x80, 
    # 0x00, 0xA1, 0x12, 0x2E, 
    # 0x59, 0x72, 0x0(nCH), 0x2(nASIC), 
    # 0x51, 0xAF, K28.1, K28.5,  LSB

    print "Send channels configuration to all ASICs to prevent the chip from triggering"
    for nASIC in range(6):
        if( nASIC == 4 ):
           continue
   	for nCH in range(16): 
            cfgValue=list(cfgTF.channelc['config'])
            
            temp1 = cfgValue[0]&0xFF000000;
            temp2 = cfgValue[0]&0x00FF0000;
            cfgValue[0] = ((temp1)&0xFF000000)+((temp2)&0x00FF0000)+((nCH<<8)&0x0000FF00)+((0x20+nASIC)&0xFF)
            
            #print(np.array(cfgValue))
            tx0RAM.writeBlock(cfgValue); 
            tx1RAM.writeBlock(cfgValue); 
            hw.dispatch();
            
            #print "Configure channel", nCH, "ASIC", nASIC   
            Tx0_Config_CMD.write(int(Value)); 
            Tx1_Config_CMD.write(int(Value)); 
            hw.dispatch();
            time.sleep(wait);
  
    ################### send Resync CMD ####################
    Value = 1;
    print "send Resync CMD!"  
    Tx0_Resync_CMD.write(int(Value)); 
    Tx1_Resync_CMD.write(int(Value)); 
    hw.dispatch();
    #time.sleep(wait)

    
    # Reset TOFHIR Rx address pointer counter
    TxValue = 1  
    for link in range(nlinks):
#        resetRxAddressCnts[link].write(1); 
#        hw.dispatch();
        resetRxAddressCnts[link].write(1); 
#        hw.dispatch();
    hw.dispatch();
   
    print "################################################"
    print "End!"  
    print "################################################"
