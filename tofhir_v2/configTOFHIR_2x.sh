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
	./TOFHIRv2_Config_v2.py -link $nlink -reset 6

	echo "----------- Set ASIC GLOBAL COMMAND -------------------"
	./TOFHIRv2_Config_v2.py -link $nlink -reg Reg32 -f config_tofhir_2x.json

	#####

	echo "send Global Reset to all ASIC!"
	./TOFHIRv2_Config_v2.py -link $nlink -reset 16

	echo "----------- Set configuration mode --------------------"
	./TOFHIRv2_Config_v2.py -link $nlink -reg Reg33 -f config_tofhir_2x.json 

	echo "send core logic RESET"
	./TOFHIRv2_Config_v2.py -link $nlink -reset 6

	echo "----------- Set ASIC GLOBAL COMMAND -------------------"
	./TOFHIRv2_Config_v2.py -link $nlink -reg Reg32 -f config_tofhir_2x.json

	echo "send core logic RESET"
	./TOFHIRv2_Config_v2.py -link $nlink -reset 6

	echo "----------- Set ASIC CHANNEL COMMAND ------------------"
	./TOFHIRv2_Config_v2.py -link $nlink -reg Reg0 -f config_tofhir_2x.json 

	echo "send core logic RESET"
	./TOFHIRv2_Config_v2.py -link $nlink -reset 6

	echo "################################################"
	echo "End!"
	echo "################################################"
done

