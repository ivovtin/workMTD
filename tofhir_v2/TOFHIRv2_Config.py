#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
#import cfgTOFHIR as cfgTF
#import numpy as np
import json
from collections import OrderedDict

if __name__ == '__main__':
    
    #np.set_printoptions(formatter={'int':hex})
    
    # PART 1: Argument parsing
    if len(sys.argv) <2:
        print "Incorrect usage!"
        print "usage: TOFHIRv2_Config.py Register_number"
        sys.exit(1)

    if int(sys.argv[1]) < 0 or int(sys.argv[1]) > 34:
        sys.exit("Bad number for register. Please use [0 .. 34]")

    uhal.disableLogging()

    #connectionFilePath = "/home/software/mtd-daq/btl-kcu105-ipbus/Real_connections_TOFHIR_FULL.xml";
    connectionFilePath = "Real_connections.xml";    
    deviceId = "KCU105real";

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);



    Init_Lnk0_modules   = hw.getNode("Init_TOFHIR_EC_IC_modules")
    Init_Lnk1_modules   = hw.getNode("Init_TOFHIR_EC_IC_modules1")

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

   
    wait = 0.01
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
    time.sleep(1)

    ############### Opening JSON file ###################
    reg = int(sys.argv[1])
    packet = "Reg" + str(reg)
    word8_str = "0x80"
    word7_str = ""
    with open("config_tofhir_v2.json") as jsonFile:
        data = json.load(jsonFile, object_pairs_hook=OrderedDict)
        print(data[packet])
        for key0, value0 in data[packet][0].iteritems():
            if int(data[packet][0]['R/W mode'])  == 1 and key0 == "Register address":
                regx = int(value0, base=16)
                ##replace bit 
                regx |= 1 << 7
                value0 = hex(regx).replace("0x","")
            if key0 != "R/W mode":
                word8_str += str(value0)
        for key1, value1 in data[packet][1].iteritems():
            word7_str += str(value1)

    word8 = int(word8_str, base=16)
    word7 = int(word7_str, base=16)
    print hex(word8)
    print hex(word7)

    ############### Send configuration to ASICs to set all ASICs to 320Mbps mode ##########
    ############################## channel 0 ########################
    print "Send  configuration:"
    print "----------- set Tx0RAM ------------"
    Nword = 10 # data payload = 280 bits = 9x32bits words (8,75, 9 words without 1 LSB byte)
    cfgValue = []
    for x in range(Nword): 
         cfgValue.append(0x0);
    #for x in range(Nword):
    #   cfgValue[x] = x+10;
    # set configuration data
    #cfgValue[0] = 
    #cfgValue[1] =
    #cfgValue[2] =
    #cfgValue[3] =
    #cfgValue[4] = 
    #cfgValue[5] =
    #cfgValue[6] =
    ############################## channel 1 ########################
    ##cfgValue[7] = 0x7FD40000    #3,4-data 1,0-not used   FFD4
    ##cfgValue[7] = 0x7FC00000    #3,4-data 1,0-not used   
    cfgValue[7] = word7    #3,4-data 1,0-not used   
    ##cfgValue[8] = 0x8001A10E    #3-80 2-chip ID 1-opcode+Register address 0-Register length  # after magic number data
    cfgValue[8] = word8    #3-80 2-chip ID 1-opcode+Register address 0-Register length  # after magic number data
    tx0RAM.writeBlock(cfgValue); 
    hw.dispatch();
    tx1RAM.writeBlock(cfgValue); 
    hw.dispatch();

    print "----------- Check Tx0RAM ------------"
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
    time.sleep(1);
  
    # core logic RESET 
    # set duration Resync signal 
    TxValue = 6 # core logic RESET
    Tx0_Resync_Freq.write(int(TxValue));
    hw.dispatch();
    Tx1_Resync_Freq.write(int(TxValue)); 
    hw.dispatch();
    Value = 1;
    Tx0_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch(); 
    Tx1_Resync_CMD.write(int(Value)); 
    hw.dispatch();
    print "send core logic RESET to all ASIC!" 
    #time.sleep(wait)


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
    time.sleep(1)
   
    print "################################################"
    print "End!"  
    print "################################################"
