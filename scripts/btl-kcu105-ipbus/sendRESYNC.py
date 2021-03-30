#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
import cfgTOFHIR as cfgTF
import numpy as np

if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) != 1:
        print "Incorrect usage!"
        print "usage: read_write_single_register.py only"
        sys.exit(1)
   
    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    Init_TOFHIR_EC_IC_moduls   = hw.getNode("A2")

    TOFHIR_Tx_RAM       = hw.getNode("TxBRAM")
    TOFHIR_Rx_RAM       = hw.getNode("RxBRAM")

    TOFHIR_Tx_Trig_Freq = hw.getNode("TOFHIR_Tx_Trig_Freq")
    TOFHIR_Tx_Resync_Freq = hw.getNode("TOFHIR_Tx_Resync_Freq")

    TOFHIR_Resync_CMD 	= hw.getNode("TOFHIR_Resync_CMD")
    TOFHIR_Trigger_CMD 	= hw.getNode("TOFHIR_Trigger_CMD")
    TOFHIR_Config_CMD 	= hw.getNode("TOFHIR_Config_CMD")

    TOFHIR_debug_Reg 	= hw.getNode("TOFHIR_debug_Reg")
    TOFHIR_debug_RAM 	= hw.getNode("TOFHIR_debug_RAM")
    TOFHIR_debug_RAM_start 	= hw.getNode("TOFHIR_debug_RAM_start")

    TOFHIR_rst_Rx_addr_cnt = hw.getNode("TOFHIR_rst_Rx_addr_cnt")
   
    wait = 0.01
    Nword = 8
    MEM = []
    MEM_decode = []


    # set Resync frequency 
    TxValue = 0 #25ns*40000=1000Hz
    TOFHIR_Tx_Resync_Freq.write(int(TxValue)); 
    hw.dispatch();
    Value = 1
    ################### send RESYNC CMD ####################
    print "send Resync CMD!"  
    TOFHIR_Resync_CMD.write(int(Value)); 
    hw.dispatch();
    time.sleep(wait);
