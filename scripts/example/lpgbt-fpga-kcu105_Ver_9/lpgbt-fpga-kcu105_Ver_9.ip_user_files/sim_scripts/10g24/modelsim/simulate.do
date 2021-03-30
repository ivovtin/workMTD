onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L gtwizard_ultrascale_v1_7_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.xlx_ku_mgt_ip_10g24 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {xlx_ku_mgt_ip_10g24.udo}

run -all

quit -force
