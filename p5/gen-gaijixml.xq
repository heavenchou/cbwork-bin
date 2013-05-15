declare copy-namespaces preserve, no-inherit;
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace chw="http://www.wittern.org";
declare variable $coll external;

declare function chw:convertToHex($number as xs:integer) as xs:string
{
let $hexDigits:=('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F')
return
if($number < 16) then
$hexDigits[$number + 1]
else
fn:concat(chw:convertToHex($number idiv 16), chw:convertToHex($number mod 16))
};

declare function chw:hexval($str as xs:string) 
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
let $gaiji := collection($coll)//gaiji
(:  the magic numbers to calculate the PUA offset  
 <xsl:variable name="cbgaijipua" as="xs:integer">983040</xsl:variable>
 <xsl:variable name="sdgaijipua" as="xs:integer">1024000</xsl:variable>
 <xsl:variable name="rjgaijipua" as="xs:integer">1048576</xsl:variable>
:)
let $cbgaijipua := 983040,
$sdgaijipua := 1024000,
$rjgaijipua := 1048576
return
<dataroot xmlns="http://www.tei-c.org/ns/1.0" xmlns:cb="http://www.cbeta.org/ns/1.0" >
{
for $g in distinct-values($gaiji//@cb)
let $current := ($gaiji[./@cb=$g])[1]
order by $g
return
if (starts-with($g, 'CBx0011')) then
 let $x := $current/@cx
  let $des := tokenize($current/@des, '\]') 
  for $c at $pos in tokenize($x, '；')[not(. = '')]
   let $g1 := substring($c, 2)
  return 
   if (not ($gaiji[./@cb=$g1])) then
   <char xml:id ="{$g1}">
  <charName>CBETA CHARACTER {$g1}</charName>
     <charProp><localName>composition</localName>
          <value>{$des[$pos]}]</value></charProp>
     <charProp><localName>normalized form</localName>
          <value>{substring($current/@nor, $pos, 1)}</value></charProp>
     <charProp><localName>entity</localName>
          <value>{$g1}</value></charProp>
       <mapping type="PUA" cb:dec="{xs:integer(substring($g1, 3)) + $cbgaijipua}">U+{chw:convertToHex(xs:integer(substring($g1, 3)) + $cbgaijipua)}</mapping> 
   </char>
   else ()
else 
<char xml:id="{$g}">
  <charName>CBETA CHARACTER {$g}</charName>
     {
    for $n  in $current//attribute::*
    return 
     <charProp><localName>{
       let $nn := string(node-name($n)) 
       return 
       if ($nn = 'udia') then 'Romanized form in Unicode transcription'
       else if ($nn = 'cbdia') then 'Romanized form in CBETA transcription'
       else if ($nn ='sdchar') then 'Character in the Siddham font'
       else if ($nn = 'mochar') then 'Mojikyo character value'
       else if ($nn = 'mofont') then 'Mojikyo font name'
       else if ($nn = 'mojikyo') then 'Mojikyo number'
       else if ($nn = 'des') then 'composition'
       else if ($nn = 'cb') then 'entity'
       else if ($nn = 'nor') then 'normalized form'
       else ($nn)
       }
     </localName><value>{data($n)}</value></charProp>,
     
    if (starts-with($g, 'CB')) then 
       let $s := substring($g, 3)
       return
       if (matches($s, '^\d+$')) then 
       <mapping type="PUA" cb:dec="{xs:integer($s) + $cbgaijipua}">U+{chw:convertToHex(xs:integer($s) + $cbgaijipua)}</mapping> 
       else ()
    else if (starts-with($g, 'SD')) then 
       let $s := chw:hexval(substring($g, 4))
       return
       <mapping type="PUA" cb:dec="{$s + $sdgaijipua}">U+{chw:convertToHex($s + $sdgaijipua)}</mapping> 
    else if (starts-with($g, 'RJ')) then 
       let $s := chw:hexval(substring($g, 4))
       return
       <mapping type="PUA"  cb:dec="{$s + $rjgaijipua}">U+{chw:convertToHex($s + $rjgaijipua)}</mapping> 
    else ()
  }
</char>
}
</dataroot>