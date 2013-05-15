#-*- coding:utf-8 -*-
'''
修改自 Simon's XML Tools
周邦信 2011.06.11
'''

from lxml import etree

def getAncestorsTags(e):
	r=[]
	for ancestor in e.iterancestors():
		r.append(ancestor.tag)
	return r

def stripComments(tree):
	for el in tree.iter(tag=etree.Comment):
		el.getparent().remove(el)

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
