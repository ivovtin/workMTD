#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal


if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) != 5:
        print "Incorrect usage!"
        print "usage: read_write_single_register.py <path_to_connection_file> <connection_id> <register_name> <value_to_register>"
        sys.exit(1)

    uhal.disableLogging()

    connectionFilePath = sys.argv[1];
    deviceId = sys.argv[2];
    registerName = sys.argv[3];
    Nbit = sys.argv[4];

    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);
    
    # Iterating over all nodes
    topNode = hw.getNode();
    node = hw.getNode(registerName)

    # Read RAM block
    MEM=node.readBlock(int(Nbit));
    hw.dispatch();

    # print result
    for x in range(int(Nbit)):
      print "addr =", x , "data =", MEM[x]


