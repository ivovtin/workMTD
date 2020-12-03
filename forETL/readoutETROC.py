#!/bin/env python
import random
import sys
import uhal
import time
import operator
import datetime

if __name__ == '__main__':
    
    # PART 1: Argument parsing
    if len(sys.argv) < 2:
        print("Incorrect usage!")
        print("usage: readoutETROC.py outFileName")
        sys.exit(1)   
        
    # ouput file    
    nameFile = sys.argv[1]+".rawf"
    print("File name: " , nameFile)
    file = open(nameFile,"w") 
        
    uhal.disableLogging()

    connectionFilePath = "/home/ivovtin/public/forETL/Real_connections_TOFHIR_FULL.xml";
    deviceId = "KCU105real";
    
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    TOFHIR_debug_RAM 	   = hw.getNode("Tx0_debug_RAM")
    TOFHIR_debug_RAM_start = hw.getNode("Tx0_debug_RAM_start")

    Value = 1
    TOFHIR_debug_RAM_start.write(int(Value));
    hw.dispatch();
    wait = 1
    time.sleep(wait)                                       # wait 0.001 sec
    
    nWord = 2048

    ePortData = 0
    MEM = []
    MEM=TOFHIR_debug_RAM.readBlock(int(nWord));            # read 2048 words 
    hw.dispatch();

    file.write("Frame")
    for k in range(28):
      file.write(str("{:3d}B".format(k+1)))
    file.write("\n")
 
    for sl in range(256):                                  # number of slices
      file.write( str("{:3d}".format(sl)+";" + "  "))
      for i in range(8):                                   # number of words per slice
          if i < 7:                                        # take only 7 words
             for xx in range(4):
                 ePortData = (MEM[i+sl*8]>>(xx*8))&0xFF
                 file.write(hex(ePortData) + " ")          # We write 28 bytes in a line. Each byte is data from the corresponding e-link
      file.write("\n")                                     # go to the next line

