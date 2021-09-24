#!/usr/bin/env python

# ********************************************************************************************************* #
#   GBTX Project, Copyright (C) CERN                                                                        #
#                                                                                                           #
#   This source code is free for HEP experiments and other scientific research                              #
#   purposes. Commercial exploitation of the source code contained here is not                              #
#   permitted.  You can not redistribute the source code without written permission                         #
#   from the authors. Any modifications of the source code has to be communicated back                      #
#   to the authors. The use of the source code should be acknowledged in publications,                      #
#   public presentations, user manual, and other documents.                                                 #
#                                                                                                           #
#   This source code is distributed in the hope that it will be useful, but WITHOUT ANY                     #
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS                               #
#   FOR A PARTICULAR PURPOSE.                                                                               #
# ********************************************************************************************************* #
# ********************************************************************************************************* #
# Demo Python class to read and write GBTx ASIC with the USB-I2C dongle                                     #
# Written with Python 2.7.6 - requires pywinusb                                                             #
# ********************************************************************************************************* #
# ********************************************************************************************************* #
#   History:                                                                                                #
#   2015/09/06      D. Porret   : Created. 																	#
#   2018/08/29      E. Mendes   : 3 new functions: Dump Configuration + reset + read Idle state             #                                                     #
# ********************************************************************************************************* #

__author__ = 'dporret'

from usb_dongle import USB_dongle
import time
import xml.etree.ElementTree as ET

class GBTx():
    """Class for GBTx functions"""
    def __init__(self, interface_id=None):
        self.gbtx_address=112
        # dongle init
        self.my_interface=USB_dongle()
        self.my_interface.setvtargetldo(1)
        self.my_interface.i2c_connect(1)
        print(self.my_interface.i2c_scan(1,200))

    def gbtx_write_register(self,register,value):
        """write a value to a register"""
        reg_add_l=register&0xFF
        reg_add_h=(register>>8)&0xFF
        payload=[reg_add_l]+[reg_add_h]+[value]
        #print payload
        self.my_interface.i2c_write(self.gbtx_address,payload)
        
    def gbtx_read_register(self,register):
        """read a value from a register - return register byte value"""
        reg_add_l=register&0xFF
        reg_add_h=(register>>8)&0xFF
        payload=[reg_add_l]+[reg_add_h]
        answer= self.my_interface.i2c_writeread(self.gbtx_address,1,payload)
        return answer[1]

    def gbtx_read_block_registers(self,register_idx=45):
        """return error code + 15 consecutive registers from index value as list"""
        reg_add_l=register_idx&0xFF
        reg_add_h=(register_idx>>8)&0xFF
        payload=[reg_add_l]+[reg_add_h]
        #print "registers : %d -> %d" %(register_idx,register_idx+13)
        return self.my_interface.i2c_writeread(self.gbtx_address,15,payload)[1:]
		
    def gbtx_dump_config(self,config_file = 'Loopback_test.xml'): # 'GBTx_config_hptd_test.txt'
        """dump configuration to GBTx - accepts .txt of .xml input"""
        # Read configuration file
        if(config_file[-4:] == '.xml'):
            tree = ET.parse(config_file)
            root = tree.getroot()
            reg_config = []
            for i in range(0,366):
                reg_config.append([0,0]) # Value / Mask

            for child in root:
                name_signal = child.attrib['name']
                triplicated = child.attrib['triplicated']
                reg_value   = int(child[0].text)
                if(triplicated in ['true', 'True', 'TRUE']) : n=3
                else                                        : n=1
                for i in range(1,n+1):
                    #print(name_signal)
                    #print(triplicated)
                    #print(reg_value)
                    reg_addr = int(child[i].attrib['startAddress'])
                    startbit = int(child[i].attrib['startBitIndex'])
                    endbit   = int(child[i].attrib['lastBitIndex'])
                    mask     = 2**(startbit+1) - 2**(endbit)
                    reg_config[reg_addr][0] = reg_config[reg_addr][0] | (reg_value << startbit)
                    reg_config[reg_addr][1] = reg_config[reg_addr][1] | mask

            for reg_addr in range(0,len(reg_config)):
                value = reg_config[reg_addr][0]
                mask  = reg_config[reg_addr][1]
                if(mask != 0):
                    value = self.gbtx_read_register(reg_addr)
                    value = (value & (~mask)) | value
                    self.gbtx_write_register(reg_addr, value)
        else:
            with open(config_file, 'r') as f:
                config = f.read()
                config = config.split('\n')
                for reg_addr in range(0,len(config)-1):
                    value = int(config[reg_addr],16)
                    self.gbtx_write_register(reg_addr, value)
        print('GBTx Configuration Done')

    def gbtx_reset(self,register_idx=45):
        """reset the 1.5V DC-DC to GBTx"""
        self.my_interface.setod1(1)
        time.sleep(0.5)
        self.my_interface.setod1(0)
        time.sleep(0.5)

    def vtrx_reset(self,register_idx=45):
        """reset the 2.5V DC-DC to VTRx"""
        self.my_interface.setod2(1)
        time.sleep(0.5)
        self.my_interface.setod2(0)
        time.sleep(0.5)

    def get_gbtx_idle(self):
        """read a value from a register - return register byte value"""
        idle_bool = ((self.gbtx_read_register(431) >> 2) & 0x1F) == 0b11000 
        return int(idle_bool)
		
if __name__ == '__main__':

    gbt=GBTx()
    gbt.gbtx_address=115

    for i in range (0, 421,15):
        print (gbt.gbtx_read_block_registers(i))
