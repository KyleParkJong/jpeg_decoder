finn =  open('tiny/bitStream.txt', 'r')
fout = open('tiny/bitStreamFlipped.txt', 'w')
lines = finn.readlines()
for line in lines:
    fout.write(line.strip("\n")[::-1]+"\n")
finn.close()
fout.close()

