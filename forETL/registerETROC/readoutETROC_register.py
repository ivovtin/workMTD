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
        print("usage: readoutETROC_register.py N")
        sys.exit(1)   
        
    uhal.disableLogging()

    connectionFilePath = "Real_connections_ETROC_FULL.xml";
    deviceId = "KCU105real";
    
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    ETROC_rst_Rx1_addr_cnt = hw.getNode("rst_Rx1_addr_cnt")    #address="0x4"

    # write Value to rst_Rx1_addr_cnt
    WxValue = sys.argv[1]
    print "WxValue =", WxValue
    ETROC_rst_Rx1_addr_cnt.write(int(WxValue));
    # dispatch method sends write request to hardware, and waits for result to return
    hw.dispatch();
    wait = 1
    time.sleep(wait)                   
   
    # read results from rst_Rx1_addr_cnt
    RxValue = ETROC_rst_Rx1_addr_cnt.read();
    hw.dispatch();
    print "RxValue =", RxValue
    print "******************End***************************"
