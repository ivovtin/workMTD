#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
import cfgTOFHIR as cfgTF
import numpy as np

if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) != 1:
        print "Incorrect usage!"
        print "usage: read_write_single_register.py only"
        sys.exit(1)
   
    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    Init_TOFHIR_EC_IC_moduls   = hw.getNode("A2")

    TOFHIR_Tx_RAM       = hw.getNode("TxBRAM")
    TOFHIR_Rx_RAM       = hw.getNode("RxBRAM")

    TOFHIR_Tx_Trig_Freq = hw.getNode("TOFHIR_Tx_Trig_Freq")
    TOFHIR_Tx_Resync_Freq = hw.getNode("TOFHIR_Tx_Resync_Freq")

    TOFHIR_Resync_CMD 	= hw.getNode("TOFHIR_Resync_CMD")
    TOFHIR_Trigger_CMD 	= hw.getNode("TOFHIR_Trigger_CMD")
    TOFHIR_Config_CMD 	= hw.getNode("TOFHIR_Config_CMD")

    TOFHIR_debug_Reg 	= hw.getNode("TOFHIR_debug_Reg")
    TOFHIR_debug_RAM 	= hw.getNode("TOFHIR_debug_RAM")
    TOFHIR_debug_RAM_start 	= hw.getNode("TOFHIR_debug_RAM_start")

    TOFHIR_rst_Rx_addr_cnt = hw.getNode("TOFHIR_rst_Rx_addr_cnt")
   
    wait = 0.01
    Nword = 8
    MEM = []
    MEM_decode = []


    # set Resync frequency 
    TxValue = 0 #25ns*40000=1000Hz
    TOFHIR_Tx_Resync_Freq.write(int(TxValue)); 
    hw.dispatch();
    # set Trigger frequency
    TxValue = 0 #25ns*40000=1000Hz
    TOFHIR_Tx_Trig_Freq.write(int(TxValue)); 
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
    TOFHIR_Tx_RAM.writeBlock(cfgValue); 
    hw.dispatch();

    Value = 1;
    print "send Reset to all ASIC!"  
    TOFHIR_Config_CMD.write(int(Value)); 
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
    np.set_printoptions(formatter={'int':hex})
    print "Send global configuration:"
    for nASIC in range(6):
        # 320Mbps
        cfgValue=list(cfgTF.globalc['config'])
        
        #ChValue = ((0x4C<<24)&0xFF000000)+((0x5C<<16)&0x00FF0000)+((00<<8)&0x0000FF00)+((nASIC)&0xFF)
    	#cfgValue = []
    	#cfgValue.append(ChValue); 
        
        for item in cfgValue:
            print("0x123 ", end = '')
        print("\n")
        #print(np.array(cfgValue))
        
    	#TOFHIR_Tx_RAM.writeBlock(cfgValue); 
    	#hw.dispatch();
    
    	#print "send Global config CMD to chip", nASIC  
    	#TOFHIR_Config_CMD.write(int(Value)); 
    	#hw.dispatch();
    	#time.sleep(wait);

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
   	for nCH in range(16): 
            # set channel ID and chip ID (0x72 off/ 0x76 on)
            #ChValue = ((0x59<<24)&0xFF000000)+((0x72<<16)&0x00FF0000)+((nCH<<8)&0x0000FF00)+((0x20+nASIC)&0xFF)
            ChValue = ((0x59<<24)&0xFF000000)+((0x76<<16)&0x00FF0000)+((nCH<<8)&0x0000FF00)+((0x20+nASIC)&0xFF)
            cfgValue = [] 
            cfgValue.append(ChValue); 
            cfgValue=cfgValue+list(cfgTF.channelc['config'])
            print(np.array(cfgValue))
            TOFHIR_Tx_RAM.writeBlock(cfgValue); 
            hw.dispatch();
           
            print "Configure channel", nCH, "ASIC", nASIC   
            TOFHIR_Config_CMD.write(int(Value)); 
            hw.dispatch();
            time.sleep(wait);
  
    ################### send Resync CMD ####################
    Value = 1;
    print "send Resync CMD!"  
    TOFHIR_Resync_CMD.write(int(Value)); 
    hw.dispatch();
    #time.sleep(wait)

    
    # Reset TOFHIR Rx address pointer counter
    TxValue = 1  
    TOFHIR_rst_Rx_addr_cnt.write(int(TxValue)); 
    hw.dispatch();
   
    print "************************************************"
    print "End!"  
    print "################################################"


