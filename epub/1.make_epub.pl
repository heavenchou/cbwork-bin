
#-------------------------------------------------------------------------
# make_epub.bat 數字 type singlefile
# 數字 : 表示第幾冊或第幾部
# type : 1 : 部類, 2 : 大正藏單冊, 3 : 卍續藏單冊, 4 : 卍續藏的部, 5 : 嘉興藏的冊, 6 : 正史單冊, 7 : 藏外單冊  8 : 佛拓百品單冊
#        A : 金藏 C : 中華藏 D : 國圖 F : 房山石經 G : 佛教大藏經 K : 高麗藏 L : 乾隆藏 M : 卍正藏 N : 南傳大藏經單冊 N2: 南傳大藏經的部 
#        P : 永樂北藏 S : 宋藏遺珍 U : 洪武南藏
#        a : 新標, b : 福嚴精舍閱讀經典次第目錄 , c : 杜老師禮懺部
# singlefile : 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
# 產生 cbeta html help version *.hhp, *.hhc, T??n????.htm(各經目錄)
# 使用惠敏法師部類目錄
# written by Ray 2001/2/28 04:16下午
#-------------------------------------------------------------------------

use lib "../";
use utf8;
use cbeta;

my $epub_date = "2014-06-07";	# epub 的日期

### command line parameter ###

# 有 BL : 部類, T : 大正藏單冊, X : 卍續藏單冊, XB : 卍續藏的部, J : 嘉興藏的冊, H : 正史單冊, W : 藏外單冊, I : 佛拓百品單冊
#    A : 金藏 C : 中華藏 D : 國圖 F : 房山石經 G : 佛教大藏經 K : 高麗藏 L : 乾隆藏 M : 卍正藏 N : 南傳大藏經單冊 NB: 南傳大藏經的部
#    P : 永樂北藏 S : 宋藏遺珍 U : 洪武南藏
#    newsign : 新標, fuyan : 福嚴精舍閱讀經典次第目錄 , lichan : 杜老師禮懺部

$BuleiType = shift;

$BuLei=lc(shift);	# 冊數

# 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
$singlefile = shift;

# 若沒參數則離開
if ($BuLei eq "") 
{
	print "ERROR : perl 1.make_epub.pl Type Vol 1\n";
	exit;
}

# 產生記錄檔, 程式正常結束時刪除, 用來判斷程式是否正確執行完畢

open TOCERR, ">>:utf8" , "1.make_epub-err.txt";
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime;
$mon++;
$year += 1900;
print TOCERR "\n\n=============  Time : $year/$mon/$mday $hour:$min:$sec ====================\n\n";
print TOCERR "perl $0 $BuLei $BuleiType \n";
print STDERR "\n\n=============  Time : $year/$mon/$mday $hour:$min:$sec ====================\n\n";


$BuLei = "000" . $BuLei;
$BuLei =~ /.*(...)$/;
$BuLei = $1;				# 取最後三個字

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

if($BuleiType eq "BL")
{
	@chms = qw(01AHan 02BenYuan 03BoRuo 04FaHua 05HuaYan 06BaoJi 07NiePan 08DaJi 09JingJi 10MiJiao 11Vinaya 12PiTan 13ZhongGuan 14Yogacara 15LunJi 16PureLand 17Chan 18History 19Misc 20DunHuang 21XinBian);
	$chm = $chms[$BuLei-1];
}
elsif($BuleiType =~ /^[ACGLMPU]|(GA)$/)	# 三位數的冊數
{
	$chm = "$BuleiType$BuLei";
}
elsif($BuleiType =~ /^[BDFHIJKNSTWX]|(XB)|(NB)|(ZY)$/)	# 二位數的冊數
{
	$BuLei =~ /\d(\d\d)/;
	my $tmp = $1;
	$chm = "$BuleiType$tmp";
}
else	# 新標, 福嚴, 禮懺
{
	$chm = $BuleiType;
}

$BuleiTxt = "../cbreader/bulei/bulei" . $BuleiType . ".txt";

#elsif($BuleiType == 4)
#{
#	$BuleiTxt = "BuLei4.txt";
#	@chms = qw(T01_AHan T02_BenYuan T03_BoRuo T04_FaHua T05_HuaYan T06_BaoJi T07_NiePan T08_DaJi T09_JingJi T10_MiJiao T11_Vinaya T12_JingLun T13_PiTan T14_ZhongGuan T15_Yogacara T16_LunJi T17_JingShu T18_VinayaShu T19_LunShu T20_ZhuZong T21_History T22_Misc T23_WaiJiao T24_MuLu T25_GuYi T26_Apoc);
#}
#elsif($BuleiType == 5)
#{
#	$BuleiTxt = "BuLei5.txt";
#	@chms = qw(X01_History);
#}

use Getopt::Std;		# MacPerl 沒有 Getopt Module
getopts('e:');			# 取得 e: 所接的參數, 例如 e:big5
$outEncoding = $opt_e;
$outEncoding = lc($outEncoding);
#if ($outEncoding eq '') { $outEncoding = 'big5'; }
if ($outEncoding eq '') { $outEncoding = 'utf8'; } # 預設是 utf8
print STDERR "Output encoding: $outEncoding\n";

### 設定值 ###
#$buildNumber = 13;
open CFG,"1.make_epub.cfg" or die "cannot open cbeta.cfg\n";
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
#require "c:/cbwork/work/bin/hhead.pl";
#require "c:/cbwork/work/bin/subutf8.pl";
#require "c:/cbwork/work/bin/cbetasub.pl";
require "../common/cbeta_sub.pl";
#$utf8out{"\xe2\x97\x8e"} = '';

# 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
# 這部份還沒仔細處理, 只有各經獨立的情況比較 OK
if($singlefile == 0)
{
	# 開啟 xx.ncx 檔案

	my $ncxname = $outDir . "\\$chm.ncx";		# 單經版是用 toc.ncx
	open TOC, ">:utf8", $ncxname;
	print STDERR "open $ncxname\n";

	# 開啟 xx.opf 檔案

	my $opfname = $outDir . "\\$chm.opf";		# 單經版是用 content.opf
	open CONTENT, ">:utf8", $opfname;
	print STDERR "open $opfname\n";
}

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
my @saveMilestone=();	# 儲存卷數, 一卷只有一筆
my %savePin=();   # 品
my %savePin2=();  # 品 (div2)
my %saveHui=();   # 會
my %saveFen=();   # 分
my %saveJing=();  # 經
my @saveFig=();	  # 圖檔檔名 T16084501
my %saveOther=();
my %SD2Fig=();		# $SD2Fig{"SD-ABCd"} = 1 表示此字沒有羅馬轉寫字, 所以要用圖呈現
my $version;
my $firstLineOfSutra;
my $firstLineOfPage;
my $saveof = "";
my $CorrCert;
my $juanOpen=0;
#my $mostDeepLevel="";
my $jingURL="";
my $jingLabel="";
my $ncx_order = 1;	# ncx 中 <navPoint 標籤內 playOrder 的內容
my $this_SD = "";	# 若是在缺字區, 則遇到悉曇 SD 或蘭札 RJ , 要記錄起來, 因為其中有些地方要判斷此 SD 有沒有羅馬轉寫, 若沒有就要記錄, 要 copy 圖檔來用.

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
#openent("c:/cbwork/xml/dtd/cbeta.ent");
my $gaiji = new Gaiji();
$gaiji->load_access_db();
readBuLei();

my $id;
my $old_id='';
my $hhcLevel;	# 目前層次的數目
my $pre;

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

foreach $id (sort keys %BuLeiDir)
{
	##$hhcLevel = length($id)/3 - 1;		
	##$oldLevel = length($old_id)/3 - 1;
	$hhcLevel = length($id)/3;		# 一開始 $id 是六位數, 而 hhlevel 要由 2 開始算, 因為前還有 <ncx> 及 <navMap>
	$oldLevel = length($old_id)/3;
	#print TOC "<!-- s=$id old_id=$old_id level=$level oldLevel=$oldLevel -->\n";
	# 跳回上一層, 所以要將此層結束
	while($hhcLevel < $oldLevel) 
	{
		$pre = "    " x ($oldLevel-1);
		##print TOC $pre,"</UL>\n";
		print TOC $pre,"</navPoint>\n";
		$oldLevel--;
	}
	if (exists($BuLeiDir{$id."001"}))		# 如果還有下一層 <navPoint> 就不要有 </navPoint> 結束
	{
		$pre = "    " x $hhcLevel;
		##print TOC $pre, '<name>', $BuLeiDir{$id} ,'</name>',"\n";
		##print TOC $pre,"<UL>\n";
		print TOC $pre, "<navPoint id=\"navPoint-$ncx_order\" playOrder=\"$ncx_order\">\n";
		print TOC $pre, '    <navLabel>',"\n";
		print TOC $pre, '    <text>' . $BuLeiDir{$id} . '</text>',"\n";
		print TOC $pre, '    </navLabel>',"\n";
		$ncx_order++;
	}
	else 
	{
		$BuLeiDir{$id} =~ /^([A-Z]+?)([AB]?\d{3,4}\w?)(.*)$/;
		my $book = $1;
		$sutraNum = $2;
		$sutraName = $3;
		$vol = num2vol($sutraNum,$book);
		$pre = "    " x $hhcLevel;
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
		
		$tmpnum =~ s/(B0[12]n0001)[ab]/$1/;		# 跨冊要處理的資料
		$tmpnum =~ s/(B0[345]n0002)[abc]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(B1[56]n0088)[ab]/$1/;		# 跨冊要處理的資料	
		
		$tmpnum =~ s/(C05[67]n1163)[ab]/$1/;	# 跨冊要處理的資料
		
		$tmpnum =~ s/(GA01[12]n0010)[ab]/$1/;		# 跨冊要處理的資料
		$tmpnum =~ s/(GA03[12]n0032)[ab]/$1/;		# 跨冊要處理的資料
		$tmpnum =~ s/(GA08[12]n0084)[ab]/$1/;		# 跨冊要處理的資料
		$tmpnum =~ s/(GA0[89][890]n0089)[abc]/$1/;	# 跨冊要處理的資料
		
		$tmpnum =~ s/(K3[45]n1257)[ab]/$1/;	# 跨冊要處理的資料
		
		$tmpnum =~ s/(L11[56]n1490)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(L13[0123]n1557)[abcd]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(L15[34]n1638)[ab]/$1/;	# 跨冊要處理的資料
		
		$tmpnum =~ s/(N\d\dn\d{4})[a-l]/$1/;	# 跨冊要處理的資料
		
		$tmpnum =~ s/(P15[45]n1519)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(P17[89]n1611)[ab]/$1/;	# 跨冊要處理的資料
		$tmpnum =~ s/(P1\d\dn1612)[abc]/$1/;	# 跨冊要處理的資料
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
		print TOCERR "<start> $file ......\n";
		#<>; # T07 是靠這個暫停, 一個一個手動處理的
		
		# $BuleiType 2 : 大正藏單冊, 3 : 卍續藏單冊, 4 : 卍續藏的部, 5 : 嘉興藏的冊, 6 : 正史單冊, 7 : 藏外單冊, 8 : 佛拓百品單冊
		if(($BuleiType == 2 && $vol =~ /T/) ||
		   ($BuleiType == 3 && $vol =~ /X/) ||
		   ($BuleiType == 5 && $vol =~ /J/) ||
		   ($BuleiType == 6 && $vol =~ /H/) ||
		   ($BuleiType == 7 && $vol =~ /W/) ||
		   ($BuleiType == 8 && $vol =~ /I/) ||
		   ($vol =~ /$BuleiType/))
		{
			$parser->parsefile($file);
		}
	}
	$old_id = $id;
}

$oldLevel--;
while($oldLevel > 2) {
	$pre = "    " x $oldLevel;
	print TOC $pre,"</navLabel>\n";
	$oldLevel--;
}

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
	$date = $epub_date;
	$title = "";
	$juanOpen=0;
	@elements=();
	@mulu=();
	$inLg = 0;
	$inMulu = 0;
	$MuluLabel = "";
	@openTags=();
	$firstLineOfSutra = 1;
	$this_SD = "";
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
	# <figure entity="FigT16084501"/>
	# P5 XML 變成如下 <figure><graphic url="../figures/T/T16p0847_01.gif"></graphic></figure>
	if ($el eq "graphic") 
	{
		my $is_note = 0;
		# <note type="orig"> 或 <note type="mod"> 的內容不處理
		
		# 這裡就不合理了, 因為 graphinc 已經在 figure 之中了, 不過 P5 的 figure 也不會在 note 之內了. 因為 note 移到 <back> 了
		if ($parent eq "note") 
		{
			my $att = pop(@saveatt);	# 這層是 figure 的參數
			my $att1 = pop(@saveatt);	# 這層是 note 的參數
			my $noteType = $att1->{"type"};
			my $notePlace = $att1->{"place"};
			push @saveatt, $att1;
			push @saveatt, $att;
			if (($noteType eq "orig") || ($noteType eq "mod"))
			{
				$is_note = 1;	# 這是 note , 不處理了
			}
			if (($noteType eq "rest") && ($notePlace eq "foot")) # <note type="rest" place="foot"> 也不要
			{
				$is_note = 1;	# 這是 note , 不處理了
			}
		}
		
		if($is_note == 0)
		{
			if($parent ne "rdg")	# <rdg> 的內容不處理
			{
				# url="../figures/T/T16p0847_01.gif"
				my $ent = $att{"url"};
				$ent =~ s/^.*[\\\/](.*)\.gif/$1/;	# 只留下 T16p0847_01
				push(@saveFig, $ent);	# 儲存圖檔的名稱
			}
		}
		
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
				push(@saveMilestone, $juanNum);
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
			#$juanNum = $num;	# 由 <milestone> 來判斷比較準確
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

		if ($firstLineOfSutra)
		{
			if (substr($lb,0,5) ne $pb)
			{
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

	# $mulu[$i][0] 目錄類別
	# $mulu[$i][1] 目錄層級
	# $mulu[$i][2] 對應的 URL
	# $mulu[$i][3] 目錄標題
	# $mulu[$i][4] 是否有子目錄
	# $mulu[$i][5] 目錄所在卷數
	# $mulu[$i][6] 所在卷數對應的 URL
	
	### <cb:mulu> ###
	if ($el eq "cb:mulu" )
	{
		my $typeOfMulu = myDecode($att{"type"});
		my $i=@mulu;
		if ($typeOfMulu eq "卷")
		{
			my $label = myDecode($att{"label"});
			$juanURL = "/$vol$column.htm#$lb";
			my $n = $att{"n"};
			# 有些 n 是有 abc 的, 例如 : T33n1708 <juan fun="open" n="001a"><mulu type="卷" n="1a"
			# 有些 n 是有 abc-123 的, 例如 : T40n1805 <juan n="001a-1" fun="open"><mulu n="1a-1" label="上一上" type="卷"/>
			# $n =~ s/[a-zA-Z]*$//;
			$n =~ s/^(\d*).*/$1/;
			#$juanNum = $n;		# 由 <milestone> 來判斷比較準確
			#$saveJuanNum{$juanURL} = $n;		# 儲存卷數
			$saveJuanNum{$juanURL} = $juanNum;		# 儲存卷數
			
			# 如果有 label 就存起來, 否則就是 "第XX"
			if ($label eq '')
			{
				$saveJuan{$juanURL}= "第" . cNum($juanNum);
			}
			else
			{
				$saveJuan{$juanURL}= $label;
			}
		}
		else
		{
			$inMulu = 1;
			my $url = "/$vol$column.htm#$lb";
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
			#if ($level > $mostDeepLevel) { $mostDeepLevel = $level; }
		}
	}

	### <char> ###
	# 遇到檔頭缺字, 要處理 SD 及 RJ 字, 判斷有沒有羅馬轉寫, 若沒有, 表示 cbr 轉出來的 htm 是用圖檔, 因此要記錄圖檔, 以寫入 toc 等文件中.
	# $SD2Fig{"SD-ABCD"} == 1
	
	# <char xml:id="SD-D957">
	# <charName>CBETA CHARACTER SD-D957</charName>
	# <charProp>
	# 	<localName>Character in the Siddham font</localName>
	# 	<value>揨</value>
	# </charProp>
	# <mapping cb:dec="1079639" type="PUA">U+107957</mapping>
	# </char>
	
	if ($el eq "char" ) 
	{
		$tmp = $att{"xml:id"};
		if ($tmp =~ /^((SD)|(RJ))/)
		{
			$this_SD = $tmp;
			$SD2Fig{$this_SD} = 1;	# 先設為 1 , 再由底下的程式來檢查, 之後發現它有羅馬轉寫或 big5 對應字, 才設為 0
			$p->setHandlers (Char  => \&check_char_data);	# 
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
				# ePub 以 uniocde 1.1 為基礎, unicode 3.0 以上的考慮有些系統不支援, 故不呈現
				#if($gaiji->cb2uniword($cb))
				#{
				#	$MuluLabel .= $gaiji->cb2uniword($cb);
				#}
				if($gaiji->cb2nor($cb))
				{
					$MuluLabel .= $gaiji->cb2nor($cb);
				}
				elsif($gaiji->cb2des($cb))
				{
					$MuluLabel .= $gaiji->cb2des($cb);
				}
			}
		}
		# 記錄悉曇字
		# <g ref="#SD-D957">
		# 如果 $SD2Fig{"SD-ABCD"} == 1 , 就表示沒有羅馬轉寫字, 就要用圖呈現 , SD2Fig 原本 p4 是在 ent 檔中處理, p5 則是在檔頭的缺字區處理
		my $ref = $att{"ref"};
		if($ref =~ /^#((SD)|(RJ))/)
		{
			$ref =~ s/^#(.*?)/$1/;
			if($SD2Fig{$ref})
			{
				push(@saveFig, $ref);	# 儲存圖檔的名稱 SD-CFC2.gif
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
			#$date =~ s#^.*(..../../..).*$#$1#;	# 直接指定日期
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
	
	### </char> ###
	if ($el eq "char" ) 
	{
		$this_SD = "";
		$p->setHandlers ( Char  => \&char_handler );
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

# 這是專門用在 <char>...</char> 標記中的文字檢查, 要判斷某些悉曇字或蘭札字有沒有羅馬轉寫字或 big5 對應字
sub check_char_data
{
	my $p = shift;
	my $char = shift;
	
	# <localName>Romanized form in CBETA transcription</localName>
	# <localName>Romanized form in Unicode transcription</localName>
	# <localName>big5</localName>
	
	if($char =~ /Romanized form in/ || $char =~ /big5/)
	{
		$SD2Fig{$this_SD} = 0;
	}
}

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
			#$date .= $char;	# 日期改成指定的
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
		if ($noteType eq "foot" or $att->{"place"} eq "foot" or $att->{"place"} eq "foot text" or $att->{"type"} eq "mod") 
		{  return;  }
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
	print_toc();				# 印出 toc.ncf
	print_TableOfContents();	# 印出 print_TableOfContents.xhtml
	print_content();			# 印出 content.opf
	#print_coverpage();			# 印出封面 CoverPage.xhtml
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
			
			if ($val=~/uniflag=\'(.+?)\'/) {$uni_flag=$1;}
			
			if ($file=~/jap\.ent/) { # 如果是日文
		 		if ($val=~/uni=\'(.+?)\'/) { $val= "&#x" . $1 . ";" ; } # 優先使用 Unicode
			} elsif($ent=~/^((SD)|(RJ))/) {
				$val = b52utf8($val);
				
				# 如果沒有 cbdia 或 udia 就用圖檔呈現
				# <!ENTITY SD-CFC2 "<gaiji uniflag='' cb='SD-CFC2' sdchar='狟'/>" >
				# <!ENTITY SD-E36C "<gaiji uniflag='' cb='SD-E36C' big5='〔' sdchar='緄'/>" >
				# <!ENTITY SD-E36D "<gaiji uniflag='' cb='SD-E36D' big5='〕' sdchar='緆'/>" >
				# <!ENTITY SD-A440 "<gaiji uniflag='' cb='SD-A440' cbdia='ka' udia='ka' sdchar='一'/>" >
				if($val !~ /(cbdia)|(udia)|(big5)/)
				{
					$SD2Fig{$ent} = 1;		# 表示這個 SD 悉曇字只能用圖呈現了
					#push(@saveFig, $ent);	# 儲存圖檔的名稱 SD-CFC2.gif
				}
				
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
						$ent2ZuZiShi{$ent}=$des;		# 儲存組字式...好像沒用到
					} else { $des = $ent; }
					$href = "javascript:showpic(\"$href\")";
					#$no_nor{$ent} = "[<a href='$href'>$des</a>]";
					$no_nor{$ent} = "[$des]";			# 如果不用通用字的情況, 就用組字式, 沒組字式就是 [$ent] 代碼
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
					    
					if ($val=~/uni=\'(.+?)\'/ && $uni_flag)  # 優先使用 Unicode
					{
						#$val= "&#x" . $1 . ";" ;	# HTML 才能這樣用
						$val = pack "H4", $1;
						$val = toutf8($val);
					}
					elsif ($val=~/nor=\'(.+?)\'/)	# 其次使用通用字
					{
						$val=$1;
						$ent2nor{$ent}=$val;
					} 
					else 
					{
						$val = $no_nor{$ent};	# 沒通用字用 no_nor => 組字式 , ent 代碼
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
		#$book = substr($a[0],0,1);	# 取出 T or X
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
	open I, "<:utf8", $BuleiTxt or die "open $BuleiTxt error";
	my @temp;
	while (<I>) 
	{
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
# 應該是印出卷的資料

sub printJuan {
	my $a=shift;
	my $newCell = 0;
	my $deepest;

	$juanNum  = $mulu[$a][5];

	if ($juanOld eq "" or $juanNum ne $juanOld) 
	{
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
# sub print_toc 
# sub print_TableOfContents
# sub print_content
# sub print_coverpage
#
############################################################################

# --------------------------------------------------------------------------
# 新的一經基本資料都讀取到了, 目前已到 </bibl> 標記

sub endBibl 
{
	my $book="T";
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
		
		# 上面是舊的方式
		$mtit =~ s/^.*?No\./No./;
		$book = $vol;
		$book =~ s/\d*$//;
		$book = "H" if $book eq "ZS";
		$book = "W" if $book eq "ZW";
		
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
	
	######################################################
	# 底下這些好像不需要了
	
	if($book eq "T")
	{
		$sutraNum =~ s/0220[a-o]/0220/;
	}
	#elsif($book eq "X")
	#{
		#$sutraNum =~ s/0240[ab]/0240/;	# 跨冊要處理的資料
		#$sutraNum =~ s/0367[ab]/0367/;	# 跨冊要處理的資料
		#$sutraNum =~ s/0714[ab]/0714/;	# 跨冊要處理的資料
		#$sutraNum =~ s/0822[ab]/0822/;	# 跨冊要處理的資料
		#$sutraNum =~ s/1568[ab]/1568/;	# 跨冊要處理的資料
		#$sutraNum =~ s/1571[ab]/1571/;	# 跨冊要處理的資料
	#}
	#elsif($book eq "J")
	#{
		#$sutraNum =~ s/B271[ab]/B271/;	# 跨冊要處理的資料
		#$sutraNum =~ s/B277[ab]/B277/;	# 跨冊要處理的資料
	#}
	#elsif($book eq "ZY")
	#{
		#$sutraNum =~ s/0005[abc]/0005/;	# 跨冊要處理的資料
		#$sutraNum =~ s/0022[ab]/0022/;		# 跨冊要處理的資料
		#$sutraNum =~ s/0023[ab]/0023/;		# 跨冊要處理的資料
		#$sutraNum =~ s/0047[abcd]/0047/;	# 跨冊要處理的資料
	#}

	##my $pre = "    " x ($hhcLevel-1);
	
	# 印出目錄中經名的那一層
	
	##print TOC $pre, "<name>";
	##print TOC myOut($jingLabel);
	##print TOC "</name><book>$book</book><vol>${volnum}</vol><sutra>${sutraNum}</sutra>\n";
	
	# 此段移到底下, 因為要知道一開始是哪一卷.
	###print TOC $pre, '<navPoint id="navPoint-xxx" playOrder="xxx">' . "\n";
	###print TOC $pre, '<navLabel>' . "\n";
	###print TOC $pre, '  <text>' . myOut($jingLabel) . '</text>' . "\n";
	###print TOC $pre, '</navLabel>' . "\n";
	###print TOC $pre, "<content src=\"${vol}n${sutraNum}_001xxx.xhtml\" />\n";

	%saveXu=();
	%saveJuan=();
	%saveJuanNum=();
	@saveMilestone=();	# 儲存卷數, 一卷只有一筆
	%savePin=();
	%savePin2=();
	%saveHui=();
	%saveFen=();
	%saveOther=();
	@saveFig=();
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
# 一經結束, 輸出 toc.ncx

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

sub print_toc
{
	print STDERR "end sutra, print toc.ncx\n";
	my $i;
	my $key,$value;
	my $type, $level, $label, $url, $child;
	my $openUL=0;

	$vol =~ /([A-Z]+)(\d*)/;
	my $book = $1;
	my $volnum = $2;
	
	# 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
	if($singlefile == 1)
	{
		$ncx_order = 1;		# navPoint 標籤中 playOrder 屬性要歸 0
		mkdir("$outDir/${vol}");
		mkdir("$outDir/${vol}/${vol}n${sutraNum}");
		open TOC , ">:utf8", "$outDir/${vol}/${vol}n${sutraNum}/toc.ncx" or die "open  $outDir/${vol}/${vol}n${sutraNum}/toc.ncx error";

		my $my_jingLabel = myOut($jingLabel);

print TOC << "XHTML_TOC";
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN" "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" xml:lang="zh-TW" version="2005-1">
    <head>
        <meta name="dtb:uid" content="${vol}n${sutraNum}" />
        <meta name="dtb:depth" content="1" />
        <meta name="dtb:totalPageCount" content="0" />
        <meta name="dtb:maxPageNumber" content="0" />
    </head>
    <docTitle>
        <text>$my_jingLabel</text>
    </docTitle>
    <navMap>
XHTML_TOC
		
	}

	my $pre = "    " x $hhcLevel;
	
	my @keys = sort(keys(%saveJuan));
	my $key = $keys[0];
	my $juannum = sprintf("%03d" , $saveJuanNum{$key});
	my $sutraNum_ = $sutraNum;
	$sutraNum_ .= "_" if(length($sutraNum) == 4);
	
	# 印出目錄中經名的那一層

	print TOC $pre, "<navPoint id=\"navPoint-$ncx_order\" playOrder=\"$ncx_order\">\n";
	print TOC $pre, '    <navLabel>' . "\n";
	print TOC $pre, '    <text>' . myOut("編輯說明") . '</text>' . "\n"; 
	print TOC $pre, '    </navLabel>' . "\n";
	print TOC $pre, "    <content src=\"readme.xhtml\" />\n";
	print TOC $pre, "</navPoint>\n";
	$ncx_order++;
	
	#print TOC $pre, "<navPoint id=\"navPoint-$ncx_order\" playOrder=\"$ncx_order\">\n";
	#print TOC $pre, '    <navLabel>' . "\n";
	#print TOC $pre, '    <text>' . myOut($sutraName) . myOut(" 目錄") . '</text>' . "\n"; 
	#print TOC $pre, '    </navLabel>' . "\n";
	#print TOC $pre, "    <content src=\"${vol}n${sutraNum_}${juannum}.xhtml\" />\n";
	#$ncx_order++;
	
	##print "$tabs<UL>\n";

	### 一經單卷 ###
	$i = keys(%saveJuan);
	if ($i == 1)
	{
		my @keys = keys(%saveJuan);
		$key = $keys[0];
		
		$key =~ /.[A-Z].*?\#(.*)/;
     	my $pageline_num = $1;
     	
     	my $juannum = sprintf("%03d" , $saveJuanNum{$key});
      	##print $tabs, "  <name>", myOut($value), "</name>";
      	##print "<book>$book</book><vol>$vol_num</vol><juan>$saveJuanNum{$key}</juan><pageline>$pageline_num</pageline>\n";
		print TOC $pre, "    <navPoint id=\"navPoint-$ncx_order\" playOrder=\"$ncx_order\">\n";
		print TOC $pre, '        <navLabel>' . "\n";
		print TOC $pre, '        <text>' . myOut($sutraName) . '</text>' . "\n";
		print TOC $pre, '        </navLabel>' . "\n";
		print TOC $pre, "        <content src=\"${vol}n${sutraNum_}${juannum}.xhtml#p${pageline_num}\" />\n";
		print TOC $pre, '    </navPoint>' . "\n";
		$ncx_order++;
	}

	### 樹狀目錄 ###
	$i = @mulu;
	if ($i > 0) 
	{
		##print $pre, "  <name>", myOut("目錄"), "</name>\n";
		##print $pre, "  <UL>\n";

		print TOC $pre, "    <navPoint id=\"navPoint-$ncx_order\" playOrder=\"$ncx_order\">\n";
		print TOC $pre, '        <navLabel>' . "\n";
		print TOC $pre, '        <text>' . myOut("章節目錄") . '</text>' . "\n";
		print TOC $pre, '        </navLabel>' . "\n";
		print TOC $pre, "        <content src=\"TableOfContents.xhtml#chapter\" />\n";
		$ncx_order++;

		for ($j=0; $j<$i; $j++)
		{
			$level = $mulu[$j][1];
			$url   = $mulu[$j][2];
			$label = $mulu[$j][3];
			$child = $mulu[$j][4];
			
			if ($j>0 and $level < $mulu[$j-1][1])
			{
				while ($openUL >= $level )
				{
					##print $tabs, "    " x ($openUL+1) . "</UL>\n";
					print TOC $pre, "    " x ($openUL+1) . "</navPoint>\n";
					$openUL --;
				}
			}

      		$url =~ /.[A-Z].*?\#(.*)/;
     		my $pageline_num = $1;

			##print $tabs, "    " x ($level+1) . "<name>";
			##print myOut($label);
			##print "</name>";
			##print "<book>$book</book><vol>$vol_num</vol><juan>$mulu[$j][5]</juan><pageline>$pageline_num</pageline>\n";

			my $tabs = $pre . "    " x ($level+1);
			my $juannum = sprintf("%03d" , $mulu[$j][5]);

			print TOC $tabs . "<navPoint id=\"navPoint-$ncx_order\" playOrder=\"$ncx_order\">\n";
			print TOC $tabs . '    <navLabel>' . "\n";
			print TOC $tabs . '    <text>' . myOut($label) . '</text>' . "\n";
			print TOC $tabs . '    </navLabel>' . "\n";
			print TOC $tabs . "    <content src=\"${vol}n${sutraNum_}${juannum}.xhtml#p${pageline_num}\" />\n";
			$ncx_order++;

			if ($child)
			{
				##print $tabs, "    " x ($level+1) . "<UL><!-- Level $level -->\n";
				$openUL ++;
			}
			else
			{
				print TOC $tabs . "</navPoint>\n";
			}
		}
		while ($openUL > 0)
		{
			##print TOC $tabs, "    " x ($openUL+1) . "</UL><!-- 1284 end of Level $openUL -->\n";
			print TOC $pre, "    " x ($openUL+1) . "</navPoint>\n";
			$openUL --;
		}
		##print "$tabs  </UL><!-- end of Mulu -->\n";
		print TOC $pre . "    </navPoint>\n";
	}

	### 一經多卷 ###
	$i = keys(%saveJuan);
	if ($i>1) 
	{
		##print $tabs, "  <name>", myOut("卷"), "</name><value>1</value>\n";
		##print $tabs, "  <UL>\n";

		my $tabs = $pre . "    ";
		print TOC $tabs, "<navPoint id=\"navPoint-$ncx_order\" playOrder=\"$ncx_order\">\n";
		print TOC $tabs, '    <navLabel>' . "\n";
		print TOC $tabs, '    <text>' . myOut("卷次目錄") . '</text>' . "\n";
		print TOC $tabs, '    </navLabel>' . "\n";
		print TOC $tabs, "    <content src=\"TableOfContents.xhtml#juan\" />\n";
		$ncx_order++;

		for $key (sort(keys(%saveJuan))) 
		{
			my $juan_num=$saveJuanNum{$key};	# 卷數
			$value = $saveJuan{$key};

			$key =~ /.[A-Z].*?\#(.*)/;
      		my $pageline_num = $1;

			##print $tabs . "    <name>", myOut($value), "</name>";
			##print "<book>$book</book><vol>$vol_num</vol><juan>$juan_num</juan><pageline>$pageline_num</pageline>\n";

			my $juannum = sprintf("%03d" , $juan_num);
			my $tabs = $pre . "        ";
			print TOC $tabs, "<navPoint id=\"navPoint-$ncx_order\" playOrder=\"$ncx_order\">\n";
			print TOC $tabs, '    <navLabel>' . "\n";
			print TOC $tabs, '    <text>' . myOut($value) . '</text>' . "\n";
			print TOC $tabs, '    </navLabel>' . "\n";
			print TOC $tabs, "    <content src=\"${vol}n${sutraNum_}${juannum}.xhtml#p${pageline_num}\" />\n";
			print TOC $tabs, "</navPoint>\n";
			$ncx_order++;
		}
		##print TOC $tabs . "  </UL><!-- end of Juan -->\n";
		print TOC $pre . "    </navPoint>\n";
	}

	##print TOC "$tabs</UL><!-- end of Jing -->\n";
	#print TOC $pre, "</navPoint>\n";

	# 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
	if($singlefile == 1)
	{

print TOC << "HTMLEND_TOC";
        <navPoint id="navPoint-$ncx_order" playOrder="$ncx_order">
            <navLabel>
                <text>贊助資訊</text>
            </navLabel>
            <content src="donate.xhtml" />
        </navPoint>
    </navMap>
</ncx>
HTMLEND_TOC
		$ncx_order++;
		close TOC;
	}

	print TOCERR "<ok>!\n";
}

#-----------------------------------------------------------------------
# 一經結束, 輸出 TableOfContents.xhtml 的內容

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

sub print_TableOfContents
{
	print STDERR "end sutra, print TableOfContents.xhtml\n";
	my $i;
	my $key, $value;
	my $type, $level, $label, $url, $child;
	my $openUL=0;

	$vol =~ /([A-Z]+)(\d*)/;
	my $book = $1;
	my $volnum = $2;
	
	my $sutraNum_ = $sutraNum;
	$sutraNum_ .= "_" if(length($sutraNum) == 4);
	
	# 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
	if($singlefile == 1)
	{
		open TABLE , ">:utf8", "$outDir/${vol}/${vol}n${sutraNum}/TableOfContents.xhtml" or die "open  $outDir/${vol}/${vol}n${sutraNum}/TableOfContents.xhtml error";

		my $my_sutraName = myOut($sutraName);
		my $my_jingLabel = myOut($jingLabel);

#底下的中文字其實應該用 myOut() 來處理才能符合各語系

print TABLE << "XHTML_TABLE";
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xml="http://www.w3.org/XML/1998/namespace" xml:lang="zh-TW">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="stylesheet" type="text/css" href="stylesheet.css" />
    <title>目錄</title>
</head>
<body>
    <h1 class="toc_label">$my_jingLabel</h1>
    <h3 class="toc_heading">目錄</h3>
    <p><a href="readme.xhtml">編輯說明</a></p>
XHTML_TABLE
		
	}

	my $pre = "    " x $hhcLevel;
	
	##print "$tabs<UL>\n";

	### 一經單卷 ###
	$i = keys(%saveJuan);
	if ($i == 1)
	{
		my @keys = keys(%saveJuan);
		$key = $keys[0];
     	
     	my $juannum = sprintf("%03d" , $saveJuanNum{$key});
      	##print $tabs, "  <name>", myOut($value), "</name>";
      	##print "<book>$book</book><vol>$vol_num</vol><juan>$saveJuanNum{$key}</juan><pageline>$pageline_num</pageline>\n";
		
		print TABLE $pre, "<p><a id=\"juan\">" . myOut("卷次目錄") . "</a></p>\n";
		print TABLE $pre, "<ul>\n";
		print TABLE $pre, "    <li><a href=\"${vol}n${sutraNum_}${juannum}.xhtml\">" . myOut($saveJuan{$key}) . "</a></li>\n";
		print TABLE $pre, "</ul>\n";
	}
	
	### 樹狀目錄 ###
	$mulunum = @mulu;
	if ($mulunum > 0) 
	{
		print TABLE $pre, "<p><a id=\"chapter\">" . myOut("章節目錄") . "</a></p>\n";
		print TABLE $pre, "<ul>\n";

		for ($i=0; $i<$mulunum; $i++)
		{
			$level = $mulu[$i][1];
			$url   = $mulu[$i][2];
			$label = $mulu[$i][3];
			$child = $mulu[$i][4];
			
			if ($i>0 and $level < $mulu[$i-1][1])
			{
				while ($openUL >= $level )
				{
					print TABLE $pre, "    " x ($openUL) . "</ul></li>\n";
					$openUL --;
				}
			}
			
      		$url =~ /.[A-Z].*?\#(.*)/;
     		my $pageline_num = $1;
     		
			##print $tabs, "    " x ($level+1) . "<name>";
			##print myOut($label);
			##print "</name>";
			##print "<book>$book</book><vol>$vol_num</vol><juan>$mulu[$i][5]</juan><pageline>$pageline_num</pageline>\n";
			
			my $tabs = $pre . "    " x ($level);
			my $juannum = sprintf("%03d" , $mulu[$i][5]);
			
			print TABLE $tabs . "<li><a href=\"${vol}n${sutraNum_}${juannum}.xhtml#p${pageline_num}\">" . myOut($label) . "</a>";

			if ($child)
			{
				# 如果有子層, 就加 <ul>
				print TABLE "\n" . $tabs . "<ul>\n";
				$openUL ++;
			}
			else
			{
				print TABLE "</li>\n";
			}
		}
		while ($openUL > 0)
		{
			print TABLE $pre, "    " x ($openUL) . "</ul></li>\n";
			$openUL --;
		}
		
		print TABLE $pre . "</ul>\n";
	}

	### 一經多卷 ###
	$i = keys(%saveJuan);
	if ($i>1) 
	{
		my $tabs = $pre;
		
		print TABLE $pre, "<p><a id=\"juan\">" . myOut("卷次目錄") . "</a></p>\n";
		print TABLE $pre, "<ul>\n";

		for $key (sort(keys(%saveJuan))) 
		{
			my $juan_num=$saveJuanNum{$key};	# 卷數
			$value = $saveJuan{$key};
			
			$key =~ /.[A-Z].*?\#(.*)/;
      		my $pageline_num = $1;
      		
			my $juannum = sprintf("%03d" , $juan_num);
			my $tabs = $pre . "    ";
			
			print TABLE $tabs . "<li><a href=\"${vol}n${sutraNum_}${juannum}.xhtml#p${pageline_num}\">" . myOut($value) . "</a></li>\n";
		}
		print TABLE $pre . "</ul>\n";
	}

	# 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
	if($singlefile == 1)
	{
		print TABLE "    <p><a href=\"donate.xhtml\">" . myOut("贊助資訊") . "</a></p>\n";
		print TABLE "</body>\n";
		print TABLE "</html>\n";

		close TABLE;
	}

	print TOCERR "<ok>!\n";
}

#-----------------------------------------------------------------------
# 印出 content.opf 的內容
# 這在多檔整合成一檔時不易處理....

sub print_content
{
	print STDERR "end sutra, print content.opf\n";
	my $key,$value;
	my $level, $label;

	$vol =~ /([A-Z]+)(\d*)/;
	my $book = $1;
	my $volnum = $2;

	my $sutraNum_ = $sutraNum;
	$sutraNum_ .= "_" if(length($sutraNum) == 4);
	
	### 處理各卷資料 ###

	my $tmpstr1 = "";
	my $tmpstr2 = "";
	
	# 舊方法, 因為有些經文只有序, 沒有卷 (沒有 卷的 mulu ), 例 X26n0514 ,  所以要用 milestone 來處理
	#my $oldjuannum = 0;		# 因為有時一卷會有數個卷目錄, 如 卷上之一, 卷上之二... 在此處每一卷只取一筆記錄
	#for $key (sort(keys(%saveJuan))) 
	#{
	#	my $juan_num=$saveJuanNum{$key};	# 卷數
	#	if($oldjuannum != $juan_num)
	#	{
	#		my $juannum = sprintf("%03d" , $juan_num);
	#		$tmpstr1 .= "        <item id=\"${vol}n${sutraNum_}${juannum}\" href=\"${vol}n${sutraNum_}${juannum}.xhtml\" media-type=\"application/xhtml+xml\" />\n";
	#		$tmpstr2 .= "        <itemref idref=\"${vol}n${sutraNum_}${juannum}\" />\n";
	#		$oldjuannum = $juan_num;
	#	}
	#}
	
	# 新方法 , 用 milestone 的記錄
	for($i=0; $i<=$#saveMilestone; $i++)
	{
		my $juannum = sprintf("%03d" , $saveMilestone[$i]);	# 卷數
		$tmpstr1 .= "        <item id=\"${vol}n${sutraNum_}${juannum}\" href=\"${vol}n${sutraNum_}${juannum}.xhtml\" media-type=\"application/xhtml+xml\" />\n";
		$tmpstr2 .= "        <itemref idref=\"${vol}n${sutraNum_}${juannum}\" />\n";
	}

	my $tmpfig = "";
	# 處理圖檔資料
	# <item id="xyz" href="abc.jpg" media-type="image/jpeg" />
	my %same_fig = ();	# 用來判斷圖檔是否有重覆
	for($i=0; $i<=$#saveFig; $i++)
	{
		my $tmp = $saveFig[$i];
		if($same_fig{$tmp} != 1)
		{
			$same_fig{$tmp} = 1;
			$tmpfig .= "        <item id=\"${tmp}\" href=\"${tmp}.gif\" media-type=\"image/gif\" />\n";
		}
	}
	
	# 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
	if($singlefile == 1)
	{
		open CONTENT , ">:utf8", "$outDir/${vol}/${vol}n${sutraNum}/content.opf" or die "open  $outDir/${vol}/${vol}n${sutraNum}/content.opf error";

		my $my_jingLabel = myOut($jingLabel);
		my $my_date = $date;
		#$my_date =~ s/\//-/g;	# 日期要用 YYYY-MM-DD 格式才行
		
print CONTENT << "XHTML_content";
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookId" version="2.0">
    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf">
        <dc:title>$my_jingLabel</dc:title>
        <dc:creator>$author</dc:creator>
        <dc:language>zh-TW</dc:language>
        <dc:identifier id="BookId">${vol}n${sutraNum}</dc:identifier>
        <dc:subject>佛教典籍</dc:subject>
        <dc:publisher>CBETA</dc:publisher>
        <dc:date>$my_date</dc:date>
        <meta name="cover" content="CoverDesign"/>
    </metadata>
    <manifest>
        <item id="toc" href="toc.ncx" media-type="application/x-dtbncx+xml" />
        <item id="CoverDesign" href="cover.jpg" media-type="image/jpeg" />
        <item id="CoverPage" href="CoverPage.xhtml" media-type="application/xhtml+xml" />
        <item id="TableOfContents" href="TableOfContents.xhtml" media-type="application/xhtml+xml" />
        <item id="readme" href="readme.xhtml" media-type="application/xhtml+xml" />
        <item id="style" href="stylesheet.css"  media-type="text/css" />
${tmpstr1}${tmpfig}        <item id="donate" href="donate.xhtml" media-type="application/xhtml+xml" />
    </manifest>
    <spine toc="toc">
        <itemref idref="CoverPage" linear="no" />
        <itemref idref="TableOfContents" />
        <itemref idref="readme" />
${tmpstr2}        <itemref idref="donate" />
    </spine>
    <guide>
        <reference type="cover" title="Cover Page" href="CoverPage.xhtml" />
        <reference type="toc" title="目錄" href="TableOfContents.xhtml" />
    </guide>
</package>
XHTML_content
		close CONTENT;
	}

	print TOCERR "<ok>!\n";
}

#-----------------------------------------------------------------------
# 印出 CoverPage.xhtml 的內容
# 這在多檔整合成一檔時不易處理....

sub print_coverpage
{

	# 1 表示單一檔案, 各經獨立處理, 0 則是全部合在同一檔, 就像 cbreacer 的 toc 合併在一個大檔.
	if($singlefile == 1)
	{
		open COVERPAGE , ">:utf8", "$outDir/${vol}/${vol}n${sutraNum}/CoverPage.xhtml" or die "open  $outDir/${vol}/${vol}n${sutraNum}/CoverPage.xhtml error";
	
		my $my_jingLabel = myOut($jingLabel);
	
print COVERPAGE << "HTML_CP";
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xml="http://www.w3.org/XML/1998/namespace" xml:lang="zh-TW">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>封面</title>
</head>
<body style="margin-top: 0;">
<div style="position:absolute; top:0; left:0; width:600px; z-index:-1;">
<img src="cover.jpg" alt="封面圖片" />
</div>
<div style="position:absolute; top:150px; left:20px; width:600px; z-index: 1;">
<h3 style="text-align: left">CBETA 電子書</h3>
<p></p>
<h1 style="text-align: left">$my_jingLabel</h1>
<h2 style="text-align: left">$author</h2>
</div>
</body>
</html>
HTML_CP

		close COVERPAGE;
	}

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
	foreach $c (@a)
	{
		if ($c ne "\n")
		{
			if (exists $utf8out{$c})
			{
				$c =  $utf8out{$c};
			}
			else
			{
				$len = length($c);
				print STDERR "Error:859 lb=$lb {$c} not in conversion table\n";
				print STDERR "length: $len\n";
				print STDERR "$s\n";
				print TOCERR "Error:859 lb=$lb {$c} not in conversion table\n";
				print TOCERR "length: $len\n";
				print TOCERR "$s\n";
				for ($i=0; $i<$len; $i++)
				{
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


sub toutf8
{

	my $in = $_[0];
	my $old;
	# encode UTF-8
	my $uc;
	if(length($in)<=2)
	{
		$patten = "n*";
	}
	else
	{
		$patten = "N*";
	}
	for $uc (unpack($patten, $in)) {
#        print "$uc\n";
	    if ($uc < 0x80) {
		# 1 byte representation
		$old .= chr($uc);
	    } elsif ($uc < 0x800) {
		# 2 byte representation
		$old .= chr(0xC0 | ($uc >> 6)) .
	                chr(0x80 | ($uc & 0x3F));
	    } elsif ($uc < 0xFFFF) {
		# 3 byte representation
		$old .= chr(0xE0 | ($uc >> 12)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			chr(0x80 | ($uc & 0x3F));
	    } else {
		# 4 byte representation
		$old .= chr(0xF0 | ($uc >> 18)) .
                chr(0x80 | (($uc >> 12) & 0x3F)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			    chr(0x80 | ($uc & 0x3F));
	    }
	}
	return $old;
}
############################################################################
# End
############################################################################