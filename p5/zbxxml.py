#-*- coding:utf-8 -*-
import collections
import os
from lxml import etree

class Node():
	def __init__(self, e=None):
		if e is None:
			self.tag = ''
			self.attrib = collections.OrderedDict()
		else:
			self.tag=e.tag
			self.attrib=collections.OrderedDict(e.attrib)
			
	def opentag(self):
		r = '<' + self.tag
		for k, v in self.attrib.items():
			r += ' {}="{}"'.format(k, v)
		r += '>'
		return r
		
	def get(self, name):
		return self.attrib.get(name)
		
	def set(self, name, value):
		self.attrib[name] = value

def stripNamespaces(tree):
    # http://wiki.tei-c.org/index.php/Remove-Namespaces.xsl
    xslt_root = etree.XML('''\
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="no"/>

<xsl:template match="/|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
</xsl:template>

<xsl:template match="@*">
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>
</xsl:stylesheet>
''')
    transform = etree.XSLT(xslt_root)
    tree = transform(tree)
    return tree
    
def validate(xml, rnc, jing):
	cmd = 'java -Xms64000k -Xmx512000k -jar "{}" -c {} {}'.format(jing, rnc, xml)
	r = os.system(cmd)
	if r==1:
		return False
	else:
		return True

def get_ancestors(e):
	r=[]
	for ancestor in e.iterancestors():
		r.append(ancestor.tag)
	return r