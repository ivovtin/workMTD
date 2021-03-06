# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xcku040-ffva1156-2-e

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.cache/wt [current_project]
set_property parent.project_path /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.xpr [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part xilinx.com:kcu105:part0:1.1 [current_project]
set_property ip_output_repo /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_clock_div.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/clocks_us_serdes.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/lpgbtfpga_package.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/descrambler_51bitOrder49.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/descrambler_53bitOrder49.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/descrambler_58bitOrder58.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/descrambler_60bitOrder58.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/emac_hostbus_decl.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/eth_us_1000basex.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/fec_rsDecoderN15K13.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/fec_rsDecoderN31K29.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/PRBS/prbs_pattern_generator.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/PRBS/gbt_rx_checker.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/SCA/sca_pkg.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/GBT-SC/gbtsc_top.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/GBT-SC/IC/ic_deserializer.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/GBT-SC/IC/ic_rx.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/GBT-SC/IC/ic_rx_fifo.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/GBT-SC/IC/ic_top.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/GBT-SC/IC/ic_tx.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_package.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_trans_decl.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_reg_types.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_decode_ipbus_example.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_fabric_sel.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/new/ipBUS_EC_bram.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_bram.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_ipaddr_block.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_rarp_block.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_build_arp.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_build_payload.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_build_ping.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_build_resend.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_build_status.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_status_buffer.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_byte_sum.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_do_rx_reset.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_packet_parser.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_rxram_mux.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_dualportram.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_buffer_selector.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_rxram_shim.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_dualportram_rx.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_dualportram_tx.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_rxtransactor_if_simple.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_tx_mux.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_txtransactor_if_simple.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_clock_crossing_if.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/udp_if_flat.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/trans_arb.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/transactor_if.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/transactor_sm.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/transactor_cfg.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/transactor.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_ctrl.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_ctrlreg_v.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_reg_v.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/PRBS/prbs.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/led_stretcher.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/ipbus_example.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/kcu105_basex_infra.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/lpbgtfpga_downlink.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/lpgbtfpga_10g24.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/lpgbtfpga_decoder.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/lpgbtfpga_deinterleaver.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/lpgbtfpga_descrambler.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/downlink/lpgbtfpga_encoder.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/lpgbtfpga_framealigner.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/downlink/lpgbtfpga_interleaver.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/ipBUS_Lib/sources_1/payload_example.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/lpgbtfpga_patternchecker.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/lpgbtfpga_patterngen.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/uplink/lpgbtfpga_rxgearbox.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/downlink/lpgbtfpga_scrambler.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/downlink/lpgbtfpga_txgearbox.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/lpgbtfpga_uplink.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/prbs/prbs7_16b_checker.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/prbs/prbs7_2b_generator.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/prbs/prbs7_32b_checker.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/prbs/prbs7_4b_checker.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/prbs/prbs7_4b_generator.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/prbs/prbs7_8b_checker.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/prbs/prbs7_8b_generator.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/LpGBT-FPGA/downlink/rs_encoder_N7K5.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/SCA/sca_deserializer.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/SCA/sca_rx.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/SCA/sca_rx_fifo.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/SCA/sca_top.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/SCA/sca_tx.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/Mgt/xlx_ku_mgt_ip_reset_synchronizer.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/software/lpGBT/lpgbt-fpga-kcu105/mgt/10g24/xlx_ku_mgt_10g24.vhd
  /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/imports/home/alkozyre/cernbox/Alexey_BTL/lpgbt-fpga-kcu105/hdl/lpgbtfpga_kcu105_10g24_top.vhd
}
read_ip -quiet /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/gig_ethernet_pcs_pma_basex_156_25.xci
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/gig_ethernet_pcs_pma_basex_156_25_board.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/synth/gig_ethernet_pcs_pma_basex_156_25_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/ip_0/synth/gig_ethernet_pcs_pma_basex_156_25_gt_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/gig_ethernet_pcs_pma_basex_156_25/ip_0/synth/gig_ethernet_pcs_pma_basex_156_25_gt.xdc]

read_ip -quiet /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/temac_gbe_v9_0/temac_gbe_v9_0.xci
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/temac_gbe_v9_0/synth/temac_gbe_v9_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/temac_gbe_v9_0/synth/temac_gbe_v9_0.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/temac_gbe_v9_0/synth/temac_gbe_v9_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/temac_gbe_v9_0/synth/temac_gbe_v9_0_clocks.xdc]

read_ip -quiet /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/vio_0/vio_0.xci
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/vio_0/vio_0.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/vio_0/vio_0_ooc.xdc]

read_ip -quiet /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/xlx_ku_mgt_ip_10g24/ip/xlx_ku_mgt_ip_10g24/xlx_ku_mgt_ip_10g24.xci
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/xlx_ku_mgt_ip_10g24/ip/xlx_ku_mgt_ip_10g24/synth/xlx_ku_mgt_ip_10g24_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/xlx_ku_mgt_ip_10g24/ip/xlx_ku_mgt_ip_10g24/synth/xlx_ku_mgt_ip_10g24.xdc]

read_ip -quiet /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci
set_property used_in_implementation false [get_files -all /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/constrs_1/imports/Alexey_BTL/lpgbt-fpga-kcu105/constraints/kcu105_clks.xdc
set_property used_in_implementation false [get_files /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/constrs_1/imports/Alexey_BTL/lpgbt-fpga-kcu105/constraints/kcu105_clks.xdc]

read_xdc /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/constrs_1/imports/Alexey_BTL/lpgbt-fpga-kcu105/constraints/kcu105_io.xdc
set_property used_in_implementation false [get_files /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/constrs_1/imports/Alexey_BTL/lpgbt-fpga-kcu105/constraints/kcu105_io.xdc]

read_xdc -unmanaged /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/constrs_1/imports/Alexey_BTL/ipBUS_Lib/constrs_1/clock_utils.tcl
set_property used_in_implementation false [get_files /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/constrs_1/imports/Alexey_BTL/ipBUS_Lib/constrs_1/clock_utils.tcl]

read_xdc -unmanaged /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/constrs_1/imports/Alexey_BTL/ipBUS_Lib/constrs_1/kcu105_basex.tcl
set_property used_in_implementation false [get_files /home/alkozyre/cernbox/Alexey_BTL/scripts/example/lpgbt-fpga-kcu105_Ver_9/lpgbt-fpga-kcu105_Ver_9.srcs/constrs_1/imports/Alexey_BTL/ipBUS_Lib/constrs_1/kcu105_basex.tcl]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top lpgbtfpga_kcu105_10g24_top -part xcku040-ffva1156-2-e


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef lpgbtfpga_kcu105_10g24_top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file lpgbtfpga_kcu105_10g24_top_utilization_synth.rpt -pb lpgbtfpga_kcu105_10g24_top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
