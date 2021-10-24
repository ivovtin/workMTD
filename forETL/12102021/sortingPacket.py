packet = "" 

SOF = 0x25555
EOF = 0x2EADBEEF

with open('aa.txt') as file:
    print "First line with headers is deleted"
    next(file)                  
    for line in file:
         #print line
         p = line.split()
         packet += format(int(p[1], base=16), '032b')
         #print packet

#print packet
print "Packet lenght is", len(packet),"bits" 
outFile = "binaryPacket.txt"
out = open(outFile, 'w')
out.write(packet)
print "Full binary packet writed to", outFile
out.close()

#print int(packet) & (1 << int(SOF))

varSOF = str(bin(SOF).replace("0b",""))
print "SOF =", varSOF
varEOF = str(bin(EOF).replace("0b",""))
print "EOF =", varEOF

search_pos = 0
count = 0
while True:
    index = str(packet).find(str(varSOF), search_pos)
    if index != -1:
        search_pos = index + len(str(varSOF))
        print "Position for SOF is from", index, "bit to", search_pos, "bit ( words", index/32,"-",search_pos/32 ,")"
        count = count + 1
    else:
        break

if count > 0:
        print("SOF success found!") 
else:   
        print("SOF not found.")


search_pos = 0
count = 0
while True:
    index = str(packet).find(str(varEOF), search_pos)
    if index != -1:
        search_pos = index + len(str(varEOF))
        print "Position for EOF is from", index, "bit to", search_pos, "bit ( words", index/32,"-",search_pos/32 ,")"
        count = count + 1
    else:
        break

if count > 0:
	print("EOF success found!")
else:
	print("EOF not found.")





