# -*- coding: utf-8 *-*
"""
cbeta xml TEI P5 轉 txt
"""
import os, re, sys

dir_in = '/release/cbeta-p5'
dir_out = '/release/p5-normal'
import p5totxt

def do_dir(source, dest):
	if not os.path.exists(dest): os.makedirs(dest)
	if os.path.isdir(source):
		os.chdir(source)
	l=os.listdir(source)
	for s in l:
		if s == 'dtd':
			continue
		if os.path.isdir(source+'/'+s):
			if s>='X01':
				do_dir(source+'/'+s, dest+'/'+s)
		elif re.match(r'^[TX]\d\d.*?\.xml$', s, re.I) != None:
		#elif re.match(r'^T\d\d.*?\.xml$', s, re.I) != None:
			do_file(source+'/'+s, dest, s)

def do_file(source, dest, fn):
	print fn
	p = p5totxt.xmlobj()
	s = p.Parse(source, dest, fn)

if len(sys.argv)>1:
	vol = sys.argv[1]
	vol = vol.upper()
	print vol
	do_dir(dir_in+'/'+vol, dir_out+'/'+vol)
else:
	do_dir(dir_in, dir_out)
