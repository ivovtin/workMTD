#-------------------------------------------------------------------------------
#
#   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#                                     - - -
#
#   Additional information about ipbus-firmare and the list of ipbus-firmware
#   contacts are available at
#
#       https://ipbus.web.cern.ch/ipbus
#
#-------------------------------------------------------------------------------


set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Ethernet RefClk (156MHz)
set_property PACKAGE_PIN P6 [get_ports eth_clk_p]
set_property PACKAGE_PIN P5 [get_ports eth_clk_n]
create_clock -period 6.4 -name eth_refclk [get_ports eth_clk_p]

## System clock (125MHz)
#set_property IOSTANDARD LVDS [get_ports {sysclk_*}]
#set_property PACKAGE_PIN G10 [get_ports sysclk_p]
#set_property PACKAGE_PIN F10 [get_ports sysclk_n]
#create_clock -period 8 -name sysclk [get_ports sysclk_p]
                                              
#set_property LOC GTHE3_CHANNEL_X0Y10 [get_cells -hier -filter {name=~infra/eth/*/*GTHE3_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN T2 [get_ports eth_rx_p]
set_property PACKAGE_PIN T1 [get_ports eth_rx_n]
set_property PACKAGE_PIN U4 [get_ports eth_tx_p]
set_property PACKAGE_PIN U3 [get_ports eth_tx_n]

# user LEDs
set_property IOSTANDARD LVCMOS18 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AP8 [get_ports {leds[0]}]
set_property PACKAGE_PIN H23 [get_ports {leds[1]}]
set_property PACKAGE_PIN P20 [get_ports {leds[2]}]
set_property PACKAGE_PIN P21 [get_ports {leds[3]}]
false_path {leds[*]} USER_CLOCK

# user DIP switches
set_property IOSTANDARD LVCMOS12 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN AN16 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN AN19 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN AP18 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN AN14 [get_ports {dip_sw[3]}]
false_path {dip_sw[*]} USER_CLOCK


set_property LOC GTHE3_CHANNEL_X0Y10 [get_cells -hier -filter {name=~infra/eth/*/*GTHE3_CHANNEL_PRIM_INST}]


# Clocks derived from system clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT2]

set_clock_groups -asynchronous -group [get_clocks USER_CLOCK] -group [get_clocks -include_generated_clocks clk_aux] -group [get_clocks -include_generated_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ *txoutclk*}]]


# relax the setup requirement
set_multicycle_path 3 -setup -from [get_pins payload/example/FER_RST_StrbAll_s_reg/C]
set_multicycle_path 2 -hold  -from [get_pins payload/example/FER_RST_StrbAll_s_reg/C]
set_multicycle_path 3 -setup -from [get_pins payload/example/ErrCntStrbOR_s_reg/C]
set_multicycle_path 2 -hold  -from [get_pins payload/example/ErrCntStrbOR_s_reg/C]


#set_multicycle_path 3 -setup -from [get_pins payload/example/ipb_SCA_rst_cmd_ES_s_reg/C] -to [get_pins payload/example/ipb_SCA_rst_cmd_ES_s_reg/D] 
#set_multicycle_path 2 -hold  -from [get_pins payload/example/ipb_SCA_rst_cmd_ES_s_reg/C] 
#set_multicycle_path 3 -setup -from [get_pins payload/example/ipb_SCA_connect_cmd_ES_s_reg/C] 
#set_multicycle_path 2 -hold  -from [get_pins payload/example/ipb_SCA_connect_cmd_ES_s_reg/C] 
#set_multicycle_path 3 -setup -from [get_pins payload/example/ipb_SCA_start_cmd_strb_s_reg/C] 
#set_multicycle_path 2 -hold  -from [get_pins payload/example/ipb_SCA_start_cmd_strb_s_reg/C]

#set_multicycle_path -from [get_clocks -of_objects [get_pins infra/clocks/mmcm/CLKOUT1]] -to [get_clocks -of_objects [get_pins {lpgbtFpga_top_inst/mgt_inst/xlx_ku_mgt_std_i/inst/gen_gtwizard_gthe3_top.xlx_ku_mgt_ip_10g24_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[0].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]] 2

#set_multicycle_path 3 -setup -from [get_pins {infra/ipbus/trans/sm/addr_reg[2]_replica/C}] -to [get_pins payload/example/rd_to_gbtic_Trig_si_reg/D]
#set_multicycle_path 2 -hold -from [get_pins {infra/ipbus/trans/sm/addr_reg[2]_replica/C}] -to [get_pins payload/example/rd_to_gbtic_Trig_si_reg/D]

#set_multicycle_path 3 -setup -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/reg_no_destuffing_reg[*]/C}] -to [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/cnter_reg[*]/R}]
#set_multicycle_path 2 -hold  -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/reg_no_destuffing_reg[*]/C}] -to [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/cnter_reg[*]/R}]

#set_multicycle_path 3 -setup -from [get_pins lpgbtFpga_top_inst/uplink_inst/rdy_1_s_reg/C] -to [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/cnter_reg[*]/R}]
#set_multicycle_path 2 -hold  -from [get_pins lpgbtFpga_top_inst/uplink_inst/rdy_1_s_reg/C] -to [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/cnter_reg[*]/R}]

#set_multicycle_path 3 -setup -from [get_pins {infra/ipbus/trans/sm/addr_reg[*]/C}] -to [get_pins payload/example/ipb_IC_read_Status_strb_s_reg/D] 
#set_multicycle_path 2 -hold  -from [get_pins {infra/ipbus/trans/sm/addr_reg[*]/C}] -to [get_pins payload/example/ipb_IC_read_Status_strb_s_reg/D]

#set_multicycle_path -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/reg_no_destuffing_reg[*]/C}] -to [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/data_o_reg[*]/CE}] 2
#set_multicycle_path 3 -setup -from [get_pins payload/example/ipb_SCA_rst_cmd_ES_s_reg/C]
#set_multicycle_path 2 -hold  -from [get_pins payload/example/ipb_SCA_rst_cmd_ES_s_reg/C]
#set_multicycle_path 3 -setup -from [get_pins payload/example/ipb_SCA_connect_cmd_ES_s_reg/C]
#set_multicycle_path 2 -hold  -from [get_pins payload/example/ipb_SCA_connect_cmd_ES_s_reg/C]
#set_multicycle_path 3 -setup -from [get_pins payload/example/ipb_SCA_start_cmd_ES_s_reg/C]
#set_multicycle_path 2 -hold  -from [get_pins payload/example/ipb_SCA_start_cmd_ES_s_reg/C]




set_multicycle_path 3 -setup -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/cnter_reg[*]/C}] 
set_multicycle_path 2 -hold  -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/cnter_reg[*]/C}]

set_multicycle_path 3 -setup -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/reg_no_destuffing_reg[*]/C}]
set_multicycle_path 2 -hold  -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/reg_no_destuffing_reg[*]/C}]

set_multicycle_path 3 -setup -from [get_pins lpgbtFpga_top_inst/uplink_inst/rdy_1_s_reg/C]
set_multicycle_path 2 -hold  -from [get_pins lpgbtFpga_top_inst/uplink_inst/rdy_1_s_reg/C]

set_multicycle_path 3 -setup -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/ongoing_reg/C}]
set_multicycle_path 2 -hold  -from [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/ongoing_reg/C}]

set_multicycle_path 3 -setup -to [get_pins payload/example/rd_to_gbtic_Trig_si_reg/D]
set_multicycle_path 2 -hold  -to [get_pins payload/example/rd_to_gbtic_Trig_si_reg/D]

set_multicycle_path 3 -setup -from [get_pins {payload/example/lpGBTsc_inst/ic_inst/tx_inst/reg_pos_reg[*]/C}]
set_multicycle_path 2 -hold  -from [get_pins {payload/example/lpGBTsc_inst/ic_inst/tx_inst/reg_pos_reg[*]/C}]




#set_multicycle_path 3 -setup -to [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/cnter_reg[*]/R}]
#set_multicycle_path 2 -hold  -to [get_pins {payload/example/lpGBTsc_inst/sca_inst/sca_gen[0].rx_inst/sca_deserializer_inst/cnter_reg[*]/R}]


# Multicycles Between FAST-to-SLOW Clocks
set_multicycle_path 4 -setup -start -from [get_clocks -filter {name =~ *rxoutclk*}] -to [get_clocks ipbus_clk]
set_multicycle_path 3 -hold -from [get_clocks -filter {name =~ *rxoutclk*}] -to [get_clocks ipbus_clk]

# Multicycles Between SLOW-to-FAST Clocks
set_multicycle_path 3 -setup -from [get_clocks ipbus_clk] -to [get_clocks -filter {name =~ *rxoutclk*}]
set_multicycle_path 2 -hold -end -from [get_clocks ipbus_clk] -to [get_clocks -filter {name =~ *rxoutclk*}]

# Clock Phase-Shift
#set_multicycle_path 2 -setup -from [get_clocks -filter {name =~ *txoutclk*}] -to [get_clocks -filter {name =~ *rxoutclk*}]