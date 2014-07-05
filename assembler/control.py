#!/usr/bin/env python
#-*- coding: utf-8 -*-

import re
import sys

f = open("input.out", "r")
outf = open("output.v.out", "w")
a = re.sub(r"[\t ]+", " ", f.read())
a = re.sub(r"\*", r"0", a).split("\n")
for line in a:
	b = line.split(" ")
	case = "".join(b[12:])
	case = "12'b" + case + (12 - len(case)) * "?"
	if len(b) == 1:
		sys.exit(1)
	string = ": {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3\'h%s, 2\'h%s, 1\'h%s, 1\'h%s, 1\'h%s, 6\'%s, 1\'h%s, 1\'h%s, 1\'h%s, 2\'h%s, 1\'h%s, 1\'h%s};\n"%tuple(b[:12])
	outf.write(case + string)