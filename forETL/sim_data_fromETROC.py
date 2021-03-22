#!/bin/env python
import random
import sys
import uhal
import time
import operator
import datetime

#hex_digits = set('0123456789ABCDEF')
hex_digits = set('01')
 
def HeaderGen(Nbits):
    while True:
        header = ""
        pick_from = hex_digits
        for digit in range(Nbits):                                #indicate number of bits
        #for digit in range(30):
            cur_digit = random.sample(hex_digits, 1)[0]
            header += cur_digit
            if header[-1] == cur_digit:
                pick_from = hex_digits - set(cur_digit)
            else:
                pick_from = hex_digits
        yield header

def DataGen(Nbits):
    while True:
        data = ""
        pick_from = hex_digits
        for digit in range(Nbits):                                 #indicate number of bits
        #for digit in range(30):
            cur_digit = random.sample(hex_digits, 1)[0]
            data += cur_digit
            if data[-1] == cur_digit:
                pick_from = hex_digits - set(cur_digit)
            else:
                pick_from = hex_digits
        yield data

def EOFGen(Nbits):
    while True:
        eof = ""
        pick_from = hex_digits
        for digit in range(Nbits):                                  #indicate number of bits
        #for digit in range(30):
            cur_digit = random.sample(hex_digits, 1)[0]
            eof += cur_digit
            if eof[-1] == cur_digit:
                pick_from = hex_digits - set(cur_digit)
            else:
                pick_from = hex_digits
        yield eof


if __name__ == '__main__':

    # PART 1: Argument parsing
    if len(sys.argv) < 5:
        print("Incorrect usage!")
        print("usage: sim_data_fromETROC.py Nbits NdataWords Nsequence outFileName")
        sys.exit(1)

    # output file    
    nameFile = sys.argv[4]+".dat"
    print("File name: " , nameFile)
    file = open(nameFile,"w")

    #Number of data words 
    NdataWords = int(sys.argv[2])
    if NdataWords < 1:
       NdataWords = 1

    Nsequence = int(sys.argv[3])
    Nbits = int(sys.argv[1])

    print("Nbits=",Nbits," Ndatawords=",NdataWords," Nsequence=",Nsequence)

    empty_range=''
    for i in range(Nbits):
        empty_range += '0'

    out=''

    for cycle in range(Nsequence):        #indicate lenght of sequency  
      counter1 = 0
      counter2 = 0
      counter3 = 0
      for header in HeaderGen(Nbits):
          counter1 += 1
          if counter1 > 1:
             break
      print("header = ",header)
      dataOut = ""
      for data in DataGen(Nbits):
          counter2 += 1
          #dataOut += data
          if counter2 > NdataWords:
             break
          dataOut += data            
      print("dataOut = ",dataOut)
      for eof in EOFGen(Nbits):
          counter3 += 1
          if counter3 > 1:
             break
      print("eof = ",eof)
      out += empty_range + header + dataOut + eof + empty_range 

    print("Packet output: ",out)
    file.write(out)

