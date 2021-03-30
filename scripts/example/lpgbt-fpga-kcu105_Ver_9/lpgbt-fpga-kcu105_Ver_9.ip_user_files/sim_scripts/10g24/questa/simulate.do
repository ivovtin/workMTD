onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib xlx_ku_mgt_ip_10g24_opt

do {wave.do}

view wave
view structure
view signals

do {xlx_ku_mgt_ip_10g24.udo}

run -all

quit -force
