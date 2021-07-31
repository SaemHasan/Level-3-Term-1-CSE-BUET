import os
register ={
    "$zero":"0000",
    "$t0":"0001",
    "$t1":"0010",
    "$t2":"0011",
    "$t3":"0100",
    "$t4":"0101"
}
RType={
    "add" : "0000",
    "sub" : "0001",
    "and" : "0010",
    "or"  : "0011"
}

def write_to_file(code):
    f = open("output.txt", "a")
    f.write(code + "\n")
    f.close()

def R_Machine_Code(line):
    opcode = line.split().__getitem__(0);
    code = RType[opcode]
    line = line.replace(opcode, "").split(",") #opcode badh diye baki part
    for i in range(1, 3):
        code = code + register[line.__getitem__(i).strip()] #source 1, source 2
    code = code + register[line.__getitem__(0).strip()] #destinition
    code = code + "0000" #shift amount

    print(code)
    code = hex(int(code, 2))[2:]
    write_to_file(code)


if __name__ == '__main__':
    if os.path.exists("output.txt"):
        os.remove("output.txt")
    write_to_file("v2.0 raw")
    file1 = open('input.txt', 'r')
    Lines1 = file1.readlines()
    Lines = [x.lower() for x in Lines1]

    # For Loop for converting Instruction to Machine code

    for line in Lines:
        if(not line.isspace()):
            line = line.strip()
            opcode = line.split().__getitem__(0)
            if(opcode in RType):
                print(line)
                R_Machine_Code(line)
            else:
                if (len(line.strip()) != 0):
                   continue





