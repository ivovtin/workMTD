#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
#import cfgTOFHIR as cfgTF
#import numpy as np

if __name__ == '__main__':
    
    #np.set_printoptions(formatter={'int':hex})
    
    # PART 1: Argument parsing
    if len(sys.argv) != 1:
        print "Incorrect usage!"
        print "usage: read_write_single_register.py only"
        sys.exit(1)
   
    uhal.disableLogging()

    #connectionFilePath = "/home/software/mtd-daq/btl-kcu105-ipbus/Real_connections_TOFHIR_FULL.xml";
    connectionFilePath = "Real_connections.xml";    
    deviceId = "KCU105real";

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);



    Init_Lnk0_modules   = hw.getNode("Init_TOFHIR_EC_IC_modules")
    Init_Lnk1_modules   = hw.getNode("Init_TOFHIR_EC_IC_modules1")

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

   
    wait = 1
    Nword = 8
    MEM = []
    MEM_decode = []



    # set Trigger frequency
    TxValue = 0 #25ns*40000=1000Hz
    Tx0_Trig_Freq.write(int(TxValue));
    hw.dispatch();
    Tx1_Trig_Freq.write(int(TxValue)); 
    hw.dispatch();


    # initialize TOFHIR, IC and EC moduls
    TxValue = 1  
    Init_Lnk0_modules.write(int(TxValue)); 
    hw.dispatch();
    Init_Lnk1_modules.write(int(TxValue)); 
    hw.dispatch();
    
    ############### Send Global RESET ##########
    # set duration Resync signal 
    TxValue = 16 # Global reset
    Tx0_Resync_Freq.write(int(TxValue));
    hw.dispatch();
    Tx1_Resync_Freq.write(int(TxValue)); 
    hw.dispatch();
    Value = 1;
    Tx0_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch(); 
    Tx1_Resync_CMD.write(int(Value)); 
    hw.dispatch();
    print "send Global Reset to all ASIC!" 
    time.sleep(wait)

    ############### Send configuration to all ASICs #########################
    # ASIC SET MODE COMMAND: ..., K28.5, K28.1, 0x2F, 0xAF, 0xC1, 
    # 0x80, 0x01, 0xA1, 0x0D,  [8] 
    # 0xFF, 0xE0, 0x00, 0x00,  [7] 
    # 0x00, 0x00, 0x00, 0x00,  [6]
    # 0x00, 0x00, 0x00, 0x00,  [5] 
    # 0x00, 0x00, 0x00, 0x00,  [4] 
    # 0x00, 0x00, 0x00, 0x00,  [3] 
    # 0x00, 0x00, 0x00, 0x00,  [2] 
    # 0x00, 0x00, 0x00, 0x00,  [1] 
    # 0x00, 0x00, 0x00, 0x00,  [0] 
    # K28.5, ...
    # ASIC GLOBAL COMMAND: ..., K28.5, K28.1, 0x2F, 0xAF, 0xC1, 
    # 0x80, 0x01, 0xA0, 0xE1,  [8]
    # 0x83, 0x68, 0x00, 0x00,  [7] 
    # 0x0B, 0x10, 0x00, 0x3C,  [6]
    # 0xC1, 0x83, 0x06, 0x0C,  [5] 
    # 0x18, 0x30, 0x60, 0x80,  [4] 
    # 0x01, 0x90, 0x20, 0x40,  [3] 
    # 0x00, 0x00, 0x0C, 0x00,  [2] 
    # 0x00, 0x00, 0x00, 0x70,  [1] 
    # 0xC0, 0x00, 0x00, 0x00,  [0] 
    # K28.5, ...
    # ASIC CHANNEL COMMAND: ..., K28.5, K28.1, 0x2F, 0xAF, 0xC1, 
    # 0x80, 0x00, 0x80, 0x9A,  [8] 
    # 0x00, 0x2A, 0xDB, 0x31,  [7] 
    # 0xFF, 0xFF, 0xB0, 0xC1,  [6] 
    # 0x4D, 0x80, 0x03, 0x72,  [5] 
    # 0x47, 0x4F, 0x00, 0x04,  [4] 
    # 0x00, 0x00, 0x00, 0x40,  [3] 
    # 0x00, 0x00, 0x00, 0x00,  [2] 
    # 0x00, 0x00, 0x00, 0x00,  [1] 
    # 0x00, 0x00, 0x00, 0x00,  [0] 
    # K28.5, ...

    print "Send  configuration:"
    Nword = 10 # data payload = 280 bits = 9x32bits words (8,75, 9 words without 1 LSB byte)
    cfgValue = []
    for x in range(Nword): 
         cfgValue.append(0x0);

    # set configuration data
    ############################## Set mode 320Mbps, normal data ########################
    # ASIC SET MODE COMMAND: ..., K28.5, K28.1, 0x2F, 0xAF, 0xC1, 
    # 0x80, 0x01, 0xA1, 0x0D,  [8] 
    # 0xFF, 0xE0, 0x00, 0x00,  [7] 
    # 0x00, 0x00, 0x00, 0x00,  [6]
    # 0x00, 0x00, 0x00, 0x00,  [5] 
    # 0x00, 0x00, 0x00, 0x00,  [4] 
    # 0x00, 0x00, 0x00, 0x00,  [3] 
    # 0x00, 0x00, 0x00, 0x00,  [2] 
    # 0x00, 0x00, 0x00, 0x00,  [1] 
    # 0x00, 0x00, 0x00, 0x00,  [0] 
    # K28.5, ...
    cfgValue[0] = 0x00000000 
    cfgValue[1] = 0x00000000
    cfgValue[2] = 0x00000000
    cfgValue[3] = 0x00000000
    cfgValue[4] = 0x00000000 
    cfgValue[5] = 0x00000000
    cfgValue[6] = 0x00000000
    cfgValue[7] = 0xFFE00000    #3,4-data 1,0-data   			#FFD4
    cfgValue[8] = 0x8001A10D    #3-80 2-chip ID 1-opcode+Register address 0-Register length  # after magic number data
    tx0RAM.writeBlock(cfgValue); 
    hw.dispatch();
    tx1RAM.writeBlock(cfgValue); 
    hw.dispatch();

    print "----------- Check configuration mode ------------"
    MEMs = []
    MEMs=tx0RAM.readBlock(int(Nword));
    hw.dispatch();
    # print result
    for x in range(int(Nword-1)): 
       print "addr =", x , "data =", hex(MEMs[x])
    
    Value = 1;
    print "send Config CMD"  
    Tx0_Config_CMD.write(int(Value)); 
    hw.dispatch();
    Tx1_Config_CMD.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait);
  
    # core logic RESET 
    TxValue = 6 # core logic RESET duration
    Tx0_Resync_Freq.write(int(TxValue));  # set duration Resync signal 
    hw.dispatch();
    Tx1_Resync_Freq.write(int(TxValue));  # set duration Resync signal 
    hw.dispatch();
    Value = 1;
    Tx0_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch(); 
    Tx1_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch();
    print "send core logic RESET" 
    time.sleep(wait);

    #***************************************************************************************************
    # ----------------------------------- ASIC GLOBAL COMMAND ---------------------------------
    # ASIC GLOBAL COMMAND: ..., K28.5, K28.1, 0x2F, 0xAF, 0xC1, 
    # 0x80, 0x01, 0xA0, 0xE1,  [8]
    # 0x83, 0x68, 0x00, 0x00,  [7] 
    # 0x0B, 0x10, 0x00, 0x3C,  [6]
    # 0xC1, 0x83, 0x06, 0x0C,  [5] 
    # 0x18, 0x30, 0x60, 0x80,  [4] 
    # 0x01, 0x90, 0x20, 0x40,  [3] 
    # 0x00, 0x00, 0x0C, 0x00,  [2] 
    # 0x00, 0x00, 0x00, 0x70,  [1] 
    # 0xC0, 0x00, 0x00, 0x00,  [0] 
    # K28.5, ...
    cfgValue[0] = 0xC0000000
    cfgValue[1] = 0x00000070
    cfgValue[2] = 0x00000C00
    cfgValue[3] = 0x01902000   #<<<  01902040
    cfgValue[4] = 0x18306080
    cfgValue[5] = 0xC183060C 
    cfgValue[6] = 0x0B10003C 
    cfgValue[7] = 0x83680000    #3,4-data 1,0-data   
    cfgValue[8] = 0x8001A0E1    #3-80, 2-chip ID, 1-opcode+Register address, 0-Register length  
    tx0RAM.writeBlock(cfgValue); 
    hw.dispatch();
    tx1RAM.writeBlock(cfgValue); 
    hw.dispatch();

    print "----------- Check ASIC GLOBAL COMMAND ------------"
    MEMs = []
    MEMs=tx0RAM.readBlock(int(Nword));
    hw.dispatch();
    # print result
    for x in range(int(Nword-1)): 
       print "addr =", x , "data =", hex(MEMs[x])

    Value = 1;
    print "send Config CMD"  
    Tx0_Config_CMD.write(int(Value)); 
    hw.dispatch();
    Tx1_Config_CMD.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait);

    # core logic RESET 
    TxValue = 6 # core logic RESET duration
    Tx0_Resync_Freq.write(int(TxValue));  # set duration Resync signal 
    hw.dispatch();
    Tx1_Resync_Freq.write(int(TxValue));  # set duration Resync signal 
    hw.dispatch();
    Value = 1;
    Tx0_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch(); 
    Tx1_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch();
    print "send core logic RESET" 
    time.sleep(wait);

    # ----------------------------------- ASIC CHANNEL COMMAND ---------------------------------
    # ASIC CHANNEL COMMAND: ..., K28.5, K28.1, 0x2F, 0xAF, 0xC1, 
    # 0x80, 0x01, 0x80, 0x9A,  [8] 
    # 0x00, 0x2A, 0xDB, 0x31,  [7] 
    # 0xFF, 0xFF, 0xB0, 0xC1,  [6] 
    # 0x4D, 0x80, 0x03, 0x72,  [5] 
    # 0x47, 0x4F, 0x00, 0x04,  [4] 
    # 0x00, 0x00, 0x00, 0x40,  [3] 
    # 0x00, 0x00, 0x00, 0x00,  [2] 
    # 0x00, 0x00, 0x00, 0x00,  [1] 
    # 0x00, 0x00, 0x00, 0x00,  [0] 
    # K28.5, ...
    cfgValue[0] = 0x00000000
    cfgValue[1] = 0x00000000
    cfgValue[2] = 0x00000000
    cfgValue[3] = 0x00000040
    cfgValue[4] = 0x474F0004
    cfgValue[5] = 0x4D800372 
    cfgValue[6] = 0xFFFFB0C1 
    cfgValue[7] = 0x002ADB31     #3,4-data 1,0-data   
    cfgValue[8] = 0x8001809A     #3-80, 2-chip ID, 1-opcode+Register address, 0-Register length  
    tx0RAM.writeBlock(cfgValue); 
    hw.dispatch();
    tx1RAM.writeBlock(cfgValue); 
    hw.dispatch();

    print "----------- Check ASIC CHANNEL COMMAND ------------"
    MEMs = []
    MEMs=tx0RAM.readBlock(int(Nword));
    hw.dispatch();
    # print result
    for x in range(int(Nword-1)): 
       print "addr =", x , "data =", hex(MEMs[x])

    Value = 1;
    print "send Config CMD"  
    Tx0_Config_CMD.write(int(Value)); 
    hw.dispatch();
    Tx1_Config_CMD.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait);

    # core logic RESET 
    TxValue = 6 # core logic RESET duration
    Tx0_Resync_Freq.write(int(TxValue));  # set duration Resync signal 
    hw.dispatch();
    Tx1_Resync_Freq.write(int(TxValue));  # set duration Resync signal 
    hw.dispatch();
    Value = 1;
    Tx0_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch(); 
    Tx1_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch();
    print "send core logic RESET" 
    time.sleep(wait);
    #***************************************************************************************************


    ############### Send Global RESET ##########
    # set duration Resync signal 
    #TxValue = 16 # Global reset
    #Tx0_Resync_Freq.write(int(TxValue));
    #hw.dispatch();
    #Tx1_Resync_Freq.write(int(TxValue)); 
    #hw.dispatch();
    #Value = 1;
    #Tx0_Resync_CMD.write(int(Value)); # send Resync signal
    #hw.dispatch(); 
    #Tx1_Resync_CMD.write(int(Value)); 
    #hw.dispatch();
    #print "send Global Reset to all ASIC!" 
    #time.sleep(1)
   
    print "################################################"
    print "End!"  
    print "################################################"
