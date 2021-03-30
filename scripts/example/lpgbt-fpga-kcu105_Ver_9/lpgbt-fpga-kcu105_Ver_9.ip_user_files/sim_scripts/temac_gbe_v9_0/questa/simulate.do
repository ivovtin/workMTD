onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib temac_gbe_v9_0_opt

do {wave.do}

view wave
view structure
view signals

do {temac_gbe_v9_0.udo}

run -all

quit -force
