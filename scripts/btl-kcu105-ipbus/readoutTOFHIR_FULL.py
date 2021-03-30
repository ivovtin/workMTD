#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
import datetime

def readeport(ChID, nWord, TOFHIR_RxBRAMch, file):
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
           file.write( str("{:3d};{:3d};{:3d};".format(LinkID, ChID, xx)+ hex(FrameData) + "\n"))
           xx = xx + 1
           FrameData = 0
       else : 
           FrameData = FrameData + ((MEM[x]&0xFFFFFFFF)<<yy*32)
           yy = yy + 1 


def readTimeTag(ChID, nWord, TOFHIR_RxTTch, file):
    TTData = 0
    MEM = []
    xx = 1
    yy = 0
    MEM=TOFHIR_RxTTch.readBlock(int(nWord*2));
    hw.dispatch();
    for x in range(int(nWord-1)): 
       TTData = (MEM[x*2]&0xFFFFFFFF)+((MEM[x*2+1]&0xFFFFFFFF)<<32)
       file.write( str("{:3d};{:3d};{:3d};".format(LinkID, ChID, xx)+ hex(TTData) + "\n"))
      
def readeportwttag(ChID, nWord, tnWord, TOFHIR_RxBRAMch, TOFHIR_RxTTch, file):
    FrameData = 0
    portMEM = []
    TTData = 0
    tMEM = []
    tTag = []
    xx = 1
    yy = 0
    portMEM=TOFHIR_RxBRAMch.readBlock(int(nWord));
    hw.dispatch();
    tMEM=TOFHIR_RxTTch.readBlock(int(tnWord*2));
    hw.dispatch();

    for t in range(int(tnWord)): 
       TTData = (tMEM[t*2]&0xFFFFFFFF)+((tMEM[t*2+1]&0xFFFFFFFF)<<32)
       tTag.append(hex(TTData))


    # print result
    for x in range(int(nWord)): 
       if yy == 3:
 	   FrameData = FrameData + ((portMEM[x]&0xFFFFFFFF)<<yy*32) 
           yy = 0
           file.write( str("{:3d};{:3d};{:3d};".format(LinkID, ChID, xx)+tTag[xx-1]+";"+hex(FrameData) + "\n"))
           xx = xx + 1
           FrameData = 0
       else : 
           FrameData = FrameData + ((portMEM[x]&0xFFFFFFFF)<<yy*32)
           yy = yy + 1 

 
if __name__ == '__main__':


    date_time_obj = datetime.datetime.now()
    # ouput file    
    nameFile = "datafile"+str(date_time_obj.date())+"_"+str(date_time_obj.hour)+str(date_time_obj.minute)+str(date_time_obj.second)+".txt"
    print("File name: " , nameFile)
    file = open("./data/"+nameFile,"w") 
    file.write( "Link ID; Channel ID; Line; time tag; Data \n")

    # PART 1: Argument parsing
    if len(sys.argv) != 1:
        print("Incorrect usage!")
        print("usage: read_write_single_register.py only")
        sys.exit(1)
   
    uhal.disableLogging()

    connectionFilePath = "Real_connections_TOFHIR_FULL.xml";
    deviceId = "KCU105real";
       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    Init_TOFHIR_EC_IC_moduls   = hw.getNode("A2")
    TOFHIR_status       = hw.getNode("TOFHIR_status")   #hw.getNode("A3")

    TOFHIR_Tx_RAM       = hw.getNode("TxBRAM")
    neport = 21 #32 in total right now we are reading 15 to 21
    TOFHIR_RxBRAM = []
    for id in range(15):
        TOFHIR_RxBRAM.append( 0)

    for id in range(15,neport):
        TOFHIR_RxBRAM.append( hw.getNode("TOFHIR_RxBRAM_CH"+str(id)))

    TOFHIR_RxTT = []
    for id in range(15):
        TOFHIR_RxTT.append( 0)

    for id in range(15,neport):
        TOFHIR_RxTT.append( hw.getNode("TOFHIR_RxTT_CH"+str(id)))

    TOFHIR_Tx_Trig_Freq = hw.getNode("TOFHIR_Tx_Trig_Freq")
    TOFHIR_Tx_Resync_Freq = hw.getNode("TOFHIR_Tx_Resync_Freq")

    TOFHIR_Resync_CMD 	= hw.getNode("TOFHIR_Resync_CMD")
    TOFHIR_Trigger_CMD 	= hw.getNode("TOFHIR_Trigger_CMD")
    TOFHIR_Config_CMD 	= hw.getNode("TOFHIR_Config_CMD")

    TOFHIR_debug_Reg 	= hw.getNode("TOFHIR_debug_Reg")
    TOFHIR_debug_RAM 	= hw.getNode("TOFHIR_debug_RAM")
    TOFHIR_debug_RAM_start 	= hw.getNode("TOFHIR_debug_RAM_start")

    TOFHIR_RxRAM_status = hw.getNode("TOFHIR_RxRAM_status")
    TOFHIR_rst_Rx_addr_cnt = hw.getNode("TOFHIR_rst_Rx_addr_cnt")

  
    wait = 1
    nWord = 8
    Value = []
    MEM = []
    MEM_decode = []
    wait = 1



    # set Resync frequency 
    TxValue = 40000 #25ns*40000=1000Hz
    TOFHIR_Tx_Resync_Freq.write(int(TxValue)); 
    hw.dispatch();
    # set Trigger frequency
    TxValue = 0 #25ns*40000=1000Hz
    TOFHIR_Tx_Trig_Freq.write(int(TxValue)); 
    hw.dispatch();
    
    # Reset TOFHIR Rx address pointer counter
    #TxValue = 1  
    #TOFHIR_rst_Rx_addr_cnt.write(int(TxValue)); 
    #hw.dispatch();

    
    ################### send Resync CMD ####################
    #Value = 1;
    #print("send Resync CMD!")
    #TOFHIR_Resync_CMD.write(int(Value)); 
    #hw.dispatch();
    #time.sleep(wait)
    
    ################### send Trigger CMD ####################
    #print "************************************************"
    #Value = 1;
    #print "send Trigger CMD!"  
    #TOFHIR_Trigger_CMD.write(int(Value)); 
    #hw.dispatch();

    #Value = 0xA
    #RxBRAM.write(int(Value)); 
    #hw.dispatch();
    #Value = RxBRAM.read();
    #hw.dispatch();
    #print hex(Value)

    nCycRead = 3
    nCycle = 0
    TimeOut= 0
    LinkID = 1
    nWord = 1024 #512  1024   
    TTnWord = 256 #nWord / 4 
    RAM_status = 0
    CH_Read = []
    for id in range(0,32):
        CH_Read.append(id)
    while True:
        #time.sleep(0.01)
    	RAM_status = TOFHIR_RxRAM_status.read(); # bits: 20,18,17,16,15    << Logic 1 - RxRAM is full
	hw.dispatch();                           # CH  : 20,18,17,16,15
        #print bin(RAM_status)
        if (RAM_status>>9 & 0x1) == 1:
        	print("----------- Read Rx answer e-port 15------------")
                readeportwttag(9, nWord, TTnWord, TOFHIR_RxBRAM[9], TOFHIR_RxTT[9],file)
                CH_Read[0] = 1
        RAM_status = TOFHIR_RxRAM_status.read(); # bits: 20,18,17,16,15    << Logic 1 - RxRAM is full
	hw.dispatch();
	if ((RAM_status >> 9) & 0x1) == 1:
		print("----------- Read Rx answer e-port 16------------")
                readeportwttag(16, nWord, TTnWord, TOFHIR_RxBRAM[16], TOFHIR_RxTT[16],file)
		CH_Read[1] = 1
        RAM_status = TOFHIR_RxRAM_status.read(); # bits: 20,18,17,16,15    << Logic 1 - RxRAM is full
	hw.dispatch();
	if ((RAM_status >> 17) & 0x1) == 1:
		print("----------- Read Rx answer e-port 17------------")
                readeportwttag(17, nWord, TTnWord, TOFHIR_RxBRAM[17], TOFHIR_RxTT[17],file)
		CH_Read[2] = 1
        RAM_status = TOFHIR_RxRAM_status.read(); # bits: 20,18,17,16,15    << Logic 1 - RxRAM is full
	hw.dispatch();
	if ((RAM_status >> 18) & 0x1) == 1:
		print("----------- Read Rx answer e-port 18------------")
                readeportwttag(18, nWord, TTnWord, TOFHIR_RxBRAM[18], TOFHIR_RxTT[18],file)
		CH_Read[3] = 1
        RAM_status = TOFHIR_RxRAM_status.read(); # bits: 20,18,17,16,15    << Logic 1 - RxRAM is full
	hw.dispatch();
        if (RAM_status>>19 & 0x1) == 1:
        	print("----------- Read Rx answer e-port 15------------")
                readeportwttag(19, nWord, TTnWord, TOFHIR_RxBRAM[19], TOFHIR_RxTT[19],file)
                CH_Read[0] = 1
        RAM_status = TOFHIR_RxRAM_status.read(); # bits: 20,18,17,16,15    << Logic 1 - RxRAM is full
	hw.dispatch();

	if ((RAM_status >> 20) & 0x1) == 1:
		print("----------- Read Rx answer e-port 20------------")
                readeportwttag(20, nWord, TTnWord, TOFHIR_RxBRAM[20], TOFHIR_RxTT[20],file)
		CH_Read[4] = 1
        # readout cycle end: if all ch read then end
        if CH_Read[0] == 1 or CH_Read[1] == 1 or CH_Read[2] == 1 or CH_Read[3] == 1 or CH_Read[4] == 1:
		nCycle = nCycle + 1;
		CH_Read = [0,0,0,0,0,0]
                for id in range(15):
                    TOFHIR_RxBRAM.append( 0)

                for id in range(15,neport):
                    TOFHIR_RxBRAM.append( hw.getNode("TOFHIR_RxBRAM_CH"+str(id)))

                #		break;

                TOFHIR_rst_Rx_addr_cnt.write(1); 
                hw.dispatch();
                TOFHIR_rst_Rx_addr_cnt.write(0); 
                hw.dispatch();

		TimeOut = 0
		if nCycle == nCycRead:
			break;
	# exit by timeout
        if TimeOut == 10000:
		print bin(RAM_status)
		break;
        TimeOut = TimeOut + 1 

    print("")
    print("frequency frames with recognized headers")
    Nword = 24
    FREQ = []
    FREQ=TOFHIR_status.readBlock(int(Nword));
    hw.dispatch();
    # print result
    for x in range(int(Nword)): 
      print "e-port",x, " ", (FREQ[x]), "Hz"


   
    print("************************************************")
    print("End!"  )
    print("################################################")

