
# PART is kintexu xcku040ffva1156

############################################################
# Clock Period Constraints                                 #
############################################################

#
####
#######
##########
#############
#################
#BLOCK CONSTRAINTS

############################################################
# None
############################################################


#
####
#######
##########
#############
#################
#CORE CONSTRAINTS



############################################################
# Crossing of Clock Domain Constraints: please do not edit #
############################################################

# control signal is synced separately so we want a max delay to ensure the signal has settled by the time the control signal has passed through the synch
set_max_delay -from [get_cells {temac_gbe_v9_0_core/flow/rx_pause/pause*to_tx_reg[*]}] -to [get_cells {temac_gbe_v9_0_core/flow/tx_pause/count_set*reg}] 32 -datapath_only
set_max_delay -from [get_cells {temac_gbe_v9_0_core/flow/rx_pause/pause*to_tx_reg[*]}] -to [get_cells {temac_gbe_v9_0_core/flow/tx_pause/pause_count*reg[*]}] 32 -datapath_only
set_max_delay -from [get_cells {temac_gbe_v9_0_core/flow/rx_pause/pause_req_to_tx_int_reg}] -to [get_cells {temac_gbe_v9_0_core/flow/tx_pause/sync_good_rx/data_sync_reg0}] 6 -datapath_only





############################################################
# Ignore paths to resync flops
############################################################
set_false_path -to [get_pins -filter {REF_PIN_NAME =~ PRE} -of [get_cells -hier -regexp {.*\/async_rst.*}]]
set_false_path -to [get_pins -filter {REF_PIN_NAME =~ CLR} -of [get_cells -hier -regexp {.*\/async_rst.*}]]





