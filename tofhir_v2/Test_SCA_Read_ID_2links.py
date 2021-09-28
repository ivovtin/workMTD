#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time


if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) < 2:
        print "Incorrect usage!"
        print "usage: Test_SCA_Read_ID.py lpGBT_link_Number"
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
    print "link =", link

    if link == 1:
    	Init_EC_IC_moduls   = hw.getNode("Init_TOFHIR_EC_IC_modules1")
        EC_Tx_Elink_Header  = hw.getNode("EC_Tx_Elink_Header1")
        EC_Tx_SCA_Header        = hw.getNode("EC_Tx_SCA_Header1")
        EC_Tx_SCA_Data  = hw.getNode("EC_Tx_SCA_Data1")
        SCA_Rst_CMD     = hw.getNode("SCA_Rst_CMD1")
        SCA_Connect_CMD         = hw.getNode("SCA_Connect_CMD1")
        SCA_Test_CMD    = hw.getNode("SCA_Test_CMD1")
        SCA_Start_CMD   = hw.getNode("SCA_Start_CMD1")
        nFRAME              = hw.getNode("nFRAME1")
        #EC_Rx_Elink_Header = hw.getNode("ECTxElinkHRAM")
        EC_Rx_SCA_Header = hw.getNode("EC_Rx_SCA_Header1")
        EC_Rx_SCA_Data = hw.getNode("EC_Rx_SCA_Data1")
    else:
        Init_EC_IC_moduls   = hw.getNode("Init_TOFHIR_EC_IC_modules0")
    	EC_Tx_Elink_Header  = hw.getNode("EC_Tx_Elink_Header0")
    	EC_Tx_SCA_Header 	= hw.getNode("EC_Tx_SCA_Header0")
    	EC_Tx_SCA_Data 	= hw.getNode("EC_Tx_SCA_Data0")
    	SCA_Rst_CMD 	= hw.getNode("SCA_Rst_CMD0")
    	SCA_Connect_CMD 	= hw.getNode("SCA_Connect_CMD0")
    	SCA_Test_CMD 	= hw.getNode("SCA_Test_CMD0")
    	SCA_Start_CMD 	= hw.getNode("SCA_Start_CMD0")
    	nFRAME              = hw.getNode("nFRAME0")
    	#EC_Rx_Elink_Header = hw.getNode("ECTxElinkHRAM0")
    	EC_Rx_SCA_Header = hw.getNode("EC_Rx_SCA_Header0")
    	EC_Rx_SCA_Data = hw.getNode("EC_Rx_SCA_Data0")
   
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
#    TxValue = 0x00000000  # Address field
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
    RxValue = EC_Tx_SCA_Header.read(); 
    hw.dispatch();
    print "-->>> Read CMD & LEN & CH & Tr.ID =", hex(RxValue)
    
    
    TxValue = 0x10000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write to Data RAM =", hex(TxValue)
    RxValue = EC_Tx_SCA_Header.read(); 
    hw.dispatch();
    print "-->>> read Data RAM =", hex(TxValue)

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
    print "Read from lpGBT link =", link


