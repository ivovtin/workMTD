from lpgbt_registers import *
from gbt_vldb import *
import time

class lpgbt_evb():

    def __init__(self, interface_id=None):
        self.lpgbt = GBTx(interface_id)
			
    def init_lpgbt(self, modulation_current=64):
        # Configure lpGBT
        print('RESET lpGBT') 
        self.LpGBT_RESET()
        self.Read_PAUSE_FOR_PLL_CONFIG()
        self.Clock_generator_setup()
        self.line_driver_setup(modulation_current, False, False, 0)
        self.equalizer_setup()
        self.power_up_PLL_Config_done()
        self.Read_READY()
        time.sleep(1)

    ## Clock generator setup ##
    def Read_PAUSE_FOR_PLL_CONFIG(self):
        """ Read Pause for PLL config state"""
    
        read_reg = self.lpgbt.gbtx_read_register(PUSMSTATUS)
    
        if(read_reg == STATE_PAUSE_FOR_PLL_CONFIG_DONE):
            print("[OK]: State Pause for PLL config Done")
        else:
            print("[ERROR]: State not OK: NOT PAUSE FOR PLL CONFIG DONE STATE")
    
    def Clock_generator_setup(self):
        """ Writes default configuration for Clock Generator"""
        
        self.lpgbt.gbtx_write_register(REFCLK, REFCLK_REFCLKACBIAS_bm | REFCLK_REFCLKTERM_bm)
        
        self.lpgbt.gbtx_write_register(CLKGCONFIG0, (15 << CLKGCONFIG0_CLKGCALIBRATIONENDOFCOUNT_of |
                                                     8 << CLKGCONFIG0_CLKGBIASGENCONFIG_of))
        self.lpgbt.gbtx_write_register(CLKGCONFIG1, (CLKGCONFIG1_CLKGCDRRES_bm |
                                                     4 << CLKGCONFIG1_CLKGVCODAC_of))
        self.lpgbt.gbtx_write_register(CLKGPLLINTCUR, (5 <<CLKGPLLINTCUR_CLKGPLLINTCURWHENLOCKED_of |
                                                       5 <<CLKGPLLINTCUR_CLKGPLLINTCUR_of))
        self.lpgbt.gbtx_write_register(CLKGPLLPROPCUR, (5 <<CLKGPLLPROPCUR_CLKGPLLPROPCURWHENLOCKED_of |
                                                        5 <<CLKGPLLPROPCUR_CLKGPLLPROPCUR_of))
        self.lpgbt.gbtx_write_register(CLKGPLLRES, (4 <<CLKGPLLRES_CLKGPLLRESWHENLOCKED_of |
                                                    4 <<CLKGPLLRES_CLKGPLLRES_of))
        self.lpgbt.gbtx_write_register(CLKGFFCAP, (6 <<CLKGFFCAP_CLKGFEEDFORWARDCAPWHENLOCKED_of |
                                                   6 <<CLKGFFCAP_CLKGFEEDFORWARDCAP_of))
        self.lpgbt.gbtx_write_register(CLKGCDRINTCUR, (5 <<CLKGCDRINTCUR_CLKGCDRINTCURWHENLOCKED_of |
                                                       5 <<CLKGCDRINTCUR_CLKGCDRINTCUR_of))
        self.lpgbt.gbtx_write_register(CLKGFLLINTCUR, (0 <<CLKGFLLINTCUR_CLKGFLLINTCURWHENLOCKED_of |
                                                       0xF <<CLKGCDRINTCUR_CLKGCDRINTCUR_of))
        self.lpgbt.gbtx_write_register(CLKGCDRPROPCUR, (5 <<CLKGCDRPROPCUR_CLKGCDRPROPCURWHENLOCKED_of |
                                                        5 <<CLKGCDRPROPCUR_CLKGCDRPROPCUR_of))
        self.lpgbt.gbtx_write_register(CLKGCDRFFPROPCUR, (5 <<CLKGCDRFFPROPCUR_CLKGCDRFEEDFORWARDPROPCURWHENLOCKED_of |
                                                          5 <<CLKGCDRFFPROPCUR_CLKGCDRFEEDFORWARDPROPCUR_of))
        self.lpgbt.gbtx_write_register(CLKGLFCONFIG0, (CLKGLFCONFIG0_CLKGLOCKFILTERENABLE_bm |
                                                       9<<CLKGLFCONFIG0_CLKGLOCKFILTERLOCKTHRCOUNTER_of))
        self.lpgbt.gbtx_write_register(CLKGLFCONFIG1, (9<<CLKGLFCONFIG1_CLKGLOCKFILTERRELOCKTHRCOUNTER_of |
                                                       9<<CLKGLFCONFIG1_CLKGLOCKFILTERUNLOCKTHRCOUNTER_of))
        self.lpgbt.gbtx_write_register(CLKGWAITTIME, (0xa<<CLKGWAITTIME_CLKGWAITCDRTIME_of))
        
        self.lpgbt.gbtx_write_register(EPRXDLLCONFIG, 3<<EPRXDLLCONFIG_EPRXDLLCURRENT_of| \
                                       2<<EPRXDLLCONFIG_EPRXDLLCONFIRMCOUNT_of| \
                                       EPRXDLLCONFIG_EPRXDLLCOARSELOCKDETECTION_bm)
        
        self.lpgbt.gbtx_write_register(PSDLLCONFIG, 0xa)
        
        self.lpgbt.gbtx_write_register(FAMAXHEADERFOUNDCOUNT, 0x0a)
        self.lpgbt.gbtx_write_register(FAMAXHEADERFOUNDCOUNTAFTERNF, 0x1a)
        self.lpgbt.gbtx_write_register(FAMAXHEADERNOTFOUNDCOUNT, 0x2a)
        self.lpgbt.gbtx_write_register(FAFAMAXSKIPCYCLECOUNTAFTERNF, 0x3a)
    
        print("Clock generator programing done\n")
    
    
    def line_driver_setup(self,modulation_current=64, emphasis_enable=False,
                          emphasis_short=False, emphasis_amp=32):
        """ Configures line driver
        
        Args:
        
            emphasis_enable: Enable pre-emphasis in the line driver. The amplitude of
                             the pre-emphasis is controlled by LDEmphasisAmp[6:0] and
                             the duration by LDEmphasisShort.
            modulation_current: Sets high-speed line driver modulation current:
                                Im = 137 uA * modulation_current
            emphasis_short: Sets the duration of the pre-emphasis pulse. Please not that
                            pre-emphasis has to be enabled (LDEmphasisEnable) for this
                            field to have any impact.
            emphasis_amp: Sets high-speed line driver pre-emphasis current:
                          Ipre = 137 uA * LDEmphasisAmp
                          Please note that pre-emphasis has to be enabled for these
                          registers bits to be active.
        """
        modulation_current = int(modulation_current)&0x7F
        ldconfig_h = modulation_current<<LDCONFIGH_LDMODULATIONCURRENT_of
        if emphasis_enable:
            ldconfig_h |= LDCONFIGH_LDEMPHASISENABLE_bm
        
        ldconfig_l = emphasis_amp << LDCONFIGL_LDEMPHASISAMP_of
        if emphasis_short:
            ldconfig_l |= LDCONFIGL_LDEMPHASISSHORT_bm
        
        self.lpgbt.gbtx_write_register(LDCONFIGH, ldconfig_h)
        self.lpgbt.gbtx_write_register(LDCONFIGL, ldconfig_l)
    
    
    def equalizer_setup(self,attenuation=3, cap=0, res0=0, res1=0, res2=0, res3=0):
        """Configures equalizer"""
    
        eq_config = attenuation << EQCONFIG_EQATTENUATION_of |\
                    cap << EQCONFIG_EQCAP_of
        
        self.lpgbt.gbtx_write_register(EQCONFIG, eq_config)
    
        eq_res = res3 << EQRES_EQRES3_of | \
                 res2 << EQRES_EQRES2_of | \
                 res1 << EQRES_EQRES1_of | \
                 res0 << EQRES_EQRES0_of
                 
        self.lpgbt.gbtx_write_register(EQRES, eq_res)
        
        print("Equalizer programing done\n")
    
        
    def power_up_PLL_Config_done(self):
        """Power up after PLL config done"""
        
        self.lpgbt.gbtx_write_register(POWERUP2, POWERUP2_DLLCONFIGDONE_bm | POWERUP2_PLLCONFIGDONE_bm)
    	
    	
        print("Powerup configuration programing done\n")
    
    def Read_READY(self, timeout=10):
        """Read ready state"""
        ready = 0
        t0 = time.time()
        tdelta = 0		
        while(not ready and tdelta<timeout):		
            read_reg = self.lpgbt.gbtx_read_register(PUSMSTATUS)
            
            if(read_reg == STATE_READY):
                ready=1			
            tdelta = time.time() - t0

        if(ready):			
            print("[OK]: State READY")
        else:
            print("[ERROR]: State not OK: NOT READY STATE - STATE=" + str(read_reg))

        return ready

    def enable_fec_mon(self):
        self.lpgbt.gbtx_write_register(PROCESSANDSEUMONITOR, 0x0)
        self.lpgbt.gbtx_write_register(PROCESSANDSEUMONITOR, PROCESSANDSEUMONITOR_DLDPFECCOUNTERENABLE_bm)

    def read_fec_mon(self):
        errors_msb = self.lpgbt.gbtx_read_register(DLDPFECCORRECTIONCOUNTH)
        errors_lsb = self.lpgbt.gbtx_read_register(DLDPFECCORRECTIONCOUNTL)
        return (errors_msb<<8) + errors_lsb

    def eclk_setup(self, clk_id, freq=0, drive_strength=4, preemphasis_strength=0,
                   preemphasis_mode=0, preemphasis_width=0, invert=False):
        """Configures eClock

        Params:
            freq: frequency (EPORTCLOCKS_CLK40M, EPORTCLOCKS_CLK80M, ...)
        """
        config_high = freq << EPCLK0CHNCNTRH_EPCLK0FREQ_of | \
                      drive_strength << EPCLK0CHNCNTRH_EPCLK0DRIVESTRENGTH_of
        if invert:
            config_high |= EPCLK0CHNCNTRH_EPCLK0INVERT_bm

        config_low = preemphasis_width << EPCLK0CHNCNTRL_EPCLK0PREEMPHASISWIDTH_of | \
                     preemphasis_mode << EPCLK0CHNCNTRL_EPCLK0PREEMPHASISMODE_of | \
                     preemphasis_strength << EPCLK0CHNCNTRL_EPCLK0PREEMPHASISSTRENGTH_of

        self.lpgbt.gbtx_write_register(EPCLK0CHNCNTRH + 2*clk_id, config_high)
        self.lpgbt.gbtx_write_register(EPCLK0CHNCNTRL + 2*clk_id, config_low)

    def LpGBT_RESET(self):
        """ Reset of 0.5 s for the self.lpgbt"""
    
        self.lpgbt.gbtx_reset()
        time.sleep(1)

    def lpgbt_ber_raw_prbs7(self):


        #### lpGBT BER with raw PRBS-7 ####		
        # select the data source for the measurement
        self.lpgbt.gbtx_write_register(BERTSOURCE, (BC_DLFRAME<<4) + (DLFRAME_PRBS7<<0));
        
        # set the measurement time to 2**31 clock cycles (2.1G * 25 ns = 53.6s)
        config = (BC_MT_2e25 << BERTCONFIG_BERTMEASTIME_of) | BERTCONFIG_SKIPDISABLE_bm
        
        # start the measurement
        self.lpgbt.gbtx_write_register(BERTCONFIG, config)

        # Downlink frame contains 64 bits (2.56 Gbps)
        bits_per_clock_cycle = 64
        bits_checked         = 2**25 * bits_per_clock_cycle

        #print('STATUS BEFORE START: ' + str(self.lpgbt.gbtx_read_register(PUSMSTATUS)))
        #print('BERTCONFIG: ' + str(self.lpgbt.gbtx_read_register(BERTCONFIG)))
        #print('BERTSOURCE: ' + str(self.lpgbt.gbtx_read_register(BERTSOURCE)))
        time.sleep(1)		
        # start the measurement
        self.lpgbt.gbtx_write_register(BERTCONFIG, config | BERTCONFIG_BERTSTART_bm)
        #print('BERTCONFIG (AFTER START): ' + str(self.lpgbt.gbtx_read_register(BERTCONFIG)))
        ndone = 1
        while(ndone):
          status=self.lpgbt.gbtx_read_register(BERTSTATUS)	  
          ndone = not (status & BERTSTATUS_BERTDONE_bm)
        
        if status & BERTSTATUS_BERTPRBSERRORFLAG_bm:
            # stop the measurement by deaserting the start bit
            self.lpgbt.gbtx_write_register(BERTCONFIG, 0)
            raise Exception("BERT error flag (there was not data on the input)")
        
        # read the result
        bert_result = 0
        bert_result = bert_result + (self.lpgbt.gbtx_read_register(BERTRESULT0)<<(0*8))	
        bert_result = bert_result + (self.lpgbt.gbtx_read_register(BERTRESULT1)<<(1*8)) 	
        bert_result = bert_result + (self.lpgbt.gbtx_read_register(BERTRESULT2)<<(2*8)) 
        bert_result = bert_result + (self.lpgbt.gbtx_read_register(BERTRESULT3)<<(3*8))	
        bert_result = bert_result + (self.lpgbt.gbtx_read_register(BERTRESULT4)<<(4*8))

        #print('BERTRESULT0: ' + str(self.lpgbt.gbtx_read_register(BERTRESULT0)<<(0*8)))
        #print('BERTRESULT1: ' + str(self.lpgbt.gbtx_read_register(BERTRESULT1)<<(0*8)))
        #print('BERTRESULT2: ' + str(self.lpgbt.gbtx_read_register(BERTRESULT2)<<(0*8)))
        #print('BERTRESULT3: ' + str(self.lpgbt.gbtx_read_register(BERTRESULT3)<<(0*8)))
        #print('BERTRESULT4: ' + str(self.lpgbt.gbtx_read_register(BERTRESULT4)<<(0*8)))
        #
        #print('STATUS AFTER MEASUREMENT: ' + str(self.lpgbt.gbtx_read_register(PUSMSTATUS)))
        self.lpgbt.gbtx_write_register(BERTCONFIG, config)
        #print('STATUS AFTER BERT CONFIG0: ' + str(self.lpgbt.gbtx_read_register(PUSMSTATUS)))
        # calculate Bit Error Rate
        #print('TOTAL_ERRORS: ' + str(bert_result))
        if(bert_result>0):ber = bert_result / bits_checked
        else: ber = 1/bits_checked


        return ber
    def enable_EC(self):

        self.eclk_setup(28,1,7)

        self.lpgbt.gbtx_write_register(PIODIRH,0xff<<PIODIRH_PIODIR_of)
        self.lpgbt.gbtx_write_register(PIODIRL,0xff<<PIODIRL_PIODIR_of)
        self.lpgbt.gbtx_write_register(PIOOUTH,0x0<<PIOOUTH_PIOOUT_of)
        

        time.sleep(1)
        self.lpgbt.gbtx_write_register(PIOOUTL,0x3<<PIOOUTL_PIOOUT_of)
        print("GPIO H ", self.lpgbt.gbtx_read_register(PIOINH))
        print("GPIO L ", self.lpgbt.gbtx_read_register(PIOINL))

        
        # enable EC output
        self.lpgbt.gbtx_write_register(EPTXCONTROL,EPTXCONTROL_EPTXECENABLE_bm)
        ##       writeReg(getNode("LPGBT.RWF.EPORTTX.EPTXECENABLE"), 0x1, readback)

        self.lpgbt.gbtx_write_register(EPTXECCHNCNTR,7<<EPTXECCHNCNTR_EPTXECDRIVESTRENGTH_of)    
        self.lpgbt.gbtx_write_register(EPRXECCHNCNTR,EPRXECCHNCNTR_EPRXECTERM_bm|EPRXECCHNCNTR_EPRXECENABLE_bm | EPRXECCHNCNTR_EPRXECACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRXECCONTROL,2<<EPRXECCONTROL_EPRXECTRACKMODE_of)

    def enable_etxlinks(self):

        self.lpgbt.gbtx_write_register(EPTX10ENABLE, EPTX10ENABLE_EPTX13ENABLE_bm | EPTX10ENABLE_EPTX12ENABLE_bm | EPTX10ENABLE_EPTX11ENABLE_bm |EPTX10ENABLE_EPTX10ENABLE_bm |EPTX10ENABLE_EPTX00ENABLE_bm |EPTX10ENABLE_EPTX01ENABLE_bm |EPTX10ENABLE_EPTX02ENABLE_bm |EPTX10ENABLE_EPTX03ENABLE_bm )

        self.lpgbt.gbtx_write_register(EPTX32ENABLE, EPTX32ENABLE_EPTX33ENABLE_bm | EPTX32ENABLE_EPTX32ENABLE_bm | EPTX32ENABLE_EPTX31ENABLE_bm |EPTX32ENABLE_EPTX30ENABLE_bm |EPTX32ENABLE_EPTX20ENABLE_bm |EPTX32ENABLE_EPTX21ENABLE_bm |EPTX32ENABLE_EPTX22ENABLE_bm |EPTX32ENABLE_EPTX23ENABLE_bm )

        time.sleep(1)

        self.lpgbt.gbtx_write_register(EPTXDATARATE,1<<EPTXDATARATE_EPTX3DATARATE_of | 1 << EPTXDATARATE_EPTX2DATARATE_of | 1 << EPTXDATARATE_EPTX1DATARATE_of | 1 << EPTXDATARATE_EPTX0DATARATE_of)    


        self.lpgbt.gbtx_write_register(EPTX00CHNCNTR,7<<EPTX00CHNCNTR_EPTX00DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX01CHNCNTR,7<<EPTX01CHNCNTR_EPTX01DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX02CHNCNTR,7<<EPTX02CHNCNTR_EPTX02DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX03CHNCNTR,7<<EPTX03CHNCNTR_EPTX03DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX10CHNCNTR,7<<EPTX10CHNCNTR_EPTX10DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX11CHNCNTR,7<<EPTX11CHNCNTR_EPTX11DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX12CHNCNTR,7<<EPTX12CHNCNTR_EPTX12DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX13CHNCNTR,7<<EPTX13CHNCNTR_EPTX13DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX20CHNCNTR,7<<EPTX20CHNCNTR_EPTX20DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX21CHNCNTR,7<<EPTX21CHNCNTR_EPTX21DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX22CHNCNTR,7<<EPTX22CHNCNTR_EPTX22DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX23CHNCNTR,7<<EPTX23CHNCNTR_EPTX23DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX30CHNCNTR,7<<EPTX30CHNCNTR_EPTX30DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX31CHNCNTR,7<<EPTX31CHNCNTR_EPTX31DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX32CHNCNTR,7<<EPTX32CHNCNTR_EPTX32DRIVESTRENGTH_of)    

        self.lpgbt.gbtx_write_register(EPTX33CHNCNTR,7<<EPTX33CHNCNTR_EPTX33DRIVESTRENGTH_of)    


    def enable_erxlinks(self):

#        self.lpgbt.gbtx_write_register(EPRXDLLCONFIG, 2 << EPRXDLLCONFIG_EPRXDLLCURRENT_of | 1 << EPRXDLLCONFIG_EPRXDLLCONFIRMCOUNT_of | EPRXDLLCONFIG_EPRXENABLEREINIT_bm |  EPRXDLLCONFIG_EPRXDLLFSMCLKALWAYSON_bm | EPRXDLLCONFIG_EPRXDLLFSMCLKALWAYSON_bm  ) 
        self.lpgbt.gbtx_write_register(EPRXDLLCONFIG, 3 << EPRXDLLCONFIG_EPRXDLLCURRENT_of | 3 << EPRXDLLCONFIG_EPRXDLLCONFIRMCOUNT_of | EPRXDLLCONFIG_EPRXENABLEREINIT_bm | EPRXDLLCONFIG_EPRXDATAGATINGENABLE_bm   ) 
        
        self.lpgbt.gbtx_write_register(EPRX0CONTROL,  EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX02ENABLE_bm | EPRX0CONTROL_EPRX01ENABLE_bm | EPRX0CONTROL_EPRX00ENABLE_bm | 1 << EPRX0CONTROL_EPRX0DATARATE_of | 2 << EPRX0CONTROL_EPRX0TRACKMODE_of ) 
        self.lpgbt.gbtx_write_register(EPRX00CHNCNTR,EPRX00CHNCNTR_EPRX00TERM_bm | EPRX00CHNCNTR_EPRX00ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX01CHNCNTR,EPRX01CHNCNTR_EPRX01TERM_bm | EPRX01CHNCNTR_EPRX01ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX02CHNCNTR,EPRX02CHNCNTR_EPRX02TERM_bm | EPRX02CHNCNTR_EPRX02ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX03CHNCNTR,EPRX03CHNCNTR_EPRX03TERM_bm | EPRX03CHNCNTR_EPRX03ACBIAS_bm)

        self.lpgbt.gbtx_write_register(EPRX1CONTROL,  EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX02ENABLE_bm | EPRX0CONTROL_EPRX01ENABLE_bm | EPRX0CONTROL_EPRX00ENABLE_bm | 1 << EPRX0CONTROL_EPRX0DATARATE_of | 2 << EPRX0CONTROL_EPRX0TRACKMODE_of ) 
        self.lpgbt.gbtx_write_register(EPRX10CHNCNTR,EPRX10CHNCNTR_EPRX10TERM_bm | EPRX10CHNCNTR_EPRX10ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX11CHNCNTR,EPRX11CHNCNTR_EPRX11TERM_bm | EPRX11CHNCNTR_EPRX11ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX12CHNCNTR,EPRX12CHNCNTR_EPRX12TERM_bm | EPRX12CHNCNTR_EPRX12ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX13CHNCNTR,EPRX13CHNCNTR_EPRX13TERM_bm | EPRX13CHNCNTR_EPRX13ACBIAS_bm)
#
        self.lpgbt.gbtx_write_register(EPRX2CONTROL,  EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX02ENABLE_bm | EPRX0CONTROL_EPRX01ENABLE_bm | EPRX0CONTROL_EPRX00ENABLE_bm | 1 << EPRX0CONTROL_EPRX0DATARATE_of | 2 << EPRX0CONTROL_EPRX0TRACKMODE_of ) 
        self.lpgbt.gbtx_write_register(EPRX20CHNCNTR,EPRX20CHNCNTR_EPRX20TERM_bm | EPRX20CHNCNTR_EPRX20ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX21CHNCNTR,EPRX21CHNCNTR_EPRX21TERM_bm | EPRX21CHNCNTR_EPRX21ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX22CHNCNTR,EPRX22CHNCNTR_EPRX22TERM_bm | EPRX22CHNCNTR_EPRX22ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX23CHNCNTR,EPRX23CHNCNTR_EPRX23TERM_bm | EPRX23CHNCNTR_EPRX23ACBIAS_bm)

        self.lpgbt.gbtx_write_register(EPRX3CONTROL,  EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX02ENABLE_bm | EPRX0CONTROL_EPRX01ENABLE_bm | EPRX0CONTROL_EPRX00ENABLE_bm | 1 << EPRX0CONTROL_EPRX0DATARATE_of | 2 << EPRX0CONTROL_EPRX0TRACKMODE_of ) 
        self.lpgbt.gbtx_write_register(EPRX30CHNCNTR,EPRX30CHNCNTR_EPRX30TERM_bm | EPRX30CHNCNTR_EPRX30ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX31CHNCNTR,EPRX31CHNCNTR_EPRX31TERM_bm | EPRX31CHNCNTR_EPRX31ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX32CHNCNTR,EPRX32CHNCNTR_EPRX32TERM_bm | EPRX32CHNCNTR_EPRX32ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX33CHNCNTR,EPRX33CHNCNTR_EPRX33TERM_bm | EPRX33CHNCNTR_EPRX33ACBIAS_bm)

        self.lpgbt.gbtx_write_register(EPRX4CONTROL,  EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX02ENABLE_bm | EPRX0CONTROL_EPRX01ENABLE_bm | EPRX0CONTROL_EPRX00ENABLE_bm | 1 << EPRX0CONTROL_EPRX0DATARATE_of | 3 << EPRX0CONTROL_EPRX0TRACKMODE_of ) 
        self.lpgbt.gbtx_write_register(EPRX40CHNCNTR,EPRX40CHNCNTR_EPRX40TERM_bm | EPRX40CHNCNTR_EPRX40ACBIAS_bm | 12 << EPRX50CHNCNTR_EPRX50PHASESELECT_of )
        self.lpgbt.gbtx_write_register(EPRX41CHNCNTR,EPRX41CHNCNTR_EPRX41TERM_bm | EPRX41CHNCNTR_EPRX41ACBIAS_bm | 12 << EPRX50CHNCNTR_EPRX50PHASESELECT_of )
        self.lpgbt.gbtx_write_register(EPRX42CHNCNTR,EPRX42CHNCNTR_EPRX42TERM_bm | EPRX42CHNCNTR_EPRX42ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX43CHNCNTR,EPRX43CHNCNTR_EPRX43TERM_bm | EPRX43CHNCNTR_EPRX43ACBIAS_bm | 12 << EPRX50CHNCNTR_EPRX50PHASESELECT_of )

        self.lpgbt.gbtx_write_register(EPRX5CONTROL,  EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX02ENABLE_bm | EPRX0CONTROL_EPRX01ENABLE_bm | EPRX0CONTROL_EPRX00ENABLE_bm | 1 << EPRX0CONTROL_EPRX0DATARATE_of | 2 << EPRX0CONTROL_EPRX0TRACKMODE_of ) 
        self.lpgbt.gbtx_write_register(EPRX50CHNCNTR,EPRX50CHNCNTR_EPRX50TERM_bm | EPRX50CHNCNTR_EPRX50ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX51CHNCNTR,EPRX51CHNCNTR_EPRX51TERM_bm | EPRX51CHNCNTR_EPRX51ACBIAS_bm)#
        self.lpgbt.gbtx_write_register(EPRX52CHNCNTR,EPRX52CHNCNTR_EPRX52TERM_bm | EPRX52CHNCNTR_EPRX52ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX53CHNCNTR,EPRX53CHNCNTR_EPRX53TERM_bm | EPRX53CHNCNTR_EPRX53ACBIAS_bm)

#        time.sleep(2)

        self.lpgbt.gbtx_write_register(EPRX6CONTROL,  EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX03ENABLE_bm | EPRX0CONTROL_EPRX02ENABLE_bm | EPRX0CONTROL_EPRX01ENABLE_bm | EPRX0CONTROL_EPRX00ENABLE_bm | 1 << EPRX0CONTROL_EPRX0DATARATE_of | 2 << EPRX0CONTROL_EPRX0TRACKMODE_of ) 

        self.lpgbt.gbtx_write_register(EPRX60CHNCNTR,EPRX60CHNCNTR_EPRX60TERM_bm | EPRX60CHNCNTR_EPRX60ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX61CHNCNTR,EPRX61CHNCNTR_EPRX61TERM_bm | EPRX61CHNCNTR_EPRX61ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX62CHNCNTR,EPRX62CHNCNTR_EPRX62TERM_bm | EPRX62CHNCNTR_EPRX62ACBIAS_bm)
        self.lpgbt.gbtx_write_register(EPRX63CHNCNTR,EPRX63CHNCNTR_EPRX63TERM_bm | EPRX63CHNCNTR_EPRX63ACBIAS_bm)
