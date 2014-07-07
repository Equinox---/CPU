#!/bin/env python
#-*- coding: utf-8 -*-

# This is an easy assembler of simplified MIPS architecture implemeted in Python.
# v1.1
# 加入了输出hex的选择，修改了两处弄错的参数顺序
# v1.2
# 加入了对十六进制常数的支持


import re
import sys

# Parameters
Start_Addr = '0x80000000'


# Data
"""
R_PATTERN = {
			0 : "000000{arg2}{arg3}{arg1}00000{op}",
			1 : "00000000000{arg2}{arg1}{arg3}{op}",
			2 : "000000{arg1}000000000000000{op}"
			}
I_PATTERN = {
			0 : "{op}{arg1}{arg2}{arg3}",
			2 : "{op}{arg2in}{arg1}{arg2out}",
			3 : "{op}00000{arg1}{arg2}",
			1 : "{op}{arg1}00000{arg2}"
			}

J_PATTERN = {0 : "{op}{arg1}"}
"""
R_PATTERN = {
			0 : "000000_{arg2}_{arg3}_{arg1}_00000_{op}",
			1 : "00000000000_{arg2}_{arg1}_{arg3}_{op}",
			2 : "000000_{arg1}_00000_00000_00000_{op}"
			}
I_PATTERN = {
			0 : "{op}_{arg1}_{arg2}_{arg3}",
			4 : "{op}_{arg2}_{arg1}_{arg3}",
			2 : "{op}_{arg2in}_{arg1}_{arg2out}",
			3 : "{op}_00000_{arg1}_{arg2}",
			1 : "{op}_{arg1}_00000_{arg2}"
			}

J_PATTERN = {0 : "{op}_{arg1}"}
Pattern_Sets = [R_PATTERN, I_PATTERN, J_PATTERN]

R_Set = {
			"add" : (0, "100000"),
			"addu": (0, "100001"),
			"sub" : (0, "100010"),
			"subu": (0, "100011"),
			"and" : (0, "100100"),
			"or"  : (0, "100101"),
			"xor" : (0, "100110"),
			"nor" : (0, "100111"),
			"slt" : (0, "101010"), # type0: rd= $1, rs= $2, rt = $3, shamnt = 0
			"sll" : (1, "000000"),
			"srl" : (1, "000010"),
			"sra" : (1, "000011"), # type1: rd = $1, rt = $2, shamnt = $3, rs = 0
			"jr"  : (2, "001000"),
			"jalr": (2, "001001") # type2: rs = $1, rd = rt = shamnt = 0
			}
I_Set = {
			"addi" : (4, "001000"),
			"addiu": (4, "001001"),
			"andi" : (4, "001100"),
			"slti" : (4, "001010"),
			"sltiu": (4, "001011"), # type4: rt=$1, rs = $2,
			"beq"  : (0, "000100"),
			"bne"  : (0, "000101"),# type0 : rt = $2, rs = $1, immediate = $3
			"blez" : (1, "000110"),
			"bgtz" : (1, "000111"),
			"bltz" : (1, "000001"),  # type1 : rs = $1, immediate = $2, rt = 0 
			"sw"   : (2, "101011"),
			"lw"   : (2, "100011"), # type2 : rt = $1, rs = $2(括号里), immediate = $s2(括号外)
			"lui"  : (3, "001111") # type3 : rs = 0, rt = $1, immediate = $2
}

J_Set = {
			"j"  : (0, "000010"),
			"jal": (0, "000011")
}

INSTRUCT_SETS = [R_Set, I_Set, J_Set]

_RegisterNameList = ["zero", "at", "v0", "v1", "a0", "a1", "a2", "a3", "t0", "t1", "t2", "t3", "t4", "t5", "t6",
					  "t7", "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra"]
Register_Map = dict([(x, _RegisterNameList.index(x)) for x in _RegisterNameList])


# Global Data Structure
LabelDict = {}
labelWaitDict = {}


# --- regular expressions ---
regexp = re.compile
RE_WHITESPACE = regexp("[\s,]+")
RElabel = regexp("[a-zA-Z0-9_]+:")
RE_COMMENT = regexp("#[^\r\n]*\\n")

def Error(string):
	print "Error: " + string
	sys.exit(1)

def rmlae(x):
	if x[-1] == "L":
		x = x[:-1]
	return x
def IntToBinStr(integer, num):
	isNeg = False
	if isinstance(integer, str):
		if not integer.isdigit():
			if not (integer[0] == "$" or integer[0] == "-" or integer[:2] == "0x"):
				Error("Instruction format error: expected register argument: %s !"%integer)
			if integer[0] == "$":
				integer = integer[1:]
				if not integer.isdigit():
					integer = Register_Map[integer]
			else:
				if integer[0] == "-":
					isNeg = True
					integer = integer[1:]
				if integer[:2] == "0x":
					integer = int(integer, 16)

	integer = int(integer)
	isNeg = integer < 0 or isNeg
	if isNeg:
		integer = 2**num - abs(integer)
	result = bin(integer)[2:]
	result = "0" * (num - len(result)) + result
	return result

def parseText(code):
	# Given a list of instructions, produce the binary code
	global LabelDict, labelWaitDict
	code = [RE_WHITESPACE.sub(r" ", x) for x in code] # get rid of extra whitespace in every instruction
	binary = []
	asmCode = []
	number = 0
	nowAddr = Start_Addr
	#print code
	for instruct in code:
		if not instruct or instruct == " ":
			continue
		if instruct[-1] == " ":
			instruct = instruct[:-1] # get rid of empty string at end
		if instruct[0] == " ":
			instruct = instruct[1:]
		insL = instruct.split(" ")
		asmCode.append(instruct)
		# record label and its corresponding absolute address
		print insL
		while insL and insL[0][-1] == ":":
			newLabel = insL.pop(0)[:-1]
			if newLabel in LabelDict:
				Error("Repeated label '%s' in two place!"%newLabel)#: addr %s and addr %s!"%(newLabel, LabelDict[newLabel], nowAddr))
			LabelDict[newLabel] = nowAddr
		# parse the instruction
		if not insL:
			continue
		info = {}
		found = 0

		for i in range(len(INSTRUCT_SETS)):
			if insL[0] in INSTRUCT_SETS[i]:
				innerType = INSTRUCT_SETS[i][insL[0]][0]
				info = {"op" : INSTRUCT_SETS[i][insL[0]][1]}
				arg1, arg2, arg3 = insL[1], "" if len(insL) < 3 else insL[2], "" if len(insL) < 4 else insL[3]
				# J-type instruction and branch instruction
				if insL[0] in ["beq", "j", "jal", "bne", "blez", "bgtz", "bltz"]:
					if not insL[-1] in labelWaitDict:
						labelWaitDict[insL[-1]] = [(i, number, nowAddr)]
					else:
						labelWaitDict[insL[-1]].append((i, number, nowAddr))
					if i == 1:
						info["arg1"] = IntToBinStr(arg1, 5)
						if not innerType:
							info["arg2"] = IntToBinStr(arg2, 5)
							info["arg3"] = "label"
						else:
							info["arg2"] = "label"
					else:
						info["arg1"] = "label"
				else:
					info["arg1"] = IntToBinStr(arg1, 5)
					if i == 1: # I-Type i == 1
						if innerType == 2: # sw or lw
							try:
								tmpindex = arg2.index("(")
							except ValueError:
								Error("Instruction format error!")
							arg2out = arg2[:tmpindex]
							arg2in = arg2[(tmpindex + 1):-1]
							info["arg2in"] = IntToBinStr(arg2in, 5)
							info["arg2out"] = IntToBinStr(arg2out, 16)
						elif innerType == 3: # lui
							info["arg2"] = IntToBinStr(arg2, 16)
						else:
							info["arg2"] = IntToBinStr(arg2, 5)
							info["arg3"] = IntToBinStr(arg3, 16)
					else: # R-Type i == 0
						if innerType < 2:
							info["arg2"] = IntToBinStr(arg2, 5)
							info["arg3"] = IntToBinStr(arg3, 5)
				print info
				binary.append("%s\t%s"%(nowAddr, Pattern_Sets[i][innerType].format(**info)))
				found = 1
				number += 1
				nowAddr = rmlae(hex(int(nowAddr[2:], 16) + 4))
				nowAddr = "0x" + (10 - len(nowAddr)) * "0" + nowAddr[2:]
		if not found:
			Error("Instruction unrecognized: '%s' !"%instruct)

	# 处理跳转，分支指令label地址
	for waitLabel in labelWaitDict:
		if waitLabel not in LabelDict:
			Error("Unknown label %s"%waitLabel)
		for item in labelWaitDict[waitLabel]:
			_IorJ, _inum, _addr = item
			if _IorJ == 1:
				labelRepStr = IntToBinStr(int(LabelDict[waitLabel][2:], 16) - int(_addr[2:],16) - 4, 18)[:-2] # I-Type: relative
			else:
				labelRepStr = IntToBinStr(int(LabelDict[waitLabel][2:], 16), 32)[4:30] # J-Type: absolute
			binary[_inum] = re.sub(r"label", labelRepStr, binary[_inum])

	return binary, asmCode

def parseFile(filename):
	codeFile = open(filename)
	rawText = codeFile.read()
	predText = RE_COMMENT.sub(r"\n", rawText) # remove comment
	predText = re.sub("\n{2,}", "\n", predText) # remove continuous \n
	predText = re.sub(":[ \t]*\n", ": ", predText) # make label in the same line with the next instruction
	
	return parseText(predText.split("\n"))


if __name__ == "__main__":
	srcfile = sys.argv[1]
	"""if len(sys.argv) == 3:
		destfile = sys.argv[2]
	else:
		destfile = srcfile + '.out'
	destfile = open(destfile, "w")
	destfile.write("\n".join(parseFile(srcfile)))"""
	from optparse import OptionParser
	# 命令行参数
	parser = OptionParser('')

	parser.add_option('-o', '--obj', dest='destfile', type='str', metavar='DESTFILE',
					  help="destination file name", default="")
	parser.add_option('-v', '--verilog', action='store_true', dest='verilog',
					  help='output verilog code segment file that can be used directly', default = False)
	parser.add_option('--hex', action="store_true", dest="hexformat",
						help="output in hex format rather than bin format", default = False)
	parser.add_option('-c', "--comment", action="store_true", dest="comment",
						help="output asm code comment together with binary code", default = False)
	options, junk = parser.parse_args(sys.argv[2:])
	if len(junk) != 0:
		raise Exception('Command line input not understood: ' + str(junk))
	destfile = options.destfile
	verilog = options.verilog
	hexformat = options.hexformat
	comment = options.comment
	if not destfile:
		destfile = srcfile + '.out'
	destfile = open(destfile, "w")
	binary, asmCode = parseFile(srcfile)

	if verilog:
		import math
		destfile.write("case(addr[%d:2])\n"%(int(math.ceil(math.log(len(binary), 2))) + 1))
		for i in range(len(binary)):
			if ":" in asmCode[i]:
				ind = asmCode[i].index(":") + 1
				destfile.write("\t// %s\n"%(asmCode[i][:ind]))
				asmCode[i] = asmCode[i][(ind+1):]
			if hexformat:
				binary = [x.replace("_", "") for x in binary]
				hexStr = hex(int(binary[i][11:], 2))[2:]
				hexStr = (8 - len(hexStr)) * "0" + rmlae(hexStr)
				destfile.write("\t%d: data <= 32'h"%i + hexStr + ";\n")
			else:
				#destfile.write("\t%d: data <= 32'b"%i + binary[i][11:17] + "_" + binary[i][17:22] + "_"
													  #+ binary[i][22:27] + "_" + binary[i][27:32] + "_"
												      #+ binary[i][32:37] + "_" + binary[i][37:43] 
												      #+ "; // %s\n"%asmCode[i])
				destfile.write("\t%d: data <= 32'b"%i + binary[i][11:] + "; // %s\n"%asmCode[i])
		destfile.write("\tdefault: data <= 32'b" + binary[0][11:] + ";\nendcase")
	else:
		binary = [x.replace("_", "") for x in binary]
		if hexformat:
			hexF = [rmlae(hex(int(x[11:], 2))[2:]) for x in binary]
			hexF = [binary[i][:11] + "\t" +"0" * (8 - len(hexF[i])) + hexF[i] for i in range(len(hexF))]
			if comment:
				destfile.write("\n".join([hexF[i] + " // " + asmCode[i] for i in range(len(hexF))]))
			else:
				destfile.write("\n".join(hexF))
		else:
			if comment:
				destfile.write("\n".join([binary[i] + " // " + asmCode[i] for i in range(len(binary))]))
			else:
				destfile.write("\n".join(binary))
