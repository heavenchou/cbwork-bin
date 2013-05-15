<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:math="http://xsltsl.org/math"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"    xmlns:cb="http://www.cbeta.org/ns/1.0"
    exclude-result-prefixes="teix math tei xd xsi xs" version="2.0">
<xsl:output  indent="no" />
<!-- this is buggy and does not work with Saxon 8, so we stay with hex in the output for now 
<xsl:import href="http://xsltsl.sourceforge.net/modules/stdlib.xsl"/>    -->
<xd:doc type="stylesheet">
<xd:short> Stylesheet for converting CBETA P4 to P5 </xd:short>
<xd:detail/>
</xd:doc>
<xsl:variable name="rev">$Revision: 1.64 $</xsl:variable>
<xsl:variable name="revdate">$Date: 2011/08/15 03:10:34 $</xsl:variable>
<!-- this is the name of the file that holds character descriptions-->
<!--    <xsl:param name="cbdesc">../dtd/cbchardesc.xml</xsl:param>-->
<xsl:param name="cbdesc"/>
<xsl:param name="current_date">2009-06-23</xsl:param>
<xsl:param name="docfile"/>
<xsl:param name="convtabdir">/Users/chris/cbeta/common/X2R</xsl:param>
<xsl:param name="gaiji">p6</xsl:param>
<xsl:key name="x-map" match="//l" use="x"/>
<xsl:key name="c-gaiji" match="gaiji" use="cb"/>
<xsl:variable name="cbgaiji" select="document('cbgaiji.xml')"/>
<xsl:key name="x-wl" match="//tei:witness" use="."/>
<xsl:key name="x-rl" match="//tei:respStmt/@n" use="."/>
<xsl:variable name="wl">
<xsl:if test="count(//@wit) > 0">
<xsl:text>
</xsl:text>            
<xsl:element name="listWit" namespace="http://www.tei-c.org/ns/1.0">
<xsl:for-each select="distinct-values(//@wit/tokenize(., '[ 【]'))[position()>1]">
<xsl:text>
</xsl:text>            
<xsl:element name="witness" namespace="http://www.tei-c.org/ns/1.0">
<xsl:attribute name="xml:id" select="concat('wit', position())"/>
<xsl:choose>
<xsl:when test="contains(., '】')">
<xsl:text>【</xsl:text>
</xsl:when>
</xsl:choose>
<xsl:value-of select="."/>
</xsl:element>
</xsl:for-each>
<xsl:text>
</xsl:text>            
</xsl:element>
</xsl:if>
</xsl:variable>
<!--                 <respStmt xml:id="resp1"><resp></resp><name></name><name></name></respStmt>
    -->
<xsl:variable name="rl">
	<xsl:if test="count(//@resp) > 0">
		<xsl:for-each select="distinct-values(//tokenize(normalize-space(@resp), ' '))">
			<xsl:text>
	</xsl:text>
			<xsl:element name="respStmt" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:attribute name="xml:id" select="concat('resp', position())"/>
				<xsl:attribute name="n" select="."/>
				<xsl:element name="resp" namespace="http://www.tei-c.org/ns/1.0">corrections</xsl:element>
				<xsl:for-each select="tokenize(., '[ 【]')">
					<xsl:if test=".!=''">
						<xsl:element name="name" namespace="http://www.tei-c.org/ns/1.0">
							<xsl:if test="contains(., '】')">
								<xsl:text>【</xsl:text>
							</xsl:if>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:if>
				</xsl:for-each>
			</xsl:element>
		</xsl:for-each>
	</xsl:if>
</xsl:variable>
<xsl:variable name="convtab">
<xsl:if test="starts-with($docfile, 'X')">
<xsl:variable name="convtab" select="concat($convtabdir, '/', substring($docfile, 1, 3), 'R.xml')"/>
              
<!--
          
<root>
<xsl:for-each select="tokenize(unparsed-text(concat($convtabdir, '/', substring($docfile, 1, 3), 'R.txt'), 'iso-8859-1'), '\n')">
<xsl:variable name="line" select="tokenize(. , '[_#A-Za-z]?#.*?R')"/>
<l n="R{$line}">
<r><xsl:value-of select="substring-after($line[2], '_')"/></r>
<x><xsl:value-of select="substring-after($line[1], '_')"/></x>
</l><xsl:text>
</xsl:text>
</xsl:for-each>
</root>
        -->
<!--引用xml來源文件之外的xml文件，ex：document('test.xml') 就是取出當前目錄下的test.xml 當取出test.xml後，會建講出test.xml的結構樹，然後傳回僅含根節點的節點集-->
<xsl:if test="doc-available($convtab)">
<xsl:message>
<xsl:value-of select="concat($convtabdir, '/', substring($docfile, 1, 3), 'R.txt')"/>
</xsl:message>
<xsl:copy-of select="document($convtab)"/>
</xsl:if>
</xsl:if>
</xsl:variable>
<xsl:variable name="ed">
<xsl:variable name="lbval" select="concat('p', (//lb[1]/@n)[1])"/>
<xsl:for-each select="$convtab">
<xsl:value-of select="concat('R', string-join(key('x-map', $lbval)/r[1]/@vol, ''))"/>
</xsl:for-each>
</xsl:variable>

<!-- the default conversion -->
<xsl:template match="*">
<xsl:element namespace="http://www.tei-c.org/ns/1.0" name="{local-name(.)}" >
<xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
</xsl:element>
</xsl:template>
    
<!--把這些資訊都拿掉不顯示-->
    
<xsl:template match="@part|@org|@sample|@targOrder|@role"/>
<!--開始執行輸出文件本體-->
    
<xsl:template match="TEI.2">
<xsl:text>
</xsl:text>
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0"
            xml:id="{substring-before($docfile, '.')}">
<!--以下執行文件內容-->
<xsl:apply-templates/>
</TEI>   
</xsl:template>
    
<!--這幾種tag都在teiHeader/  處理方式如下，(照抄)-->
<xsl:template
        match="teiHeader|fileDesc|titleStmt|titleStmt/title|author|respStmt|edition|extent|publicationStmt|distributor|distributor/name|address|addrLine|availability|fileDesc|projectDesc|teiHeader//p|langUsage|body|encodingDesc|teiHeader//date|profileDesc">
<xsl:text>
</xsl:text>
<xsl:element namespace="http://www.tei-c.org/ns/1.0" name="{local-name(.)}">
<!--(照抄)…各種template如下，前去對照它的模板-->
<xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
</xsl:element>
</xsl:template>
    
<xsl:template match="sourceDesc">
<xsl:text>
</xsl:text>            
<xsl:element name="sourceDesc" namespace="http://www.tei-c.org/ns/1.0" >
<xsl:choose>
<!--  T08n0236a and b have a <p> in the sourceDesc -->
<xsl:when test="./p">
<xsl:element name="p">
<xsl:apply-templates select="p/child::*"/>
<xsl:copy-of select="$wl"/>
</xsl:element>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates/>
<xsl:copy-of select="$wl"/>
</xsl:otherwise>
</xsl:choose>
<xsl:text>
</xsl:text>            
</xsl:element>
</xsl:template>
    
<xsl:template match="editionStmt">
<xsl:text>
</xsl:text>
<xsl:element namespace="http://www.tei-c.org/ns/1.0" name="{local-name(.)}">
<xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
<xsl:copy-of select="$rl"/>
</xsl:element>
</xsl:template>


<!--記錄修改者資訊-->
    
<xsl:template match="revisionDesc">
	<xsl:text>
</xsl:text>
	<xsl:element name="revisionDesc" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:text>
</xsl:text>
		<xsl:element name="change" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:attribute name="when">
				<xsl:value-of select="substring(string(current-date()), 1, 10)"/>
			</xsl:attribute>
			<xsl:element name="name" namespace="http://www.tei-c.org/ns/1.0">CW</xsl:element>
			<xsl:element name="name" namespace="http://www.tei-c.org/ns/1.0">Ray Chou 周邦信</xsl:element>
			<xsl:text>P4 to P5 conversion by cbetap4top5.xsl  Rev. </xsl:text>
			<xsl:value-of select="substring($rev, 11, string-length($rev)-11)"/>
			<xsl:text> of </xsl:text>
			<xsl:value-of select="substring($revdate, 7, 11)"/>
			<xsl:text>: P5 version, intended for publication</xsl:text>
		</xsl:element>
		<!-- 
			保留 cvs commit messages, 2010.10.25 modified by Ray
			移除 cvs commit messages, 2010.10.23 modified by Ray
		<xsl:apply-templates select="*|@*|text()"/>
		-->
		<xsl:apply-templates/>
		<xsl:text>
</xsl:text>
	</xsl:element>
</xsl:template>
<!--記錄修改時間-->
<xsl:template match="change">
<xsl:text>
</xsl:text>
<xsl:element name="change" namespace="http://www.tei-c.org/ns/1.0">
<xsl:attribute name="when">
<xsl:choose>
<!--  a date of this format:  19990810/22:31:27  (for example in T01n0001 -->
<xsl:when test="string-length(date) = 17">
<xsl:value-of select="concat(substring(date, 1, 4), '-', substring(date, 5, 2), '-', substring(date, 7, 2), 'T', substring(date, 10))"/>
</xsl:when>
<!--  a date of this format:   2008/04/15 13:13:18 (for example in J01nA042-->
<xsl:when test="contains(date, ' ')">
<xsl:value-of select="translate(date, '/ ', '-T')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="date"/>
</xsl:otherwise>
</xsl:choose>
</xsl:attribute>
<xsl:value-of select="respStmt/name"/> 
<xsl:text> (</xsl:text>
<xsl:value-of select="respStmt/resp"/>
<xsl:text>) </xsl:text>
<xsl:apply-templates select="item"/>
</xsl:element>
</xsl:template>
    
<xsl:template match="change/item">
<xsl:apply-templates/>
</xsl:template>

<!-- marked by Ray 2010.12.31
<xsl:template match="foreign/@place|lg/@place|juan/@place|entry/@place|note/@place|tt/@place">
	<xsl:attribute name="rend" select="."/>
</xsl:template>
-->
<xsl:template match="foreign/@place|entry/@place|lg/@place">
	<xsl:attribute name="cb:place" select="."/>
</xsl:template>
    
<xsl:template match="table/@border">
<xsl:attribute name="rend" select="concat('border:', .)"/>
</xsl:template>
<xsl:template match="trailer/head">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="head[@type='no']">
<xsl:text>
</xsl:text>
<xsl:element name="cb:docNumber" namespace="http://www.cbeta.org/ns/1.0">
	<xsl:apply-templates/>
</xsl:element>
</xsl:template>

<xsl:template match="ref">
 <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
  <xsl:attribute name="target" select="concat('#', @target)"/>
  <xsl:apply-templates/>
 </xsl:element>
</xsl:template>

<xsl:template match="xref">
 <xsl:element name="ref">
  <xsl:attribute name="target">
   <xsl:value-of
                    select="concat('../', substring(@doc, 1, 3), '/', @doc, '.xml#xpath2(//', @loc, ')')"
                />
  </xsl:attribute>
  <xsl:if test="@rend">
   <xsl:attribute name="rend" select="@rend"/>
  </xsl:if>
  <xsl:apply-templates/>
 </xsl:element>
</xsl:template>
    
<!--製作圖片連結-->
<!-- modified by Ray 2010.10.21, <lem> 和 <rdg> 裏面的 <figure> 在 <back> 裏要出現
<xsl:template match="figure">
-->
<xsl:template match="figure" mode="#all">
	<xsl:variable name="doc-letter">
		<xsl:value-of select="substring($docfile, 1, 1)"/>
	</xsl:variable>
	<xsl:element name="figure" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:element name="graphic">
			<xsl:choose>
				<xsl:when test="$doc-letter = 'T'">
					<!-- modified by Ray 2011.8.3
					<xsl:attribute name="url" select="concat('../figures/', $doc-letter, '/', $doc-letter, substring-after( unparsed-entity-uri(@entity), 'figures/'))"/>
					-->
					<xsl:attribute name="url" select="concat('../figures/', $doc-letter, '/', substring-after( unparsed-entity-uri(@entity), 'figures/'))"/>
				</xsl:when>
				<xsl:when test="$doc-letter = 'X'">
					<xsl:attribute name="url" select="concat('../figures/', $doc-letter, '/',  substring-after( unparsed-entity-uri(@entity), 'figures/'))"/>
				</xsl:when>
				<xsl:otherwise><!-- added by Ray 2010.10.20 -->
					<xsl:attribute name="url" select="concat('../figures/', $doc-letter, '/', substring-after( unparsed-entity-uri(@entity), 'figures/'))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:element>
</xsl:template>
    
<xsl:template match="@resp" mode="#all">
	<xsl:variable name="token" select="normalize-space(.)" />
	<xsl:attribute name="{local-name()}">
		<xsl:text>#</xsl:text>
		<xsl:for-each select="$rl">
			<xsl:choose>
				<xsl:when test="contains($token, ' ')">
					<xsl:variable name="tok1" select="substring-before($token, ' ')"/>
					<xsl:variable name="tok2" select="substring-after($token, ' ')"/>
					<xsl:value-of select="key('x-rl', $tok1)/parent::tei:respStmt/@xml:id"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="key('x-rl', $tok2)/parent::tei:respStmt/@xml:id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="key('x-rl', $token)/parent::tei:respStmt/@xml:id"/>
				</xsl:otherwise>
			</xsl:choose>    
		</xsl:for-each>    
	</xsl:attribute>
</xsl:template>


<!-- we need to get rid of the corr attribute on sic -->
<xsl:template match="@corr" mode="#all"/>


<!--  we need to change this to the #wit1 ID defined in the header  -->
<xsl:template match="@wit" mode="#all">
<xsl:attribute name="{local-name()}">
<xsl:choose>
<xsl:when test="contains(., '【')">
<xsl:for-each select="tokenize(., '【')[position()>1]">
<xsl:variable name="token" select="concat('【', .)"/>
<xsl:text>#</xsl:text>
<xsl:for-each select="$wl">
<xsl:value-of select="key('x-wl', $token)/@xml:id"/>
</xsl:for-each>    
<xsl:if test="not (position() = last())">
<xsl:text> </xsl:text>
</xsl:if>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<xsl:for-each select="tokenize(., '\s')">
<xsl:text>#</xsl:text>
<xsl:value-of select="."/>
<xsl:if test="not (position() = last())">
<xsl:text> </xsl:text>
</xsl:if>
</xsl:for-each>
</xsl:otherwise>
</xsl:choose>
</xsl:attribute>
</xsl:template>    
    

<xsl:template match="@*|processing-instruction()|comment()">
<xsl:choose>
<xsl:when test="contains(., &quot;-*- coding&quot;)"> 
<!-- do nothing if we have the coding cookie -->
</xsl:when>
<xsl:when test="contains(., &quot;cbeta.xsl&quot;)"/>
<xsl:otherwise>
<xsl:copy/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
    
<xsl:template match="@TEIform" mode="#all">
<xsl:if test="not(. = name(..))">
<xsl:attribute name="TEIform">
<xsl:value-of select="."/>
</xsl:attribute>
</xsl:if>
</xsl:template>
<xsl:template match="langUsage/language">
<xsl:element name="language">
<xsl:attribute name="ident">
<xsl:call-template name="nlang">
<xsl:with-param name="l" select="@id"/>
</xsl:call-template>
</xsl:attribute>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>
<xsl:template match="langUsage/@default"/>

<xsl:template match="p/@place">
	<xsl:choose>
		<xsl:when test="contains(., 'inline')">
			<xsl:attribute name="rend" select="."/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="cb:type" namespace="http://www.cbeta.org/ns/1.0">
				<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="app/@source" mode="#all">
	<xsl:attribute name="corresp">
		<xsl:value-of select="concat('#', .)"/>
	</xsl:attribute>
</xsl:template>
	
<xsl:template match="@lang|@id">
<xsl:variable name="l"><xsl:value-of select="."/></xsl:variable>
<xsl:attribute name="{concat('xml:', name())}">
<xsl:call-template name="nlang">
<xsl:with-param name="l" select="$l"/>
</xsl:call-template>
</xsl:attribute>
</xsl:template>

<xsl:template match="sic">
<!-- we need to move the choice to the end!-->
<!-- sic in T01n0001.xml for example seems to be app rather than sic!  (e.g. 

<lb n="0126b07" ed="T"/><l>百千<note n="0126005" resp="Taisho" place="foot text" pe="orig">明校&CB01319;曰無當作厚</note><sic n="0126005" resp="【明】" corr="厚">無</sic>雲壽</l><l><note n="0126006" resp="Taisho" place="foot text" type="orig">明校&CB01319;曰四十一雲當作一&CB00425;頭摩</note><sic n="0126006" resp="【明】" corr="一CB00425頭摩">四十一雲</sic>壽</ly
-->
<xsl:element name="anchor">
    <xsl:attribute name="xml:id">
        <xsl:text>begsic</xsl:text>
        <xsl:choose>
            <xsl:when test="@n">
                <xsl:value-of select="@n"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:element>
<xsl:value-of select="@corr"/>
<xsl:element name="anchor">
    <xsl:attribute name="xml:id">
        <xsl:text>endsic</xsl:text>
        <xsl:choose>
            <xsl:when test="@n">
                <xsl:value-of select="@n"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
</xsl:element>    
</xsl:template>

<!-- ed="C T" 表示 CBETA版跟大正藏, ed="C" 代表中華大藏經 -->
<xsl:template match="@ed">
 <xsl:choose>
  <xsl:when test="contains(., ' ')">
   <xsl:variable name="ed1" select="replace(., 'C ', '')"/>
   <xsl:attribute name="ed" select="replace($ed1, ' C', '')"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:attribute name="ed" select="."/>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="lb">
	<xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0">
		<!-- <xsl:if test="contains(@ed, 'C')"> -->
		<xsl:if test="contains(@ed, 'C') and contains(@ed, ' ')">
			<xsl:attribute name="type">honorific</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="@*"/>
	</xsl:element>
	<xsl:variable name="lbval" select="concat('p', @n)"/>
	<!--      <xsl:message select="$lbval"/> -->
	<xsl:if test="not($convtab = '')">
		<!--
		<xsl:variable name="temp">
		<xsl:for-each select="$convtab">
		<xsl:copy-of select="key('x-map', concat('p', $lbval))"/>
		</xsl:for-each>
		</xsl:variable>
		      -->
		<xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:attribute name="ed" select="$ed"/>
			<!--
			<xsl:for-each select="$convtab">
			<xsl:value-of select="concat('Z', string-join(key('x-map', $lbval)/r[1]/@vol, ''))"/>
			</xsl:for-each>
			</xsl:attribute>
			<xsl:variable name="temp1">
			<xsl:for-each select="$convtab">
			<xsl:copy-of select="key('x-map', $lbval)"/>
			</xsl:for-each>
			</xsl:variable>
			      -->
			<xsl:attribute name="n" >
				<xsl:for-each select="$convtab">
					<xsl:value-of select="substring(string-join(key('x-map', $lbval)/r, ''), 2)"/>
				</xsl:for-each>
			</xsl:attribute>
		</xsl:element>
		<!--
		<xsl:if test="contains($temp/preceding-sibling::l[1]/@n, '-')">
		<xsl:element name="pb" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:attribute name="ed">Z</xsl:attribute>
		<xsl:attribute name="n"><xsl:value-of select="substring($temp/r, 1, 5)"/></xsl:attribute>
		<xsl:attribute name="xml:id"><xsl:value-of select="concat('Z.', $temp/r/@vol, '.', substring($temp/r, 1, 5))"/></xsl:attribute>
		</xsl:element>
		</xsl:if>
		-->
	</xsl:if>
</xsl:template>

<xsl:template match="c" mode="#all">
<xsl:choose>
<xsl:when test="@rend">
<xsl:value-of select="@rend"/>
</xsl:when>
</xsl:choose>
</xsl:template>
  
<xsl:template match="gaiji" mode="#all">
  <!--  there is a bug here , and I do not know if we need this, so for the moment disabled   -->
  <!-- for no nor, we make no gaiji replacements -->
  <!--    
    <xsl:choose>
        <xsl:when test="ancestor-or-self::*/@rend='no_nor'">
        <xsl:element name="g">
        <xsl:attribute name="ref">
        <xsl:value-of select="$cbdesc"/>#<xsl:value-of select="@cb"/>
        </xsl:attribute>
        </xsl:element>
        </xsl:when>
        <xsl:otherwise>
        -->
  <xsl:variable name="tmp" select="substring(@cb, 3)"/>          
    
  <!-- $cbgaiji//gaiji[cb = $tmp] -->
  <xsl:variable name="thisgaiji">
    <xsl:for-each select="$cbgaiji">
      <xsl:copy-of select="key('c-gaiji', $tmp)"/>
    </xsl:for-each>
  </xsl:variable> 
  <!--
        thisgaiji: <xsl:copy-of select="$thisgaiji"/>
        uni:
  <xsl:value-of select="$thisgaiji//uni"/> -->
  <xsl:choose>
  <!--
  <xsl:when test="@uni">
    <xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
    <xsl:value-of select="@uni"/>
    <xsl:text>;</xsl:text>
  </xsl:when>
            -->
    <xsl:when test="$thisgaiji//uni">
      <xsl:choose>
        <xsl:when test="starts-with($thisgaiji//uni[1], '&amp;')">
          <xsl:value-of select="$thisgaiji//uni[1]" disable-output-escaping="yes"/>
        </xsl:when>
        <xsl:when test="string($thisgaiji//uni[1]) = '?'">
          <xsl:element name="g">
            <xsl:attribute name="ref">
              <xsl:value-of select="$cbdesc"/>#<xsl:value-of select="@cb"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:when>
        <xsl:when test="string-length($thisgaiji//uni[1]) = 1">
          <xsl:comment> here was the problem</xsl:comment> 
          <xsl:value-of select="$thisgaiji//uni[1]"/>
        </xsl:when>
        <!-- do I ever reach this? -->
        <xsl:when test="contains($thisgaiji//uni[1], ';')">
          <xsl:for-each select="tokenize($thisgaiji//uni[1], ';')">
            <xsl:if test="string-length(.)&gt;0">
              <xsl:comment>this is the value : "<xsl:value-of select="."/>"</xsl:comment>
              <xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
              <xsl:value-of select="."/>
              <xsl:text>;</xsl:text>
            </xsl:if>   
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!--                        <xsl:comment select="@cb"></xsl:comment> -->
          <xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
          <xsl:value-of select="$thisgaiji//uni[1]"/>
          <xsl:text>;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--測試有沒有uni的欄位 條件：有多一個分號-->
    <xsl:when test="contains(@uni, ';')">
      <xsl:comment>found @uni <xsl:copy-of select="."/></xsl:comment>
      <xsl:for-each select="tokenize(@uni, ';')">
      <xsl:if test="string-length(.)&gt;0">
        <xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>;</xsl:text>
      </xsl:if>    
      </xsl:for-each>
    </xsl:when>
    <!--測試有沒有uni的欄位 測試條件 長度小於5-->
    <xsl:when test="@uni">
      <!--                <xsl:comment>UNI <xsl:value-of select="@uni"/> from ent file.</xsl:comment>-->
      <xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
      <xsl:value-of select="@uni"/>
      <xsl:text>;</xsl:text>
    </xsl:when>
    <xsl:when test="starts-with($tmp, 'x')">
      <!-- CI entity, but no Unicode: we split the values and output two <g> characters-->
      <xsl:for-each select="tokenize(@cx, '；')[not(. = '')]">
        <xsl:element name="g">
          <xsl:attribute name="ref">
            <xsl:value-of select="$cbdesc"/>#<xsl:value-of select="substring(., 2)"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:for-each>
    </xsl:when>
    <xsl:when test="@cb">
      <xsl:element name="g">
        <xsl:attribute name="ref">
          <xsl:value-of select="$cbdesc"/>#<xsl:value-of select="@cb"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:comment>
        <xsl:text>Unhandled gaiji!</xsl:text>
        <xsl:value-of select="@des"/>
      </xsl:comment>
    </xsl:otherwise>
  </xsl:choose>
<!--</xsl:otherwise>
</xsl:choose>
-->
</xsl:template>
  
<xsl:template match="mulu">
<xsl:element name="cb:mulu" namespace="http://www.cbeta.org/ns/1.0">
<!--  [2010-02-08T14:32:25+0900]
     this avoids setting empty @level for the cb:mulu elements that indicate the beginning of juan
            -->
<xsl:apply-templates select="@* except @label"/>
<!-- <xsl:attribute name="type">
<xsl:value-of select="@type"/>
</xsl:attribute>
<xsl:attribute name="level">
<xsl:value-of select="@level"/>
</xsl:attribute>
-->
<xsl:call-template name="attgaiji">
	<xsl:with-param name="str">
		<xsl:value-of select="@label"/>
	</xsl:with-param>
</xsl:call-template>
</xsl:element>
<!--            
<xsl:for-each select="//gaiji[count(. | key('c-gaiji', @cb)[1]) = 1]">
            -->
<!--            <xsl:value-of select="$gai" disable-output-escaping="yes"/>-->
</xsl:template>
    
<xsl:template match="juan/head">
<xsl:element name="cb:jhead" namespace="http://www.cbeta.org/ns/1.0">
<xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
</xsl:element>
</xsl:template>
    
<xsl:template match="byline">
<xsl:element name="byline" namespace="http://www.tei-c.org/ns/1.0">
<xsl:if test="@type">
<xsl:attribute name="cb:type">
<xsl:value-of select="@type"/>
</xsl:attribute>
</xsl:if>  
<xsl:apply-templates/>
</xsl:element>
</xsl:template>

<!-- todo: need to do something sensible with t, cf <tt n="0080003" type="app"> in T01n0001.xml  -->
<!--在<text/>下產生 各區塊的資料-->
<!-- here is the stuff for moving the text critical stuff -->
<xsl:template match="text">
	<xsl:text>
</xsl:text>
	<xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/><!--如常取值，及製造節點-->
	<xsl:text>
</xsl:text>

<!--有發現<app/>的話-->
<!-- modified by Ray 2010.10.20, T20n1144 完全沒有 app, 但有 <note resp="CBETA"> 還是要產生 <back> 
<xsl:if test="count(//app|//note[@resp='ZangWai'])&gt;0">
-->
<xsl:if test="count(//app|//note[@resp='CBETA']|//note[@resp='ZangWai'])&gt;0">
<!--產生所有的校勘資料  會先測試是否有<app>-->
	<xsl:element name="back" namespace="http://www.tei-c.org/ns/1.0">
	<!--有的話就製造back 節點來包裏-->
		<xsl:text>
</xsl:text>
		<xsl:if test="//app">
			<cb:div type="apparatus" >
				<xsl:text>
</xsl:text>
				<head>校勘記</head>
				<xsl:text>
</xsl:text><p>
				<!--產生app/*  的校勘資料-->
				<xsl:call-template name="gen-app"/>
				<xsl:text>
</xsl:text>
				</p>
				<xsl:text>
</xsl:text>
			</cb:div>
			<xsl:text>
</xsl:text>
		</xsl:if>
		
<!--把所有的tt的資料用這個區塊處理-->
<xsl:if test="//tt[@type='app']">
	<xsl:element name="cb:div" namespace="http://www.cbeta.org/ns/1.0">
		<xsl:attribute name="type"><xsl:text>tt</xsl:text></xsl:attribute>
		<xsl:text>
</xsl:text>
		<xsl:element name="head">
			<xsl:text>多語詞條對照</xsl:text>
		</xsl:element>
		<xsl:text>
</xsl:text>
		<xsl:element name="p">
			<xsl:call-template name="gen-tt"/>
			<xsl:text>
</xsl:text>
		</xsl:element>
		<xsl:text>
</xsl:text>
	</xsl:element>
	<xsl:text>
</xsl:text>
</xsl:if>
		
<!--把所有的Taisho.note的資料用這個區塊處理    大正-->
<xsl:if test="//note[@resp='Taisho']">
	<cb:div type="taisho-notes">
	<xsl:text>
</xsl:text>
		<head>大正校勘記</head>
		<xsl:text>
</xsl:text>
		<p>
		<xsl:call-template name="gen-tnote"/>
		<xsl:text>
</xsl:text>
		</p>
		<xsl:text>
</xsl:text>
	</cb:div>
	<xsl:text>
</xsl:text>
</xsl:if>
    
<!-- see if we have xuzangjing-notes -->
<xsl:if test="//note[@resp='Xuzangjing']">
	<cb:div type="xuzang-notes">
	<xsl:text>
</xsl:text>
		<head>卍續藏校勘記</head>
		<xsl:text>
</xsl:text>
		<p>
		<xsl:call-template name="gen-tnote"/>
		<xsl:text>
</xsl:text>
		</p>
		<xsl:text>
</xsl:text>
	</cb:div>
	<xsl:text>
</xsl:text>
</xsl:if>

<!-- [2010-04-06T13:23:06+0900] add ihp notes  -->
<!--把所有的ihp.note的資料用這個區塊處理    【史】-->
<xsl:if test="//note[@resp='ihp']">
	<cb:div type="ihp-notes">
	<xsl:text>
</xsl:text>
		<head>中央研究院歷史語言研究所校勘記</head>
		<xsl:text>
</xsl:text>
		<p>
		<xsl:call-template name="gen-tnote"/>
		<xsl:text>
</xsl:text>
		</p>
		<xsl:text>
</xsl:text>
	</cb:div>
	<xsl:text>
</xsl:text>
</xsl:if>

<!-- [2010-04-06T13:23:06+0900] add ihp notes  -->
<!-- and ZangWai notes -->
<!--把所有的ZangWai.note的資料用這個區塊處理    -->
<xsl:if test="//note[@resp='ZangWai']">
<cb:div type="zangwai-notes">
<xsl:text>
</xsl:text>
<head>方廣錩校勘記</head>
<xsl:text>
</xsl:text>
<p>
<xsl:call-template name="gen-tnote"/>
<xsl:text>
</xsl:text>
</p>
<xsl:text>
</xsl:text>
</cb:div>
<xsl:text>
</xsl:text>
</xsl:if>

<!-- 2010-02-04:  moving sic to the back -->
<xsl:if test="//sic">
<cb:div type="apparatus" >
<xsl:text>
</xsl:text>
<head>CBETA修訂記錄</head>
<xsl:text>
</xsl:text>
<p>
<!--產生app/*  的校勘資料-->
<xsl:call-template name="gen-sic"/>
<xsl:text>
</xsl:text>
</p>
<xsl:text>
</xsl:text>
</cb:div>    
</xsl:if>    
    
    <!-- see if there are any extra notes  -->    
    <!-- 2010-02-04: adding this for extra notes  cf evalu Q1-->
<xsl:if test="//note[@type='equivalent']">
<cb:div type="equiv-notes">
<xsl:text>
</xsl:text>
<head>相對應巴利文書名</head>
<xsl:text>
</xsl:text>
<p>
<xsl:call-template name="gen-eqnote"/>
<xsl:text>
</xsl:text>
</p>
<xsl:text>
</xsl:text>
</cb:div>
<xsl:text>
</xsl:text>
</xsl:if>

<!-- added by Ray 2010.10.20 -->
<xsl:if test="//note[@type='rest']|//note[@type='cf.']|//foreign[@place='foot']">
<cb:div type="rest-notes">
<xsl:text>
</xsl:text>
<head>其他註解</head>
<xsl:text>
</xsl:text>
<p>
<xsl:call-template name="gen-restnote"/>
<xsl:text>
</xsl:text>
</p>
<xsl:text>
</xsl:text>
</cb:div>
<xsl:text>
</xsl:text>
</xsl:if>

<!--把所有的CBETA.note的資料用這個區塊處理    CBETA-->
<xsl:if test="//note[@resp='CBETA']">
<cb:div type="cbeta-notes">
<xsl:text>
</xsl:text>
<head>CBETA校勘記</head>
<xsl:text>
</xsl:text>
<p>
<xsl:call-template name="gen-cbnote"/>
<xsl:text>
</xsl:text>
</p>
<xsl:text>
</xsl:text>
</cb:div>
<xsl:text>
</xsl:text>
</xsl:if>
</xsl:element>       
</xsl:if>
<xsl:text>
</xsl:text>
</xsl:element>
</xsl:template>

<!-- app within the text -->
<xsl:template match="app">
 <xsl:variable name="appid">
  <xsl:call-template name="gen-appid">
   <xsl:with-param name="thisnode" select="."/>
  </xsl:call-template>
 </xsl:variable>
 <!--
 <xsl:message>
 <xsl:text>APPID:</xsl:text><xsl:value-of select="$appid"/>
 </xsl:message>
        -->
<xsl:element name="anchor">
<xsl:attribute name="xml:id">
<xsl:text>beg</xsl:text>
<xsl:value-of select="$appid"/>
</xsl:attribute>
<xsl:choose>
<xsl:when test="@type='＊'">
<xsl:attribute name="type">
<!--  the ＊ is not a valid XML name, thus can't be used for a type value -->
<xsl:text>star</xsl:text>
</xsl:attribute>
</xsl:when>
<xsl:when test="@type='◎'">
<xsl:attribute name="type">
<!--  the ◎ is not a valid XML name, thus can't be used for a type value -->
<xsl:text>circle</xsl:text>
</xsl:attribute>
</xsl:when>
<!-- maybe not needed? CW 2009-04-18 -->
<xsl:when test="@n">
<xsl:attribute name="n" select="@n"/>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="type">
<xsl:text>cb-app</xsl:text>
</xsl:attribute>
</xsl:otherwise>
</xsl:choose>
</xsl:element>
<!--第一層<app>產生-->
<xsl:apply-templates/>
<xsl:element name="anchor">
<xsl:attribute name="xml:id">
<xsl:text>end</xsl:text>
<xsl:value-of select="$appid"/>
</xsl:attribute>
</xsl:element>
<!--  end of handling for app within the text -->
        
        
<!-- this is nesting it in an element, but this might cause problems later... 
<xsl:element name="seg">
<xsl:attribute name="xml:id">
<xsl:text>beg</xsl:text>
<xsl:value-of select="$appid"/>
</xsl:attribute>
<xsl:apply-templates/>
</xsl:element>
-->
</xsl:template>

<xsl:template match="tt">
	<xsl:variable name="ttid">
		<xsl:call-template name="gen-ttid">
			<xsl:with-param name="thisnode" select="."/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="@type='app'"><!-- ray 2010.10.19 -->
			<xsl:element name="anchor">
				<xsl:attribute name="xml:id">
					<xsl:text>beg</xsl:text>
					<xsl:value-of select="$ttid"/>
				</xsl:attribute>
			</xsl:element>
			<xsl:apply-templates/>
			<xsl:element name="anchor">
				<xsl:attribute name="xml:id">
					<xsl:text>end</xsl:text>
					<xsl:value-of select="$ttid"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="cb:tt" namespace="http://www.cbeta.org/ns/1.0">
				<xsl:apply-templates select="@*"/>
				<!-- tt 之下可能有 lb, 不能只處理 t, 2010.12.17 by Ray -->
				<xsl:apply-templates/>
				<!-- 
				<xsl:for-each select="t">
					<xsl:element name="cb:t" namespace="http://www.cbeta.org/ns/1.0">
						<xsl:apply-templates select="@*"/>
						<xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
					</xsl:element>
				</xsl:for-each>
				  -->
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	
<xsl:template match="tt[@type='app']/t">
	<xsl:choose>
		<xsl:when test="@place='foot'"/>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="t">
	<xsl:choose>
		<xsl:when test="@place='foot'"/>
		<xsl:otherwise>
			<xsl:element name="cb:t" namespace="http://www.cbeta.org/ns/1.0">
				<xsl:apply-templates select="@*"/>
				<xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<!--    
<xsl:template match="text()">
<xsl:value-of select="."/> 
</xsl:template>
-->

<!--產生app 的地方  duncan-->
<xsl:template name="gen-app">
 <xsl:for-each select="//app">
	<xsl:text>
</xsl:text>
	<xsl:variable name="appid">
		<xsl:choose>
			<xsl:when test="@n">
				<xsl:value-of select="./@n"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="generate-id()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
    <!-- add by Ray 2010.12.31
    lem 及 rdg 最多只有 【CBETA】【CB】【大】 , 沒有其他的版本, 就是 choice 
    lem 或 rdg 有出現  【CBETA】【CB】【大】之外其他的版本, 就是 app
    以上是針對大正藏, 若是嘉興, 就是把【大】換成【嘉興】, 其餘類推.
    -->
    <xsl:variable name="wit1">
        <xsl:for-each select="rdg|lem">
            <xsl:value-of select="@wit"/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="wit2">
        <xsl:value-of select="replace($wit1,'【CBETA】','')"/>
    </xsl:variable>
    <xsl:variable name="wit3">
        <xsl:value-of select="replace($wit2,'【CB】','')"/>
    </xsl:variable>
    <xsl:variable name="wit4">
        <xsl:choose>
            <xsl:when test="starts-with($docfile, 'A')">
                <xsl:value-of select="replace($wit3,'【金藏】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'B')">
                <xsl:value-of select="replace($wit3,'【補編】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'C')">
                <xsl:value-of select="replace($wit3,'【中華】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'D')">
                <xsl:value-of select="replace($wit3,'【國圖】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'F')">
                <xsl:value-of select="replace($wit3,'【房山】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'G')">
                <xsl:value-of select="replace($wit3,'【佛教】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'H')">
                <xsl:value-of select="replace($wit3,'【正史】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'J')">
                <xsl:value-of select="replace($wit3,'【嘉興】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'K')">
                <xsl:value-of select="replace($wit3,'【麗】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'L')">
                <xsl:value-of select="replace($wit3,'【龍】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'M')">
                <xsl:value-of select="replace($wit3,'【卍正】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'N')">
                <xsl:value-of select="replace($wit3,'【南藏】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'P')">
                <xsl:value-of select="replace($wit3,'【北藏】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'Q')">
                <xsl:value-of select="replace($wit3,'【磧砂】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'S')">
                <xsl:value-of select="replace($wit3,'【宋遺】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'T')">
                <xsl:value-of select="replace($wit3,'【大】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'U')">
                <xsl:value-of select="replace($wit3,'【洪武】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'W')">
                <xsl:value-of select="replace($wit3,'【藏外】','')"/>
            </xsl:when>
            <xsl:when test="starts-with($docfile, 'X')">
                <xsl:value-of select="replace($wit3,'【卍續】','')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$wit3"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
<!-- we will check for choice-like constructions:
<app from="begd1e11014" to="endd1e11014"><lem wit="【CBETA】" resp="CBETA.maha">已</lem><rdg wit="【卍續】">巳</rdg></app>            
                                    -->
		<!-- modified by Ray
		<lem> 沒有 @resp: Ex: T29n1559, <lem wit="【CBETA】">反</lem>
		<lem> 沒有 @wit: Ex: T45n1899, 883b10, <app><lem>&M062485;</lem><rdg wit="【大】">&M062311;</rdg></app
		<xsl:when test="contains(./lem/@wit, 'CBETA') and contains(./lem/@resp, 'CBETA') and count(rdg)=1 and (contains(rdg/@wit, '卍續') or contains(rdg/@wit, '大') or contains(rdg/@wit, '嘉興'))"> 
		<xsl:when test="(contains(./lem/@wit, 'CBETA') or not(./lem/@wit)) and count(rdg)=1 and (contains(rdg/@wit, '卍續') or contains(rdg/@wit, '大') or contains(rdg/@wit, '嘉興'))">
		-->
        <xsl:when test="$wit4=''">
            <xsl:element name="choice" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:attribute name="cb:from" namespace="http://www.cbeta.org/ns/1.0">
					<xsl:text>#beg</xsl:text>
					<xsl:value-of select="$appid"/>
				</xsl:attribute>
				<xsl:attribute name="cb:to" namespace="http://www.cbeta.org/ns/1.0">
					<xsl:text>#end</xsl:text>
					<xsl:value-of select="$appid"/>
				</xsl:attribute>
				<xsl:if test="lem/@resp">
					<xsl:attribute name="cb:resp">
						<xsl:apply-templates select="lem/@resp"/>
					</xsl:attribute>
				</xsl:if>    
				<xsl:if test="@type">
					<xsl:attribute name="cb:type">
						<xsl:apply-templates select="@type"/>
					</xsl:attribute>
				</xsl:if>    
				<xsl:apply-templates mode="choice"/>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="app" namespace="http://www.tei-c.org/ns/1.0">
				<!--
				<xsl:attribute name="debug">
					<xsl:value-of select="$wit4"/>
				</xsl:attribute>
				-->
				<xsl:attribute name="from">
					<xsl:text>#beg</xsl:text>
					<xsl:value-of select="$appid"/>
				</xsl:attribute>
				<xsl:attribute name="to">
					<xsl:text>#end</xsl:text>
					<xsl:value-of select="$appid"/>
				</xsl:attribute>
				<xsl:if test="@word-count"><!-- added by Ray 2010.10.20 -->
					<xsl:attribute name="cb:word-count">
						<xsl:apply-templates select="@word-count"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="@source"/><!-- added by Ray 2010.10.20 T02n0099 app/@source -->
				<xsl:for-each select="rdg|lem">
					<xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
						<xsl:apply-templates select="@*"/>
						<xsl:apply-templates mode="appgen"/>
						<!--由此產生 app/app-->
						<xsl:if test="@cf1">
							<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
								<xsl:attribute name="type">
									<xsl:value-of select="'cf1'"/>
								</xsl:attribute>
								<xsl:call-template name="attgaiji">
									<xsl:with-param name="str">
										<xsl:value-of select="@cf1"/>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:element>
						</xsl:if>
						<xsl:if test="@cf2">
							<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
								<xsl:attribute name="type">
									<xsl:value-of select="'cf2'"/>
								</xsl:attribute>
								<xsl:call-template name="attgaiji">
									<xsl:with-param name="str">
										<xsl:value-of select="@cf2"/>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:for-each>
				<xsl:if test="@cf1">
					<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
						<xsl:attribute name="type">
							<xsl:value-of select="'cf1'"/>
						</xsl:attribute>
						<xsl:call-template name="attgaiji">
							<xsl:with-param name="str">
								<xsl:value-of select="@cf1"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:element>
				</xsl:if>
				<xsl:if test="@cf2">
					<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
						<xsl:attribute name="type">
							<xsl:value-of select="'cf2'"/>
						</xsl:attribute>
						<xsl:call-template name="attgaiji">
							<xsl:with-param name="str">
								<xsl:value-of select="@cf2"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:for-each>
</xsl:template>

<xsl:template name="gen-sic">
	<xsl:for-each select="//sic">
		<xsl:text>
</xsl:text>
		<xsl:variable name="sicid">
			<xsl:choose>
				<xsl:when test="@n">
					<xsl:value-of select="./@n"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="choice" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:attribute name="cb:from" namespace="http://www.cbeta.org/ns/1.0">
				<xsl:text>#begsic</xsl:text>
				<xsl:value-of select="$sicid"/>
			</xsl:attribute>
			<xsl:attribute name="cb:to" namespace="http://www.cbeta.org/ns/1.0">
				<xsl:text>#endsic</xsl:text>
				<xsl:value-of select="$sicid"/>
			</xsl:attribute>
			<xsl:apply-templates select="@* except (@resp | @cert | @type)" mode="appgen"/>
			<xsl:if test="@resp">
				<xsl:attribute name="cb:resp">
    					<xsl:apply-templates select="@resp"/>
				</xsl:attribute>
			</xsl:if>    
			<xsl:if test="@cert">
				<xsl:attribute name="cb:cert">
    					<xsl:apply-templates select="@cert"/>
				</xsl:attribute>
			</xsl:if>    
			<xsl:if test="@type">
				<xsl:attribute name="cb:type">
					<xsl:apply-templates select="@type"/>
				</xsl:attribute>
			</xsl:if>    
			<!--<xsl:if test="@resp">
			<xsl:attribute name="cb:resp">
			<xsl:value-of select="concat('#', @resp)"/>
			</xsl:attribute>
			</xsl:if>    
			-->
			<xsl:element name="sic">
				<xsl:apply-templates/>
			</xsl:element>
			<xsl:element name="corr">
				<xsl:value-of select="@corr"/>
			</xsl:element>
		</xsl:element>
	</xsl:for-each>
</xsl:template>    
    
<xsl:template name="gen-tt">
	<xsl:for-each select="//tt[@type='app']">
		<xsl:variable name="ttid">
			<xsl:choose>
				<xsl:when test="@n">
					<xsl:text>tt</xsl:text>
					<xsl:value-of select="./@n"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:text>
</xsl:text>
		<xsl:element name="cb:tt" namespace="http://www.cbeta.org/ns/1.0">
			<xsl:attribute name="from">
				<xsl:text>beg</xsl:text>
				<xsl:value-of select="$ttid"/>
			</xsl:attribute>
			<xsl:attribute name="to">
				<xsl:text>end</xsl:text>
				<xsl:value-of select="$ttid"/>
			</xsl:attribute>
			<xsl:if test="@word-count"><!-- add by Ray 2011.8.4 -->
				<xsl:attribute name="word-count">
					<xsl:value-of select="@word-count"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="t">
				<xsl:text>
</xsl:text>
				<xsl:element name="cb:{local-name(.)}" namespace="http://www.cbeta.org/ns/1.0">
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates mode="back"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:for-each>
</xsl:template>
    
<!--
<xsl:template match="anchor" mode="appgen">
<xsl:element name="anchor">
<xsl:attribute name="n">
<xsl:value-of select="@id"/>
</xsl:attribute>
</xsl:element>
</xsl:template>
    -->
<xsl:template match="@cf1" mode="#all"/>
<xsl:template match="@cf2" mode="#all"/>
    
<xsl:template match="@type">
<xsl:attribute name="type">
<xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
</xsl:attribute>
</xsl:template>
    
<!--20070827 by duncan ，令巢狀的app/app 變成anchor的tag -->
<!--mode="appgen" 表示是由 app之後 沿生出來的-->
<xsl:template match="anchor/@type">
<xsl:attribute name="type">
<xsl:choose>
<xsl:when test=".='＊'">
<!--  the ＊ is not a valid XML name, thus can't be used for a type value -->
<xsl:text>star</xsl:text>
</xsl:when>
<xsl:when test=".='◎'">
<xsl:attribute name="type">
<!--  the ◎ is not a valid XML name, thus can't be used for a type value -->
<xsl:text>circle</xsl:text>
</xsl:attribute>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="."/>
</xsl:otherwise>    
</xsl:choose>
</xsl:attribute>    
</xsl:template>
<xsl:template match="@type" mode="appgen">
<xsl:attribute name="type">
<xsl:choose>
<xsl:when test=".='＊'">
<!--  the ＊ is not a valid XML name, thus can't be used for a type value -->
<xsl:text>star</xsl:text>
</xsl:when>
<xsl:when test=".='◎'">
<xsl:attribute name="type">
<!--  the ◎ is not a valid XML name, thus can't be used for a type value -->
<xsl:text>circle</xsl:text>
</xsl:attribute>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="."/>
</xsl:otherwise>    
</xsl:choose>
</xsl:attribute>
</xsl:template>

<xsl:template match="@word-count" mode="appgen">
	<xsl:attribute name="cb:{local-name()}" select="."/>
</xsl:template>

<!-- need to add # for @wit, @resp,  -->
<xsl:template match="@*" mode="appgen">
<xsl:attribute name="{local-name()}" select="."/>
</xsl:template>

<xsl:template match="app" mode="appgen back">
<!-- 由app下一層而來-->
<!--原本的內容 -->
	<xsl:choose>
		<!-- modified by Ray 2010.10.17 可能沒有 @resp, 例如 T29n1559_p0309c03
		<xsl:when test="contains(./lem/@wit, 'CBETA') and contains(./lem/@resp, 'CBETA') and count(rdg)=1">
		-->
		<xsl:when test="contains(./lem/@wit, 'CBETA') and count(rdg)=1">
			<xsl:element name="choice" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:if test="@type">
					<xsl:attribute name="cb:type">
						<xsl:apply-templates select="@type"/>
					</xsl:attribute>
				</xsl:if>    
				<xsl:apply-templates select="@* except @type" mode="appgen"/>
				<xsl:apply-templates mode="choice"/>
			</xsl:element>
		</xsl:when>
		<!-- genuine app: -->
		<xsl:otherwise>
			<xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:apply-templates select="@*" mode="appgen"/>
				<xsl:apply-templates mode="appgen"/>
			</xsl:element> 
		</xsl:otherwise>
	</xsl:choose>
	<!--200708/27 edit by duncan-->
	<!-- 2009-04-18 duncan, this is rubbish , this will cause duplicate id
	<xsl:if test="@n">
	<xsl:element name="anchor">
	<xsl:attribute name="xml:id">
	<xsl:text>beg</xsl:text>
	<xsl:value-of select="@n"/>
	</xsl:attribute>
	</xsl:element>
	</xsl:if>     
	<xsl:apply-templates mode="appgen"/>
	<xsl:if test="@n">
	<xsl:element name="anchor">
	<xsl:attribute name="xml:id">
	<xsl:text>end</xsl:text>
	<xsl:value-of select="@n"/>
	</xsl:attribute>
	</xsl:element>
	</xsl:if>    
		-->
</xsl:template>

<xsl:template match="note" mode="appgen">
<!-- so we ignore notes in lem and rdg? -->
<!-- added by Ray 2010.10.21, T34, <rdg> 裏的 <note place="interlinear"> 要產生 -->
	<xsl:if test="@place='interlinear'">
		<xsl:element name="note">
			<xsl:apply-templates select="@*" mode='appgen'/>
			<xsl:apply-templates select="*|text()|comment()" mode='appgen'/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- if an inline note shows up in lem, we want to show that -->    
<xsl:template match="note[@place='inline']" mode="appgen">
    <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:attribute name="place">inline</xsl:attribute>
        <xsl:apply-templates mode="appgen"/>
    </xsl:element>
</xsl:template>    
<xsl:template match="lem/note[@place='foot text']" mode="appgen"/>
<xsl:template match="lem/note[@resp='CBETA']" mode="appgen"/>
<xsl:template match="rdg/note[@place='foot text']" mode="appgen"/>
<xsl:template match="rdg/note[@resp='CBETA']" mode="appgen"/>
    
<!-- not sure, why we need this, CW 2009-04-18  
<xsl:template match="lem/note" mode="appgen">
<xsl:comment>appgen</xsl:comment>
<xsl:apply-templates mode="appgen"/>
</xsl:template>
<xsl:template match="rdg/note" mode="appgen">
<xsl:comment>appgen</xsl:comment>
<xsl:apply-templates mode="appgen"/>
</xsl:template>
    -->
<xsl:template match="lem" mode="appgen">
	<xsl:element name="lem" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:apply-templates select="@*" mode="appgen"/>
		<xsl:apply-templates mode="appgen"/>
	</xsl:element>
</xsl:template>

<xsl:template match="lb" mode="appgen"/>
	
<xsl:template match="rdg" mode="appgen">
	<xsl:element name="rdg" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:apply-templates select="@*" mode="appgen"/>
		<xsl:apply-templates mode="appgen"/>
	</xsl:element>
</xsl:template>

<!--  choice -->
<xsl:template match="lem" mode="choice">
	<xsl:element name="corr" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:apply-templates mode="appgen"/>
		<xsl:if test="@cf1">
			<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:attribute name="type">cf1</xsl:attribute>
				<xsl:call-template name="attgaiji">
					<xsl:with-param name="str">
						<xsl:value-of select="@cf1"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
		<xsl:if test="@cf2">
			<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:attribute name="type">cf2</xsl:attribute>
				<xsl:call-template name="attgaiji">
					<xsl:with-param name="str">
						<xsl:value-of select="@cf2"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
	</xsl:element>
</xsl:template>

<xsl:template match="rdg" mode="choice">
<xsl:element name="sic" namespace="http://www.tei-c.org/ns/1.0">
<xsl:apply-templates mode="appgen"/>
</xsl:element>
</xsl:template>
    

<xsl:template name="gen-tnote">
<xsl:for-each select="//(note[@resp='Taisho']|note[@resp='Xuzangjing']|note[@resp='ihp']|note[@resp='ZangWai'])">
	<xsl:text>
</xsl:text>
	<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:apply-templates select="@*"/>
		<xsl:attribute name="target">
			<xsl:text>#</xsl:text>
			<xsl:choose>
				<!-- modified by Ray 2010.11.8, <note> 與 <app> 之間可能夾有文字
				<xsl:when test="(local-name(following-sibling::*[1]) = 'app') or (local-name(following-sibling::*[2]) = 'app')">
				-->
				<xsl:when test="(local-name(following-sibling::node()[1]) = 'app') or (local-name(following-sibling::node()[2]) = 'app')">
					<xsl:text>beg</xsl:text>
					<xsl:call-template name="gen-appid">
						<xsl:with-param name="thisnode" select="following-sibling::app[1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>tnote</xsl:text>
					<xsl:value-of select="./@n"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template name="gen-eqnote">
<xsl:for-each select="//note[@type='equivalent']">
<xsl:text>
</xsl:text>
<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
<xsl:apply-templates select="@*"/>
<xsl:attribute name="target">
<xsl:text>#tnote</xsl:text>
<xsl:value-of select="translate(normalize-space(./@n), ' ', '')"/>
</xsl:attribute>
<xsl:apply-templates/>
</xsl:element>
</xsl:for-each>
</xsl:template>

<!-- added by Ray 2010.10.20 -->
<xsl:template name="gen-restnote">
	<xsl:for-each select="//note[@type='rest']|//note[@type='cf.']">
		<xsl:text>
</xsl:text>
		<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="target">
				<xsl:text>#tnote</xsl:text>
				<xsl:value-of select="translate(normalize-space(./@n), ' ', '')"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:for-each>
	<xsl:for-each select="//foreign[@place='foot']">
		<xsl:text>
</xsl:text>
		<xsl:element name="note">
			<xsl:attribute name="target">
				<xsl:text>#tnote</xsl:text>
				<xsl:value-of select="translate(normalize-space(./@n), ' ', '')"/>
			</xsl:attribute>
			<xsl:element name="foreign" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:apply-templates select="@*"/>
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:element>
	</xsl:for-each>
</xsl:template>


<xsl:template name="gen-cbnote">
<xsl:for-each select="//note[starts-with(@resp, 'CBETA')]">
	<xsl:text>
</xsl:text>
	<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
		<xsl:apply-templates select="@*"/>
		<xsl:attribute name="target">
			<xsl:text>#</xsl:text>
			<xsl:choose>
				<!-- modified by Ray, 2010.11.8, <note> 與 <app> 之間可能夾有文字
				<xsl:when test="(local-name(following-sibling::*[1]) = 'app') or (local-name(following-sibling::*[2]) = 'app')">
				-->
				<xsl:when test="(local-name(following-sibling::node()[1]) = 'app') or 
					(local-name(following-sibling::node()[1])!='' and local-name(following-sibling::node()[2]) = 'app')">
					<xsl:text>beg</xsl:text>
					<xsl:call-template name="gen-appid">
						<xsl:with-param name="thisnode" select="following-sibling::app[1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>cbnote-</xsl:text>
					<xsl:choose>
						<xsl:when test="@type">
							<xsl:value-of select="translate(normalize-space(./@type), ' ', '_')"/>
							<xsl:value-of select="translate(normalize-space(./@n), ' ', '_')"/>
						</xsl:when>
						<xsl:when test="@n">
							<xsl:value-of select="translate(normalize-space(./@n), ' ', '_')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="generate-id()"/>        
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template match="lem">
<xsl:apply-templates/>
</xsl:template>
<xsl:template match="rdg"/>
	
<!-- ignore any notes that belong to the foot of the page (do we want to put an anchor?) -->
<!-- modified by Ray 2010.10.20 因為跟 rule match note[starts-with(@resp, 'CBETA')] 會有衝突
<xsl:template match="note[contains(@place, 'foot') and not(@resp='Taisho' or @resp='Xuzangjing' or @resp='ZangWai')]"/>
-->
<xsl:template match="note[contains(@place, 'foot') and not(@resp='CBETA' or @resp='Taisho' or @resp='Xuzangjing' or @resp='ZangWai')]"/>    

<!-- added by Ray 2010.10.22
	<foreign place='foot' 在本文中不出現 
-->
<xsl:template match="foreign[contains(@place, 'foot')]"/>    
    
<xsl:template match="note[@resp='Taisho']">
<!-- not needed ?? CW -->
	<!-- modified by Ray, 
	可以省略 <anchor>
		T01n0023, p. 284a28
		<note type="orig">...</note><note type="mod">...</note><app>...
	不能省略 <anchor>, 因為跟後面的 <app> 之間有文字
		T01n0026, p. 434a17 <note resp="Taisho"> 沒有產生 anchor 
		<note type="orig">...</note><foreign place="foot">...</foreign>尼<app type="＊" source="0434011">...
		T20n1143, p. 600b26
		<note type="orig">...</note><note type="mod">...</note>婆囉<app type="＊">...
	<xsl:if test="not((local-name(following-sibling::*[1]) = 'app') or (local-name(following-sibling::*[2]) = 'app') or tt)">
	-->
	<xsl:if test="not((local-name(following-sibling::node()[1])='app') or (local-name(following-sibling::node()[2])='app') or tt)">
		<xsl:element name="anchor">
			<xsl:attribute name="xml:id">
				<xsl:text>tnote</xsl:text>
				<xsl:value-of select="./@n"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:if>
</xsl:template>

    
<xsl:template match="note[@resp='Xuzangjing']|note[@resp='ZangWai']">
<!-- not needed ?? CW -->
<xsl:if test="not((local-name(following-sibling::*[1]) = 'app') or (local-name(following-sibling::*[2]) = 'app') or tt)">
<xsl:element name="anchor">
<xsl:attribute name="xml:id">
<xsl:text>tnote</xsl:text>
<xsl:value-of select="./@n"/>
</xsl:attribute>
</xsl:element>
</xsl:if>
</xsl:template>
    
<!--屬性是resp=CBETA-->
<xsl:template match="note[starts-with(@resp, 'CBETA')]">
<!-- not needed ?? CW -->
    <!--  looks like we need to remove all notes with @resp= CBETA -->
	<!-- modified by Ray 2010.11.8, <note> 與 <app> 之間可能夾有文字, T20n1143, p. 600b26 
	<xsl:if test="not((local-name(following-sibling::*[1]) = 'app') or (local-name(following-sibling::*[2]) = 'app')  or tt)">
	-->
	<xsl:if test="not((local-name(following-sibling::node()[1]) = 'app') or 
		(local-name(following-sibling::node()[1])!='' and local-name(following-sibling::node()[2]) = 'app')  or tt)">
		<xsl:element name="anchor">
			<xsl:attribute name="xml:id">
				<xsl:text>cbnote-</xsl:text>
				<xsl:choose>
    					<xsl:when test="@type">
    						<xsl:value-of select="translate(normalize-space(./@type), ' ', '_')"/>
    						<xsl:value-of select="translate(normalize-space(./@n), ' ', '_')"/>
    					</xsl:when>
    					<xsl:when test="@n">
    						<xsl:value-of select="translate(normalize-space(./@n), ' ', '_')"/>
    					</xsl:when>
    					<xsl:otherwise>
    						<xsl:value-of select="generate-id()"/>        
    					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:element>
	</xsl:if>
</xsl:template>
	
<xsl:template name="nlang">
	<xsl:param name="l"/>
	<xsl:choose>
		<xsl:when test="$l = 'eng'">
			<xsl:text>en</xsl:text>
		</xsl:when>
		<xsl:when test="$l = 'chi'">
			<xsl:text>zh</xsl:text>
		</xsl:when>
		<xsl:when test="$l = 'san'">
			<xsl:text>sa</xsl:text>
		</xsl:when>
		<xsl:when test="$l = 'pli'">
			<xsl:text>pi</xsl:text>
		</xsl:when>
		<xsl:when test="$l = 'san-sd'">
			<xsl:text>sa-Sidd</xsl:text>
		</xsl:when>
		<xsl:when test="$l = 'san-rj'">
			<xsl:text>sa-x-rj</xsl:text>
		</xsl:when>
		<xsl:when test="$l = 'chi-yy'">
			<xsl:text>zh-x-yy</xsl:text>
		</xsl:when>
		<xsl:when test="$l = 'unknown'">
			<xsl:text>x-unknown</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$l"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<!-- end of app handling -->
<xsl:template match="div1|div2|div3|div4|div5|div6|div7|div8">
<xsl:element name="cb:div" namespace="http://www.cbeta.org/ns/1.0">
<xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
</xsl:element>
</xsl:template>

<xsl:template name="gen-appid">
<xsl:param name="thisnode"/>
<xsl:variable name="appid">
<xsl:for-each  select="$thisnode">
<!--
<xsl:message>
<xsl:text>appid: </xsl:text>
<xsl:value-of select="$thisnode/@n"/>
</xsl:message>
-->
<xsl:choose>
<xsl:when test="$thisnode/@n">
<xsl:value-of select="$thisnode/@n"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="generate-id()"/>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:variable>
<xsl:value-of select="$appid"/>
</xsl:template>
    
<xsl:template name="gen-ttid">
<xsl:param name="thisnode"/>
<xsl:variable name="ttid">
<xsl:for-each select="$thisnode">
<xsl:choose>
<xsl:when test="@n">
<xsl:text>tt</xsl:text>
<xsl:value-of select="./@n"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="generate-id()"/>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:variable>
<xsl:value-of select="$ttid"/>
</xsl:template>
<!-- 
[2010-10-15T10:28:24+0800] 
maybe change to a comment?    
<xsl:template match="todo"/>
-->    
<!-- modified by Ray 2011.8.1, <back> 裏的 todo 也要出現
<xsl:template match="todo">
-->
<xsl:template match="todo" mode="#all">
 <xsl:comment>CBETA todo type: <xsl:value-of select="@type"/></xsl:comment>
</xsl:template>
<!--  marked by Ray 2010.12.17
<xsl:template match="t[@place='foot']"/>
-->
<xsl:template match="tt[@app]/t">
<xsl:apply-templates/>
</xsl:template>        
<xsl:template match="t" mode="back">
<xsl:element name="cb:{local-name(.)}" namespace="http://www.cbeta.org/ns/1.0"> 
<xsl:apply-templates select="@*"/>
<xsl:apply-templates mode="back"/>
</xsl:element> 
</xsl:template>

<!-- process gaiji in attributes -->
<xsl:template name="attgaiji">
<xsl:param name="str"/>
<xsl:variable name="label" select="replace($str, '(CB[0-9]{5})', '＆$1；')"/>
<xsl:for-each select="tokenize(translate($label, '＆；', '##'), '#')">
	<xsl:variable name="curg" select="."/>
	<xsl:choose>
		<xsl:when test="starts-with($curg , 'CB')">
			<xsl:variable name="tmp" select="substring($curg, 3)"/>
			<xsl:variable name="thisgaiji">
				<xsl:for-each select="$cbgaiji">
					<xsl:copy-of select="key('c-gaiji', $tmp)"/>
				</xsl:for-each>
			</xsl:variable> 
			<xsl:choose>
				<xsl:when test="$thisgaiji//uni">
					<xsl:choose>
						<xsl:when test="starts-with($thisgaiji//uni[1], '&amp;')">
							<xsl:value-of select="$thisgaiji//uni[1]" disable-output-escaping="yes"/>
						</xsl:when>
						<xsl:when test="string($thisgaiji//uni[1]) = '?'">
							<xsl:element name="g">
								<xsl:attribute name="ref">
									<xsl:value-of select="$cbdesc"/>#<xsl:value-of select="$curg"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:when>
						<xsl:when test="string-length($thisgaiji//uni[1]) = 1">
							<xsl:comment> here was the problem</xsl:comment> 
							<xsl:value-of select="$thisgaiji//uni[1]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
							<xsl:value-of select="$thisgaiji//uni[1]"/>
							<xsl:text>;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="g">
						<xsl:attribute name="ref">
							<xsl:value-of select="$cbdesc"/>
							<xsl:text>#</xsl:text>
							<xsl:value-of select="$curg"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$curg = ''"/>
		<xsl:when test="$curg = 'unrec'"><!-- added by Ray 2010.10.17 -->
			<xsl:element name='unclear'/>
		</xsl:when>
		<!-- added by Ray 2010.10.19 -->
		<xsl:when test="$curg = 'lac-space'"><space quantity="1" unit="chars"/></xsl:when>
		<xsl:when test="$curg = 'lac'"><space quantity="0"/></xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:for-each>
</xsl:template>
    
    
<!-- elements that needs to go into cbeta namespace -->
    
<xsl:template match="dTitle|dialog|juan|jhead|fan|zi|yin|sg|jl_byline|jl_juan|jl_title|def">
<xsl:element namespace="http://www.cbeta.org/ns/1.0" name="cb:{local-name(.)}" >
<xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
</xsl:element>
</xsl:template>
<!-- modified by Ray 2010.10.20 foreign/@place 要改成 @rend, foreign/@resp 也要另外處理成 reference
<xsl:template match="sp/@type|choice/@resp|choice/@type|foreign/@resp|foreign/@place|foreign/@cert">
-->
<xsl:template match="sp/@type|choice/@resp|choice/@type|foreign/@cert">
<xsl:attribute name="cb:{local-name(.)}" namespace="http://www.cbeta.org/ns/1.0" select="."/>
</xsl:template>

<xsl:template match="foreign/@resp"><!-- added by Ray 2010.10.20 -->
	<xsl:variable name="token" select="normalize-space(.)" />
	<xsl:attribute name="cb:{local-name()}">
		<xsl:text>#</xsl:text>
		<xsl:for-each select="$rl">
			<xsl:choose>
				<xsl:when test="contains($token, ' ')">
					<xsl:variable name="tok1" select="substring-before($token, ' ')"/>
					<xsl:variable name="tok2" select="substring-after($token, ' ')"/>
					<xsl:value-of select="key('x-rl', $tok1)/parent::tei:respStmt/@xml:id"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="key('x-rl', $tok2)/parent::tei:respStmt/@xml:id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="key('x-rl', $token)/parent::tei:respStmt/@xml:id"/>
				</xsl:otherwise>
			</xsl:choose>    
		</xsl:for-each>    
	</xsl:attribute>
</xsl:template>

<xsl:template match="p/@type">
<xsl:choose>
<xsl:when test="contains(., 'inline')">
<xsl:attribute name="rend"  select="."/>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="cb:{local-name(.)}" namespace="http://www.cbeta.org/ns/1.0" select="."/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!--  changing the jl_* stuff to proper bibl   -->    
    
<!-- or not     
<xsl:template match="item[..//jl_title]">
<xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>    
<xsl:template match="list[.//jl_title]">
<xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>
<xsl:template match="item[.//jl_title]/p">
<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
<xsl:attribute name="type">p</xsl:attribute>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>    
<xsl:template match="jl_title">
<xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>    
<xsl:template match="note[.//jl_juan and @place='inline']">
<xsl:apply-templates/>
</xsl:template>
<xsl:template match="note[@place='inline']/jl_juan">
<xsl:element name="extent" namespace="http://www.tei-c.org/ns/1.0">
<xsl:attribute name="rend">inline-small</xsl:attribute>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>    
<xsl:template match="jl_juan">
<xsl:element name="extent" namespace="http://www.tei-c.org/ns/1.0">
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>    
    -->
<!--
<xsl:template match="jl_byline">
<xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>    
    -->
<!-- TODO: check!! -->
<xsl:template match="p[./lg]"/>    

<xsl:template match="sup">
<xsl:choose>
<xsl:when test="matches(., '\(\d+\)')">
<xsl:variable name="sup" select="."/>
<note anchored="true" rend="{$sup}">
<xsl:apply-templates select="following::p[starts-with(., $sup)][1]"/>
</note>
</xsl:when>
<xsl:otherwise>
<formula rend="vertical-align:super;">
<xsl:apply-templates/>
</formula>    
</xsl:otherwise>
</xsl:choose>
    
</xsl:template>

<xsl:template match="annals">
<cb:event>
<date><xsl:apply-templates select="date/p" mode="event"/></date>
<xsl:apply-templates select="lb"/><!-- added by Ray 2010.10.17 -->
<xsl:apply-templates select="event/p" mode="event"/>
</cb:event>
</xsl:template>    

<xsl:template match="date/p" mode="event">
<xsl:apply-templates select="@*"/>
<xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
</xsl:template>

<xsl:template match="event/p" mode="event">
<p>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
</p>
</xsl:template>

<!--p xml:id="pH01p0021a1501" rend="margin-left:0em;text-indent:2em">(1)
    these p have already been output!
    -->
    
<xsl:template match="p[matches(., '^\(\d+\)') ]"/>
<xsl:template match="lg/label">
<head>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
</head>
</xsl:template>
	
<!-- app 裏的文字不要換行 added by Ray 2010.10.21 -->
<xsl:template match="text()" mode="appgen">
	<xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<!-- back 裏的文字不要換行 added by Ray 2010.12.17 -->
<xsl:template match="text()" mode="back">
	<xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<!-- added by Ray 2010.12.17 -->
<!-- back 裏 t 包 校勘, 校勘條目不應出現, 例如 T01n0001, p. 80a19 -->
<xsl:template match="note" mode="back">
	<xsl:choose>
		<xsl:when test="@type='orig'"></xsl:when>
		<xsl:when test="@type='mod'"></xsl:when>
		<xsl:otherwise>
			<xsl:element name="note">
				<xsl:apply-templates select="@*" mode='appgen'/>
				<xsl:apply-templates select="*|text()|comment()" mode='appgen'/>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- added by Ray 2010.12.17 -->
<xsl:template match="space" mode="#all">
	<xsl:element name="space">
		<xsl:apply-templates select="@*" mode='appgen'/>
	</xsl:element>
</xsl:template>

</xsl:stylesheet>