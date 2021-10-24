import random
import sys
import uhal
import time
import operator
import datetime
import copy
import json
from collections import OrderedDict
import os

class TOFHIR:

    def __init__(self, nlinks):
	# Creating the HwInterface
    	uhal.disableLogging()
    	connectionMgr = uhal.ConnectionManager("file://" + "configdir/Real_connections.xml");
    	self.hw = connectionMgr.getDevice("KCU105real");

    	self.resetTFHRbufAddrCnt = self.hw.getNode("Common_rst_TFHR_Frame_addr_cnt")
    	self.resetTimeTagger     = self.hw.getNode("Common_rst_TFHR_TT_counter")

    	self.resetTimeTagger.write(1) # common reset TT counters
    	self.hw.dispatch();
    	self.resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
    	self.hw.dispatch();

    	self.neports = 28
    	self.nlinks = nlinks
	self.wait = 1.5
    	self.statusLinks = []
    	self.txRAMs = []
    	self.rxRAMs_status = []
    	self.TxTrig_Freqs = []
    	self.TxResync_Freqs = []
	self.Tx_Resync_CMDs = []
	self.Tx_Config_CMDs = []
	self.Init_Lnks_modules = []
    	self.rxRAMs = [[],[]]
    	self.RxTTs  = [[],[]]
    	for link in range(self.nlinks):
            statusLink       = self.hw.getNode("LINK"+str(link)+"_RHCnt_status")
            self.statusLinks.append(statusLink)
            txRAM            = self.hw.getNode("Tx"+str(link)+"BRAM")
            self.txRAMs.append(txRAM)
            RxRAM_status     = self.hw.getNode("Rx"+str(link)+"RAM_status")
            self.rxRAMs_status.append(RxRAM_status)
            TxTrig_Freq      = self.hw.getNode("Tx"+str(link)+"_Trig_Freq")
            self.TxTrig_Freqs.append(TxTrig_Freq)
            TxResync_Freq    = self.hw.getNode("Tx"+str(link)+"_Resync_Freq")
            self.TxResync_Freqs.append(TxResync_Freq)
	    TxResync_CMD     = self.hw.getNode("Tx"+str(link)+"_Resync_CMD")
            self.Tx_Resync_CMDs.append(TxResync_CMD)
	    Tx_Config_CMD    = self.hw.getNode("Tx"+str(link)+"_Config_CMD")
	    self.Tx_Config_CMDs.append(Tx_Config_CMD)	
            # set Resync frequency 
            #TxValue = 4000000 #25ns*4000000=10Hz
            #self.TxResync_Freqs[link].write(int(TxValue));
            #self.hw.dispatch();
            # set Trigger frequency  
            TxValue = 0 #25ns*40000=1000Hz
            self.TxTrig_Freqs[link].write(int(TxValue));
            self.hw.dispatch();
	    Init_Lnk_modules = self.hw.getNode("Init_TOFHIR_EC_IC_modules"+str(link))
	    self.Init_Lnks_modules.append(Init_Lnk_modules)
	    # initialize TOFHIR, IC and EC moduls
    	    TxValue = 1
            self.Init_Lnks_modules[link].write(int(TxValue));
            self.hw.dispatch();
            time.sleep(self.wait)
            for eport in range(self.neports):
                self.rxRAMs[link].append( self.hw.getNode("Rx"+str(link)+"BRAM_CH"+str(eport)))
                self.RxTTs[link].append( self.hw.getNode("Rx"+str(link)+"TT_CH"+str(eport)))


    def chipReset(self, link, RESlen):
	self.resetTimeTagger.write(1) # common reset TT counters
        self.hw.dispatch();
        self.resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
        self.hw.dispatch();
        #set duration Resync signal 
        self.TxResync_Freqs[link].write(int(RESlen));
        self.hw.dispatch();
        #time.sleep(self.wait)
        Value = 1;
        self.Tx_Resync_CMDs[link].write(int(Value)); # send Resync signal
        self.hw.dispatch();
        time.sleep(self.wait)
	if RESlen <=3:
	   print("Reset only time tag counter")	
	elif RESlen >= 4 and RESlen <= 7: 
	   print("Reset core logic")
	else:
	   print("Global reset")


    def configReg(self, link, packet, configName):
	portMEM = []
    	nWord = 10
    	#nWord = 4096
    	eport = 13
    	if link == 1:
            eport = 19
    	for xx in range(nWord): # init data array
            portMEM.append(0x0)

    	self.rxRAMs[link][eport].writeBlock(portMEM);
    	self.hw.dispatch();
    	#time.sleep(self.wait)

    	portMEM = self.rxRAMs[link][eport].readBlock(int(nWord));
    	self.hw.dispatch();
    	print "Read rxRAM"
    	for x in range(int(nWord)):
            print "addr =", x , "data =", hex(portMEM[x])
    	time.sleep(self.wait)

    	############### Open JSON file for reading configuration ###################
    	word8_str = "0x80"
    	word7_str = ""
    	word6_str = ""
    	word5_str = ""
    	word4_str = ""
    	word3_str = ""
    	word2_str = ""
    	word1_str = ""
    	word0_str = ""
   	with open(configFile) as jsonFile:
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
    	self.txRAMs[link].writeBlock(cfgValue);
    	self.hw.dispatch();
    	time.sleep(self.wait)

    	##----------- Check TxRAM ------------
    	MEMs = []
    	MEMs=self.txRAMs[link].readBlock(int(Nword));
    	self.hw.dispatch();
    	time.sleep(self.wait)
    	# print result
    	for x in range(int(Nword-1)):
       	   strName = "payload"
       	   if x==8:
              strName = "header"
       	   print "addr =", x , "data =", hex(MEMs[x]), " "+str(strName)

    	#wait = 1.0
    	Value = 1;
    	print "send Config CMD"
    	self.Tx_Config_CMDs[link].write(int(Value));
    	self.hw.dispatch();
    	time.sleep(self.wait);

    	self.resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
    	self.hw.dispatch();
    	time.sleep(self.wait)

    	portMEM = self.rxRAMs[link][eport].readBlock(int(nWord));
    	self.hw.dispatch();
    	time.sleep(self.wait)
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


    def config(self, link, configFile):
        print "Start configuration TOFHIR for", link, "link"
	#Core logic RESET 
	self.chipReset(link, 6)
	print "---------- Set ASIC GLOBAL COMMAND ------------"
	self.configReg(link, 'Chip_00010101_reg32', configFile)
	
	#Global Reset to all ASIC!
	self.chipReset(link, 16)
	
	print "---------- Set configuration mode -------------"
	self.configReg(link, 'Chip_00010101_reg33', configFile)
	#Core logic RESET 
        self.chipReset(link, 6)

	print "---------- Set ASIC GLOBAL COMMAND ------------"
        self.configReg(link, 'Chip_00010101_reg32', configFile)
	#Core logic RESET 
        self.chipReset(link, 6)

	print "---------- Set ASIC CHANNEL COMMAND ------------"
        self.configReg(link, 'Chip_00010101_reg00', configFile)
        #Core logic RESET 
        self.chipReset(link, 6)

	print "Configuration TOFHIR on", link, "link is finished"


    def readeport(self, ChID, nWord, TOFHIR_RxBRAMch, linkID, file):
        FrameData = 0
        MEM = []
        xx = 1
        yy = 0
        MEM=TOFHIR_RxBRAMch.readBlock(int(nWord));
        self.hw.dispatch();
        for x in range(int(nWord)):
            if yy == 3:
                FrameData = FrameData + ((MEM[x]&0xFFFFFFFF)<<yy*32)
                yy = 0
                file.write( str("{:3d};{:3d};{:3d};".format(linkID, ChID, xx)+ hex(FrameData) + "\n"))
                xx = xx + 1
                FrameData = 0
            else :
                FrameData = FrameData + ((MEM[x]&0xFFFFFFFF)<<yy*32)

    
    def readTimeTag(self, ChID, nWord, TOFHIR_RxTTch, linkID, file):
        TTData = 0
        MEM = []
        xx = 1
        yy = 0
        MEM=TOFHIR_RxTTch.readBlock(int(nWord*2));
        self.hw.dispatch();
        for x in range(int(nWord-1)):
            TTData = (MEM[x*2]&0xFFFFFFFF)+((MEM[x*2+1]&0xFFFFFFFF)<<32)
            file.write( str("{:3d};{:3d};{:3d};".format(linkID, ChID, xx)+ hex(TTData) + "\n"))


    def readeportwttag(self, ChID, nWord, tnWord, RxBRAMch, RxTTch, linkID, file):
        FrameData = 0
        portMEM = []
        TTData = 0
        tMEM = []
        tTag = []
        xx = 1
        yy = 0
        portMEM=RxBRAMch.readBlock(int(nWord));
        self.hw.dispatch();
        tMEM=RxTTch.readBlock(int(tnWord*2));
        self.hw.dispatch();

        for t in range(int(tnWord)):
            TTData = (tMEM[t*2]&0xFFFFFFFF)+((tMEM[t*2+1]&0xFFFFFFFF)<<32)
            tTag.append(hex(TTData))

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


    def readFEB(self, connectorID, TOFHIR_rxRAM_status, nWord, TTnWord, TOFHIR_RxBRAM, TOFHIR_RxTT, linkID,  channelRead, file):
        RAM_status = TOFHIR_rxRAM_status.read();
        self.hw.dispatch();
        channelIDs  = self.mapLink[connectorID];
        channelMask = self.enableLink[str(linkID)][connectorID]
        for index,channel in enumerate(channelIDs) :
            if (RAM_status>>channelIDs[index] & 0x1) == 1 and channelMask[index] == 1 and channelRead[str(linkID)][connectorID][index] == 1:
                print("----------- Read Rx answer e-port {}------------".format(channel))
                self.readeportwttag(channel, nWord, TTnWord, TOFHIR_RxBRAM[channel], TOFHIR_RxTT[channel], linkID ,file)
                channelRead[str(linkID)][connectorID][index] = 0


    def readout(self, mapFile, outFile, nCycRead):
        #load readout map with mapLink, enableLink, readMaskIni 
	with open(mapFile) as jsonFile:
            data = json.load(jsonFile, object_pairs_hook=OrderedDict)

    	self.mapLink = data['mapLink']
    	self.enableLink = data['enableLink']
    	self.readMaskIni = data['readMaskIni']

   	MEM                 = []
    	TimeOut             = 0
    	nCycle              = 0
    	nWord               = 1020 #512  1024   
    	TTnWord             = 255 #nWord / 4 
    	channelRead         = copy.deepcopy(self.enableLink)
    	Timeout             = 0
   	
	#create ouput file with data from TOFHIR2
    	dirOut = 'outTOFHIR2'
    	if not os.path.exists(dirOut):
            os.mkdir(dirOut)
    	print "File name: "+dirOut+"/"+outFile+".rawf"
    	file = open(dirOut+"/"+outFile+".rawf","w")
    	file.write( "Link ID; Channel ID; Line; time tag; Data \n")
    	
	while nCycle < int(nCycRead) and Timeout < 10000:
            print("cycle: %d") % nCycle
            for link in range(self.nlinks):
            	self.readFEB('A', self.rxRAMs_status[link], nWord, TTnWord, self.rxRAMs[link], self.RxTTs[link], link, channelRead, file)
            	self.readFEB('B', self.rxRAMs_status[link], nWord, TTnWord, self.rxRAMs[link], self.RxTTs[link], link, channelRead, file)
            	self.readFEB('C', self.rxRAMs_status[link], nWord, TTnWord, self.rxRAMs[link], self.RxTTs[link], link, channelRead, file)
            	self.readFEB('D', self.rxRAMs_status[link], nWord, TTnWord, self.rxRAMs[link], self.RxTTs[link], link, channelRead, file)
            	print(channelRead[str(link)].values())
            if self.readMaskIni == channelRead:
                nCycle = nCycle + 1;
            	print("cycle: %d") % nCycle
            	print("Total: %d") % nCycRead
            	channelRead         = copy.deepcopy(self.enableLink)
            	print(channelRead)
            	if (1 ):
                   self.resetTFHRbufAddrCnt.write(1) # common reset TT and TOFHIR data buffers
                   self.hw.dispatch();
                   print(channelRead)
                   TimeOut = 0
            TimeOut = TimeOut + 1
    	print("")
    	print("frequency frames with recognized headers")
    	nWord = 5
    	for link in range(self.nlinks):
            MEM=self.statusLinks[link].readBlock(int(nWord))
            self.hw.dispatch()
            print("link: " , link )
            print("frequency frames with recognized headers")
            Nword = 27
            FREQ = []
            FREQ=self.statusLinks[link].readBlock(int(Nword))
            self.hw.dispatch();
            # print result
            for x in range(int(Nword)):
               print "e-port",x, " ", (FREQ[x]), "Hz"
 
