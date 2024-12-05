class Stream:
    def __init__(self, data: str):
        #Data is a string of binary, eg "0110"
        self.data = data
        self.pos = 0

    def GetBit(self) -> int:
        b = self.data[self.pos]
        self.pos += 1
        return (int(b))

    def GetBitN(self, N: int) -> str:
        out = ""
        for i in range(N):
            out = out + str(self.GetBit())
        return out
    
    def EndOfStream(self):
        return self.pos >= len(self.data)

class HuffmanTable:
    def __init__(self):
        self.root=[]
        self.elements = []
    
    def BitsFromLengths(self, root, element, pos):
        if isinstance(root,list):
            if pos==0:
                if len(root)<2:
                    root.append(element)
                    return True                
                return False
            for i in [0,1]:
                if len(root) == i:
                    root.append([])
                if self.BitsFromLengths(root[i], element, pos-1) == True:
                    return True
        return False
    
    def GetHuffmanBits(self,  lengths, elements):
        self.elements = elements
        ii = 0
        for i in range(len(lengths)):
            for j in range(lengths[i]):
                self.BitsFromLengths(self.root, elements[ii], i)
                ii+=1

    def Decode(self,st):
        r = self.root
        while isinstance(r, list):
            r=r[st.GetBit()]
        return  r 

    def GetCode(self, st):
        while(True):
            res = self.Decode(st)
            if res == 0:
                return 0
            elif ( res != -1):
                return res
            
    def search(self,tree,val):
        #Check left side first
        if(isinstance(tree[0], list)):
            path = self.search(tree[0],val)
            if (path != ""):
                return "0"+path
        else: #Left branch is leaf
            if(tree[0] == val):
                return "0"
        #Check right side
        if(isinstance(tree[1], list)):
            path = self.search(tree[1],val)
            if (path != ""):
                return "1"+path
        else: #Right branch is leaf
            if(tree[1] == val):
                return "1"
        return ""
    
    def GetTable(self):
        huffTable = [[],[]] #Binary Codes, Values
        for elem in self.elements:
            code = self.search(self.root,elem)
            huffTable[0].append(code)
            huffTable[1].append(elem)
        return huffTable
    
    def WriteTableToFile(self, fileName):
        table = self.GetTable()
        f = open(fileName, "w")
        for i in range(len(table[0])):
            f.write(table[0][i]+" "+str(table[1][i])+" "+str(len(str(table[0][i])))+"\n")
        f.close()
    def WriteTableToFileFlipped(self, fileName):
        table = self.GetTable()
        f = open(fileName, "w")
        for i in range(len(table[0])):
            f.write(table[0][i][::-1]+" "+str(table[1][i])+" "+str(len(str(table[0][i])))+"\n")
        f.close()
    
if __name__ == "__main__":
    le = [0, 2, 2, 3, 1, 1, 1, 0, 0, 0]
    el = [5, 6, 3, 4, 2, 7, 8, 1, 0, 9]
    hf = HuffmanTable()
    hf.GetHuffmanBits(le, el)
    print(hf.root)
    print(hf.elements)

    s = Stream("0110")
    print(s.GetBitN(3))

    s = Stream("01100")
    while(not s.EndOfStream()):
        print(hf.Decode(s))

    print(hf.GetTable())


    #print(hf.Find(s))
