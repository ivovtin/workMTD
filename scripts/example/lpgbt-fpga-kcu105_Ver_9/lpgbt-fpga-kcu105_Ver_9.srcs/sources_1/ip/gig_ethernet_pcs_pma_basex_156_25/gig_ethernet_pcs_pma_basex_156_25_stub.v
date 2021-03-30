// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon Nov 18 20:44:10 2019
// Host        : laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               F:/Users/Alexey/Project/CERN/Xilinx/2018.3/Full_Prj/KCU105_Prj_Ver_0/KCU105_Prj_Ver_0.srcs/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/gig_ethernet_pcs_pma_basex_156_25_stub.v
// Design      : gig_ethernet_pcs_pma_basex_156_25
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku040-ffva1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "gig_ethernet_pcs_pma_v16_1_5,Vivado 2018.3" *)
module gig_ethernet_pcs_pma_basex_156_25(gtrefclk_p, gtrefclk_n, gtrefclk_out, txp, txn, 
  rxp, rxn, resetdone, userclk_out, userclk2_out, rxuserclk_out, rxuserclk2_out, pma_reset_out, 
  mmcm_locked_out, independent_clock_bufg, gmii_txd, gmii_tx_en, gmii_tx_er, gmii_rxd, 
  gmii_rx_dv, gmii_rx_er, gmii_isolate, configuration_vector, status_vector, reset, 
  gtpowergood, signal_detect)
/* synthesis syn_black_box black_box_pad_pin="gtrefclk_p,gtrefclk_n,gtrefclk_out,txp,txn,rxp,rxn,resetdone,userclk_out,userclk2_out,rxuserclk_out,rxuserclk2_out,pma_reset_out,mmcm_locked_out,independent_clock_bufg,gmii_txd[7:0],gmii_tx_en,gmii_tx_er,gmii_rxd[7:0],gmii_rx_dv,gmii_rx_er,gmii_isolate,configuration_vector[4:0],status_vector[15:0],reset,gtpowergood,signal_detect" */;
  input gtrefclk_p;
  input gtrefclk_n;
  output gtrefclk_out;
  output txp;
  output txn;
  input rxp;
  input rxn;
  output resetdone;
  output userclk_out;
  output userclk2_out;
  output rxuserclk_out;
  output rxuserclk2_out;
  output pma_reset_out;
  output mmcm_locked_out;
  input independent_clock_bufg;
  input [7:0]gmii_txd;
  input gmii_tx_en;
  input gmii_tx_er;
  output [7:0]gmii_rxd;
  output gmii_rx_dv;
  output gmii_rx_er;
  output gmii_isolate;
  input [4:0]configuration_vector;
  output [15:0]status_vector;
  input reset;
  output gtpowergood;
  input signal_detect;
endmodule
