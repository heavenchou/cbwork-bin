import codecs, dircache, os, re
import datetime

current_date = datetime.date.today()
dir_in = '/release/cbeta-xml-2006-02-18'
dir_out = '/release/cbeta-p4'

if not os.path.exists(dir_out): os.makedirs(dir_out)
	
l=dircache.listdir(dir_in)
for s in l:
	if s == 'dtd' or s=='CVS':
		continue
	d = dir_in+'/'+s
	if not os.path.isdir(d):
		continue
	os.chdir(d)
	cmd = 'add_id ' + s
	print cmd
	os.system(cmd)
	cmd = 'copy *.ent %s/%s/' % (dir_out, s)
	cmd = cmd.replace("/", "\\")
	print cmd
	os.system(cmd)