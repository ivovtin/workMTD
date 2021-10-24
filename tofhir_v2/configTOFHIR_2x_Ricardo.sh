#!/bin/bash

list=("$@")

if [ $# -lt 1 ]
then
  list=(0 1)
fi

for nlink in ${list[@]}
do
        echo "Start configuration for $nlink link"  
	echo "send core logic RESET"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6

	echo "----------- Set ASIC GLOBAL COMMAND -------------------"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg32 -f config_tofhir_2x_newRicardo.json
	##./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg32 -f config_tofhir_2x_GenOff.json

	#####

	echo "send Global Reset to all ASIC!"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 16
	

	echo "----------- Set configuration mode --------------------"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg33 -f config_tofhir_2x_newRicardo.json 

	echo "send core logic RESET"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6

	echo "----------- Set ASIC GLOBAL COMMAND -------------------"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg32 -f config_tofhir_2x_newRicardo.json
	##./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg32 -f config_tofhir_2x_GenOff.json

	echo "send core logic RESET"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6

	echo "----------- Set ASIC CHANNEL COMMAND ------------------"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg00 -f config_tofhir_2x_newRicardo.json
	##./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg09 -f config_tofhir_2x_newRicardo.json

	echo "send core logic RESET"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6

	#./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg05 -f config_tofhir_2x_newRicardo.json

	#echo "send core logic RESET"
	#./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6

	echo "################################################"
	echo "End!"
	echo "################################################"
done

