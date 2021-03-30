##===================================================================================================##
##=========================================  CLOCKS  ================================================##
##===================================================================================================##

##==============##
## FABRIC CLOCK ##
##==============##
set_property IOSTANDARD LVDS [get_ports USER_CLOCK_P]
set_property PACKAGE_PIN G10 [get_ports USER_CLOCK_P]
set_property IOSTANDARD LVDS [get_ports USER_CLOCK_N]
set_property PACKAGE_PIN F10 [get_ports USER_CLOCK_N]

create_clock -period 8.000 -name USER_CLOCK [get_ports USER_CLOCK_P]
set_clock_groups -asynchronous -group USER_CLOCK

##===========##
## MGT CLOCK ##
##===========##

## Comment: * The MGT reference clock MUST be provided by an external clock generator.
##
##          * The MGT reference clock frequency must be 320MHz.

set_property PACKAGE_PIN V6 [get_ports SMA_MGT_REFCLK_P]
set_property PACKAGE_PIN V5 [get_ports SMA_MGT_REFCLK_N]

create_clock -period 3.125 -name SMA_MGT_REFCLK [get_ports SMA_MGT_REFCLK_P]

# Optional constraint to use PMA slide: allow recovering the clock phase:
# set_property RXSLIDE_MODE PMA [get_cells -hier -filter {NAME =~ *GTHE3_CHANNEL_PRIM_INST}]

##====================##
## TIMING CONSTRAINTS ##
##====================##

# Multicycle constraints: ease the timing constraints

# Uplink constraints: Values depend on the c_multicyleDelay. Shall be the same one for setup time and -1 for the hold time
set_multicycle_path 3 -from [get_pins {lpgbtFpga_top_inst/uplink_inst/frame_pipelined_s_reg[*]/C}] -setup
set_multicycle_path 2 -from [get_pins {lpgbtFpga_top_inst/uplink_inst/frame_pipelined_s_reg[*]/C}] -hold
set_multicycle_path 3 -from [get_pins -hierarchical -filter {NAME =~ lpgbtFpga_top_inst/uplink_inst/*descrambledData_reg[*]/C}] -setup
set_multicycle_path 2 -from [get_pins -hierarchical -filter {NAME =~ lpgbtFpga_top_inst/uplink_inst/*descrambledData_reg[*]/C}] -hold

# Downlink constraints: Values depend on the c_multicyleDelay. Shall be the same one for setup time and -1 for the hold time
set_multicycle_path -setup -to [get_pins -hierarchical -filter {NAME =~ lpgbtFpga_top_inst/downlink_inst/lpgbtfpga_scrambler_inst/scrambledData*/D}] 3
set_multicycle_path -hold -to [get_pins -hierarchical -filter {NAME =~ lpgbtFpga_top_inst/downlink_inst/lpgbtfpga_scrambler_inst/scrambledData*/D}] 2