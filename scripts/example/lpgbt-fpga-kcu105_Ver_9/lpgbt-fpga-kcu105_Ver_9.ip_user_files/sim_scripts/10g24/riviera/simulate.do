onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+xlx_ku_mgt_ip_10g24 -L gtwizard_ultrascale_v1_7_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.xlx_ku_mgt_ip_10g24 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {xlx_ku_mgt_ip_10g24.udo}

run -all

endsim

quit -force
