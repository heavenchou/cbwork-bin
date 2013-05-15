"""
zip.py
壓縮 xml 目錄
執行方式: 
	zip.py 輸入目錄 輸出目錄
	zip.py 輸入目錄 輸出目錄 冊數
by Ray Chou 2006/3/28 9:14
"""
import zipfile
import glob, os, re, sys

def zip_vol(vol):
	file = zipfile.ZipFile(dirout + "/" + vol + ".zip", "w")
	d = dirin + "/" + vol
	l = os.listdir(d)
	for name in l:
		if name.endswith('xml') or name.endswith('ent'):
			print name,
			file.write(d+'/'+name, vol+'/'+name, zipfile.ZIP_DEFLATED)

	file.close()

dirin = sys.argv[1]
dirout = sys.argv[2]
if not os.path.exists(dirout): os.makedirs(dirout)
if len(sys.argv)>3:
	vol = sys.argv[3].upper()
	zip_vol(vol)
else:
	l=os.listdir(dirin)
	l.sort()
	for s in l:
		if re.match(r'^[TX]\d\d', s, re.I) != None:
			zip_vol(s)