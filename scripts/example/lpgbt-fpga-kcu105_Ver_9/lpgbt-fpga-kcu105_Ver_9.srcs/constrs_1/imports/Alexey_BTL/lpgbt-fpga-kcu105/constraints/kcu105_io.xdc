##===================================================================================================##
##========================================  I/O PINS  ===============================================##
##===================================================================================================##
##=======##
## RESET ##
##=======##
set_property PACKAGE_PIN AN8 [get_ports CPU_RESET]
set_property IOSTANDARD LVCMOS18 [get_ports CPU_RESET]

##==========##
## MGT(GTX) ##
##==========##

## SERIAL LANES:
##--------------
# Use of SMAs
set_property PACKAGE_PIN D5 [get_ports SFP0_TX_N]
set_property PACKAGE_PIN D6 [get_ports SFP0_TX_P]
set_property PACKAGE_PIN D1 [get_ports SFP0_RX_N]
set_property PACKAGE_PIN D2 [get_ports SFP0_RX_P]

# Use of SMAs
#set_property PACKAGE_PIN R4 [get_ports SFP0_TX_P]
#set_property PACKAGE_PIN R3 [get_ports SFP0_TX_N]
#set_property PACKAGE_PIN P2 [get_ports SFP0_RX_P]
#set_property PACKAGE_PIN P1 [get_ports SFP0_RX_N]

# Use of SFP
#set_property PACKAGE_PIN U4 [get_ports SFP0_TX_P]
#set_property PACKAGE_PIN U3 [get_ports SFP0_TX_N]
#set_property PACKAGE_PIN T2 [get_ports SFP0_RX_P]
#set_property PACKAGE_PIN T1 [get_ports SFP0_RX_N]

## SFP CONTROL:
##-------------
set_property PACKAGE_PIN AL8 [get_ports SFP0_TX_DISABLE]
set_property IOSTANDARD LVCMOS18 [get_ports SFP0_TX_DISABLE]

##====================##
## SIGNALS FORWARDING ##
##====================##

## SMA OUTPUT:
##------------
set_property PACKAGE_PIN H27 [get_ports USER_SMA_GPIO_P]
set_property IOSTANDARD LVCMOS18 [get_ports USER_SMA_GPIO_P]
set_property SLEW FAST [get_ports USER_SMA_GPIO_P]

set_property PACKAGE_PIN G27 [get_ports USER_SMA_GPIO_N]
set_property IOSTANDARD LVCMOS18 [get_ports USER_SMA_GPIO_N]
set_property SLEW FAST [get_ports USER_SMA_GPIO_N]


#FireFly FMC Controls
# FireFly Control & Status Signals
set_property PACKAGE_PIN A13    [get_ports ff_tx_prsnt_n ]; # FMC 1: LA03_p
set_property PACKAGE_PIN K10    [get_ports ff_rx_prsnt_n ]; # FMC 1: LA02_p
set_property PACKAGE_PIN L12    [get_ports ff_tx_int_n   ]; # FMC 1: LA04_p
set_property PACKAGE_PIN H11    [get_ports ff_rx_int_n   ]; # FMC 1: LA00_p
set_property PACKAGE_PIN K12    [get_ports ff_tx_reset_n ]; # FMC 1: LA04_n
set_property PACKAGE_PIN G9     [get_ports ff_rx_reset_n ]; # FMC 1: LA01_p
set_property PACKAGE_PIN A12    [get_ports ff_tx_select_n]; # FMC 1: LA03_n
set_property PACKAGE_PIN G11    [get_ports ff_rx_select_n]; # FMC 1: LA00_n

set_property IOSTANDARD LVCMOS18 [get_ports ff_tx_prsnt_n ]
set_property IOSTANDARD LVCMOS18 [get_ports ff_rx_prsnt_n ]
set_property IOSTANDARD LVCMOS18 [get_ports ff_tx_int_n   ]
set_property IOSTANDARD LVCMOS18 [get_ports ff_rx_int_n   ]
set_property IOSTANDARD LVCMOS18 [get_ports ff_tx_reset_n ]
set_property IOSTANDARD LVCMOS18 [get_ports ff_rx_reset_n ]
set_property IOSTANDARD LVCMOS18 [get_ports ff_tx_select_n]
set_property IOSTANDARD LVCMOS18 [get_ports ff_rx_select_n]

set_property PULLUP TRUE [get_ports ff_tx_prsnt_n]
set_property PULLUP TRUE [get_ports ff_rx_prsnt_n]
set_property PULLUP TRUE [get_ports ff_tx_int_n]
set_property PULLUP TRUE [get_ports ff_rx_int_n]