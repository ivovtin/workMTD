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
    
    Value = []
    
    wait = 1
    # initialize IC and EC moduls
    TxValue = 1  
    Init_EC_IC_moduls.write(int(TxValue)); 
    hw.dispatch();

    # EOF register for SCA
    TxValue = 2 
    nFRAME.write(int(TxValue)); 
    hw.dispatch();

    RxValue = nFRAME.read();
    hw.dispatch();
    print "nFRAME register =", hex(RxValue)

   
    ###############################################################################
    # ADC: 
    ###############################################################################
    #------------------------------------------------------------------------------
    # Start of conversion
    print "send two frame in the loop" 
    print "ADC: Start of conversion: address 0" 
    print "SCA ID: address 1"
    Value.append(0x02041407); # CMD & LEN & CH & Tr.ID field "ADC: Start of conversion"
    Value.append(0xD1041408); # CMD & LEN & CH & Tr.ID field "SCA ID"
    EC_Tx_SCA_Header.writeBlock(Value); 
    hw.dispatch();

    Value.append( 0x00000001 ); # data field "ADC: Start of conversion"
    Value.append( 0x00000001 ); # data field "SCA ID" 
    EC_Tx_SCA_Data.writeBlock(Value);
    hw.dispatch();

    print "send SCA start CMD!" 
    SCA_Start_CMD.write(int(TxValue)); 
    hw.dispatch();
    time.sleep(wait) # wait 1 sec
    
    # read SCA results from RxRAM
    Value = EC_Rx_SCA_Header.readBlock(2);
    hw.dispatch();
    print "LEN & ERR & CH & Tr.ID =", hex(Value[0])," ",hex(Value[1])

    Value = EC_Rx_SCA_Data.readBlock(2);
    hw.dispatch();
    print "Data =", hex(Value[0])," ",hex(Value[1])
    print "************************************************"

    print " "   
    print "ADC value =", Value[0]
    print "SCA ID =", hex(Value[1])
    print "End!"  
    print "************************************************"



