import codecs, dircache, os, re, sys

dir_in = os.environ['CBWORK'] + '/common/X2R'
#dir_in = '/cbwork/common/X2R'
dir_out = os.environ['CONVTABDIR'] 
doconvtab = os.environ['DOCONVTAB'] 
if doconvtab != 'yes':
	sys.exit()
if not os.path.exists(dir_out): os.makedirs(dir_out)
l=dircache.listdir(dir_in)
for s in l:
	if s.endswith('.txt'):
		fnx = s.replace('.txt', '.xml')
		print s + ' => ' + fnx
		fi = codecs.open(dir_in+'/'+s, 'r', 'cp950')
		fo = codecs.open(dir_out+'/'+fnx, 'w', 'utf-8')
		fo.write('<?xml version="1.0" encoding="utf-8"?>\n')
		fo.write('<root>\n')
		for line in fi:
			line = line.strip()
			fo.write('\t<l n="%s">\n' % line)
			fo.write('\t\t<r vol="%s">%s</r>\n' % (line[19:22], line[23:]))
			fo.write('\t\t<x>%s</x>\n' % line[9:17])
			fo.write('\t</l>\n')
		fo.write('</root>')
		fi.close()
		fo.close()
