onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L gtwizard_ultrascale_v1_7_5 -L gig_ethernet_pcs_pma_v16_1_5 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.gig_ethernet_pcs_pma_basex_156_25 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {gig_ethernet_pcs_pma_basex_156_25.udo}

run -all

quit -force
