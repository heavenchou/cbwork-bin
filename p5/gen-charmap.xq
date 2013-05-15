declare copy-namespaces preserve, no-inherit;
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace loc="http://www.wittern.org";
declare variable $coll external;
declare function loc:hexval($str as xs:string) 
{
let $seq := string-to-codepoints(lower-case($str))
let $h := string-to-codepoints('0123456789abcdef')
let $ret :=
  for $sx at $i in $seq
  return
  index-of($h, $sx) -1
  let $a1 := 16*$ret[1] + $ret[2] 
  let $a2 := 16*$ret[3] + $ret[4]  
  return 
  256 * $a1 + $a2
  };
  
  

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
<xsl:character-map name="cbeta">
{
for $g in distinct-values(collection($coll)//tei:g/@ref)
order by $g
return
if (contains($g, '#CB')) then
 let $s := xs:integer(substring($g, 4))
 return
 <xsl:output-character character="{codepoints-to-string($s + 983040)}" string="{concat('&lt;g  ref=&quot;', $g, '&quot;/&gt;')}"/>
else if (contains($g, '#FK')) then
 let $s := loc:hexval( substring($g, 5))
 return
 <xsl:output-character character="{codepoints-to-string($s + 983040)}" string="{concat('&lt;g  ref=&quot;', $g, '&quot;/&gt;')}"/>
else if (contains($g, '#RJ')) then
 let $s := loc:hexval( substring($g, 4))
 return
 <xsl:output-character character="{codepoints-to-string($s + 1048576 ) }" string="{concat('&lt;g  ref=&quot;', $g, '&quot;/&gt;')}"/>
else if (contains($g, '#SD')) then
 let $s := loc:hexval( substring($g, 4))
 return
 <xsl:output-character character="{codepoints-to-string($s + 1024000 ) }" string="{concat('&lt;g  ref=&quot;', $g, '&quot;/&gt;')}"/>

else 
<xsl:output-character character="&amp;{substring($g, 2)};" string="{concat('&lt;g  ref=&quot;', $g, '&quot;/&gt;')}"/> 

}
</xsl:character-map>
</xsl:stylesheet>
