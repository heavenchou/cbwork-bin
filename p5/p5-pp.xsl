<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:chw="http://wittern.org"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:teix="http://www.tei-c.org/ns/Examples"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0" xmlns:math="http://xsltsl.org/math"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cb="http://www.cbeta.org/ns/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="teix math tei xd chw xs xsi" version="2.0">
  <xsl:output method="xml" encoding="utf-8" indent="no"/>
  <xd:doc type="stylesheet">
    <xd:short>Stylesheet for updating charDesc from cbgaiji.xml</xd:short>
    <xd:detail>This is the second part of the conversion process, called after cbetap4top5.xsl</xd:detail>
  </xd:doc>
  <xsl:variable name="rev">$Revision: 1.13 $</xsl:variable>
  <xsl:variable name="revdate">$Date: 2011/05/04 06:50:56 $</xsl:variable>

 <!-- the magic constants for calculating the PUA character values 
the range for cbgaiji starts at 983040 == 0xF0000,
sdgaiji at 0xFA000
rjgaiji at 0x100000
-->
 <xsl:variable name="cbgaijipua" as="xs:integer">983040</xsl:variable>
 <xsl:variable name="sdgaijipua" as="xs:integer">1024000</xsl:variable>
 <xsl:variable name="rjgaijipua" as="xs:integer">1048576</xsl:variable>

 <xsl:function name="chw:hexval">
  <xsl:param name="str"/>
  <xsl:variable name="seq" select="string-to-codepoints(lower-case($str))"/>
  <xsl:variable name="h" select="string-to-codepoints('0123456789abcdef')"/>
  <xsl:variable name="ret">
   <xsl:for-each select="$seq">
    <xsl:value-of select="index-of($h, .) -1"/>
    <xsl:if test="position() != last()">,</xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="a1"
   select="16* xs:integer(tokenize($ret, ',')[1]) + xs:integer(tokenize($ret, ',')[2])"
   as="xs:integer"/>
  <xsl:variable name="a2"
   select="16* xs:integer(tokenize($ret, ',')[3]) + xs:integer(tokenize($ret, ',')[4])"
   as="xs:integer"/>
  <xsl:value-of select="256*$a1 + $a2"/>
 </xsl:function>
<xsl:param name="gpath">/tmp/map</xsl:param>
<!--
  <xsl:variable name="cbgaiji" select="document('cbgaiji.xml')"/>
  <xsl:key name="c-gaiji" match="gaiji" use="cb"/>
  <xsl:variable name="cbgaiji" select="document(concat($gpath, '/', substring(/tei:TEI/@xml:id, 1, 3), '.xml'))"/>
-->
  <xsl:variable name="cbgaiji" select="document(concat($gpath, '/', substring-before(/tei:TEI/@xml:id, 'n'), '.xml'))"/>
  <xsl:key name="c-gaiji" match="tei:char" use="@xml:id"/>
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  <!--  this is unnecessary and a leftover of the previous step of the conversion  -->
  <xsl:template match="tei:respStmt/@n"/>

<xsl:template match="tei:TEI">
<xsl:text>
</xsl:text>
  <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
  </TEI>  
</xsl:template>
  <xsl:template match="*">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
    </xsl:element>  
  </xsl:template>

<!-- marked by Ray because of this error: Ambiguous rule match ... Matches both "attribute()" on line 314 and "attribute()" on line 73
<xsl:template match="@*">
	<xsl:attribute name="{name()}" select="."/>
</xsl:template>
-->
  <xsl:template match="tei:charDesc"/>
  <xsl:template match="tei:charDecl"/>
  <xsl:template match="tei:encodingDesc">
    <xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
      <xsl:if test="count(//tei:g) &gt; 0">
       <xsl:text>
       </xsl:text>
        <xsl:element name="charDecl" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:for-each select="distinct-values(//tei:g/@ref)">
            <xsl:sort select="."/>
            <xsl:variable name="gref" select="substring(., 4)"/>
            <!--  2009-05-02 using cbgaiji.xml, this used to be : 
              <xsl:with-param name="gref" select="$gref"/>
            -->
            <xsl:call-template name="charinfo">
              <xsl:with-param name="gref" select="substring(., 2)"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:lb[contains(@n, 'xxx')]"/>
      <!--      <xsl:when test="(substring(preceding::tei:lb[contains(@ed, 'Z')][1]/@n, 5, 1) ne substring(following::tei:lb[contains(@ed, 'Z')][1]/@n, 5, 1)) and (not(contains(preceding::tei:lb[contains(@ed, 'Z')][1]/@n, 'xxx')) and not(contains(following::tei:lb[contains(@ed, 'Z')][1]/@n, 'xxx')))"> -->
<!-- there are a lot files that have multiple 01 lb's, thus we can't use this.-->
<!--
  <xsl:template match="tei:lb">
    <xsl:choose>
    <xsl:when test="contains(@ed, 'Z') and substring(@n, 6,2) = '01'">
    <xsl:element name="pb" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="ed">Z</xsl:attribute>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="concat(@ed, '.')"/> 
        <xsl:value-of select="substring(@n, 1, 5)"/> 
      </xsl:attribute>
      <xsl:attribute name="n">
        <xsl:value-of select="substring(@n, 1, 5)"/> 
      </xsl:attribute>
    </xsl:element>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
      </xsl:copy>
  </xsl:when>
  <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
      </xsl:copy>
  </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->
  <xsl:template name="charinfo">
    <xsl:param name="gref"/>
<!--
    <xsl:message>
      <xsl:value-of select="$gref"/>
    </xsl:message>
-->
    <xsl:for-each select="$cbgaiji">
      <xsl:text>
   </xsl:text>
      <xsl:copy-of select="key('c-gaiji', $gref)"/>
    </xsl:for-each>
  </xsl:template>  
<!--  I am using the pre-produced files here, so dont need to create the <char> stuff here   -->
  <xsl:template name="charinfo-old">
    <xsl:param name="gref"/>
            <xsl:variable name="curr-gaiji">
              <xsl:for-each select="$cbgaiji">
                <xsl:copy-of select="key('c-gaiji', $gref)"/>
              </xsl:for-each>
            </xsl:variable>
  
            <xsl:message>
              <xsl:value-of select="$gref"/>
            </xsl:message>
            <xsl:text>
            </xsl:text>
            <xsl:element name="char">
              <xsl:choose>
                <xsl:when test="$curr-gaiji//cb">
                  <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('CB', $curr-gaiji//cb)"/>
                  </xsl:attribute>
                  <xsl:text>
                  </xsl:text>
                  <xsl:element name="charName" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:text>CBETA CHARACTER </xsl:text>
                    <xsl:value-of select="concat('CB', $curr-gaiji//cb)"/>
                  </xsl:element>
                  <xsl:if test="$curr-gaiji//des">
                    <xsl:text>
                    </xsl:text>
                    <xsl:element name="charProp" namespace="http://www.tei-c.org/ns/1.0">
                      <xsl:element name="localName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:text>composition</xsl:text>
                      </xsl:element>
                      <xsl:element name="value" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="normalize-space($curr-gaiji//des)"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                  <xsl:if test="$curr-gaiji//mojikyo">
                    <xsl:text>
                    </xsl:text>
                    <xsl:element name="charProp" namespace="http://www.tei-c.org/ns/1.0">
                      <xsl:element name="localName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:text>Mojikyo number</xsl:text>
                      </xsl:element>
                      <xsl:element name="value" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="$curr-gaiji//mojikyo"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                  <xsl:if test="$curr-gaiji//@mofont">
                    <xsl:text>
                    </xsl:text>
                    <xsl:element name="charProp" namespace="http://www.tei-c.org/ns/1.0">
                      <xsl:element name="localName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:text>Mojikyo font name</xsl:text>
                      </xsl:element>
                      <xsl:element name="value" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="$curr-gaiji//mofont"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                  <xsl:if test="$curr-gaiji//mochar">
                    <xsl:text>
                    </xsl:text>
                    <xsl:element name="charProp" namespace="http://www.tei-c.org/ns/1.0">
                      <xsl:element name="localName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:text>Mojikyo character value</xsl:text>
                      </xsl:element>
                      <xsl:element name="value" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="$curr-gaiji//mochar"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                  
                </xsl:when>
              </xsl:choose>
              
              <xsl:if test="$curr-gaiji//cbdia">
                <xsl:text>
                </xsl:text>
                <xsl:element name="charProp" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:element name="localName" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:text>Romanized form in CBETA transciption</xsl:text>
                  </xsl:element>
                  <xsl:element name="value" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="$curr-gaiji//cbdia"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="$curr-gaiji//udia">
                <xsl:text>
                </xsl:text>
                <xsl:element name="charProp" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:element name="localName" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:text>Romanized form in Unicode transcription</xsl:text>
                  </xsl:element>
                  <xsl:element name="value" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="$curr-gaiji//udia"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="$curr-gaiji//sdchar">
                <xsl:text>
                </xsl:text>
                <xsl:element name="charProp" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:element name="localName" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:text>Character in the Siddham font</xsl:text>
                  </xsl:element>
                  <xsl:element name="value" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="$curr-gaiji//sdchar"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <!-- end of the siddham stuff-->
              <xsl:if test="$curr-gaiji//cb">
                <xsl:text>
                </xsl:text>
                <xsl:element name="charProp" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:element name="localName" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:text>entity</xsl:text>
                  </xsl:element>
                  <xsl:element name="value" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="$curr-gaiji//cb"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="$curr-gaiji//nor">
                <xsl:text>
                </xsl:text>
                <xsl:element name="mapping" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:attribute name="type">
                    <xsl:text>normalized</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="$curr-gaiji//nor"/>
                </xsl:element>
              </xsl:if>
              <!--
              <xsl:if test="not($mo = '')">
                <xsl:element name="mapping" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:attribute name="type">
                    <xsl:text>ucs codepoint</xsl:text>
                  </xsl:attribute>
                </xsl:element>
              </xsl:if>
              -->
            </xsl:element>
    
  </xsl:template>
  <!-- here we add an appropriate PUA character to the g element 
       (strictly speaking, we could then eliminate the g, iff the PUA value is defined in the header) 
       on the other hand, P5 explicitly says, these PUA chars should be removed for exchange.
-->
  <xsl:template match="tei:g" mode="#all">
    <xsl:element name="g" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
      <xsl:when test="contains(@ref, '#CB')">
         <xsl:value-of   select="codepoints-to-string(xs:integer(substring(@ref, 4)) +   $cbgaijipua)"/>
      </xsl:when>
      <xsl:when test="contains(@ref, '#SD')">
        <xsl:value-of
      		 select="codepoints-to-string(xs:integer(chw:hexval(substring(@ref, 5))) +  $sdgaijipua)"/>
      </xsl:when>
      <xsl:when test="contains(@ref, '#RJ')">
        <xsl:value-of
      		 select="codepoints-to-string(xs:integer(chw:hexval(substring(@ref, 5))) +  $rjgaijipua)"/>
      </xsl:when>
       
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

<xsl:template match="@*|processing-instruction()|comment()">
<xsl:copy/>
</xsl:template>
    
</xsl:stylesheet>
