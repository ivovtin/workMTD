#!/bin/env python

import random # For randint
import sys # For sys.argv and sys.exit
import uhal
import time
#import cfgTOFHIR as cfgTF
#import numpy as np
import json
from collections import OrderedDict

if __name__ == '__main__':
    
    #np.set_printoptions(formatter={'int':hex})
    
    # PART 1: Argument parsing
    if len(sys.argv) <2:
        print "Incorrect usage!"
        print "usage: TOFHIRv2_Config.py Register_number"
        sys.exit(1)

    if int(sys.argv[1]) < 0 or int(sys.argv[1]) > 34:
        sys.exit("Bad number for register. Please use [0 .. 34]")

    ############### Opening JSON file ###################
    reg = int(sys.argv[1])
    packet = "Reg" + str(reg) 
    word8_str = "0x80"
    word7_str = ""
    with open("config_tofhir_v2.json") as jsonFile:
        data = json.load(jsonFile, object_pairs_hook=OrderedDict)
        print(data[packet])
        for key0, value0 in data[packet][0].iteritems():
            ##del data[packet][0]['R/W mode'] 
            if int(data[packet][0]['R/W mode'])  == 1 and key0 == "Register address":
                ##print data[packet][0]['R/W mode'] 
                print key0, value0
                regx = int(value0, base=16)  
                print regx  
                print bin(regx)  
                print format(regx, '08b')  
                print hex(regx) 
                ##replace bit 
                regx |= 1 << 7 
                print bin(regx)  
                print format(regx, '08b')  
                print hex(regx)
                #value0 = hex(regx) 
                value0 = hex(regx).replace("0x","")
                ##value0 = str(regx) 
            if key0 != "R/W mode":
                word8_str += str(value0)
                print word8_str
        for key1, value1 in data[packet][1].iteritems():
            word7_str += str(value1)

    word8 = int(word8_str, base=16)
    word7 = int(word7_str, base=16)
    print hex(word8)
    print hex(word7)

 
    print "################################################"
    print "End!"  
    print "################################################"
