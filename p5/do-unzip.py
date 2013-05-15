# -*- coding: utf-8 *-*
""" do-unzip.py
	2005/3/24 08:48¤U¤È
	by Ray
"""
import dircache, os, unzip

dir_in = 'c:/temp2/zip'
dir_out = 'c:/temp2'

l=dircache.listdir(dir_in)
for f in l:
	i = f.rfind('.')
	d = dir_out + '/' + f[:i]
	os.makedirs(d)
	un = unzip.unzip(True)
	un.extract(dir_in + '/' + f, d)
