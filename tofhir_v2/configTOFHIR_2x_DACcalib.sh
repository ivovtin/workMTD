#!/bin/bash

list=("$@")

if [ $# -lt 1 ]
then
  list=(0 1)
fi

for nlink in ${list[@]}
do
	echo "----------- Start DAC calibration ------------------------------------------------------------"
	echo "----------- Set ASIC COMMAND to Reg35 -------------------"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg35 -f config_tofhir_2x_newRicardo.json
        sleep 1 
	echo "send core logic RESET"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6


	echo "----------- Set ASIC COMMAND to Reg36 -------------------"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg36 -f config_tofhir_2x_newRicardo.json
        sleep 1 
	echo "send core logic RESET"
	./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6


        echo "----------- Set ASIC GLOBAL COMMAND - Iref_probe_enable to 1 -------------------"
        sed -i '/global.Iref_probe_enable = /c global.Iref_probe_enable = 1' config_ivan.ini
        /home/software/mtd-daq/sw_daq_tofhir2x/build/daqv1_json_builder  --config config_ivan.ini -o /tmp/autogenTest.json --ith_t1 30
        ./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg32 -f /tmp/autogenTest.json
        sleep 1 
        echo "send core logic RESET"
        ./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6


        echo "----------- Set ASIC GLOBAL COMMAND - Comparator_enable to 1 -------------------"
        sed -i '/global.Comparator_enable = /c global.Comparator_enable = 1' config_ivan.ini
        /home/software/mtd-daq/sw_daq_tofhir2x/build/daqv1_json_builder  --config config_ivan.ini -o /tmp/autogenTest.json --ith_t1 30
        ./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg32 -f /tmp/autogenTest.json
        sleep 1 
        echo "send core logic RESET"
        ./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6


        for i in {0..20}
	do
                var=$(printf '%02x\n' $i)
                sed -i '/global.Iref_cal_DAC = 0x/c global.Iref_cal_DAC = 0x'${var}'' config_ivan.ini
	       /home/software/mtd-daq/sw_daq_tofhir2x/build/daqv1_json_builder  --config config_ivan.ini -o /tmp/autogenTest.json --ith_t1 30

        	echo "----------- Set ASIC GLOBAL COMMAND - Iref_cal_DAC to 0x${var} ---------------------"
        	./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg32 -f /tmp/autogenTest.json
        	sleep 2 

        	echo "send core logic RESET"
        	./TOFHIRv2_Config_v2_2x.py -link $nlink -reset 6
        	sleep 2 
	done       
 
        #echo "----------- Read status calibration_comparator from Reg 34 -------------------"
        #./TOFHIRv2_Config_v2_2x.py -link $nlink -reg Chip_00010101_reg34 -f config_tofhir_2x_newRicardo.json
        sleep 2

	echo "################################################"
	echo "End!"
	echo "################################################"
done

