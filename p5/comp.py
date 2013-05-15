# -*- coding: big5 *-*
"""
add_id 前後的 xml 檔比對
2006/4/3 10:20 by Ray Chou
"""
import glob, re, sys

def comp_dir(dir1, dir2):
	l1=glob.glob(dir1+"/*.xml")
	l2=glob.glob(dir2+"/*.xml")
	if len(l1)!=len(l2):
		print '檔案數不同' 
		return
	for i in range(len(l1)):
		comp_file(l1[i], l2[i])

def comp_file(fn1, fn2):
	print fn1, fn2
	fi1=open(fn1, 'r')
	fi2=open(fn2, 'r')
	lines1=fi1.readlines()
	s = lines1[-1].strip()
	if s=='':
		del lines1[-1]
	lines2=fi2.readlines()
	if len(lines1)!=len(lines2):
		print '行數不同' 
		return
	for i in range(len(lines1)):
		if lines1[i]!=lines2[i]:
			comp_line(lines1[i], lines2[i])
	fi1.close()
	fi2.close()

def comp_line(s1, s2):
	s1=s1.replace('\n', '')
	s2=s2.replace('\n', '')
	s1=s1.replace('\r', '')
	s2=s2.replace('\r', '')
	s1=s1.replace('<cell/>', '<cell></cell>')
	s1 = re.sub('<milestone( .*?)></milestone>', r'<milestone\1/>', s1)
	s1 = re.sub('<mulu( .*?)></mulu>', r'<mulu\1/>', s1)
	s1 = re.sub('<figure( .*?)></figure>', r'<figure\1/>', s1)
	l1=re.split('(<.*?>)', s1)
	l2=re.split('(<.*?>)', s2)
	#for s in l1:
	#	print s
	#for s in l2:
	#	print s
	if len(l1)!=len(l2):
		print s1
		print s2
		for s in l1:
			print '['+s+']'
		print '>>>>>>>>>>>>'
		for s in l2:
			print '['+s+']'
		print '標記數不同'
		print '=============='
		return
	for i in range(len(l1)):
		t1 = l1[i]
		t2 = l2[i]
		if t1!= t2:
			equ = False
			if t1.startswith('</') or t2.startswith('</'):
				pass
			elif t1.startswith('<') and t2.startswith('<'):
				equ = comp_tag(t1, t2)
			if not equ:
				print '51'
				print t1
				print s1
				print '>>>>>>>>>>>>>>'
				print t2
				print s2
				print '=============='
				return
def comp_tag(t1, t2):
	i1 = t1.find(' ')
	i2 = t2.find(' ')
	n1 = t1[1:i1]
	n2 = t2[1:i2]
	if n1!=n2:
		return False

	if i1==-1:
		attrs1=''
	else:
		attrs1 = t1[i1+1:-1]
	if i2==-1:
		attrs2 = ''
	else:
		attrs2 = t2[i2+1:-1]

	if attrs1.endswith('/') and attrs2.endswith('/'):
		attrs1 = attrs1[:-1]
		attrs2 = attrs2[:-1]
	if n1=='lb':
		attrs1 = attrs1.replace(' ed="T"', '')
		attrs2 = attrs2.replace(' ed="T"', '')
	elif n1=='lem':
		attrs1 = re.sub(' ?wit=".*?"', '', attrs1)
		attrs2 = re.sub(' ?wit=".*?"', '', attrs2)
	elif n1=='p' or n1=='lg' or n1=='item':
		attrs1 = re.sub(' ?id=".*?"', '', attrs1)
		attrs2 = re.sub(' ?id=".*?"', '', attrs2)
	l1 = attrs1.split()
	l2 = attrs2.split()
	i1 = len(l1)
	i2 = len(l2)
	if i1!=i2:
		return False
	l1.sort()
	l2.sort()
	for i in range(i1):
		l1[i] = re.sub("loc='(.*?)'", r'loc="\1"', l1[i])
		l1[i] = re.sub("label='(.*?)'", r'label="\1"', l1[i])
		if l1[i]!=l2[i]:
			print '============='
			print l1
			print '>>>>>>>>>>>'
			print l2
			print '=============='
			return False
	return True

dir1 = sys.argv[1]
dir2 = sys.argv[2]
comp_dir(dir1, dir2)
