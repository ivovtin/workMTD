vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vcom -work xil_defaultlib -64 -93 \
"../../../../lpgbt-fpga-kcu105-10g24.srcs/sources_1/ip/vio_0/sim/vio_0.vhd" \


