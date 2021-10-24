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
        #debug_RAM 	  = hw.getNode("Tx1_debug_RAM")
	debug_RAM 	  = hw.getNode("Rx0_debug_ETROC")
        debug_RAM_start   = hw.getNode("Tx1_debug_RAM_start")
    else:
        Init_EC_IC_moduls = hw.getNode("Init_TOFHIR_EC_IC_modules0")
        TOFHIR_status     = hw.getNode("LINK0_RHCnt_status")   
        #debug_RAM 	  = hw.getNode("Tx0_debug_RAM")
        debug_RAM 	  = hw.getNode("Rx0_debug_ETROC")
        debug_RAM_start   = hw.getNode("Tx0_debug_RAM_start")

     
    Value = []
    MEM1 = []

    wait = 1

    # ouput file
    file = open("aa.txt","w") 
    file.write( "Word number;		Data \n")



    #########################
    Value = 1;
    debug_RAM_start.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec

     
    #print "----------- data in output lpGBT uplink for each e-port ------------"
    Nword = 4096
    MEM1=debug_RAM.readBlock(int(Nword));
    hw.dispatch();
    for x in range(Nword): 
       file.write( str("{:5d};			".format(x)+ hex(MEM1[x]) + "\n"))
    for x in range(16): 
       print "N ", x, " " , "data in output lpGBT =", bin(MEM1[x]), "	" , hex(MEM1[x])



    
    print "************************************************"
    print "End!"  
    print "################################################"


