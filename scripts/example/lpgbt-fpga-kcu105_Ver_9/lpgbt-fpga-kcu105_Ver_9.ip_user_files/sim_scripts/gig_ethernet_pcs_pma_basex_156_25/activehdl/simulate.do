onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+gig_ethernet_pcs_pma_basex_156_25 -L xil_defaultlib -L xpm -L gtwizard_ultrascale_v1_7_5 -L gig_ethernet_pcs_pma_v16_1_5 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.gig_ethernet_pcs_pma_basex_156_25 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {gig_ethernet_pcs_pma_basex_156_25.udo}

run -all

endsim

quit -force
