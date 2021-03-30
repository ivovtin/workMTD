#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time


if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) < 2:
        print "Incorrect usage!"
        print "usage: Test_SCA_Read_Temperature_Sensor.py link"
        sys.exit(1)

    if int(sys.argv[1]) < 1 or int(sys.argv[1]) > 2:
        sys.exit("Bad number for link. Please use 1 or 2")
   
    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    link = int(sys.argv[1])
    print "link =", link

    if link == 2:
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
        print "A2"
    else:
        Init_EC_IC_moduls   = hw.getNode("A1")
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
        print "A1"


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
    print "Write control register D (Enable Serial Number reading)"  
    TxValue = 0x06040001  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x10000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)

    print "send SCA start CMD!" 
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

    #------------------------------------------------------------------------------
    # read control register D
    print "Read control register D (Enable Serial Number reading)" 
    TxValue = 0x07040002  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x00000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "Write Data =", hex(TxValue)

    print "send SCA start CMD!" 
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
    # Set output (write MUX register)
    ###############################################################################
    print "Write ADC MUX register"  
    TxValue = 0x50041403  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x0000001F  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)

    print "send SCA start CMD!" 
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

    #------------------------------------------------------------------------------
    # read ADC MUX register
    print "Read ADC MUX register" 
    TxValue = 0x51011404  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x00000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)
    print "send SCA start CMD!" 
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
    
    ###############################################################################
    # ADC: 
    ###############################################################################
    # Enable the current generator
    print "ADC: Enable the current generator" 
    TxValue = 0x60041405  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x80000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)

    print "send SCA start CMD!" 
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

    #------------------------------------------------------------------------------
    # Read enable register of the current generator
    print "ADC: Read enable register of the current generator" 
    TxValue = 0x61011406  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x00000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)

    print "send SCA start CMD!" 
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

    #------------------------------------------------------------------------------
    # Start of conversion
    print "ADC: Start of conversion"
    TxValue = 0x02041407  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "write CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x00000001  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "write Data =", hex(TxValue)

    print "send SCA start CMD!" 
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

    
    print " "   
    print "ADC code =", RxValue
    T = RxValue*110/4096
    print "Internal temperature (approximate) =", T ,"degrees"
    print "End!"  
    print "************************************************"


