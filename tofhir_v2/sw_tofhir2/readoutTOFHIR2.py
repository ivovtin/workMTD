#!/bin/env python

import random 
import sys 
import uhal
import time
import operator
import datetime
import argparse
from tofhir2_tools import TOFHIR

parser =  argparse.ArgumentParser(description='Configuration and readout TOFHIR2')
parser.add_argument('--config', action='store_true', help='Configuration TOFHIR2')
parser.add_argument('-c', '--configFile', dest="configFile", type=str, default="configdir/config_tofhir_2x.json", help="Configuration json-file (default is configdir/config_tofhir_2x.json)")
parser.add_argument('-l', '--configLinks', nargs='+', default='01', help="Numbers of link for configuration (default is 0,1)")
parser.add_argument('-m', '--mapFile', dest="mapFile", type=str, default="configdir/readout_map_tofhir2.json", help="Json-file for readout map (default is configdir/readout_map_tofhir2.json)")
parser.add_argument('-f', '--outFile', dest="outFile", type=str, default="test", help="Output file name (default is test.rawf)")
parser.add_argument('-n', '--nCycRead', dest="nCycRead", type=int, default=1, help="Number cycles for read (default is 1)")

opt = parser.parse_args()


if __name__ == '__main__':

    args = parser.parse_args()

    #number of links for configurate and readout
    nlinks = 2

    tofhir = TOFHIR(nlinks)
   
    ## start configuration TOFHIR
    if args.config:
       for link in args.configLinks:
    	   tofhir.config(int(link), opt.configFile)
       sys.exit()
 
    #readout tofhir
    tofhir.readout(opt.mapFile, opt.outFile, opt.nCycRead)
