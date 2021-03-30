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

    IC_Read             = hw.getNode("IC_Read")
    IC_Write 	        = hw.getNode("IC_Write")
    IC_Read_Status 	= hw.getNode("IC_Read_Status")
    IC_Read_rxData 	= hw.getNode("IC_Read_rxData")
    IC_Write_txData 	= hw.getNode("IC_Write_txData")
    IC_Write_txConf 	= hw.getNode("IC_Write_txConf")
    IC_Write_txNWord 	= hw.getNode("IC_Write_txNWord")

    SCA_Rst_CMD 	= hw.getNode("SCA_Rst_CMD")


    print "************************************************"
    # write to Tx ID ID frame
    # SCA v2

    # SCA rst CMD
    #TxValue = 1;
    #print "send SCA reset CMD!"  
    #print "************************************************"
    #SCA_Rst_CMD.write(int(TxValue)); 
    #hw.dispatch();
    
    # IC read transaction
    #TxValue = 0x00014170  # I2C slave address (0..7bits) & internal register address (8..23bits) field
    TxValue = 0x00000070    
    IC_Write_txConf.write(int(TxValue)); 
    hw.dispatch();
    print "I2C slave & internal address =", hex(TxValue)

    TxValue = 0x00000004  # Number of words/bytes to be read (16bits only for read transactions) field
    IC_Write_txNWord.write(int(TxValue)); 
    hw.dispatch();
    print "Read NWords =", hex(TxValue)

    print "TxFrame writing success!"  
    print "************************************************"

    time.sleep(1) # wait 1 sec
    
    # read IC status
    RxValue = IC_Read_Status.read();
    hw.dispatch();
    print "IC Status =", hex(RxValue)

    if (RxValue & 0x1) == 1:
         print "IC ready"
    else:
         print "IC not ready" 

    
         # read IC data
    for x in range(int(8)): 
              if (RxValue & 0x2) == 2:
                  print "IC rxFIFO is empty"
                  break;
              else:
                  RValue = IC_Read_rxData.read();
                  hw.dispatch();
                  print "IC rxData =", hex(RValue)
                  RxValue = IC_Read_Status.read();
                  hw.dispatch();
    print "IC status read!"    

    TxValue = 1
    print "************************************************"
    print "start Read IC CMD!"  
    print "************************************************"
    IC_Read.write(int(TxValue)); 
    hw.dispatch();
    
   
    time.sleep(1) # wait 1 sec

    
    # read IC status
    RxValue = IC_Read_Status.read();
    hw.dispatch();
    print "IC Status =", hex(RxValue)

    if (RxValue & 0x2) == 2:
         print "IC rxFIFO is empty"
    else:
         # read IC data
      #   for x in range(int(8)): 
      #       RxValue = IC_Read_rxData.read();
      #       hw.dispatch();
      #       print "IC rxData =", hex(RxValue)
      #   print "IC rxAnswer reading success!" 

          for x in range(int(16)): 
              if (RxValue & 0x2) == 2:
                  print "IC rxFIFO is empty"
                  break;
              else:
                  RValue = IC_Read_rxData.read();
                  hw.dispatch();
                  print x, " IC rxData =", hex(RValue)
                  RxValue = IC_Read_Status.read();
                  hw.dispatch();
    print "IC rxAnswer reading success!" 
     
    print "************************************************"


