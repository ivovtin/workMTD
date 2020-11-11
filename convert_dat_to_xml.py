#!/usr/bin/env python3.7

infile_name = 'input.dat'
outfile_name = 'test.xml'

third = 'block'
four = '4096'
  
outfile = open(outfile_name, "w")
outfile.write(
"""<?xml version="1.0" encoding="ISO-8859-1"?>
<node id="TOP">
"""
)

with open(infile_name, "r") as f:
    for line in f:
        print(line)
        first = line.split()[0]
        second = line.split()[1]
        outfile.write(
        """   <node id="{0}" address="{1}" mode="{2}" size="{3}" />
""".format(first, second, third, four)
        )
        print(first, second)

outfile.write("""</node> """)
outfile.close()
