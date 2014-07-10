#!/usr/bin/env python
#-*- coding: utf-8 -*-


import re

def gcd(m, n):
	if m == n:
		return m
	return gcd(min(m, n), abs(m - n))

def createTestFile(number):
	import random
	def conver(a):
		a = hex(a)[2:]
		return "0" * (2 - len(a)) + a
	f = open("test_input.txt", "w")
	for i in range(number):
		a = conver(random.randint(1, 255))
		b = conver(random.randint(1, 255))
		f.write(a)
		f.write(b)
	f.close()

def judgeRight(inStr, outStr):
	inStr = re.sub("\s", "", inStr)
	outStr = re.sub("\s", "", outStr)
	wrongAnsList = []
	for i in range(len(inStr)/4):
		m = int("0x" + inStr[4 * i:(4 * i + 2)], 16)
		n = int("0x" + inStr[(4 * i+2):(4 * i + 4)], 16)
		ans = gcd(m, n)
		if ans != int("0x" + outStr[2*i:(2*i + 2)], 16):
			wrongAnsList.append("gcd(%s, %s) ?= %s"%(inStr[4 * i:(4 * i + 2)], 
								inStr[(4 * i+2):(4 * i + 4)],outStr[2*i:(2*i + 2)]))
	if not wrongAnsList:
		print "all data is correct!"
	else:
		print "wrong!!!:", wrongAnsList


if __name__ == "__main__":
	import sys
	f = open(sys.argv[1])
	f1 = open(sys.argv[2])
	inStr = f.read()
	outStr = f1.read()
	judgeRight(inStr, outStr)