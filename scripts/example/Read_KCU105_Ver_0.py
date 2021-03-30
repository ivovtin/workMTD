#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal


if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) != 3:
        print "Incorrect usage!"
        print "usage: read_write_single_register.py <register_name> <number_of_words>"
        sys.exit(1)
   
    uhal.disableLogging()

    #connectionFilePath = sys.argv[1];
    #deviceId = sys.argv[2];
    #registerName = sys.argv[3];
    #value = sys.argv[4];

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";
    registerName = sys.argv[1];
    Nbit = sys.argv[2];

    value = []

    if Nbit.isdigit() is False:
    	print "argv[3] '"+Nbit+"' can be a digit only"
	sys.exit(1)
       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);
    
    node = hw.getNode(registerName)

    print "************************************************"
    if int(Nbit) > 1 :
    # Read RAM block
    	print "----------- Read ------------"
    	MEM=node.readBlock(int(Nbit));
    	hw.dispatch();
        # print result
       	for x in range(int(Nbit)): 
      		print "addr =", x , "data =", MEM[x], "  ", hex(MEM[x])
    else :
	# Reading from the register
	print "Reading value from register '" + registerName + "' ..."
    	prev_reg = node.read();
    	hw.dispatch();
	print "Value =", prev_reg, "  ", hex(prev_reg)

    print "... success!"   
    print "************************************************"

