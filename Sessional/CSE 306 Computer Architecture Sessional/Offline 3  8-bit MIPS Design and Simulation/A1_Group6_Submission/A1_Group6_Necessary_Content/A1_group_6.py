import os
Label={

}

register ={
    "$zero":"0000",
    "$t0":"0001",
    "$t1":"0010",
    "$t2":"0011",
    "$t3":"0100",
    "$t4":"0101",
    "$sp":"0110",
    "$t5":"0111"
}
JType={
"j":"0000"
}
IType={
    "bneq":"0001",
    "andi":"0010",
    "lw":"0011",
    "addi":"0100",
    "beq":"0101",
    "subi":"0110",
    "ori":"1100",
    "sw":"1110"
}
RType={
    "and":"0111",
    "sub":"1000",
    "add":"1001",
    "or":"1010",
    "sll":"1011",
    "nor":"1101",
    "srl":"1111"
}

def write_to_file(code):
    f = open("output.txt", "a")
    f.write(code + "\n")
    f.close()
def to_binary(value, n):
    binary = bin(value).replace('0b', '')
    x = binary[::-1]
    while len(x) < n:
        x += '0'
    binary = x[::-1]
    return binary

def R_Machine_Code(line):
    opcode = line.split().__getitem__(0);
    code = RType[opcode]

    line = line.replace(opcode, "").split(",") #opcode badh diye baki part


    if (line.__getitem__(2).strip() in register): #3 tai reg, without srl sll
        for i in range(1, 3):
            code = code + register[line.__getitem__(i).strip()] #source 1, source 2
        code = code + register[line.__getitem__(0).strip()] #destinition
        code = code + "0000" #shift amount
    else:   #for srl sll
        code = code + register[line.__getitem__(1).strip()] #source
        code = code + "0000"
        code = code + register[line.__getitem__(0).strip()] #destinition
        code = code + to_binary(int(line.__getitem__(2).strip()), 4) #shift amount
    print(code)
    code = hex(int(code, 2))[2:]
    write_to_file(code)


def I_Machine_Code(line,line_count):
    opcode = line.split().__getitem__(0)

    line = line.replace(opcode+" ", "").split(",") #opcode badh diye baki part
    register_count=line.__len__() #count 2 hle sw lw, 3 hle bakigula
    code = ""
    if(register_count == 3): #I without store load
        code=code+IType[opcode]
        source=register[line[1].strip()]
        destination=register[line[0].strip()]
        offset = line[2].strip()
        if(offset == "$zero"):  #For zero register
            offset="00000000"
            code = code + source + destination +offset
        elif(offset in Label):  #For lebel in beq and bneq
            address = offset
            address=Label[address]
            address = address - line_count - 1 #PC relative addressing
            if(address <0 ):
                address = 2**8+address  #2's compliment if address is negative
            code = code + source + destination + to_binary(address,8)
        else:  #For immediate values
            #print(offset)
            check = int(offset)
            if (check < 0):
                offset = 2 ** 8 + check #2's compliment if constant is negative
            code = code + source + destination + to_binary(int(offset), 8)


    else: #I for store load sw lw
        code = code + IType[opcode]
        destination = line[0].strip()
        temp = line[1].split("(")
        offset=temp[0].strip()
        source = temp[1].split(")")
        check = int(offset)
        if (check < 0):
            offset = 2 ** 8 + check
        code=code+register[source[0].strip()]+register[destination]+to_binary(int(offset),8)
    print(code)
    code = hex(int(code, 2))[2:]
    write_to_file(code)

def J_Machine_Code(line):
    str = line.split()
    opcode=str[0].strip()
    target_address = Label[str[1].strip()]
    code =JType[opcode] +to_binary(target_address,8) +"0000"+"0000"
    print(code)
    code = hex(int(code, 2))[2:]
    write_to_file(code)



if __name__ == '__main__':
    if os.path.exists("output.txt"):
        os.remove("output.txt")
    write_to_file("v2.0 raw")
    file1 = open('input5.txt', 'r')
    Lines1 = file1.readlines()
    Lines = [x.lower() for x in Lines1]
    count = 0
    I_Machine_Code("addi $sp, $zero, 255",0)
    count+=1
    #For Loop for scanning all the Lebels
    for line in Lines:

        if (len(line.strip()) == 0):
            continue
        opcode = line.split().__getitem__(0)
        if (opcode in RType):
            count += 1
            continue
        elif(opcode in IType):
            count += 1
            continue
        elif (opcode in JType):
            count += 1
            continue
        elif (opcode == "push" or opcode == "pop"):
            parts = line.split()
            op = parts[0]
            num_or_usd = parts.__getitem__(1).strip()[0:1]
            if (op == "push"):
                count += 1
                if (num_or_usd == "$"):
                    count += 1
                else:
                    count += 2
                    # print("lw " + reg + ", " + num_or_usd+"("+reg+")")
            elif (op == "pop"):
                count += 2
            continue
        else:
            if (len(line.strip()) != 0):
                line=line.strip()
                l = line.split(":")
                val = l[0]
                target_address = count
                Label[val] = target_address

    # For Loop for converting Instruction to Machine code
    count = 0
    for line in Lines:
        if(not line.isspace()):
            line = line.strip()

            opcode = line.split().__getitem__(0)
            if(opcode in RType):
                print(line)
                count+=1
                R_Machine_Code(line)
            elif(opcode in IType):
                print(line)
                count += 1
                I_Machine_Code(line,count)
            elif (opcode in JType):
                print(line)
                count += 1
                J_Machine_Code(line)
            elif(opcode == "push" or opcode == "pop"):
                print(line)
                parts = line.split()
                op = parts[0]
                num_or_usd = parts.__getitem__(1).strip()[0:1]
                if (op == "push"):
                    count += 1
                    I_Machine_Code("subi $sp, $sp, 1", count)
                    if (num_or_usd == "$"):
                        count += 1
                        I_Machine_Code("sw " + parts[1] + ", 0($sp)", count)
                    else:
                        reg = parts[1][2:5]
                        count += 2
                        I_Machine_Code("lw $t5, " + num_or_usd + "(" + reg + ")", count)
                        I_Machine_Code("sw $t5, 0($sp)", count)
                        # print("lw " + reg + ", " + num_or_usd+"("+reg+")")
                elif (op == "pop"):
                    count += 2
                    I_Machine_Code("lw " + parts[1] + ", 0($sp)", count)
                    I_Machine_Code("addi $sp, $sp, 1", count)
            else:
                if (len(line.strip()) != 0):
                   continue





