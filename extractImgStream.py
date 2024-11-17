import struct

imgName = "cat_august.jpg"#"charcoal_cat.jpg"#

def readWord(fileBytes, scanPosition):
    word, = struct.unpack(">H", fileBytes[scanPosition:scanPosition+2])
    return (scanPosition+2, word)

def readByte(fileBytes, scanPosition):
    byte, = struct.unpack(">B", fileBytes[scanPosition:scanPosition+1])
    return (scanPosition+1, byte)

#Read file
fileBytes = open(imgName, "rb").read()
#Setup arrays to hold extracted data
sp = 0 #Scan Position
appHeader = []
appUnitOptions = ["","DPI",""]
quantTables = []
huffTables = []
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
            print(appText + " Version: "+str(appHeader[0])+"."+str(appHeader[1]))
            print("Unit: " + appUnitOptions[appHeader[2]])

        elif (marker == 0xE1):
            print("App1 Header - EXIF")
            quit()
        elif (marker == 0xDB):
            print("Quantization Table")
            (sp,length) = readWord(fileBytes, sp)
            for i in range(length-2):
                (sp,b)=readByte(fileBytes, sp)
                print(hex(b))
        elif (marker == 0xC0):
            print("Start of Frame0 - Baseline DCT-Based JPEG")
            (sp,length) = readWord(fileBytes, sp)
            for i in range(length-2):
                (sp,b)=readByte(fileBytes, sp)
                print(hex(b))
        elif (marker == 0xC2):
            print("Start of Frame2 - Progressive DCT-Based JPEG")
            exit()
        elif (marker == 0xC4):
            print("Huffman Table")
            (sp,length) = readWord(fileBytes, sp)
            for i in range(length-2):
                (sp,b)=readByte(fileBytes, sp)
                print(hex(b))
        elif (marker == 0xFE):
            print("Comment")
            (sp,length) = readWord(fileBytes, sp)
            for i in range(length-2):
                (sp,b)=readByte(fileBytes, sp)
                print(hex(b))
        elif (marker == 0xDA):
            print("Start of Scan")
            (sp,length) = readWord(fileBytes, sp)
            for i in range(length-2):
                (sp,b)=readByte(fileBytes, sp)
                print(hex(b))
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

        