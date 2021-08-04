#!/bin/bash/

echo "----------- Check configuration mode ------------"
./TOFHIRv2_Config_v2.py -r Reg33 -f config_tofhir_v2.json -res 1
echo "----------- Check ASIC GLOBAL COMMAND ------------"
./TOFHIRv2_Config_v2.py -r Reg32 -f config_tofhir_v2.json -res 0
echo "----------- Check ASIC CHANNEL COMMAND ------------"
./TOFHIRv2_Config_v2.py -r Reg0 -f config_tofhir_v2.json -res 0

echo "################################################"
echo "End!"
echo "################################################"

