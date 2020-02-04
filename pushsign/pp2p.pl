# 這是在新標插入後要做的檢查, 因為有時原來是 <p> 或 P## 卻變成 <P,1> 或 <o><P> 時,
# 會有重覆的 <p> 在 xml 產生, 所以要用此程式去除重覆的 <p>
# </p><!-- <o> --><p><p>  ==>  <!-- <o> --><p>
# </p><p style="margin-left:1em"><p>  ==>  <p style="margin-left:1em">
# </p><!-- <o> --><p place="inline"></p><p place="inline">  ==>  </p><!-- <o> --><p place="inline">
# </p><p place="inline" style="margin-left:1em"></p><p place="inline">  ==>  </p><p place="inline" style="margin-left:1em">

# 有時是這樣 ></p><!-- <o> --><p><p id="pT25p0075c1301">
# 甚至是 ></p><!-- <o> --><p><div2 type="other"><mulu level="2" n="5" label="5 住王舍城釋論" type="其他"/><p id="pT25p0075c1301">
# 所以要過濾 <divx ><mulu><note orig><note mod><app n="..."><lem><anchor>

#</p><p xxxxxxxx><div><mulu><app><lem><p yyyyyyyy>
#合併成 
#<div><mulu><app><lem><p yyyyyyyy xxxxxxxx>

use utf8;

# $in = "out.txt";		# 輸入檔名, 若是批次檔的參數, 可用 $in = shift; 即可
# $out = "pp2p_out.txt";			# 輸出檔名, 若是批次檔的參數, 可用 $out = shift; 即可
my $in = shift;		# 輸入檔名, 若是批次檔的參數, 可用 $in = shift; 即可
my $out = shift;			# 輸出檔名, 若是批次檔的參數, 可用 $out = shift; 即可
my $skip = '(?:(?:<div\d[^>]*?>)|(?:<mulu[^>]*?>)|(?:<note[^>]*?>[^>]*?<\/note>)|(?:<app[^>]*?>)|(?:<lem[^>]*?>)|(?:<anchor[^>]*?>))';

open IN, "<:utf8", $in;
open OUT, ">:utf8", $out;

while(<IN>)
{
	s/<\/p>(<!-- <[ouwas]> -->)<p>(${skip}*)(<p\s?.*?>)/$1$2$3/g;
	s/<\/p>(<!-- <[ouwas]> -->)<p place="inline">(<\/p>)(${skip}*)(<p\s?.*?>)/$2$3$1$4/g;
	s/<\/p><p( style="margin-left:\-?\d+em">)(${skip}*)(<p\s?.*?)>/$2$3$1/g;
	s/<\/p><p place="inline"( style="margin-left:\-?\d+em">)(<\/p>)(${skip}*)(<p\s?.*?)>/$2$3$4$1/g;
	
	#</p><p xxxxxxxx><div><mulu><app><lem><p yyyyyyyy>
	#合併成 
	#<div><mulu><app><lem><p yyyyyyyy xxxxxxxx>
	
	s/<\/p><p(\s?[^>]*?>)(${skip}*)(<p\s?[^>]*?)>/$2$3$1/g;
	
	print OUT;
}

close IN;
close OUT;
