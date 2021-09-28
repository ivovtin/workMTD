#!/usr/bin/env python

import uhal
import time
import sys

if __name__ == '__main__':

    if len(sys.argv) != 1:
        print "Incorrect usage!"
        print "usage: ic_config_lpgbt.py only"
        sys.exit(1)

    # Creating the HwInterface
    uhal.disableLogging()

    connectionFilePath = "Real_connections.xml";
    deviceId = "KCU105real";

    connectionMgr = uhal.ConnectionManager("file://" + connectionFilePath);
    hw = connectionMgr.getDevice(deviceId);

    IC_Read = hw.getNode("IC_Read")                          #IC start read operation 
    IC_Write = hw.getNode("IC_Write")                        #IC start write operation
    IC_Read_Status = hw.getNode("IC_Read_Status")            #IC Status register  
    IC_Read_rxData = hw.getNode("IC_Read_rxData")            #IC Rx FIFO data 
    IC_Write_txData = hw.getNode("IC_Write_txData")          #IC Tx FIFO data
    IC_Write_txConf = hw.getNode("IC_Write_txConf")          #IC Tx Configuration: lpGBT address 0..7bits, Internal address 23..8bits = 24bits  
    IC_Write_txNWord = hw.getNode("IC_Write_txNWord")        #IC Number of words to be read (only for read transactions) 
    
    wait = 1

    TxValue = 0x00000070    
    IC_Write_txConf.write(int(TxValue)); 
    hw.dispatch();
    print "internal address =", hex(TxValue)

    TxValue = 0x00000004  # Number of words/bytes to be read (16bits only for read transactions) field
    IC_Write_txNWord.write(int(TxValue)); 
    hw.dispatch();
    print "Read NWords =", hex(TxValue)
    time.sleep(1) # wait 1 sec

    #TxValue = 0x00000000
    #IC_Write_txData.write(int(TxValue));
    #hw.dispatch();
    #print "Tx data =", hex(TxValue)
    #time.sleep(1);

    print "TxFrame writing success!"  
    print "************************************************"
    
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



