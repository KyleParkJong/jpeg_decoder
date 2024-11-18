import struct
import huffman

######## USER - ENTER I/O FILE NAMES ###########
imgName = "cat_august.jpg" #"charcoal_cat.jpg"#
bitStreamOutFile = "bitStream.txt"
######## USER - CONFIGURE PARAMETERS ###########
outType = "bin32" #Options: "binary" = one long string, "bin32" = lines of 32 bits, "hex" = lines of 32 hex
################################################

####### Function Definitions ###########
def readWord(fileBytes, scanPosition):
    word, = struct.unpack(">H", fileBytes[scanPosition:scanPosition+2])
    return (scanPosition+2, word)

def readByte(fileBytes, scanPosition):
    byte, = struct.unpack(">B", fileBytes[scanPosition:scanPosition+1])
    return (scanPosition+1, byte)

def splitByte(byteInt):
    b_str = f'{byteInt:08b}'
    upper = b_str[0:4]
    lower = b_str[4:8]
    return (int(upper),int(lower))

def printMatrix8(matrix):
    for row in range(8):
        for col in range(8):
            print("%02d, " %(matrix[col+row*8]), end="")
        print()

def readScan(fileBytes, scanPosition):
    sp = scanPosition
    bitStream = ""
    while(True):
        (sp,byte) = readByte(fileBytes, sp)
        if(byte == 0xFF):
            (sp,marker) = readByte(fileBytes, sp)
            if(marker == 0x00):
                #Padding detected, add FF to bitsream
                bitStream = bitStream + '11111111'
            elif(marker == 0xD9):
                #End of file detected
                break
            else:
                print("Error - 0xFF Not followed by stuffing or EOF")
        else:
            bitStream = bitStream + f'{byte:08b}'    
    return (sp-2, bitStream)

def readScan32(fileBytes, scanPosition):
    sp = scanPosition
    bitStream = ""
    bitsAdded = 0
    while(True):
        (sp,byte) = readByte(fileBytes, sp)
        if(byte == 0xFF):
            (sp,marker) = readByte(fileBytes, sp)
            if(marker == 0x00):
                #Padding detected, add FF to bitsream
                bitStream = bitStream + '11111111'
                bitsAdded = bitsAdded + 8
            elif(marker == 0xD9):
                #End of file detected
                break
            else:
                print("Error - 0xFF Not followed by stuffing or EOF")
        else:
            bitStream = bitStream + f'{byte:08b}'
            bitsAdded = bitsAdded + 8
        if(bitsAdded >= 32):
            bitStream = bitStream + '\n'
            bitsAdded = 0 
    return (sp-2, bitStream)

def readScanHex(fileBytes, scanPosition):
    sp = scanPosition
    bitStream = ""
    bytesAdded = 0
    while(True):
        (sp,byte) = readByte(fileBytes, sp)
        if(byte == 0xFF):
            (sp,marker) = readByte(fileBytes, sp)
            if(marker == 0x00):
                #Padding detected, add FF to bitsream
                bitStream = bitStream + 'FF'
                bytesAdded = bytesAdded + 1
            elif(marker == 0xD9):
                #End of file detected
                break
            else:
                print("Error - 0xFF Not followed by stuffing or EOF")
        else:
            bitStream = bitStream + f'{byte:02x}'
            bytesAdded = bytesAdded + 1
        if(bytesAdded >= 16):
            bitStream = bitStream + '\n'
            bytesAdded = 0 
    return (sp-2, bitStream)

####### Start Extracting Data ############
#Read file
print("--Reading image: "+imgName+" --")
f = open(imgName, "rb")
fileBytes = f.read()
f.close()
#Setup arrays to hold extracted data
sp = 0 #Scan Position
appHeader = []
appUnitOptions = ["No Units/Pixel Aspect Ratio","Pixels Per Inch","Pixels per cm"]
quantTables = []
huffSizeTables = [[],[]] #Size of Code Tables. [DC Tables(up to 4), AC Tables(up to 4)] 
huffValTables = [[],[]] #Value of Codes Tables. [DC Tables(up to 4), AC Tables(up to 4)]
bitStream = []

#Check for valid Start of Image Marker
(sp,marker) = readWord(fileBytes, sp)
if (marker == 0xFFD8):
    print("SOI - Valid JPEG")
else:
    print("Not a valid JPEG")
    exit()
#Start scanning bytes
while(True):
    (sp,byte) = readByte(fileBytes, sp)
    #Check for marker indicator oxFF
    if(byte == 0xFF):
        #Read next bye to determine marker type
        (sp,marker) = readByte(fileBytes, sp)
        if (marker == 0xE0):
            print("App0 Header - JFIF")
            (sp,length) = readWord(fileBytes, sp)
            appText=""
            terminated=False
            for i in range(length-2):
                (sp,b)=readByte(fileBytes, sp)
                if(terminated == False):
                    if(b == 0):
                        terminated = True
                    else:
                        appText = appText + chr(b)
                else:
                    appHeader.append(b)
            if(appText == "JFIF"):
                print("  "+appText + " Version: "+str(appHeader[0])+"."+str(appHeader[1]))
                print("  Unit: " + appUnitOptions[appHeader[2]])
                print("  Horizontal Pixel Density: "+str(appHeader[3]*256+appHeader[4])+". Vertical Pixel Density: "+str(appHeader[5]*256+appHeader[6]))
                print("  Thumbnail X: "+str(appHeader[7])+", Thumbnail Y: "+str(appHeader[8]))
            else:
                print("Unsupported Extension: "+appText)
        elif (marker == 0xE1):
            print("App1 Header - EXIF")
            quit()
        elif (marker == 0xDB):
            print("Quantization Table")
            (sp,length) = readWord(fileBytes, sp)
            destination = "empty"
            for i in range(length-2):
                (sp,b)=readByte(fileBytes, sp)
                if(destination == "empty"):
                    destination = b
                    while(len(quantTables) < destination+1):
                        quantTables.append([])
                else:
                    quantTables[destination].append(b)
            print("  Destination: "+str(destination))
            printMatrix8(quantTables[destination])
        elif (marker == 0xC0):
            print("Start of Frame - Baseline DCT-Based JPEG")
            (sp,length) = readWord(fileBytes, sp)
            (sp,prec) = readByte(fileBytes, sp)
            print("  Precision: " + str(prec) + " bits")
            (sp,Y) = readWord(fileBytes, sp)
            (sp,X) = readWord(fileBytes, sp)
            print("  Resolution: " + str(Y) + " x " + str(X) + " bits")
            (sp,num_c) = readByte(fileBytes, sp)
            for i in range(num_c):
                (sp,c)=readByte(fileBytes, sp)
                print("  Channel: " + str(c))
                (sp,b)=readByte(fileBytes, sp)
                print("  Horizontal Sampling Factor: " + str(b & 0b1111))
                print("  Vertical Sampling Factor: " + str(b >> 4))
                (sp,b)=readByte(fileBytes, sp)
                print("  Quantization Table Index: " + str(b))
        elif (marker == 0xC2):
            print("Start of Frame - Progressive DCT-Based JPEG")
            exit()
        elif (marker == 0xC4):
            print("Huffman Table")
            (sp,length) = readWord(fileBytes, sp)
            (sp,classDest) = readByte(fileBytes, sp)
            (clss,destination) = splitByte(classDest)
            print("  Class: "+str(clss)+", Destination: "+str(destination))
            while(len(huffSizeTables[clss]) < destination+1):
                huffSizeTables[clss].append([])
                huffValTables[clss].append([])
            for i in range(16):
                (sp,b)=readByte(fileBytes, sp)
                huffSizeTables[clss][destination].append(b)
            for i in range(length-2-1-16):
                (sp,b)=readByte(fileBytes, sp)
                huffValTables[clss][destination].append(b)
            print("  Number of codes with bit-lengths 1-16: "+str(huffSizeTables[clss][destination]))
            print("  Code equivalent values: "+str(huffValTables[clss][destination]))
        elif (marker == 0xFE):
            print("Comment")
            comment="  "
            (sp,length) = readWord(fileBytes, sp)
            for i in range(length-2):
                (sp,b)=readByte(fileBytes, sp)
                comment = comment+chr(b)
            print(comment)
        elif (marker == 0xDA):
            print("Start of Scan")
            (sp,length) = readWord(fileBytes, sp)
            (sp,ns) = readByte(fileBytes, sp)
            for i in range(ns):
                (sp,c)=readByte(fileBytes, sp)
                (sp,t)=readByte(fileBytes, sp)
                print("  Channel: " + str(c))
                print("  DC Entropy Table Index: " + str(t & 0b1111))
                print("  AC Entropy Table Index: " + str(t >> 4))
            (sp,b)=readByte(fileBytes, sp)
            print("  Start of selection: " + str(b))
            (sp,b)=readByte(fileBytes, sp)
            print("  End of selection: " + str(b))
            (sp,b)=readByte(fileBytes, sp)
            print("  Successive approx. bit position high: " + str(b & 0b1111))
            print("  Successive approx. bit position low: " + str(b >> 4))
            #Extract image data
            if(outType == "binary"):
                (sp,bitStream) = readScan(fileBytes, sp)
            elif(outType == "bin32"):
                (sp,bitStream) = readScan32(fileBytes, sp)
            else:
                (sp,bitStream) = readScanHex(fileBytes, sp)
        elif (marker == 0xD9):
            print("End of Image")
            break
        else:
            print("Unrecognized marker: " + hex(marker))
    else:
        print("Data not preceded by a marker: " + hex(byte))

####### Handle Extracted Data & Output ############
#Write bitstream to file
of = open(bitStreamOutFile, "w")
of.write(bitStream)
of.close()
print("Recovered bitstream output to file: "+bitStreamOutFile)
#Write DC huffman tables to files
for i in range(len(huffSizeTables[0])):
    hf = huffman.HuffmanTable()
    hf.GetHuffmanBits(huffSizeTables[0][i], huffValTables[0][i])
    fileName = "DC_HuffTable_Index"+str(i)+".txt"
    hf.WriteTableToFile(fileName)
    print("Recovered Huffman Table output to file: "+fileName)
#Write AC huffman tables to files
for i in range(len(huffSizeTables[1])):
    hf = huffman.HuffmanTable()
    hf.GetHuffmanBits(huffSizeTables[1][i], huffValTables[1][i])
    fileName = "AC_HuffTable_Index"+str(i)+".txt"
    hf.WriteTableToFile(fileName)
    print("Recovered Huffman Table output to file: "+fileName)
