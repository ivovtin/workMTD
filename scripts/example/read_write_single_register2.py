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

    connectionFilePath = sys.argv[1];
    deviceId = sys.argv[2];
    registerName = sys.argv[3];
    value = sys.argv[4];

    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);
    
    # Iterating over all nodes
    topNode = hw.getNode();
    print "Full list of nodes (from begin and end methods):"
    for node in topNode:
        print " *", node.getPath()
    print ""

    node = hw.getNode(registerName)
 
    print "Node attributes ..."
    print node    # Prints id. Equivalent to print node.getId()
    print "  ID         = '" + node.getId() + "'"
    print "  ID path    = '" + node.getPath() + "'"
    print "  Address    =", node.getAddress()
    print "  adddress   =", hex(node.getAddress())
    print "  mask       =", hex(node.getMask())
    print "  mode       =", node.getMode()
    print "  permission =", node.getPermission()
    print "  size       =", node.getSize()
    print "  tags       =", node.getTags()
    print "  parameters =", node.getParameters()
 
    #for x in range(100000):
    for x in range(1):
      print(x)   
      # PART 3: Reading from the register
      print "Reading from register '" + registerName + "' ..."
      prev_reg = node.read();
      # dispatch method sends read request to hardware, and waits for result to return
      # N.B. Before dispatch, reg.valid() == false, and reg.value() will throw
      hw.dispatch();

      print "previos value... success!"
      print "Value =", hex(prev_reg)
      print "Value =", prev_reg


      # PART 4: Writing (random value) to the register
      print "Writing random value to register '" + registerName + "' ..."
      #node.write(random.randint(0, 0xffffffff));
      #node.write(10);
      node.write(int(value)); 
      hw.dispatch();

      Curr_reg = node.read();
      hw.dispatch();
      print "current value... success!"
      print "Value =", hex(Curr_reg)
      print "Value =", Curr_reg
      # N.B. Depending on how many transactions are already queued, this write request may either be sent to the board during the write method, or when the dispatch method is called
      
      # In case there are any problems with the transaction, an exception will be thrown from the dispatch method
      # Alternatively, if you want to check whether an individual write succeeded or failed, you can call the 'valid()' method of the uhal::ValHeader object that is returned by the write method
      print "... success!"

