#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal


if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) != 4:
        print "Incorrect usage!"
        print "usage: read_write_single_register.py <register_name> <value_to_register> <number_of_words>"
        sys.exit(1)
   
    uhal.disableLogging()

    #connectionFilePath = sys.argv[1];
    #deviceId = sys.argv[2];
    #registerName = sys.argv[3];
    #value = sys.argv[4];

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";
    registerName = sys.argv[1];
    ArgvValue = sys.argv[2];
    Nbit = sys.argv[3];

    RND = "RND" in ArgvValue
    value = []

    if ArgvValue.isdigit() is False:
	if RND is False:
		print "argv[2] '",ArgvValue,"' can be a digit or RND"
		sys.exit(1)

    if Nbit.isdigit() is False:
    	print "argv[3] '",Nbit,"' can be a digit only"
	sys.exit(1)
       
    # PART 2: Creating the HwInterface
    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);
    
    node = hw.getNode(registerName)

    print "************************************************"
    if int(Nbit) > 1 :
    # Read RAM block
    	print "----------- Read previos ------------"
    	MEM=node.readBlock(int(Nbit));
    	hw.dispatch();
        # print result
       	for x in range(int(Nbit)): 
      		print "addr =", x , "data =", MEM[x], "  ", hex(MEM[x])
    	# write RAM block
    	print "----------- Write New ------------"
    	if RND is True:
        	for i in range(int(Nbit)):
           		value.append( random.randint(0, 100) );
    	else : 
        	for i in range(int(Nbit)):
           		value.append( int(ArgvValue) );
	# print result
    	for x in range(int(Nbit)):
      		print "addr =", x , "data =", value[x], "  ", hex(value[x])
    		node.writeBlock(value);
    		hw.dispatch();
        MEMcur=node.readBlock(int(Nbit));
    	hw.dispatch();
	print "----------- Read new ------------"
	# print result
       	for x in range(int(Nbit)): 
      		print "addr =", x , "data =", MEMcur[x], "  ", hex(MEMcur[x])
    	print "----------- compare W/R new ------------"
        for x in range(int(Nbit)):
		if MEMcur[x] != value[x]:
			print "addr =", x , "data RD =", MEMcur[x], " != WR", value[x]
    else :
	# Reading from the register
	print "Reading previos value from register '" + registerName + "' ..."
    	prev_reg = node.read();
    	hw.dispatch();
    	print "Value =", hex(prev_reg)
    	print "Value =", prev_reg
    	# Writing to the register
    	RND = "RND" in ArgvValue
    	if RND is True:
        	#value = random.randint(0, 0xffffffff);
        	value = random.randint(0, 100);
    	else : 
        	value = int(ArgvValue);

    	print "Writing value to register '" + registerName + "' ..."
    	print "Value =", hex(int(value))
    	print "Value =", value
    	node.write(int(value)); 
    	hw.dispatch();
	cur_reg = node.read();
    	hw.dispatch();
	if cur_reg != value:
		print "addr =", registerName , "data RD =", cur_reg, " != WR", value
 
    print "... success!"   
    print "************************************************"

