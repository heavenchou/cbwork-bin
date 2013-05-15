# -*- coding: utf-8 *-*
"""
Programmer: 周邦信 zhoubx@gmail.com
2007/1/2 10:04上午
"""
import os
folder_i = '/release/cbeta-p5'
folder_o = '/release/cbeta-p5-7z'

vols = os.listdir(folder_i)
for v in vols:
	dv = folder_i + '/' + v
	if os.path.isdir(dv):
		os.system('/cbwork/bin/7-Zip/7z a ' + folder_o + '/' + v + '.7z ' + dv + '/*')