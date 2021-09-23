#!/usr/bin/env python

import time
import datetime
import matplotlib.pyplot as plt

####################################################
###                 LPGBT STUFF                  ###
####################################################
from lpgbt_config_DONGLE import lpgbt_evb

def test_lpgbt_xcvr():

    # Open lpGBT
    lpgbt = lpgbt_evb()

    # Configure lpGBT
    print('RESET lpGBT') 
    lpgbt.LpGBT_RESET()
    lpgbt.Read_PAUSE_FOR_PLL_CONFIG()
    lpgbt.Clock_generator_setup()
    lpgbt.line_driver_setup()
    lpgbt.equalizer_setup()
    lpgbt.power_up_PLL_Config_done()
    lpgbt.Read_READY()
    time.sleep(1)

    # Config DESCLK0	
    #lpgbt.lpgbt.gbtx_write_register(0x05c, (7<<3)+(4<<0))
    #lpgbt.lpgbt.gbtx_write_register(0x05f, (7<<3)+(4<<0))
    #lpgbt.lpgbt.gbtx_write_register(0x062, (7<<3)+(4<<0))
    #lpgbt.lpgbt.gbtx_write_register(0x065, (7<<3)+(4<<0))




    # Config ECLK0
    for i in range(0,27):
#        lpgbt.eclk_setup(i,4,7)
        lpgbt.eclk_setup(i,3,7)

    lpgbt.enable_EC()

    lpgbt.enable_etxlinks()
    lpgbt.enable_erxlinks()

if __name__ == "__main__":  
    test_lpgbt_xcvr()
