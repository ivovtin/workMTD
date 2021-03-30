#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time


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

    Init_EC_IC_moduls   = hw.getNode("A2")

    EC_Tx_Elink_Header  = hw.getNode("EC_Tx_Elink_Header")
    EC_Tx_SCA_Header 	= hw.getNode("EC_Tx_SCA_Header")
    EC_Tx_SCA_Data 	= hw.getNode("EC_Tx_SCA_Data")
    SCA_Rst_CMD 	= hw.getNode("SCA_Rst_CMD")
    SCA_Connect_CMD 	= hw.getNode("SCA_Connect_CMD")
    SCA_Test_CMD 	= hw.getNode("SCA_Test_CMD")
    SCA_Start_CMD 	= hw.getNode("SCA_Start_CMD")
    nFRAME              = hw.getNode("nFRAME")

    #EC_Rx_Elink_Header = hw.getNode("ECTxElinkHRAM")
    EC_Rx_SCA_Header = hw.getNode("EC_Rx_SCA_Header")
    EC_Rx_SCA_Data = hw.getNode("EC_Rx_SCA_Data")

    
    wait = 1
    # initialize IC and EC moduls
    TxValue = 1  
    Init_EC_IC_moduls.write(int(TxValue)); 
    hw.dispatch();

    # EOF register for SCA
    TxValue = 0 
    nFRAME.write(int(TxValue)); 
    hw.dispatch();

    print "************************************************"
    # Read SCA ID frame
    # SCA v2

    # set SCA address
    TxValue = 0x00000000  # Address field
    EC_Tx_Elink_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write address =", hex(TxValue)

    TxValue = 1;
    print "send SCA reset CMD!"  
    print "************************************************"
    SCA_Rst_CMD.write(int(TxValue)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec

    print "send SCA connect CMD!"  
    print "************************************************"
    SCA_Connect_CMD.write(int(TxValue)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec
    
    ###############################################################################
    # set Analog to Digital converter enable flag eFuses/Serial Number reading bit4
    ###############################################################################
    # write control register D
    TxValue = 0x06040001  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x10000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)

    print "send SCA start CMD!" 
    print "Write control register D (Enable Serial Number reading)"  
    print "************************************************"
    SCA_Start_CMD.write(int(TxValue)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec
    
    # read SCA results from RxRAM
    RxValue = EC_Rx_SCA_Header.read();
    hw.dispatch();
    print "LEN & ERR & CH & Tr.ID =", hex(RxValue)

    RxValue = EC_Rx_SCA_Data.read();
    hw.dispatch();
    print "Data =", hex(RxValue)

    #------------------------------------------------------------------------------
    # read control register D
    TxValue = 0x07040002  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x00000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)

    print "send SCA start CMD!" 
    print "Read control register D (Enable Serial Number reading)"  
    print "************************************************"
    SCA_Start_CMD.write(int(TxValue)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec
    
    # read SCA results from RxRAM
    RxValue = EC_Rx_SCA_Header.read();
    hw.dispatch();
    print "LEN & ERR & CH & Tr.ID =", hex(RxValue)

    RxValue = EC_Rx_SCA_Data.read();
    hw.dispatch();
    print "Data =", hex(RxValue)
    print "************************************************"
    print "************************************************"
    

    ###############################################################################
    # Read SCA ID
    ###############################################################################
    # Read SCA ID register
    TxValue = 0xD1041403  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x00000001  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)

    print "send SCA start CMD!" 
    print "Read SCA ID register"  
    print "************************************************"
    SCA_Start_CMD.write(int(TxValue)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec
    
    # read SCA results from RxRAM
    RxValue = EC_Rx_SCA_Header.read();
    hw.dispatch();
    print "LEN & ERR & CH & Tr.ID =", hex(RxValue)

    RxValue = EC_Rx_SCA_Data.read();
    hw.dispatch();
    print "Data =", hex(RxValue)
       
    print " "   
    print "SCA ID value =", hex(RxValue)
    print "End!"  
    print "************************************************"


