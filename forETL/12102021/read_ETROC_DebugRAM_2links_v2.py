#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
import operator
import datetime
import copy
import argparse

parser =  argparse.ArgumentParser(description='Readout ETROC')
parser.add_argument('-l', '--link', dest="numlink", type=str, default=0, help="Link for readout (default is 0)")
parser.add_argument('-f', '--outFile', dest="nameFile", type=str, default="aa", help="Out file name (default is aa.txt)")
parser.add_argument('-n', '--nCycRead', dest="nCycRead", type=int, default=1, help="Number cycles for read (default is 1)")

opt = parser.parse_args()

if __name__ == '__main__':

    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";
       
    #Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);
    
    link = int(opt.numlink)
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
    nCycle = 0
     
    # ouput file    
    print "File name: "+opt.nameFile+".txt"
    file = open(opt.nameFile+".txt","w")
    file.write( "Word number;		Data \n")

    #########################
    Value = 1;
    debug_RAM_start.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec

    while nCycle < int(opt.nCycRead):  
    	#print "----------- data in output lpGBT uplink for each e-port ------------"
    	Nword = 4096
    	MEM1=debug_RAM.readBlock(int(Nword));
    	hw.dispatch();
    	for x in range(Nword): 
       		file.write( str("{:5d};			".format(x)+ hex(MEM1[x]) + "\n"))
    	for x in range(16): 
       		print "N ", x, " " , "data in output lpGBT =", bin(MEM1[x]), "	" , hex(MEM1[x])
        nCycle = nCycle + 1;
    
    print "************************************************"
    print "End!"  
    print "################################################"


