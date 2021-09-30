import random
import sys
import uhal
import time
import operator
import datetime
import copy

class TOFHIR:

    def __init__(self, mapLink, enableLink, readMaskIni, hw):
        self.mapLink = mapLink
        self.enableLink = enableLink
        self.readMaskIni = readMaskIni
        self.hw = hw

    def readeport(self, ChID, nWord, TOFHIR_RxBRAMch,linkID, file):
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

    def readFEB(self, connectorID, TOFHIR_rxRAM_status, hw, nWord, TTnWord, TOFHIR_RxBRAM, TOFHIR_RxTT, linkID,  channelRead, file):
        RAM_status = TOFHIR_rxRAM_status.read();
        self.hw.dispatch();
        channelIDs  = self.mapLink[connectorID];
        channelMask = self.enableLink[str(linkID)][connectorID]
        for index,channel in enumerate(channelIDs) :
            if (RAM_status>>channelIDs[index] & 0x1) == 1 and channelMask[index] == 1 and channelRead[str(linkID)][connectorID][index] == 1:
                print("----------- Read Rx answer e-port {}------------".format(channel))
                self.readeportwttag(channel, nWord, TTnWord, TOFHIR_RxBRAM[channel], TOFHIR_RxTT[channel], linkID ,file)
                channelRead[str(linkID)][connectorID][index] = 0

