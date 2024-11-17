import struct

imgName = "cat_august.jpg"#"charcoal_cat.jpg"#

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
#Read file
fileBytes = open(imgName, "rb").read()
print("Reading image: "+imgName)
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
    if(byte == 0xFF):
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
            print("Precision: " + str(prec) + " bits")
            (sp,Y) = readWord(fileBytes, sp)
            (sp,X) = readWord(fileBytes, sp)
            print("Resolution: " + str(Y) + " x " + str(X) + " bits")
            (sp,num_c) = readByte(fileBytes, sp)
            for i in range(num_c):
                (sp,c)=readByte(fileBytes, sp)
                print("Channel: " + str(c))
                (sp,b)=readByte(fileBytes, sp)
                print("Horizontal Sampling Factor: " + str(b & 0b1111))
                print("Vertical Sampling Factor: " + str(b >> 4))
                (sp,b)=readByte(fileBytes, sp)
                print("Quantization Table Index: " + str(b))
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
                print("Channel: " + str(c))
                print("DC Entropy Table Index: " + str(t & 0b1111))
                print("AC Entropy Table Index: " + str(t >> 4))
            (sp,b)=readByte(fileBytes, sp)
            print("Start of selection: " + str(b))
            (sp,b)=readByte(fileBytes, sp)
            print("End of selection: " + str(b))
            (sp,b)=readByte(fileBytes, sp)
            print("Successive approx. bit position high: " + str(b & 0b1111))
            print("Successive approx. bit position low: " + str(b >> 4))
        elif (marker == 0xD9):
            print("End of Image")
            break
        else:
            print("Unrecognized marker: " + hex(marker))
    # else:
    #     print("Data not preceded by a marker: " + hex(byte))




##Old version: reading for markers two bytes at a time
    # (sp,marker) = readWord(fileBytes, sp)
    # if (marker == 0xFFE0):
    #     print("App0 Header")
    #     (sp,length) = readWord(fileBytes, sp)
    #     for i in range(length-2):
    #         (sp,b)=readByte(fileBytes, sp)
    #         print(hex(b))
    # elif (marker == 0xFFDB):
    #     print("Quantization Table")
    #     (sp,length) = readWord(fileBytes, sp)
    #     for i in range(length-2):
    #         (sp,b)=readByte(fileBytes, sp)
    #         print(hex(b))
    # elif (marker == 0xFFC2):
    #     print("Start of Frame2 - Progressive DCT-Based JPEG")
    #     exit()
    # elif (marker == 0xFFC0):
    #     print("Start of Frame0 - Baseline DCT-Based JPEG")
    #     (sp,length) = readWord(fileBytes, sp)
    #     for i in range(length-2):
    #         (sp,b)=readByte(fileBytes, sp)
    #         print(hex(b))
    # elif (marker == 0xFFC4):
    #     print("Huffman Table")
    #     (sp,length) = readWord(fileBytes, sp)
    #     for i in range(length-2):
    #         (sp,b)=readByte(fileBytes, sp)
    #         print(hex(b))
    # elif (marker == 0xFFFE):
    #     print("Comment")
    #     (sp,length) = readWord(fileBytes, sp)
    #     for i in range(length-2):
    #         (sp,b)=readByte(fileBytes, sp)
    #         print(hex(b))
    # elif (marker == 0xFFDA):
    #     print("Start of Scan")
    #     (sp,length) = readWord(fileBytes, sp)
    #     for i in range(length-2):
    #         (sp,b)=readByte(fileBytes, sp)
    #         print(hex(b))
    # elif (marker == 0xFFD9):
    #     print("End of Image")
    #     break

        
