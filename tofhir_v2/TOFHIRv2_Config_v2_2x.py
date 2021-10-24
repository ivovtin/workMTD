#!/bin/env python

import uhal
import time
import json
from collections import OrderedDict
import sys
import argparse

parser =  argparse.ArgumentParser(description='TOFHIRv2 configuration')
parser.add_argument('-link', '--link', dest="linkN", type=int, default=0, help="Link number")
parser.add_argument('-reg', '--register', dest="RegNumber", type=str, help="Register number")
parser.add_argument('-f', '--configFile', dest="configName", type=str, default="config_tofhir_v2.json", help="Json config file")
parser.add_argument('-reset', '--reset', dest="Reset", type=int, default=-1, help="Chip reset")

opt = parser.parse_args()

if __name__ == '__main__':
    
    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";    
    deviceId = "KCU105real";
 
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    if opt.linkN<0 or opt.linkN>1:
	sys.exit("Bad number for link. Please use 0 or 1")
   
    Init_Lnk_modules = hw.getNode("Init_TOFHIR_EC_IC_modules"+str(opt.linkN))

    statusLink       = hw.getNode("LINK"+str(opt.linkN)+"_RHCnt_status")   
    statusLinks = []
    statusLinks.append(statusLink)

    txRAM            = hw.getNode("Tx"+str(opt.linkN)+"BRAM")
    txRAMs = []
    txRAMs.append(txRAM)

    rxRAMs = [[],[]]
    neports = 28
    for eport in range(neports):
        rxRAMs[opt.linkN].append( hw.getNode("Rx"+str(opt.linkN)+"BRAM_CH"+str(eport)))
   
    resetTFHRbufAddrCnt = hw.getNode("Common_rst_TFHR_Frame_addr_cnt")
    resetTimeTagger     = hw.getNode("Common_rst_TFHR_TT_counter")

    Tx_Trig_Freq     = hw.getNode("Tx"+str(opt.linkN)+"_Trig_Freq")
    Tx_Resync_Freq   = hw.getNode("Tx"+str(opt.linkN)+"_Resync_Freq")
    Tx_Resync_CMD 	 = hw.getNode("Tx"+str(opt.linkN)+"_Resync_CMD")
    Tx_Trigger_CMD 	 = hw.getNode("Tx"+str(opt.linkN)+"_Trigger_CMD")
    Tx_Config_CMD 	 = hw.getNode("Tx"+str(opt.linkN)+"_Config_CMD")
    Tx_debug_Reg 	 = hw.getNode("Tx"+str(opt.linkN)+"_debug_Reg")
    Tx_debug_RAM 	 = hw.getNode("Tx"+str(opt.linkN)+"_debug_RAM")
    Tx_debug_RAM_start = hw.getNode("Tx"+str(opt.linkN)+"_debug_RAM_start")

    RxRAM_status       = hw.getNode("Rx"+str(opt.linkN)+"RAM_status")
    rxRAMs_status       = []
    rxRAMs_status.append(RxRAM_status)
   
    MEM = []

    #wait = 1.5
    wait = 1.0

    # set Trigger frequency  - external simulation trigger
    TxValue = 0 #25ns*40000=1000Hz
    Tx_Trig_Freq.write(int(TxValue));
    hw.dispatch();
    #time.sleep(wait)

    # initialize TOFHIR, IC and EC moduls
    TxValue = 1  
    Init_Lnk_modules.write(int(TxValue)); 
    hw.dispatch();
    time.sleep(wait)

    resetTimeTagger.write(1) # common reset TT counters
    hw.dispatch();
    time.sleep(wait) # wait 1 sec 
    resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
    hw.dispatch();
    time.sleep(wait) # wait 1 sec 
 
    ############### Send RESET ##########
    if opt.Reset >= 0:
        #set duration Resync signal 
    	Tx_Resync_Freq.write(int(opt.Reset));
    	hw.dispatch();
        #time.sleep(wait)
    	Value = 1;
    	Tx_Resync_CMD.write(int(Value)); # send Resync signal
    	hw.dispatch(); 
    	time.sleep(wait)
        sys.exit()
  
    portMEM = []
    nWord = 10
    #nWord = 4096
    eport = 13
    if opt.linkN == 1:
	eport = 19 
    for xx in range(nWord): # init data array
        portMEM.append(0x0)

    rxRAMs[opt.linkN][eport].writeBlock(portMEM);
    hw.dispatch();
    #time.sleep(wait)

    portMEM = rxRAMs[opt.linkN][eport].readBlock(int(nWord));
    hw.dispatch();
    print "Read rxRAM"
    for x in range(int(nWord)):
        print "addr =", x , "data =", hex(portMEM[x])
    time.sleep(wait)

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
        length = len(data)
        k=0
        for i in range(0, length):
        	for key, value in data[i].iteritems():
                	#print key
                	if key == packet:
                        	k=i
        #registers
        #print data[0][packet][0]
        for key0, value0 in data[k][packet][0].iteritems():
            if int(data[k][packet][0]['R/W mode'])  == 1 and key0 == "Register address":
                regx = int(value0, base=16)
                ##replace bit 
                regx |= 1 << 7
                value0 = hex(regx).replace("0x","")
            if key0 != "CC link" and key0 != "CC port" and key0 != "R/W mode":
                word8_str += str(value0)
        for key1, value1 in data[k][packet][1].iteritems():
            word7_str += str(value1)
        for key2, value2 in data[k][packet][2].iteritems():
            word6_str += str(value2)
        for key3, value3 in data[k][packet][3].iteritems():
            word5_str += str(value3)
        for key4, value4 in data[k][packet][4].iteritems():
            word4_str += str(value4)
        for key5, value5 in data[k][packet][5].iteritems():
            word3_str += str(value5)
        for key6, value6 in data[k][packet][6].iteritems():
            word2_str += str(value6)
        for key7, value7 in data[k][packet][7].iteritems():
            word1_str += str(value7)
        for key8, value8 in data[k][packet][8].iteritems():
            word0_str += str(value8)

    ############### Send configuration to ASICs  ##########
    print "Send  configuration:"
    ##----------- set Tx0RAM ------------
    Nword = 10 # data payload = 280 bits = 9x32bits words (8,75, 9 words without 1 LSB byte)
    cfgValue = []
    for x in range(Nword): 
         cfgValue.append(0x0);
    # set configuration data
    ###
    cfgValue[0] = int(word0_str, base=16)
    cfgValue[1] = int(word1_str, base=16)
    cfgValue[2] = int(word2_str, base=16)
    cfgValue[3] = int(word3_str, base=16)
    cfgValue[4] = int(word4_str, base=16)
    cfgValue[5] = int(word5_str, base=16)
    cfgValue[6] = int(word6_str, base=16)
    cfgValue[7] = int(word7_str, base=16)    #3,4-data 1,0-not used   
    cfgValue[8] = int(word8_str, base=16)    #3-80 2-chip ID 1-opcode+Register address 0-Register length  # after magic number data
    txRAM.writeBlock(cfgValue); 
    hw.dispatch();
    time.sleep(wait)

    ##----------- Check TxRAM ------------
    MEMs = []
    MEMs=txRAM.readBlock(int(Nword));
    hw.dispatch();
    time.sleep(wait)
    # print result
    for x in range(int(Nword-1)): 
       strName = "payload"
       if x==8:
          strName = "header"
       print "addr =", x , "data =", hex(MEMs[x]), " "+str(strName)

    #wait = 1.0
    Value = 1;
    print "send Config CMD"  
    Tx_Config_CMD.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait);

    resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
    hw.dispatch();
    time.sleep(wait)  

    portMEM = rxRAMs[opt.linkN][eport].readBlock(int(nWord));
    hw.dispatch();
    time.sleep(wait)
    print "Read rxRAM"
    packetReg34 = "" 
    for x in range(int(nWord)):
        print "addr =", x , "data =", hex(portMEM[x])
        if packet == "Chip_00010101_reg34":
           packetReg34 += format(portMEM[x], '032b')

    if packet == "Chip_00010101_reg34":
       out = open("/tmp/binaryPacket.txt", 'w')
       out.write(packetReg34)
       out.close()

