packet = "" 

with open('reg32hex.txt') as file:
    #print "First line with headers is deleted"
    #next(file)                  
    for line in file:
         #print line
         p = line.split()
         packet += format(int(p[1], base=16), '032b')
         print p[1],"      ", format(int(p[1], base=16), '032b')

#print packet
print "Packet lenght is", len(packet),"bits" 
outFile = "binaryPacket.txt"
out = open(outFile, 'w')
out.write(packet)
print "Full binary packet writed to", outFile
out.close()





