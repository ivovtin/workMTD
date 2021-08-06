#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
import operator
import datetime
import copy



if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) < 2:
        print "Incorrect usage!"
        print "usage: Read_DebugRAM_2link.py lpGBT_link_Number"
        sys.exit(1)

    if int(sys.argv[1]) < 0 or int(sys.argv[1]) > 1:
    	sys.exit("Bad number for link. Please use 0 or 1")
   
    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);
    
    link = int(sys.argv[1])
    print "Read from lpGBT link =", link

    if link == 1:
        Init_EC_IC_moduls = hw.getNode("Init_TOFHIR_EC_IC_modules1")
        TOFHIR_status     = hw.getNode("LINK1_RHCnt_status")   
        debug_RAM 	  = hw.getNode("Tx1_debug_RAM")
        debug_RAM_start   = hw.getNode("Tx1_debug_RAM_start")
    else:
        Init_EC_IC_moduls = hw.getNode("Init_TOFHIR_EC_IC_modules0")
        TOFHIR_status     = hw.getNode("LINK0_RHCnt_status")   
        debug_RAM 	  = hw.getNode("Tx0_debug_RAM")
        debug_RAM_start   = hw.getNode("Tx0_debug_RAM_start")

     
    Value = []
    MEM1 = []

    wait = 1


    #########################
    Value = 1;
    debug_RAM_start.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec

     
    #print "----------- data in output lpGBT uplink for each e-port ------------"
    Num_ePort = 28;
    depht = 32
    Nword = depht*8*4
    MEM1_decode = []
    MEM1=debug_RAM.readBlock(int(Nword));
    hw.dispatch();
        
    #-------------------------------------------------------
    FrameData = 0
    xx = 0
    yy = 0
    shift = 0;
    
    for x in range(28): 
       MEM1_decode.append( 0 )

    for x in range(int(depht)):
      for y in range(8):
        if y == 7:
            xx = xx + 1
            FrameData = 0
        else :
         for z in range(4): 
            shift = ( int((depht-x-1)*8) );
            #print shift,x,Nword;
            FrameData = ( (MEM1[xx]>>(z*8))&0xFF )<<(int(shift)) 
            MEM1_decode[z+yy*4] = MEM1_decode[z+4*yy] + FrameData;
         yy = yy + 1
         xx = xx + 1 
      yy =0 

    print "--------------------- uplink", link ,"data -------------------------"
    for x in range(Num_ePort): 
       print "e-port ", x, " " , "data in output lpGBT =", hex(MEM1_decode[x])  
 
    print "************************************************"
    #print "e-port ", 0, "ID1" , " " , "data in output lpGBT =", hex(MEM1_decode[0])
    #print "e-port ", 0, "ID1" , " " , "data in output lpGBT =", bin(MEM1_decode[0])

    print "e-port ", 13, "ID1" , " " , "data in output lpGBT =", hex(MEM1_decode[13])
    print "e-port ", 13, "ID1" , " " , "data in output lpGBT =", bin(MEM1_decode[13])
    print " "
    #print "e-port ", 14, "ID0" , " " , "data in output lpGBT =", hex(MEM1_decode[14])
    #print "e-port ", 14, "ID0" , " " , "data in output lpGBT =", bin(MEM1_decode[14])

    #xx = 0;
    #for x in range(64): 
    #   print "MEM", x, " " , "data in output lpGBT =", hex(MEM1[x])
    #   xx = xx + 1
    #   if xx == 8:
    #      xx = 0
    #      print ("------------------")

  

    #print ""
    #print "frequency frames with recognized headers"
    #Nword = 24
    #FREQ = []
    #FREQ=TOFHIR_status.readBlock(int(Nword));
    #hw.dispatch();
    #for x in range(int(Nword)): 
    #  print "e-port",x, " ", (FREQ[x]), "Hz"

    
    print "************************************************"
    print "End!"  
    print "################################################"


