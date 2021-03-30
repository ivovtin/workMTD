-makelib ies_lib/xil_defaultlib -sv \
  "/home/software/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/home/software/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/gtwizard_ultrascale_v1_7_5 \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_bit_sync.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gte4_drp_arb.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_delay_powergood.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_delay_powergood.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe3_cpll_cal.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe3_cal_freqcnt.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_rx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_tx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cal_freqcnt.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_rx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_tx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cal_freqcnt.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_rx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_tx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_reset.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_rx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_tx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_rx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_tx.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_reset_sync.v" \
  "../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_reset_inv_sync.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/ip_0/sim/gtwizard_ultrascale_v1_7_gthe3_channel.v" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/ip_0/sim/gig_ethernet_pcs_pma_basex_156_25_gt_gthe3_channel_wrapper.v" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/ip_0/sim/gig_ethernet_pcs_pma_basex_156_25_gt_gtwizard_gthe3.v" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/ip_0/sim/gig_ethernet_pcs_pma_basex_156_25_gt_gtwizard_top.v" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/ip_0/sim/gig_ethernet_pcs_pma_basex_156_25_gt.v" \
-endlib
-makelib ies_lib/gig_ethernet_pcs_pma_v16_1_5 \
  "../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_1_rfs.vhd" \
-endlib
-makelib ies_lib/gig_ethernet_pcs_pma_v16_1_5 \
  "../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_1_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25_resets.vhd" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25_clocking.vhd" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25_support.vhd" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25_reset_sync.vhd" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25_sync_block.vhd" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/transceiver/gig_ethernet_pcs_pma_basex_156_25_transceiver.vhd" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25_block.vhd" \
  "../../../../../../ipBUS_Lib/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

