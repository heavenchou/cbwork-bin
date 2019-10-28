
#-------------------------------------------------------------------------
# make_toc.bat 數字 type
# 數字 : 表示第幾冊或第幾部
# type : BL : 部類, T : 大正藏單冊, X : 卍續藏單冊, XB : 卍續藏的部, J : 嘉興藏的冊, H : 正史單冊, W : 藏外單冊 , I : 佛拓百品單冊
#     A : 金藏  C : 中華藏  D : 國圖  F : 房山石經  G : 佛教大藏經  K : 高麗藏  L : 乾隆藏  M : 卍正藏  N : 南傳大藏經單冊  NB: 南傳大藏經的部
#    P : 永樂北藏  S : 宋藏遺珍  U : 洪武南藏
#    newsign : 新標, fuyan : 福嚴精舍閱讀經典次第目錄 , lichan : 杜老師禮懺部
# 產生 cbeta html help version *.hhp, *.hhc, T??n????.htm(各經目錄)
# 使用惠敏法師部類目錄
# written by Ray 2001/2/28 04:16下午
#-------------------------------------------------------------------------

use lib "../../";
use utf8;
use cbeta;

### command line parameter ###

# 有 BL : 部類, T : 大正藏單冊, X : 卍續藏單冊, XB : 卍續藏的部, J : 嘉興藏的冊, H : 正史單冊, W : 藏外單冊, I : 佛拓百品單冊
#    A : 金藏  B : 補編 C : 中華藏  D : 國圖  GA : 佛寺志  F : 房山石經  G : 佛教大藏經  K : 高麗藏  L : 乾隆藏  M : 卍正藏  
#    N : 南傳大藏經單冊  NB: 南傳大藏經的部  P : 永樂北藏  S : 宋藏遺珍  U : 洪武南藏
#    newsign : 新標, fuyan : 福嚴精舍閱讀經典次第目錄 , lichan : 杜老師禮懺部
$BuleiType = shift;

$BuLei=lc(shift);

# 若沒參數則離開
if ($BuLei eq "") 
{
	print "ERROR : perl make_toc.pl Type Vol\n";
	exit;
}

# 產生記錄檔, 程式正常結束時刪除, 用來判斷程式是否正確執行完畢

open TOCERR, ">>:utf8" , "make_toc-err.txt";
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime;
$mon++;
$year += 1900;
print TOCERR "\n\n=============  Time : $year/$mon/$mday $hour:$min:$sec ====================\n\n";
print TOCERR "perl $0 $BuleiType  $BuLei\n";
print STDERR "\n\n=============  Time : $year/$mon/$mday $hour:$min:$sec ====================\n\n";

# 取最後三個字

$BuLei = "000" . $BuLei;
$BuLei =~ /.*(...)$/;
$BuLei = $1;				

# 為了特殊冊數而處理的情況

if($BuleiType eq "T")
{
	$BuLei = "09a" if($BuLei eq "009");
	$BuLei = "12a" if($BuLei eq "012");
	$BuLei = "26a" if($BuLei eq "026");
	$BuLei = "30a" if($BuLei eq "030");
	$BuLei = "40a" if($BuLei eq "040");
	$BuLei = "44a" if($BuLei eq "044");
	$BuLei = "54a" if($BuLei eq "054");
	$BuLei = "85a" if($BuLei eq "085");
}

################################################
# 將要產生的檔名算出來
################################################

local @chms;
local $chm;

if($BuleiType eq "BL")		# 部類
{
	@chms = qw(01AHan 02BenYuan 03BoRuo 04FaHua 05HuaYan 06BaoJi 07NiePan 08DaJi 09JingJi 10MiJiao 11Vinaya 12PiTan 13ZhongGuan 14Yogacara 15LunJi 16PureLand 17Chan 18History 19Misc 20DunHuang 21XinBian);
	$chm = $chms[$BuLei-1];
}
elsif($BuleiType =~ /^[ACGLMPU]|(GA)|(GB)$/)	# 三位數的冊數
{
	$chm = "$BuleiType$BuLei";
}
elsif($BuleiType =~ /^[BDFHIJKNSTWX]|(XB)|(NB)|(ZY)|(ZYB)|(DAB)|(GAB)$/)	# 二位數的冊數
{
	$BuLei =~ /(\d\d[a-z]?)$/;
	my $tmp = $1;
	$chm = "$BuleiType$tmp";
}
else	# 新標, 福嚴, 禮懺
{
	$chm = $BuleiType;
}

$BuleiTxt = "../bulei/bulei" . $BuleiType . ".txt";

###########################################################

use Getopt::Std;		# MacPerl 沒有 Getopt Module
getopts('e:');			# 取得 e: 所接的參數, 例如 e:big5
$outEncoding = $opt_e;
$outEncoding = lc($outEncoding);
if ($outEncoding eq '') { $outEncoding = 'utf8'; } # 預設是 utf8
print STDERR "Output encoding: $outEncoding\n";

### 設定值 ###
#$buildNumber = 13;
open CFG,"make_toc.cfg" or die "cannot open cbeta.cfg\n";
while (<CFG>) {
	next if (/^#/);			#comments
	chomp;
	($key, $val) = split(/=/, $_);
	$cfg{$key}=$val;		#store cfg values
	print STDERR "$key\t$cfg{$key}\n";
}
close CFG;

$inDir = $cfg{"xml_root"};
$outDir = $cfg{"out_dir"};

if ($outEncoding eq "gbk") {
	$outDir .= "-gbk";
}

mkdir("$outDir", "0777");
$nid=0;

print STDERR "Initialising....\n";

#utf8 pattern
$utf8 = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

#big5 pattern
$big5zi = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require "c:/cbwork/work/bin/b52utf8.plx";  ## this is needed for handling the big5 entity replacements
if ($outEncoding eq "gbk") {
	require "c:/cbwork/work/bin/utf8gbk.plx";
	require "c:/cbwork/work/bin/utf8.pl";
} else {
	require "c:/cbwork/work/bin/utf8b5o.plx";
}
require "c:/cbwork/work/bin/hhead.pl";
require "../../common/cbeta_sub.pl";
#require "c:/cbwork/work/bin/cbetasub.pl";
$utf8out{"\xe2\x97\x8e"} = '';

# 開啟 xx.toc 檔案

my $tocname = $outDir . "\\$chm.toc";
print "debug tocname : $tocname \n";
open VTOC, ">:utf8", $tocname;
print STDERR "open $tocname\n";

#######################################################
# 變數設定
#######################################################

use XML::Parser;
#use Image::Size;

my $debug=0;
local @pages = ();
my %Entities = ();
local %no_nor = ();
local $no_nor = 0;
my $ent;
my $val;
my $text;
my $headText;
my $div1head;
my $div2head;
my $juanText;
my $juanNum;
my $juanURL;
my $juanOld="";
my $flagSource=0;
my $source;
my $column="";    # 記錄目前頁碼，如：0001a
my $preColumn=""; # 上一頁
my $sutraNum="";  # 記錄目前經號，如：1111
my $sutraName=""; # 經名
my $div1Type="";
my $div2Type="";
my $headId="";
my @saveatt=();   # 儲存 attribute
my @lines=();     # 儲存上一欄的經文
my @tagBeforeLine=();
my @elements=();
my @mulu=();      # $mulu[$i][0] 目錄類別
                  # $mulu[$i][1] 目錄層級
                  # $mulu[$i][2] 對應的 URL
                  # $mulu[$i][3] 目錄標題
                  # $mulu[$i][4] 是否有子目錄
                  # $mulu[$i][5] 目錄所在卷數
                  # $mulu[$i][6] 所在卷數對應的 URL
local @close=();

my %saveXu=();
my %saveJuan=();
my %saveJuanNum=();	# 儲存卷數
my %savePin=();   # 品
my %savePin2=();  # 品 (div2)
my %saveHui=();   # 會
my %saveFen=();   # 分
my %saveJing=();  # 經
my %saveOther=();
my $version;
my $firstLineOfSutra;
my $firstLineOfPage;
my $saveof = "";
my $CorrCert;
my $juanOpen=0;
my $mostDeepLevel="";
my $jingURL="";
my $jingLabel="";
local $author;
local $lastChm='';
local $extent='';
local $text_buffer = '';
local $text_buffer_flag = 0;

my %dia = (
 "Amacron","A^",
 "amacron","a^",
 "ddotblw","d!",
 "Ddotblw","D!",
 "hdotblw","h!",
 "imacron","i^",
 "ldotblw","l!",
 "Ldotblw","L!",
 "mdotabv","m%",
 "mdotblw","m!",
 "ndotabv","n%",
 "ndotblw","n!",
 "Ndotblw","N!",
 "ntilde","n~",
 "rdotblw","r!",
 "sacute","s/",
 "Sacute","S/",
 "sdotblw","s!",
 "Sdotblw","S!",
 "tdotblw","t!",
 "Tdotblw","T!",
 "umacron","u^"
);

#my $parser = new XML::Parser(Style => Stream, NoExpand => True);
my $parser = new XML::Parser(NoExpand => True);


$parser->setHandlers (
	Init => \&init_handler,
	Start => \&start_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default,
	End => \&end_handler,
	Final => \&final_handler
);

readSutraList();	# 取出各經的卷數
#readGaiji();		# 讀取缺字檔
my $gaiji = new Gaiji();
$gaiji->load_access_db();
#openent("c:/cbwork/xml/dtd/cbeta.ent");
readBuLei();

my $id;
my $old_id='';
my $hhcLevel;	# 目前層次的數目
my $pre;
select VTOC;
#$btoc_block_open=0;
#$btoc_open_needed=1;

##############################################################################
#
#              TOC 及 ePub NCX 的處理法
#
#         toc                             ePub ncx
#
# 一開始  <name>...</name>....            <np><nl>...</nl>...
#
# 如果有子層  <UL>                         不要有結尾的 </np> , 否則就 </np>
#
# 子層結束    </UL>                        </np>
#
##############################################################################

foreach $id (sort keys %BuLeiDir) {
	$hhcLevel = length($id)/3 - 1;
	$oldLevel = length($old_id)/3 - 1;
	#print VTOC "<!-- s=$id old_id=$old_id level=$level oldLevel=$oldLevel -->\n";
	# 跳回上一層, 所以要將此層結束
	while($hhcLevel < $oldLevel) {
		$pre = "  " x ($oldLevel-2);
		print VTOC $pre,"</UL><!-- end of this level -->\n";
		$oldLevel--;
	}
	if (exists($BuLeiDir{$id."001"})) { # 如果還有下一層
		$pre = "  " x ($hhcLevel-1);
		select VTOC;
		# print VTOC $pre, '<LI><OBJECT type="text/sitemap">', "\n";
		# print VTOC $pre, "\t", '<param name="Name" value="', myOut($BuLeiDir{$id}) ,'">',"\n";
		# print VTOC $pre,"\t",'<param name="ImageNumber" value="1">',"\n";
		# print VTOC $pre,"</OBJECT>\n";
		# print VTOC $pre,"<UL>\n";
		#print VTOC $pre, '<name>', myOut($BuLeiDir{$id}) ,'</name>',"\n";
		print VTOC $pre, '<name>', $BuLeiDir{$id} ,'</name>',"\n";
		print VTOC $pre,"<UL>\n";
		#select BTOC;
		#if ($btoc_block_open) {
		#	print BTOC "</table>";
		#	$btoc_block_open--;
		#}
		#$dirName = $BuLeiDir{$id};
		#if ($hhcLevel<3) {
		#	print BTOC "<h" . ($hhcLevel+1) . ">";
		#	$dirName =~ s#([\d\-Tab,]{2,})#<font face=\"Times New Roman\">$1</font>#g;
		#} else {
		#	print BTOC "<p>" . myOut("　") x ($hhcLevel-2);
		#}
		#print myOut($dirName);
		#$btoc_open_needed=1;
		#if ($hhcLevel<3) {
		#	print BTOC "</h" . ($hhcLevel+1) . ">\n";
		#} else {
		#	print BTOC "<p>\n";
		#}
	} else {
		$BuLeiDir{$id} =~ /^([A-Z]+?)(\d{3,4}\w?)(.*)$/;
		my $book = $1;
		$sutraNum = $2;
		$sutraName = $3;
		
		# 額外處理嘉興藏, 因為嘉興藏是 JA, JB 開頭, 但AB是經號
		if($book eq "JA")
		{
			$book = "J";
			$sutraNum = "A" . $sutraNum;
		}
		if($book eq "JB")
		{
			$book = "J";
			$sutraNum = "B" . $sutraNum;
		}		
		
		$vol = num2vol($sutraNum,$book);
		
		$pre = "  " x ($hhcLevel-1);
		chdir("$inDir/$book/$vol");
		my $tmpnum = "${vol}n$sutraNum";
		$tmpnum =~ s/(X0[89]n0240)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(X2[01]n0367)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(X\d\dn0714)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(X5[01]n0822)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(X8[01]n1568)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(X8[12]n1571)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(J3[12]nB271)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(J3[23]nB277)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(A09[78]n1276)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(A11[12]n1501)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(A12[01]n1565)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(C05[67]n1163)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(B0[12]n0001)[ab]/$1/;		# 跨冊要處理的資料
		$tmpnum =~ s/(B0[345]n0002)[abc]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(B1[56]n0088)[ab]/$1/;		# 跨冊要處理的資料
		$tmpnum =~ s/(C05[67]n1163)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(GA01[12]n0010)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(GA03[12]n0032)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(GA08[12]n0084)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(GA0[89][890]n0089)[abc]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(K3[45]n1257)[ab]/$1/;		# 跨冊要處理的資料
		$tmpnum =~ s/(L11[56]n1490)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(L13[0123]n1557)[abcd]/$1/;# 跨冊要處理的資料
		$tmpnum =~ s/(L15[34]n1638)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(N\d\dn\d{4})[a-l]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(P15[45]n1519)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(P17[89]n1611)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(P179n1612)a/$1/;			# 跨冊要處理的資料
		$tmpnum =~ s/(P18[01]n1612)[bc]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(P18[123]n1615)[abc]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(P18[45]n1617)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(U22[23]n1418)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(ZY0[345]n0005)[abc]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(ZY1[78]n0022)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(ZY\d\dn0023)[ab]/$1/;		# 跨冊要處理的資料
		$tmpnum =~ s/(ZY3[6789]n0047)[abcd]/$1/;# 跨冊要處理的資料
		$tmpnum =~ s/(DA0[45]n0004)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(DA\d\dn0005)[a-h]/$1/;	# 跨冊要處理的資料
		
		$file = "$inDir/$book/$vol/$tmpnum.xml";
		print STDERR "$file\n";
		print TOCERR "<start> $file ...... \n";
		$parser->parsefile($file);
		#if ($btoc_open_needed) {
			#print BTOC '<table border="1" cellpadding="6" cellspacing="0" bordercolor="#E1E9CB" style="margin-left: ' . ($hhcLevel-1) . 'em">';
			#$btoc_open_needed=0;
			#$btoc_block_open++;
		#}
		#select BTOC;
		#print BTOC "　　" x $hhcLevel;
		#print "<tr><td nowrap valign='top'>";
		#print "<a href=\"$chm.chm::/$chm/${vol}N$sutraNum.htm\">No. $sutraNum</a>";
		#print myOut("<td>$sutraName<td>$extent<td>$author\n");
	}
	$old_id = $id;
}
#if ($btoc_block_open) {
	#print BTOC "</table>";
	#$btoc_block_open--;
#}

$oldLevel = $hhcLevel - 1;	# 此時 hhcLevel 就是最後一筆了
while($oldLevel > 0) {
	$pre = "  " x ($oldLevel-1);
	print VTOC $pre,"</UL><!-- end of end -->\n";
	$oldLevel--;
}
# print VTOC "</UL>\n";
# print VTOC "</BODY></HTML>";

# print BTOC "<hr></body></html>";

#foreach $m (sort keys %mojikyo) { print HHP "fontimg\\$m.GIF\n"; }
#foreach $s (sort keys %ifont) { print HHP "$s\n"; }
#print HHP "\n\n[INFOTYPES]\n";
#close HHP;
#unlink "make_toc-err.txt";
close TOCERR;

############################################################################
# XML Parser 開始
############################################################################

sub init_handler
{
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$fileopen = 0;
	$num = 0;
	$oldof = "";
	$close = "";
	$date = '';
	$title = "";
	$juanOpen=0;
	@elements=();
	@mulu=();
	$inLg = 0;
	$inMulu = 0;
	$MuluLabel = "";
	@openTags=();
	$firstLineOfSutra = 1;
}

# --------------------------------------------------------------------------

sub start_handler
{
	my $p = shift;
	$el = shift;
	my %att = @_;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);

	$elementChar="";

	### <author>
	if ($el eq "author") {
		$author = '';
		$text_buffer_flag = 1;
		$text_buffer = \$author;
	}

	### <body> ###
	$pass = 0 if $el eq "body";

	### <byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:33AM
		#$text .= "<span class='byline'><br>　　　　" ;
		#$indent = "<br>　　　　";
		$text .= "<p><span class='byline'>　　　　" ;

		# marked by Ray 1999/11/30 10:26AM
		#$indent = "　　　　";
	}

	### <cell>
	if ($el eq "cell" and $pass==0) {
		$s = "<td";
		if ($att{"rows"} ne '') {
			$s .= ' rowspan="' . $att{"rows"} . '"';
		}
		if ($att{"cols"} ne '') {
			$s .= ' colspan="' . $att{"cols"} . '"';
		}
		$s .= ">";
		push @openTags, $s;
		$text .= $s;
	}

	### <corr>
	if ($el eq "corr") {
		$CorrCert = lc($att{"cert"});
		if ($CorrCert ne "" and $CorrCert ne "100") {
			my $sic = myDecode(lc($att{"sic"}));
			$text .= $sic;
		} else {
			$text .= "<span class='corr'>";
		}
	}

	### <div1> ###
	if ($el eq "div1"){
		$div1head = "";
		$div2head = "";
		# div1 的 type 屬性可以延續上一個 div1
		if ($att{"type"} ne "") {	$div1Type = lc($att{"type"}); }
		if (div1Type eq "xu"){
			$xu = 1;
			$num = 0;
		} elsif ($div1Type eq "w") {  # added by Ray 2000/5/24 11:09AM
			$text .= "<blockquote class='FuWen'>";
			$indent = "";
			$BlockquoteOpen ++;
		} elsif ($num == 0 && (div1Type eq "juan" || div1Type eq "jing" || div1Type eq "pin" || div1Type eq "other")) {
			$num = 1;
		}
	}

	### <div2> ###
	if ($el eq "div2"){
		$div2head='';
		# div2 的 type 屬性可以延續上一個 div2
		if ($att{"type"} ne "") {	$div2Type = lc($att{"type"}); }
		if ($div2Type eq "w") {  # added by Ray 2000/5/24 11:09AM
			$text .= "<blockquote class='FuWen'>";
			$indent = "";
			$BlockquoteOpen ++;
		}
	}

	### <extent>
	if ($el eq "extent") {
		$extent = '';
		$text_buffer = \$extent;
		$text_buffer_flag = 1;
	}

	### <figure>
	if ($el eq "figure") {
		my $ent = $att{"entity"};
		#my ($x, $y) = imgsize($outDir . '/' . $figure{$ent});
		#$x = int($x/2);
		#$y = int($y/2);
		#$text .= '<img src="' . $figure{$ent} . "\" height=\"$y\" width=\"$x\">";
		#$text .= '<img src="' . $figure{$ent} . '">';
	}

	### <gloss> ###
	$pass++ if $el eq "gloss";

	### <head> ###
	if ($el eq "head") {
		$headText="";
		if (lc($att{"type"}) eq "added"){
			$pass++;
			$added = 1;
		} else {
			$text .=	"<p><b>　　" ;
			$bibl = 1;
			$bib = "";
			$nid++;
			$text .= "<A NAME=\"n$nid\"></A>";
		}
	}

	if ($head == 1){
		#$bibl = 1 if ($el =~ /^bibl|title|p$/);
		$bibl = 1 if ($el =~ /^bibl$/);
	}

	if ($head == 1 && lc($att{"type"}) eq "ly"){
		if ($att{"lang"} eq "chi"){
			$lang = "chi";
		} else {
			$lang = "eng";
		}
	}

	### <item> ###
	if ($el eq "item"){
		if ($att{"n"} ne '') { $text .= myDecode($att{'n'}); }
		$itemLang = $att{"lang"};
		if ($itemLang eq '' and $parent eq "list") { $itemLang = $listLang; }
		if ($pass==0) {
			if ($itemLang eq 'sk-sd') {
				my $s = "<font face=\"siddam\">";
				push @openTags, $s;
				$text .= $s;
			}
			my $s = "<li>";
			push @openTags, $s;
			$text .= $s;
		}
	}
	
	### <milestone> ###
	# <milestone n="2" unit="juan"/>
	if ($el eq "milestone")
	{
		if($att{"unit"} eq "juan")
		{
			if($att{"n"})
			{
				# 因為有些經文, 例如 "品名" , 會在 <juan> 之前, 所以要由 milestone 來代表卷的開始
				$juanNum = $att{"n"};
			}
		}
	}
	
	### <juan> ###
	if ($el eq "juan"){
		$xu = 0;
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
			$juanOpen = 1;
			if ($juanNum ne $att{"n"}) {
				#$juanURL = "/$vol$column.htm#$lb";
				$juanText="";
			}
			$num = "001" if ($att{"n"} eq "");
			$num = $att{"n"};
			# 有些 n 是有 abc 的, 例如 : T33n1708 <juan fun="open" n="001a"><mulu type="卷" n="1a"
			# 有些 n 是有 abc-123 的, 例如 : T40n1805 <juan n="001a-1" fun="open"><mulu n="1a-1" label="上一上" type="卷"/>
			#$num =~ s/[a-zA-Z]*$//;
			$num =~ s/^(\d*).*/$1/;
			# $juanNum = $num;		# 由 <milestone> 來判斷比較準確
			$bibl = 1;
			$bib = "";
			$nid++;
			#$text .= "<A NAME=\"n$nid\"></A>";
		} elsif ($fun eq "close") {
			$juanOpen = 0;
		}
		$text .= "<p class='juan'>\n";
	}

	### <l> ###
	if ($el eq "l"){
		$text .= "<td>";
		$text .= "　";
		my $rend = $att{"rend"};
		#$rend =~ s/($pattern)/$utf8out{$1}/g;
		#$rend = parseRend($rend);
		if ($rend eq "") { $rend = "　"; }
		# 如果偈頌前有 (
		if ($text =~ /(.*║.*)\($/s) {
			$text = $1 . $rend . "(";
		} else { $text .= $rend; }
	}

	### <lb> ###
	if ($el eq "lb")
	{
		# 卍續藏有二組 lb , ed 為 R 開頭的不要理它
		# <lb ed="R150" n="0708b08"/>
		my $ed = $att{"ed"};
		return if (substr($ed,0,1) eq "R");
		
		$lb = $att{"n"};
		#if ($lb =~ /1463a05/) { $debug=1; }
		#if ($column eq "") { $column = substr($lb,0,5); }

		if ($firstLineOfSutra) {
			if (substr($lb,0,5) ne $pb) {
				$pb = substr($lb,0,5);
				$column = $pb;
			}
			$firstLineOfPage = 0;
			my $num = $sutraNum;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$jingURL = "$vol$pb.htm";
			if ($debug) {print STDERR "675 jingURL: $jingURL pb=$pb\n";}
			$firstLineOfSutra = 0;
		}

		$text = "$br<a name=\"$lb\" id=\"$lb\">$indent";

		if ($inLg) { $text .= "<tr>"; }
	}

	### <lg> ###
	if ($el eq "lg" ){
		#$text =~ s/^(.*)(<a name=.+? id=.+?>.*)$/$1<p class='lg'>$2/;
		my $s = '<p><table border="0" cellspacing="5"><tr>';
		push @openTags, $s;
		$text .= $s;
		#$text .= "<p class='lg'>";
		$br = "";
		$inLg = 1;
	}

	### <cb:mulu> ###
	if ($el eq "cb:mulu" ) {
		my $typeOfMulu = myDecode($att{"type"});
		my $i=@mulu;
		if ($typeOfMulu eq "卷") {
			my $label = myDecode($att{"label"});
			$juanURL = "/${vol}n$column.htm#$lb";
			my $n = $att{"n"};
			# 有些 n 是有 abc 的, 例如 : T33n1708 <juan fun="open" n="001a"><mulu type="卷" n="1a"
			# 有些 n 是有 abc-123 的, 例如 : T40n1805 <juan n="001a-1" fun="open"><mulu n="1a-1" label="上一上" type="卷"/>
			# $n =~ s/[a-zA-Z]*$//;
			$n =~ s/^(\d*).*/$1/;
			# $juanNum = $n;		# 由 <milestone> 來判斷比較準確
			# $saveJuanNum{$juanURL} = $n;		# 儲存卷數
			$saveJuanNum{$juanURL} = $juanNum;		# 儲存卷數
			if ($label eq '') { $saveJuan{$juanURL}= "第" . cNum($juanNum);}
			else { $saveJuan{$juanURL}= $label; }
		} else {
			$inMulu = 1;
			my $url = "/${vol}n$column.htm#$lb";
			my $label = myDecode($att{"label"});
			my $level = int($att{"level"});
			if ($level == 0) {
				die "level 不能為 0, lb=$lb";
			}
			$mulu[$i][0] = $typeOfMulu;
			$mulu[$i][1] = $level;
			$mulu[$i][2] = $url;
			#$mulu[$i][3] = $label;	# p5 版移到後面才做
			$mulu[$i][4] = 0;
			$mulu[$i][5] = int($juanNum);
			$mulu[$i][6] = $juanURL;
			# 如果到了一下層, 記錄上一層有子目錄
			if ($level > $mulu[$i-1][1]) { $mulu[$i-1][4] = 1; }
			if ($level > $mostDeepLevel) { $mostDeepLevel = $level; }
		}
	}
	
	### <g> ###
	#<g ref="#CB00145">㝹</g>
	if ($el eq "g" ) 
	{
		# 在目錄中的才處理
		if($inMulu)
		{
			my $ref = $att{"ref"};
			if($ref =~ /CB(.{5})/)
			{
				my $cb = $1;
				if($gaiji->cb2uniword($cb))
				{
					$MuluLabel .= $gaiji->cb2uniword($cb);
				}
				elsif($gaiji->cb2nor($cb))
				{
					$MuluLabel .= $gaiji->cb2nor($cb);
				}
				elsif($gaiji->cb2des($cb))
				{
					$MuluLabel .= $gaiji->cb2des($cb);
				}
			}
		}
	}

	### <list> ###
	if ($el eq "list"){
		$listLang = $att{"lang"};
		if ($pass==0) {
			$s = "<ul>";
			push @openTags, $s;
			$text .= $s;
		}
	}

	### <note> ###
	if ($el eq "note") {
		if(lc($att{"type"}) eq "inline" or lc($att{"place"}) eq "inline"){
			$close='';
	  		if ($pass==0) {
				$text .= "<font size=-1>(";
				$close = ")</font>";
			}
			push @close, $close;
		}
	}

	### <p> ###
	if ($el eq "p"){
		$ptype = lc($att{"type"});
		if ($pass==0) {
			if ($ptype eq "w" or $ptype eq "winline") {
				$text .= "<blockquote class='FuWen'>";
				$indent = "";
				$BlockquoteOpen ++;
			} else {
				$text .= "<p>";
			}
			if ($att{"lang"} eq "sk-sd") {
				my $s = "<font face=\"siddam\">";
				push @openTags, $s;
				$text .= $s;
			}
		}
		if ($ptype eq "ly") {
			if ($head==1) { $flagSource=1; }
			$source="";
		}
	}

	### <pb> ###
	if ($el eq "pb") {
		$firstLineOfPage = 1;
		$vl = $att{"id"};
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;

		$pb = $att{"n"};
		$column = $pb;
	}


	### <rdg> ###
	$pass++ if $el eq "rdg";

	### <row> ###
	if ($el eq "row" and $pass==0) {
		$s = "<tr>";
		push @openTags, $s;
		$text .= $s;
	}

	### <t> ###
	if ($el eq "t") {
		if ($att{"lang"} eq "sk-sd") { $text .= "<font face=\"siddam\">"; }
	}

	### <table> ###
	if ($el eq "table" and $pass==0) {
		$s = '<table border="1" cellspacing="0" cellpadding="5">';
		push @openTags, $s;
		$text .= $s;
	}

	### <teiHeader> ###
	$head = 1 if $el eq "teiHeader";  #We are in the header now!

	if ($el eq "term") {
		if ($att{"lang"} eq "sk-sd") { $text .= "<font face=\"siddam\">"; }
	}
	
	### <back> ###	p5 特有的標記, 到了 back 就不再分析了
	if ($el eq "back") {
		$p->setHandlers (
			Start => \&no_fun,
			Char  => \&no_fun,
			Entity => \&no_fun,
			Default => \&no_fun,
			End => \&no_fun
		);
	}
	#end startchar
}

# --------------------------------------------------------------------------

sub end_handler
{
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);

	# </author>
	if ($el eq "author") {
		$text_buffer_flag = 0;
	}

	### </bibl> ###
	if ($el eq "bibl"){ endBibl(); }

	# </body>
		if ($el eq "body") {
	}

	### </byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:34AM
		#$text .= "</span>" ;
		$text .= "</span><br>" ;
		$indent = "";
	}

	## </cell> ###
	if ($el eq "cell" and $pass==0) {
		$text .= "</td>";
		pop @openTags;
	}

	## </corr> ###
	if ($el eq "corr"){
		if ($CorrCert eq "" or $CorrCert eq "100") { $text .= "</span>"; }
	}

	# </date>
	if ($el eq "date") {
		if (lc($parent) eq "publicationstmt") {
			$date =~ s#^.*(..../../..).*$#$1#;
			#watch("756 完成日期：$date\n");
		}
	}

	### </div> ###
	if ($el =~ /div/i){
		$xu = 0;
		# added by Ray 2000/5/24 11:11AM
		my $s='';
		if ($el eq "div1") {
			$s = $div1Type;
		} elsif ($el eq "div2") {
			$s = $div2Type;
		}
		if ($s eq "w" and $pass==0) {
			$text .= "</blockquote>";
			$BlockquoteOpen --;
		}
	}

	# </edition>
	if ($el eq "edition") {
		$version =~ /\b(\d+\.\d+)\b/;
		$version = $1;
	}

	# </extent>
	if ($el eq "extent") {
		$text_buffer_flag = 0;
	}

	$head = 0 if $el eq "teiHeader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";

	### </head> ###
	if ($el eq "head" ) { endHead(); }

	### </item> ###
	if ($el eq "item") {
		if ($pass==0) {
			if ($itemLang eq "sk-sd") {
				$text .= "</font>";
				pop @openTags;
			}
			$text .= "</li>";
			pop @openTags;
		}
	}

	### </juan> ###
	if ($el eq "juan" ){
		$bibl = 0;
		#$bib =~ s/\[[0-9（[0-9珠\]//g;
		$bib =~ s/\[[0-9]{2,3}\]//g;
		#$bib =~ s/#[0-9][0-9]#//g;
		$bib =~ s/#[0-9]{2,3}#//g;
		$bib = "";
		$text .= "</p>\n";

		if (lc($att->{"fun"}) eq "open" and $div1Type ne "w") {
			my $num = $juanNum;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$juanText =~ s/\[\d\d\]//g;  # 去掉校勘符號
			$juanText =~ s/\[＊\]//g;
		} elsif (lc($att->{"fun"}) eq "close" and $div1Type ne "w") {
			$juanText =~ s/\[\d\d\]//g;  # 去掉校勘符號
			$juanText =~ s/\[＊\]//g;
			my $i = cNum($juanNum);
			#print FTOC "<TD><A HREF=\"$chm.chm::$juanURL\">卷第$i</A>\n";
			#print FTOC "<TR>\n";
		}
	}


	### </l> ###
	if ($el eq "l") {
		#$text .= "　" if $el eq "l";
		$text .= '</td>';
	}

	### </lg> ###
	if ($el eq "lg" ){
		#$text .= "</table></p>";
		$text .= "</table>";
		$br = "";
		$inLg=0;
		pop @openTags;
	}

	### </list> ###
	if ($el eq "list" ){
		#if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
		if ($pass==0) {
			$text .= "</ul>";
			pop @openTags;
		}
	}


	## </note> ###
	if ($el eq "note"){
		$close = pop @close;
		if ($close ne "") {
			if ($text =~ /(.*)<\/font>$/) {
				$text = $1 . $close . "</font>";
			} else {
				$text .= $close
			}
		}
		$close = "";
	}

	## </p> ###
	if ($el eq "p"){
		$indent = "";
		if ($head == 1) {
			$bib =~ s/^\t+//;
			#$ly{$lang} = $bib;
			$source =~ s/^\t+//;
			$ly{$lang} = $source;
			$flagSource = 0;
			$source="";
		}
		if ($att->{"lang"} eq "sk-sd") {
			$text .= "</font>";
			pop @openTags;
		}
		if (lc($att->{"type"}) eq "w" and $pass==0) {
			$text .= "</blockquote>";
			$BlockquoteOpen --;
		}
	}

	### </row> ###
	if ($el eq "row" and $pass==0) {
		$text .= "</tr>";
		pop @openTags;
	}

	### </t> ###
	if ($el eq "t") {
		if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
	}

	### </table> ###
	if ($el eq "table" and $pass==0) {
		$text .= "</table>";
		pop @openTags;
	}

	### </term> ###
	if ($el eq "term") {
		if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
	}

	### </title> ###
	if ($el eq "title"){
		#$bib =~ s/^\t+//;
		#$title = $bib;
		if ($debug) { print STDERR "title=$title\n"; getc; }
	}

	if ($el eq "teiHeader"){
#	&head;
	}
	$lang = "" if ($el eq "p");

  ## </TEI.2> ###
	if ($el eq "TEI.2"){
		#$text = myReplace($text);

		#$text =~ s/　$//;
		#$text =~ s/　\)$/)/;

		#select OF;
		#print myOut($text);
		$text = "";
		#print "</a><hr>";
		#print "<a href=\"${prevof}#start\" style='text-decoration:none'>▲</a>" if ($prevof ne "");
		#print "</html>\n";
		#close (OF);
		$vl = "";
		$num = 0;


		# marked by Ray 1999/11/9 12:07PM
		#print HHP "\n\n[INFOTYPES]\n";
		#close HHP;
	}
	
	#</cb:mulu>
	if ($el eq "cb:mulu" ) {
		if($inMulu)
		{
			my $i=@mulu;
			$mulu[$i-1][3] = $MuluLabel;	# 因為 p5 的目錄內容在子層
			$MuluLabel = "";
			$inMulu = 0;
		}
	}

	$bib = "";
#	print STDERR "$pass\n";
	$no_nor=0;
}

# --------------------------------------------------------------------------

sub char_handler
{
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);

	# <app>裏的文字只能出現在<lem>或<rdg>裏 added by Ray
	if ($parent eq "app") { return; }

	# <note type="sk"> 的內容不顯示
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
		if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}

	# added by Ray 1999/12/15 10:14AM
	# 不是 100% 的勘誤不使用
	if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }

	#$char =~ s/($pattern)/$utf8out{$1}/g;
	$char =~ s/\n//g;

	if ($parent eq "date") {
		my $len = @elements;
		if ($elements[$len-2] eq "publicationStmt") {
			$date .= $char;
			return;
		}
	}

	my $i = @elements - 1;
	while ($parent eq "lem" or $parent eq "term" or $parent eq "corr") {
		if ($parent eq "lem") {
			$i -= 2;
			$parent = $elements[$i];
		} elsif ($parent eq "term") {
			if ($elements[$i-1] eq "skgloss") {
				$i -= 2;
				$parent = $elements[$i];
			}  else { last; }
		} elsif ($parent eq "corr") {
			$i--;
			$parent = $elements[$i];
		}
	}

	if ($parent eq "head") { $headText .= $char; }
	if ($parent eq "title") { $title .= $char; }
	if ($parent eq "juan" or $parent eq "jhead") { $juanText .= $char; }
	if ($parent eq "edition") { $version .= $char; }
	if ($text_buffer_flag) { $$text_buffer .= $char; }

	$bib .= $char if ($bibl == 1);
	$source .= $char if ($flagSource);
	if ($pass == 0 && $el ne "pb") {
		if ($text =~ /(.*)<\/font>$/) {
			my $s1 = $1;
			if ($char =~ /^([\w\s]+)(.*)$/) { $text = $s1 . $1 . "</font>" . $2; }
			else { $text .= $char; }
		} else { $text .= $char; }
	}
	if ($parent eq "cb:mulu") { $MuluLabel .= $char; }
#	print $char if ($pass == 0 && $el ne "pb");
}

# --------------------------------------------------------------------------

sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;

	if ($ent =~ /Fig/) {
		$figure{$ent} = $next;
	} else {
		&openent($next);
	}
	return 1;
}

# --------------------------------------------------------------------------

sub default {
	my $p = shift;
	my $string = shift;

	my $parent = lc($p->current_element);

	# added by Ray 2000/5/11 09:13AM T10,n299,p892c09, rdg 裏的梵文轉寫不應出現
	if ($parent eq "rdg") { return; }

	# added by Ray 1999/11/23 05:25PM
	# <note type="sk">, <note type="foot"> 的內容不顯示
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
		if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}

	$string =~ s/^\&(.+);$/&rep($1)/eg;
	if ($bibl == 1){
		$bib .= $string ;
		if ($debug) { print STDERR "bib=$bib\n"; getc;}
	}

	# added by Ray 2000/2/17 03:24PM
	if ($parent eq "head") { $headText .= $string; }
	if ($parent eq "title") { $title .= $string; }
	if ($parent eq "juan" or $parent eq "jhead") { $juanText .= $string; }

	if ($text =~ /(.*)<\/font>$/) {
		my $s1 = $1;
		if ($string =~ /^<font face=\"CBDia\">(.*)/) {
			$text = $s1 . $1;
		} elsif ($string =~ /^(\w)$/) {
			$text = $s1 . $1 . "</font>";
		} else {
			$text .= $string if ($pass == 0);
		}
	} else {
		$text .= $string if ($pass == 0);
	}
}

# --------------------------------------------------------------------------

sub final_handler {
	endSutra();
}

# --------------------------------------------------------------------------

# 讓遇到 <back> 標記的 xml 不再分析, 因此指到這裡來
sub no_fun {
	return;
}

############################################################################
# XML Parser 結束
############################################################################

############################################################################
# 讀取基本資料
#
# sub openent  讀 ent 檔存入 %Entities
# sub readSutraList 取出各經的卷數
# sub readGaiji 讀取缺字檔
# sub readBuLei 讀取部類目錄
#
############################################################################

# --------------------------------------------------------------------------
# 讀 ent 檔存入 %Entities

sub openent{
	local($file) = $_[0];
	if ($file =~ /gif$/) { return; }

	#print STDERR "252 open: $file\n";
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chomp;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		if (/gaiji/) {
			/^(.+)\s+\"(.*)\".*/;
			$ent = $1;
			$val = $2;
			$ent =~ s/ //g;
			$gaiji{$ent} = $val;
			if ($file=~/jap\.ent/) { # 如果是日文
		 		if ($val=~/uni=\'(.+?)\'/) { $val= "&#x" . $1 . ";" ; } # 優先使用 Unicode
			} elsif($ent=~/^SD/) {
				$val = b52utf8($val);
				$val =~ s#<gaiji .* big5=\'(.+?)\'/>#$1#;
				#$val = "<font face=\"siddam\">$val</font>";
			} else {
				$val = b52utf8($val);
				# 不用mojikyo 的 gif 了
				#if ( $val=~/mojikyo=\'(.+?)\'/) {
				#	my $m=$1;  # 否則用 M 碼
				#	my $des = "";
				#	if ( $val=~/des=\'(.+?)\'/) {
				#		$des=$1;
				#		$ent2ZuZiShi{$ent}=$des;
				#	} else { $des = $m; }
				#	if ($des=~/\[(.*)\]/) { $des = $1; }
				#	$m =~ s/^M//;
				#	my $href = "mojikyo-gif/$m.gif";
				#	if (-e "$outDir/$href") {
				#		$ifont{$href}=0;
				#	}
				#	$href = "javascript:showpic(\"$href\")";
				#	$no_nor{$ent} = "[<a href='$href'>$des</a>]";
				#} elsif ( $ent =~ /^CB(\d\d)/ ) {
				if ( $ent =~ /^CB(\d\d)/ ) {
					my $href = "gaiji-CB/$1/$ent.gif";
					$ifont{$href}=0;
					if ( $val=~/des=\'\[(.+?)\]\'/) {
						$des=$1;
						$ent2ZuZiShi{$ent}=$des;
					} else { $des = $ent; }
					$href = "javascript:showpic(\"$href\")";
					#$no_nor{$ent} = "[<a href='$href'>$des</a>]";
					$no_nor{$ent} = "[$des]";
				} else { $no_nor{$ent}=$ent; } # 最後用 CB 碼

				if ($outEncoding eq "gbk") {
					if ($val=~/nor=\'(.+?)\'/) {  # 優先使用通用字
						$val=$1;
						$ent2nor{$ent}=$val;
					} elsif ($val=~/uni=\'(.+?)\'/) {  # 沒有通用字的話用 unicode
						$val = pack("H*", $1);
						$val = toutf8($val);
						$ent2nor{$ent}=$val;
					} else {
						$val = $no_nor{$ent};
					}
				} else {
					# 校勘版不用通用字
					if ($val=~/nor=\'(.+?)\'/) {  # 優先使用通用字
						$val=$1;
						$ent2nor{$ent}=$val;
					} else {
						$val = $no_nor{$ent};
					}
				}
			}
		} else {
			s/\s+>$//;
			($ent, $val) = split(/\s+/);
			$val =~ s/"//g;
			$val = b52utf8($val);
		}
		$Entities{$ent} = $val;
		if ($debug) { print STDERR "Entity: $ent -> $val\n"; }
	}
}

# --------------------------------------------------------------------------
# 取出各經的卷數

sub readSutraList {
	my @a;
	#my $book;
	open I, "C:/cbwork/bin/sutralist/sutralist.txt";
	while (<I>) {
		# T01##0001##長阿含經##22##0001a01
		#$_ = b52utf8($_);
		@a = split /##/;
		#$book = substr($a[0],0,1);
		my $tmp = $a[0] . "n" . $a[1];
		$juansOfSutra{$tmp}=$a[3];
	}
	close I;
}

#-----------------------------------------------------------------------
# 讀取缺字檔

sub readGaiji {
	use Win32::ODBC;
	my $cb,$zu,$ent,$mojikyo;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = $row{"cb"};       # cbeta code
		$zu      = $row{"des"};      # 組字式

		next if ($cb =~ /^#/);

	  	$des{$cb} = b52utf8($zu);
	}
	$db->Close();
	print STDERR "ok\n";
}

# --------------------------------------------------------------------------
# 讀取部類目錄

sub readBuLei {
	my $cb, $s;
	print STDERR "read $BuleiTxt \n";
	open I, "<:utf8", $BuleiTxt or die "open error";
	my @temp;
	while (<I>) {
		chomp;
		#$_ = b52utf8($_);
		@temp = split /##/;
		if ($temp[0] =~ /^$BuLei/) {
			if ($temp[1] =~ /&CB(\d{4});/) {
				$cb = '0' . $1;
				if (not defined($des{$cb})) { die "CB$cb 不存在"; }
				$s = $des{$cb};
				$temp[1] =~ s/&CB\d{4};/$s/g;
			}
			if ($temp[1] =~ /&(M\d{6});/) {
				my $ent = $1;
				if (not defined($Entities{$ent})) { die "$ent 不存在"; }
				$temp[1] =~ s/&M\d{6};/$s/g;
			}
			$BuLeiDir{$temp[0]}=$temp[1];
		}
	}
	close I;
	#$cchm = substr($BuLeiDir{$BuLei},2);
	delete $BuLeiDir{$BuLei};
}

############################################################################
#
# 一些文字取代
#
############################################################################
# --------------------------------------------------------------------------
# 一些字串取代

sub myDecode {
	my $s = shift;
	#$s =~ s/($pattern)/$utf8out{$1}/g;
	#$s =~ s/M010527/恒/g;
	$s =~ s/＆(CB\d{5}|CI\d{4}|M\d{6})；/&rep($1)/eg;
	$s =~ s/(M\d{6})/&rep($1)/eg;
	$s =~ s/(M\d\d\d\d)/&rep($1)/eg;
	$s =~ s/(CB\d{5})/&rep($1)/eg;
	return $s;
}

# --------------------------------------------------------------------------
# 一些字串取代

sub rep{
	local($x) = $_[0];
	if ($debug) { print STDERR "rep($x)="; }
	# modified by Ray 1999/10/13 07:16PM
	#return $Entities{$x} if defined($Entities{$x});
	local $str='';
	if ($no_nor) {
		if (defined($no_nor{$x})) { $str = $no_nor{$x}; }
	} else {
		if (defined($Entities{$x})) { $str = $Entities{$x}; }
	}

	if ($str =~ /^\[(.*)\]$/) {
		my $exp = $1;
		if (defined($dia{$exp})) {
			$str = "<font face=\"CBDia\">" . $dia{$exp} . "</font>";
			if ($debug) { print STDERR "$str\n"; }
			return $str;
		}
	}
	if ($debug) { print STDERR "$str\n"; }
	return $str;
	
	# 這裡以下應該執行不到吧
	die "Unknkown entity $x!!\n";
	if ($debug) { print STDERR "$x\n"; }
	return $x;
}


############################################################################
# 比較不重要的
############################################################################

# --------------------------------------------------------------------------
# <head> 標記結束

sub endHead {
	if ($added == 1) {
		$pass--;
		$added = 0;
	}

	my $i = @elements - 1;
	while ($parent eq "lem" or $parent eq "term" or $parent eq "corr") {
		if ($parent eq "lem") {
			$i -= 2;
			$parent = $elements[$i];
		} elsif ($parent eq "term") {
			if ($elements[$i-1] eq "skgloss") {
				$i -= 2;
				$parent = $elements[$i];
			} else { last; }
		} elsif ($parent eq "corr") {
			$i--;
			$parent = $elements[$i];
		}
	} # end of while

	$bibl = 0;
	$bib = "";
	$indent = "" ;
}

#-----------------------------------------------------------------------
# created by Ray 2000/3/15 06:14PM
# 應該是卷的資料

sub printJuan {
	my $a=shift;
	my $newCell = 0;
	my $deepest;

	$juanNum  = $mulu[$a][5];

	if ($juanOld eq "" or $juanNum ne $juanOld) {
		$label = "第" . cNum($juanNum) . "卷";
		$url = $mulu[$a][6];
		#print FTOC "（<A HREF=\"$chm.chm::$url\">$label</A>）\n";
		#print FTOC myOut("（$label）\n");
		$juanOld = $juanNum;
	}
}

############################################################################
#
# 新的一經及經文讀到最後的處理
#
# sub endBibl
# sub changeSutra
# sub endSutra 
#
############################################################################

# --------------------------------------------------------------------------
# 新的一經基本資料都讀取到了, 目前已到 </bibl> 標記

sub endBibl {
	my $book="";
	$bibl = 0;
	#
	if ($bib =~ /Vol\.\s+([0-9]+).*?No\.\s*([A-Za-z]?[0-9]+)([A-Za-z])?/){
		$prevof = "";
		$sutraNum = $2;
		if ($3 eq ""){
			$c = "_";
		} else {
			$c = $3;
			$sutraNum .= $c;
		}

		# 將經號補滿四位數
		if ($sutraNum =~ /\d$/) {
			$sutraNum = "0" x (4-length($sutraNum)) . $sutraNum;
		} else {
			$sutraNum = "0" x (5-length($sutraNum)) . $sutraNum;
		}
		
		$text = "";
		$vl = sprintf("t%2.2dn%4.4d%sp", $1, $2, $c);
		$od = sprintf("t%2.2d", $1);
#		mkdir($outDir . "\\htmlhelp\\$od", MODE);
#		$c = "n" if ($c eq "_");
#		$oof = $of;
		#base name for file

		$xu = 0;
		#$fileopen = 0;
		$num = 0;
		#$bof = $ourDir . sprintf("\\htmlhelp\\$od\\%4.4d$c", $2, $3);
		$bof = $outDir . "\\";
		$bof =~ tr/A-Z/a-z/;
		$fhead = $outDir . sprintf("\\htmlhelp\\$od\\%4.4dh", $2, $3);
		$fhead =~ tr/A-Z/a-z/;

		if ($debug) { print "title=[$title]\n"; }
		$mtit = $title;
		
		# 有新的經文要修改的地方 -- 這行文字不要刪
		#if($mtit =~ /Taisho Tripitaka, Electronic version, /i)
		#{
		#	$mtit =~ s/Taisho Tripitaka, Electronic version, //i;
		#	$book = "T";
		#}
		#elsif($mtit =~ /卍 Xuzangjing, Electronic version, /i)
		#{
		#	$mtit =~ s/卍 Xuzangjing, Electronic version, //i;
		#	$book = "X";
		#}
		#elsif($mtit =~ /Jiaxing Canon, Electronic version, /i)
		#{
		#	$mtit =~ s/Jiaxing Canon, Electronic version, //i;
		#	$book = "J";
		#}
		#elsif($mtit =~ /Jiaxing Canon\(Xinwenfeng Edition\), Electronic version, /i)
		#{
		#	$mtit =~ s/Jiaxing Canon\(Xinwenfeng Edition\), Electronic version, //i;
		#	$book = "J";
		#}
		#elsif($mtit =~ /Passages concerning Buddhism from the Official histories, Electronic version, /i)
		#{
		#	$mtit =~ s/Passages concerning Buddhism from the Official histories, Electronic version, //i;
		#	$book = "H";
		#}
		#elsif($mtit =~ /Buddhist Texts Not Contained in the Tripitaka, Electronic version, /i)
		#{
		#	$mtit =~ s/Buddhist Texts Not Contained in the Tripitaka, Electronic version, //i;
		#	$book = "W";
		#}
		#elsif($mtit =~ /Selections of Buddhist Stone Rubbings from the Northern Dynasties, Electronic version, /i)
		#{
		#	$mtit =~ s/Selections of Buddhist Stone Rubbings from the Northern Dynasties, Electronic version, //i;
		#	$book = "I";
		#}
		#elsif($mtit =~ /Jin Edition of the Canon, Electronic version, /i)
		#{
		#	$mtit =~ s/Jin Edition of the Canon, Electronic version, //i;
		#	$book = "A";
		#}
		#elsif($mtit =~ /Zhonghua Canon\(Zhonghua shuju Edition\), Electronic version, /i)
		#{
		#	$mtit =~ s/Zhonghua Canon\(Zhonghua shuju Edition\), Electronic version, //i;
		#	$book = "C";
		#}
		#elsif($mtit =~ /Fangshan shijing, Electronic version, /i)
		#{
		#	$mtit =~ s/Fangshan shijing, Electronic version, //i;
		#	$book = "F";
		#}
		#elsif($mtit =~ /Fojiao Canon, Electronic version, /i)
		#{
		#	$mtit =~ s/Fojiao Canon, Electronic version, //i;
		#	$book = "G";
		#}
		#elsif($mtit =~ /Tripitaka Koreana, Electronic version, /i)
		#{
		#	$mtit =~ s/Tripitaka Koreana, Electronic version, //i;
		#	$book = "K";
		#}
		#elsif($mtit =~ /Qianlong Edition of the Canon\(Xinwenfeng Edition\), Electronic version, /i)
		#{
		#	$mtit =~ s/Qianlong Edition of the Canon\(Xinwenfeng Edition\), Electronic version, //i;
		#	$book = "L";
		#}
		#elsif($mtit =~ /Manji Daizokyo\(Xinwenfeng Edition\), Electronic version, /i)
		#{
		#	$mtit =~ s/Manji Daizokyo\(Xinwenfeng Edition\), Electronic version, //i;
		#	$book = "M";
		#}
		#elsif($mtit =~ /Northern Yongle Edition of the Canon, Electronic version, /i)
		#{
		#	$mtit =~ s/Northern Yongle Edition of the Canon, Electronic version, //i;
		#	$book = "P";
		#}
		#elsif($mtit =~ /Songzang yizhen\(Xinwenfeng Edition\), Electronic version, /i)
		#{
		#	$mtit =~ s/Songzang yizhen\(Xinwenfeng Edition\), Electronic version, //i;
		#	$book = "S";
		#}
		#elsif($mtit =~ /Southern Hongwu Edition of the Canon, Electronic version, /i)
		#{
		#	$mtit =~ s/Southern Hongwu Edition of the Canon, Electronic version, //i;
		#	$book = "U";
		#}
		
		# 上面是舊的方式
		$mtit =~ s/^.*?No\./No./;
		$book = $vol;
		$book =~ s/\d*$//;
		$book = "H" if $book eq "ZS";
		$book = "W" if $book eq "ZW";
		
		if($book eq "")
		{
			print STDERR "error : no book!!\n";
			<>;
		}
		
		$mtit =~ s/(.*)No\. 0(.*)/$1No. $2/i;
		$mtit =~ s/(.*)No\. 0(.*)/$1No. $2/i;
		if ($debug) { print "mtit=[$mtit]\n"; }
		$sutraName = $mtit;
		$sutraName =~ s/No\. \d*\w* //;
		$jingLabel = "$book$sutraNum " . $sutraName;
		my $tmp = "${vol}n${sutraNum}";
		if($juansOfSutra{$tmp} eq "")
		{
			print STDERR "$book$sutraNum no juan ... press anykey continue...\n";
			print TOCERR "$book$sutraNum no juan ... press anykey continue...\n";
		}
		$jingLabel .= " (" . $juansOfSutra{$tmp} . "卷)";

		$firstLineOfSutra = 1;
		$firstLineOfPage = 1;

		# added by Ray 1999/12/15 10:50AM
		if ($vol eq "T06") { $juanNum = 201; }
		elsif ($vol eq "T07") { $juanNum = 401; }
		else { $juanNum = 1; }
	}
	$bib =~ s/^\t+//;
	$ebib = $bib;
	&changeSutra;	# 切換到新的一經時呼叫
	$newSutra=1;
}

# --------------------------------------------------------------------------
# 切換到新的一經時呼叫

sub changeSutra {
	my $pre = "  " x ($hhcLevel-1);
	
	print VTOC $pre, "<name>";
	print VTOC myOut($jingLabel);
	$vol =~ /([A-Z]+)(\d*)/;
	my $book = $1;
	my $volnum = $2;

	# 處理一些特殊的經名
	#T05n0220a
	#T06n0220b
	#T07n0220c,d,e,f,g,h,i,j,k,l,m,n,o
	#X80n1568a
	#X81n1568b
	#X81n1571a
	#X82n1571b
	if($book eq "T")
	{
		$sutraNum =~ s/0220[a-o]/0220/;
	}
	elsif($book eq "X")
	{
		$sutraNum =~ s/0240[ab]/0240/;	# 跨冊要處理的資料
		$sutraNum =~ s/0367[ab]/0367/;	# 跨冊要處理的資料
		$sutraNum =~ s/0714[ab]/0714/;	# 跨冊要處理的資料
		$sutraNum =~ s/0822[ab]/0822/;	# 跨冊要處理的資料
		$sutraNum =~ s/1568[ab]/1568/;	# 跨冊要處理的資料
		$sutraNum =~ s/1571[ab]/1571/;	# 跨冊要處理的資料
	}
	elsif($book eq "J")
	{
		$sutraNum =~ s/B271[ab]/B271/;	# 跨冊要處理的資料
		$sutraNum =~ s/B277[ab]/B277/;	# 跨冊要處理的資料
	}
	elsif($book eq "A")
	{
		$sutraNum =~ s/1276[ab]/1276/;	# 跨冊要處理的資料
		$sutraNum =~ s/1501[ab]/1501/;	# 跨冊要處理的資料
		$sutraNum =~ s/1565[ab]/1565/;	# 跨冊要處理的資料
	}
	elsif($book eq "B")
	{
		$sutraNum =~ s/0001[ab]/0001/;	# 跨冊要處理的資料
		$sutraNum =~ s/0002[abc]/0002/;	# 跨冊要處理的資料
		$sutraNum =~ s/0088[ab]/0088/;	# 跨冊要處理的資料
	}
	elsif($book eq "C")
	{
		$sutraNum =~ s/1163[ab]/1163/;	# 跨冊要處理的資料
	}
	elsif($book eq "GA")
	{
		$sutraNum =~ s/0010[ab]/0010/;	# 跨冊要處理的資料
		$sutraNum =~ s/0032[ab]/0032/;	# 跨冊要處理的資料
		$sutraNum =~ s/0084[ab]/0084/;	# 跨冊要處理的資料
		$sutraNum =~ s/0089[abc]/0089/;	# 跨冊要處理的資料
	}
	elsif($book eq "K")
	{
		$sutraNum =~ s/1257[ab]/1257/;	# 跨冊要處理的資料
	}
	elsif($book eq "L")
	{
		$sutraNum =~ s/1490[ab]/1490/;		# 跨冊要處理的資料
		$sutraNum =~ s/1557[abcd]/1557/;	# 跨冊要處理的資料
		$sutraNum =~ s/1638[ab]/1638/;		# 跨冊要處理的資料
	}
	elsif($book eq "P")
	{
		$sutraNum =~ s/1519[ab]/1519/;	# 跨冊要處理的資料
		$sutraNum =~ s/1611[ab]/1611/;	# 跨冊要處理的資料
		$sutraNum =~ s/1612[abc]/1612/;	# 跨冊要處理的資料
		$sutraNum =~ s/1615[abc]/1615/;	# 跨冊要處理的資料
		$sutraNum =~ s/1617[ab]/1617/;	# 跨冊要處理的資料
	}
	elsif($book eq "U")
	{
		$sutraNum =~ s/1418[ab]/1418/;	# 跨冊要處理的資料
	}
	elsif($book eq "ZY")
	{
		$sutraNum =~ s/0005[abc]/0005/;		# 跨冊要處理的資料
		$sutraNum =~ s/0022[ab]/0022/;		# 跨冊要處理的資料
		$sutraNum =~ s/0023[ab]/0023/;		# 跨冊要處理的資料
		$sutraNum =~ s/0047[abcd]/0047/;	# 跨冊要處理的資料
	}
	elsif($book eq "DA")
	{
		$sutraNum =~ s/0004[ab]/0004/;		# 跨冊要處理的資料
		$sutraNum =~ s/0005[a-h]/0005/;		# 跨冊要處理的資料
	}

	print VTOC "</name><book>$book</book><vol>${volnum}</vol><sutra>${sutraNum}</sutra>\n";

	%saveXu=();
	%saveJuan=();
	%saveJuanNum=();
	%savePin=();
	%savePin2=();
	%saveHui=();
	%saveFen=();
	%saveOther=();
	@lines=();
	@tagBeforeLine=();
	$div1head="";
	$div2head="";
	$div1Type="";
	$BlockquoteOpen = 0;

	# marked by Ray 2000/3/7 09:09PM
	#$column="";
	#$preColumn="";
}

#-----------------------------------------------------------------------
# 一經結束時呼叫

##############################################################################
#
#              TOC 及 ePub NCX 的處理法
#
#         toc                             ePub ncx
#
# 一開始  <name>...</name>....            <np><nl>...</nl>...
#
# 如果有子層  <UL>                         不要有結尾的 </np> , 否則就 </np>
#
# 子層結束    </UL>                        </np>
#
##############################################################################

sub endSutra {
	print STDERR "end sutra\n";
	my $i;
	my $key,$value;
	my $type, $level, $label, $url, $child;
	my $openUL=0;
	my $juanPrinted=0;

	my $oldFile = select();
	#select FTOC;
	$i = int($mostDeepLevel) + 1;
	if ($i > 4) { $i = 4; }
	
	$lastLevel = 0;
	$juanOld = "";
	my $len = @mulu;
	for ($i=0; $i<$len; $i++) {
		$level = $mulu[$i][1];
		$url   = $mulu[$i][2];
		my $label = $mulu[$i][3];
		
		printJuan($i);
		$lastLevel = $level;
	}
	if ($len>0) { printJuan($len-1); }

	my $tabs = "  " x ($hhcLevel-1);
	select VTOC;
	print "$tabs<UL>\n";

	### 一經單卷 ###
	my $i = keys(%saveJuan);
	if ($i == 1) {
		my @keys = keys(%saveJuan);
		$value=$sutraName;
		$key = $keys[0];
		
		$key =~ /.([A-Z]+)(\d*).*\#(.*)/;
		my $book = $1;
      	my $vol_num = $2;
     	my $pageline_num = $3;
      	print $tabs, "  <name>", myOut($value), "</name>";
      	print "<book>$book</book><vol>$vol_num</vol><juan>$saveJuanNum{$key}</juan><pageline>$pageline_num</pageline>\n";
	}
	
	### 樹狀目錄 ###
	my $i = @mulu;
	if ($i > 0) 
	{
		print $tabs, "  <name>", myOut("目錄"), "</name>\n";

		print $tabs, "  <UL>\n";

		for ($j=0; $j<$i; $j++) {
			$level = $mulu[$j][1];
			$url   = $mulu[$j][2];
			$label = $mulu[$j][3];
			$child = $mulu[$j][4];
			
			if ($j>0 and $level < $mulu[$j-1][1]) {
				while ($openUL >= $level ) {
					print $tabs, "  " x ($openUL+1) . "</UL><!-- 1267 end of Level $openUL -->\n";
					$openUL --;
				}
			}
			print $tabs, "  " x ($level+1) . "<name>";
			print myOut($label);
			print "</name>";
			
      		$url =~ /.([A-Z]+)(\d*).*\#(.*)/;
      		my $book = $1;
      		my $vol_num = $2;
     		my $pageline_num = $3;
			print "<book>$book</book><vol>$vol_num</vol><juan>$mulu[$j][5]</juan><pageline>$pageline_num</pageline>\n";

			if ($child) {
				print $tabs, "  " x ($level+1) . "<UL><!-- Level $level -->\n";
				$openUL ++;
			}
		}
		while ($openUL > 0) {
			print $tabs, "  " x ($openUL+1) . "</UL><!-- 1284 end of Level $openUL -->\n";
			$openUL --;
		}
		print "$tabs  </UL><!-- end of Mulu -->\n";
	}

	### 一經多卷 ###
	my $i = keys(%saveJuan);
	if ($i>1) {

		print $tabs, "  <name>", myOut("卷"), "</name><value>1</value>\n";
		print $tabs, "  <UL>\n";

		for $key (sort(keys(%saveJuan))) {
			my $juan_num=$saveJuanNum{$key};	# 卷數
			$value = $saveJuan{$key};
			$value=$value;
			
			$key =~ /.([A-Z]+)(\d*).*\#(.*)/;
			my $book = $1;
		    my $vol_num = $2;
      		my $pageline_num = $3;
			print "$tabs    <name>", myOut($value), "</name>";
			print "<book>$book</book><vol>$vol_num</vol><juan>$juan_num</juan><pageline>$pageline_num</pageline>\n";
		}
		print "$tabs  </UL><!-- end of Juan -->\n";
	}

	print "$tabs</UL><!-- end of Jing -->\n";
	select $oldFile;
	
	print TOCERR "<ok>!\n";
}


############################################################################
# 輸出
############################################################################

# --------------------------------------------------------------------------
# 依據指定的編碼來輸出結果

sub myOut {
	my $s = shift;
	if ($outEncoding eq "utf8") {
		return $s;
	}
	my @a=();
	push(@a, $s =~ /$utf8/gs);
	my $c;
	$s = '';
	foreach $c (@a) {
		if ($c ne "\n") {
			if (exists $utf8out{$c}) { $c =  $utf8out{$c}; }
			else {
				$len = length($c);
				print STDERR "Error:859 lb=$lb {$c} not in conversion table\n";
				print STDERR "length: $len\n";
				print STDERR "$s\n";
				print TOCERR "Error:859 lb=$lb {$c} not in conversion table\n";
				print TOCERR "length: $len\n";
				print TOCERR "$s\n";
				for ($i=0; $i<$len; $i++) {
					$s = unpack("H2",substr($c,$i,1));
					print STDERR "\\x$s\n";
					print TOCERR "\\x$s\n";
				}
				exit;
			}
		}
		$s.=$c;
	}
	return $s;
}

############################################################################
# End
############################################################################