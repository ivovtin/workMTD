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

    value = []
    wNFame_reg = 2

       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);
    
    EC_Tx_address = hw.getNode("ECTxRAM")
    EC_Rx_address = hw.getNode("ECRxRAM")
    EC_NFrame_address = hw.getNode("nFRAME")
    print "************************************************"
    # write to TxRAM SCA Id reading frame
    # SCA v2
    value.append( 0x14050500 ); # CH,Tr.Id,Ctrl,Address
    #value.append( 0x0123010D ); # CH,Tr.Id,Ctrl,Address
    value.append( 0x0001D101 ); # Data16,CMD,Lenght
    #value.append( 0x02010404 ); # Data16,CMD,Lenght
    value.append( 0x00000403 ); # not used
    value.append( 0x00000000 ); # not used
    # SCA v1
    value.append( 0x14060600 ); # CH,Tr.Id,Ctrl,Address
    #value.append( 0x026931DD ); # CH,Tr.Id,Ctrl,Address
    value.append( 0x0001D101 ); # Data16,CMD,Lenght
    #value.append( 0x00019101 ); # Data16,CMD,Lenght
    #value.append( 0x32510202 ); # Data16,CMD,Lenght
    value.append( 0x00000403 ); # not used
    value.append( 0x00000000 ); # not used
    # write to TxRAM SCA internal T sensor reading frame
    # Set MUX position
    value.append( 0x14010100 ); # CH,Tr.Id,Ctrl,Address
    value.append( 0x001F5004 ); # Data16,CMD,Lenght
    #value.append( 0x001F0404 ); # Data16,CMD,Lenght
    value.append( 0x00000000 ); # not used
    value.append( 0x00000000 ); # not used
    # Start of ADC Conversion
    value.append( 0x14020200 ); # CH,Tr.Id,Ctrl,Address
    value.append( 0x00010204 ); # Data16,CMD,Lenght
    value.append( 0x00000000 ); # not used
    value.append( 0x00000000 ); # not used
    # Aditional ADC reading
    value.append( 0x14030300 ); # CH,Tr.Id,Ctrl,Address
    value.append( 0x00002101 ); # Data16,CMD,Lenght
    value.append( 0x00000000 ); # not used
    value.append( 0x00000000 ); # not used
    # print result
    for x in range(20):
      	print "addr =", x , hex(value[x])
    	EC_Tx_address.writeBlock(value);
    	hw.dispatch();
    print "TxRAM writing success!"  
    print "************************************************"
    # write Number of Frame register
    EC_NFrame_address.write(int(wNFame_reg)); 
    hw.dispatch();
    NFame_reg = EC_NFrame_address.read();
    hw.dispatch();
    print "Number of Frame =", hex(int(NFame_reg))
    print "************************************************"


    time.sleep(1) # wait 1 sec
    # write 0 Number of Frame register
    EC_NFrame_address.write(int(0)); 
    hw.dispatch();
    time.sleep(1) # wait 1 sec

    # read results from RxRAM: 2 SCA Id frame, ADC data
    RxRAMdata = EC_Rx_address.readBlock(int(20));
    hw.dispatch();
    # print result
    for x in range(int(20)): 
      	print "addr =", x , "data =", hex(RxRAMdata[x])
        if x == 3 or x == 7 or x == 11 or x == 15 or x == 19 : 
           print "-----------------"
    print "RxRAM reading success!"  
    print "************************************************"


