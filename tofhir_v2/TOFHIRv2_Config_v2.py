#!/bin/env python

import uhal
import time
import json
from collections import OrderedDict

import argparse

parser =  argparse.ArgumentParser(description='TOFHIRv2 configuration')
parser.add_argument('-r', '--register', dest="RegNumber", type=str, required=True, help="Register number")
parser.add_argument('-f', '--configFile', dest="configName", type=str, default="config_tofhir_v2.json", help="Json config file")
parser.add_argument('-res', '--globreset', dest="GlobReset", type=int, default=1, help="Global RESET")

opt = parser.parse_args()

if __name__ == '__main__':
    
    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";    
    deviceId = "KCU105real";
 
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    Init_Lnk0_modules   = hw.getNode("Init_TOFHIR_EC_IC_modules")
    Init_Lnk1_modules   = hw.getNode("Init_TOFHIR_EC_IC_modules1")

    statusLink0       = hw.getNode("LINK0_status")   
    statusLink1       = hw.getNode("LINK1_status")   
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
   
    MEM = []
    MEM_decode = []

    ############### Open JSON file for reading configuration ###################
    packet = opt.RegNumber
    word8_str = "0x80"
    word7_str = ""
    word6_str = ""
    word5_str = ""
    word4_str = ""
    word3_str = ""
    word2_str = ""
    word1_str = ""
    word0_str = ""
    with open(opt.configName) as jsonFile:
        data = json.load(jsonFile, object_pairs_hook=OrderedDict)
        #resync
        TxVTimeTagCnt = data["Resync"][0]["Reset only time tag counter"]
        TxVGoreLogic = data["Resync"][1]["Reset core logic"]
        TxVGlob = data["Resync"][2]["Global reset"]
        #registers
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
        for key2, value2 in data[packet][2].iteritems():
            word6_str += str(value2)
        for key3, value3 in data[packet][3].iteritems():
            word5_str += str(value3)
        for key4, value4 in data[packet][4].iteritems():
            word4_str += str(value4)
        for key5, value5 in data[packet][5].iteritems():
            word3_str += str(value5)
        for key6, value6 in data[packet][6].iteritems():
            word2_str += str(value6)
        for key7, value7 in data[packet][7].iteritems():
            word1_str += str(value7)
        for key8, value8 in data[packet][8].iteritems():
            word0_str += str(value8)


    # set Trigger frequency  - external simulation trigger
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
    if opt.GlobReset == 1:
        # set duration Resync signal 
    	Tx0_Resync_Freq.write(int(TxVGlob));
    	hw.dispatch();
    	Tx1_Resync_Freq.write(int(TxVGlob)); 
    	hw.dispatch();
    	Value = 1;
    	Tx0_Resync_CMD.write(int(Value)); # send Resync signal
    	hw.dispatch(); 
    	Tx1_Resync_CMD.write(int(Value)); 
    	hw.dispatch();
    	print "send Global Reset to all ASIC!" 
    	time.sleep(1)

    ############### Send configuration to ASICs to set all ASICs to 320Mbps mode ##########
    ############################## channel 0 ########################
    print "Send  configuration:"
    ##----------- set Tx0RAM ------------
    Nword = 10 # data payload = 280 bits = 9x32bits words (8,75, 9 words without 1 LSB byte)
    cfgValue = []
    for x in range(Nword): 
         cfgValue.append(0x0);
    # set configuration data
    cfgValue[0] = int(word0_str, base=16)
    cfgValue[1] = int(word1_str, base=16)
    cfgValue[2] = int(word2_str, base=16)
    cfgValue[3] = int(word3_str, base=16)
    cfgValue[4] = int(word4_str, base=16)
    cfgValue[5] = int(word5_str, base=16)
    cfgValue[6] = int(word6_str, base=16)
    cfgValue[7] = int(word7_str, base=16)    #3,4-data 1,0-not used   
    cfgValue[8] = int(word8_str, base=16)    #3-80 2-chip ID 1-opcode+Register address 0-Register length  # after magic number data
    tx0RAM.writeBlock(cfgValue); 
    hw.dispatch();
    tx1RAM.writeBlock(cfgValue); 
    hw.dispatch();

    ##----------- Check Tx0RAM ------------
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
    Tx0_Resync_Freq.write(int(TxVGoreLogic));
    hw.dispatch();
    Tx1_Resync_Freq.write(int(TxVGoreLogic)); 
    hw.dispatch();
    Value = 1;
    Tx0_Resync_CMD.write(int(Value)); # send Resync signal
    hw.dispatch(); 
    Tx1_Resync_CMD.write(int(Value)); 
    hw.dispatch();
    print "send core logic RESET" 

