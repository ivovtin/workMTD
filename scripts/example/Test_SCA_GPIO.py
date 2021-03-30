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

    
    wait = 5
    # initialize IC and EC moduls
    TxValue = 1  
    Init_EC_IC_moduls.write(int(TxValue)); 
    hw.dispatch();

    # EOF register for SCA
    TxValue = 0 
    nFRAME.write(int(TxValue)); 
    hw.dispatch();

    print "************************************************"
    # SCA v2
    # send_command {addr trid channel len command data}
    # Write register B (Enable GPIO interface)
    # send_command 0x00 0x01 0x00 0x02 0xFF000000
 
    # Configure GPIO direction (output)
    # send_command 0x00 0x02 0x02 0x20 0xFFFFFFFF

    # Write GPIO out register value (12345678h)
    # send_command 0x00 0x03 0x02 0x10 0x12345678

    # Read GPIO out register value
    # send_command 0x00 0x03 0x02 0x11 0x00000000

    TxValue = 0x00000000  # Address field SCA address 0x00
    EC_Tx_Elink_Header.write(int(TxValue)); 
    hw.dispatch();
    print "address =", hex(TxValue)

    ##############################################################################
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

    ##############################################################################
    # Write register B (Enable GPIO interface)
    ##############################################################################
    TxValue = 0x02040001  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0xFF000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "Data =", hex(TxValue)

    print "send SCA start CMD!"  
    print "Write register B (Enable GPIO interface)" 
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

    print "RxRAM reading success!"  
    print "************************************************"

    ##############################################################################
    # Configure GPIO direction (output)
    # send_command 0x00 0x02 0x02 0x20 0xFFFFFFFF
    ##############################################################################
    TxValue = 0x20040202  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0xFFFFFFFF  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "Data =", hex(TxValue)

    print "send SCA start CMD!"  
    print "Configure GPIO direction (output)" 
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

    print "RxRAM reading success!"  
    print "************************************************"


    ##############################################################################
    # Write GPIO out register value (12345678h)
    # send_command 0x00 0x03 0x02 0x10 0x12345678
    ##############################################################################
    TxValue = 0x10040203  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x12345678  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "Data =", hex(TxValue)

    print "send SCA start CMD!"  
    print "Write GPIO out register value (12345678h)" 
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

    print "RxRAM reading success!"  
    print "************************************************"

    ##############################################################################
    # Read GPIO out register value
    # send_command 0x00 0x04 0x02 0x11 0x00000000
    ##############################################################################
    TxValue = 0x11040204  # CMD & LEN & CH & Tr.ID field
    EC_Tx_SCA_Header.write(int(TxValue)); 
    hw.dispatch();
    print "CMD & LEN & CH & Tr.ID =", hex(TxValue)

    TxValue = 0x00000000  # data field
    EC_Tx_SCA_Data.write(int(TxValue)); 
    hw.dispatch();
    print "Data =", hex(TxValue)

    print "send SCA start CMD!"  
    print "Read GPIO out register value" 
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

    print "RxRAM reading success!"  
    print "************************************************"


