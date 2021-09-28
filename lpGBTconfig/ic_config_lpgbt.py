#!/usr/bin/env python

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

    print "link =", opt.linkN

    IC_Read = hw.getNode("IC_Read")
    IC_Write = hw.getNode("IC_Write")
    IC_Read_Status = hw.getNode("IC_Read_Status")
    IC_Read_rxData = hw.getNode("IC_Read_rxData")
    IC_Write_txData = hw.getNode("IC_Write_txData")
    IC_Write_txConf = hw.getNode("IC_Write_txConf")
    IC_Write_txNWord = hw.getNode("IC_Write_txNWord")
    
    wait = 1

    # read IC status
    RxValue = IC_Read_Status.read();
    hw.dispatch();
    print "IC Status =", hex(RxValue)

    if (RxValue & 0x1) == 1:
         print "IC ready"
    else:
         print "IC not ready" 





