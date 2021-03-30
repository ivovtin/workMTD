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

    EC_Tx_Elink_Header  = hw.getNode("EC_Tx_Elink_Header")
    EC_Tx_SCA_Header 	= hw.getNode("EC_Tx_SCA_Header")
    EC_Tx_SCA_Data 	= hw.getNode("EC_Tx_SCA_Data")
    SCA_Rst_CMD 	= hw.getNode("SCA_Rst_CMD")
    SCA_Connect_CMD 	= hw.getNode("SCA_Connect_CMD")
    SCA_Start_CMD 	= hw.getNode("SCA_Start_CMD")

    #EC_Rx_Elink_Header = hw.getNode("ECTxElinkHRAM")
    EC_Rx_SCA_Header = hw.getNode("EC_Rx_SCA_Header")
    EC_Rx_SCA_Data = hw.getNode("EC_Rx_SCA_Data")




    print "************************************************"
    # write to TxRAM SCA T sensor reading frame
    # SCA v2
    # MUX 31 internal T sensor
    TxValue = 0x00000000  # Address field
    EC_Tx_Elink_Header.write(int(TxValue)); 
    hw.dispatch();
    print "address =", hex(TxValue)

    TxValue = 0x50501401  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x0000001F  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "Data =", hex(TxValue)

    print "TxRAM writing success!"  
    print "************************************************"

    time.sleep(1) # wait 1 sec

    TxValue = 1;
    print "send SCA reset CMD!"  
    print "************************************************"
    SCA_Rst_CMD.write(int(TxValue)); 
    hw.dispatch();

    #time.sleep(2) # wait 1 sec
    #print "send SCA connect CMD!"  
    #print "************************************************"
    #SCA_Connect_CMD.write(int(TxValue)); 
    #hw.dispatch();

    time.sleep(2) # wait 1 sec

    print "send SCA start CMD!"  
    print "************************************************"
    SCA_Start_CMD.write(int(TxValue)); 
    hw.dispatch();

    # ADC GO 
    TxValue = 0x00000000  # Address field
    EC_Tx_Elink_Header.write(int(TxValue)); 
    hw.dispatch();
    print "address =", hex(TxValue)

    TxValue = 0x02021402  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x00000001  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "Data =", hex(TxValue)

    print "TxRAM writing success!"  
    print "************************************************"

    time.sleep(1) # wait 1 sec

    print "send SCA start CMD!"  
    print "************************************************"
    SCA_Start_CMD.write(int(TxValue)); 
    hw.dispatch();


    time.sleep(2) # wait 1 sec


    # read SCA results from RxRAM
    RxValue = EC_Rx_SCA_Header.read();
    hw.dispatch();
    print "LEN & ERR & CH & Tr.ID =", hex(RxValue)

    RxValue = EC_Rx_SCA_Data.read();
    hw.dispatch();
    print "Data =", hex(RxValue)

    print "RxRAM reading success!"  
    print "************************************************"


