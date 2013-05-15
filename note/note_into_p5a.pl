######################################################################################
# 把卍續藏校注 XML 格式插入 XML 經文中  by heaven 2007/04/11
# 格式介紹在最底下
######################################################################################

use utf8;
use autodie;
use Encode;

######################################################################################
# 參數
######################################################################################

my $vol = shift;						# 傳入冊數 N01

my $ed = substr($vol,0,1);						# 取出 $vol 第一個英文字
my $infile = "out_" . $vol . ".txt";			# 校注來源檔, 若改成 shift , 則表示由參數傳入
my $source = "c:/cbwork/xml-p5a/${ed}/${vol}";	# 經文來源檔, 最後不要加斜線, 注意目錄之間斜線的方向必須為 /
my $outdir = $vol . "_out";						# 輸出目錄 , 也就是在輸入檔名後加上 _out 
my $errfile = "err_" . $infile;					# 錯誤檔名 , 也就是在輸入檔名前加上 err_ 

if (not -d $outdir)
{
	mkdir($outdir);
}

######################################################################################
# 變數
######################################################################################

my $key = "";
my $page = "";
my $find = "";
my %hash = ();

######################################################################################
# 主程式
######################################################################################

# 先讀入 校注檔
open IN, "<:utf8", $infile;
while(<IN>)
{
	chomp;
	if(/^<note\s.*?n="(.*?)"/)
	{
		$key = $1;
		$hash{$key} = $_;
	}
}
close IN;

my $patten =  $source . "/*.xml";
my @xmlfiles = <{$patten}>;

open ERROUT , ">:utf8", $errfile;

for($i=0; $i<=$#xmlfiles; $i++)
{
	my $infile = $xmlfiles[$i];		# c:/xxx/xxx/xxx/abc.xml
	my $file = $infile;			# abc.xml
	$file =~ s/^.*[\\\/]//;		
	my $outfile = $outdir . "/" . $file;		# c:/xxx/xxx/xxx_out/abc.xml

	print "Running $infile ...";

	# 再讀入 XML 檔, 產生有校注的 XML 檔
	open IN, "<:utf8", $infile;
	open OUT, ">:utf8", $outfile;
	while(<IN>)
	{
		chomp;
		# <lb ed="X" n="0001a03"/><head type="no">No. 1</head>
		if(/<lb.*?n="(....).*?>/)
		{
			/<lb.*?n="(....).*?>/;
			$page = $1;
		}
		
		# <lb ed="X" n="0238a04"/>云何為卑陋。何因而卑陋。云何六<anchor id="fnX01p0238a01"/>節攝。云何一闡提。
		# <lb ed="X" n="0121a24"/>場眾<anchor id="fnX04p0121a01A"/>會海<anchor id="fnX04p0121a01B"/>巳即說頌言。</p>
		# <lb ed="X" n="0121a24"/>場眾<anchor id="fnX04p0121a01A"/>會海<anchor id="fnX04p0121a01-02"/>巳即說頌言。</p>	# 這是假設的.
		# <anchor xml:id="fnN01p0001a01"/>
		while(/^.*?<anchor\s+xml:id="fn${ed}..p(....).(\d\d[a-zA-Z]?\-?[a-zA-Z]?\d*)"\/>/)
		{
			$page = $1;
			my $tmp = $2;
			my $tmp2 = $page . "0" . $tmp;
			$find = "";
			if($hash{$tmp2})
			{
				$find = $hash{$tmp2};
				$hash{$tmp2} = "";
			}
			else
			{
				$find = "<anchor xml:id=\"$tmp\" type=\"error\">";
				print ERROUT "校注檔找不到校注 [$tmp] [$tmp2] , $_\n";
			}
			
			s/^(.*?)<anchor\s+xml:id="fn${ed}..p(....).(\d\d[a-zA-Z]?\-?[a-zA-Z]?\d*)"\/>/$1$find/;
		}
		
		# 有 【科01】 或 【標01】 或 【解01】
		#<lb ed="X" n="0550a10"/>答。備悉深旨。【標02】某自驗者三。一事無逆順。隨緣即應。不
		#<lb ed="X" n="0626a07"/><div2 type="orig"><p id="pX14p0626a0701">【解01】時波斯匿王為....
		
		while(/^.*?【((?:科)|(?:標)|(?:解))(\d\d[a-zA-Z]?\-?[a-zA-Z]?\d*)】/)
		{
			my $tmp1 = $1;
			my $tmp2 = $2;
			my $tmp3 = "";
			
			if($tmp1 eq "科")
			{
				$tmp3 = $page . "k" . $tmp2;
			}
			if($tmp1 eq "標")
			{
				$tmp3 = $page . "b" . $tmp2;
			}
			if($tmp1 eq "解")
			{
				$tmp3 = $page . "j" . $tmp2;
			}
			
			$find = "";
			if($hash{$tmp3})
			{
				$find = $hash{$tmp3};
				$hash{$tmp3} = "";
			}
			else
			{
				$find = "【xx $tmp1$tmp2】";
				print ERROUT "校注檔找不到校注 【$tmp1$tmp2】 , $_\n";
			}
			
		
			s/^(.*?)【(?:(?:科)|(?:標)|(?:解))(\d\d[a-zA-Z]?\-?[a-zA-Z]?\d*)】/$1$find/;
		}
			
		print OUT "$_\n";
	}
	close IN;
	close OUT;
	
	print " ok\n";
}

# 最後把沒出現的校注列出來
print ERROUT "==============================================================================\n";
foreach $key (sort(keys(%hash)))
{
	if($hash{$key} ne "")
	{
		print ERROUT "沒用到的校注：" . $hash{$key} . "\n";
	}
}

close ERROUT;


######################################################################################
# 格式說明
######################################################################################

=begin

 來源格式

X01
p0002
  01 省略觀無量壽佛經文
p0008
  01 省略阿彌陀經文
  02 省略普賢行願品文
p0238
  01 大龍[巳>已]<resp="CBETA.maha">下一葉半餘脫
p0239
  01 ＊[差-工+目]疑若（＊印&M062446;字&M062447;本文&M062440;異&M062442;&M062475;。[○@編]）
  02 難上異有旃&SD-A47C;
p0240
  01A 冷疑作細，<o>冷細疑倒置歟
  01B 細疑作冷，<o>冷細疑倒置歟
p0245
  【科01】釋止觀義例二初所述題目
  【標01】釋止觀義例二
  【解01】釋止觀義例
p0246
  01 成上疏作化成（CBETA按：本校注在原書391頁[01]），<o>成上疏作化成
p0247
  01 例二●初所述題

輸出格式

p0002 
<note n="0002001" resp="Xuzangjing" place="foot text" type="orig">省略觀無量壽佛經文</note>
p0008
<note n="0008001" resp="Xuzangjing" place="foot text" type="orig">省略阿彌陀經文</note>
<note n="0008002" resp="Xuzangjing" place="foot text" type="orig">省略普賢行願品文</note>
p0238
<note n="0238001" resp="Xuzangjing" place="foot text" type="orig">大龍巳下一葉半餘脫</note><note n="0238001" resp="CBETA" type="mod">大龍<app><lem wit="【CBETA】" resp="CBETA.maha">已</lem><rdg wit="【卍續】">巳</rdg></app>下一葉半餘脫</note>
p0239
<note n="0239001" resp="Xuzangjing" place="foot text" type="orig">＊&CB00473;疑若（＊印&M062446;字&M062447;本文&M062440;異&M062442;&M062475;。&CB18834;）</note>
<note n="0239002" resp="Xuzangjing" place="foot text" type="orig">難上異有旃&SD-A47C;</note>
p0240
<note n="0240001A" resp="Xuzangjing" place="foot text" type="orig">冷細疑倒置歟</note><note n="0240001A" resp="CBETA" type="mod">冷疑作細</note>
<note n="0240001B" resp="Xuzangjing" place="foot text" type="orig">冷細疑倒置歟</note><note n="0240001B" resp="CBETA" type="mod">細疑作冷</note> 
p0245
<note n="0245k01" resp="Xuzangjing" place="foot text" type="orig ke">釋止觀義例二初所述題目</note>
<note n="0245b01" resp="Xuzangjing" place="foot text" type="orig biao">釋止觀義例二</note>
<note n="0245j01" resp="Xuzangjing" place="foot text" type="orig jie">釋止觀義例</note>
p0246
<note n="0246001" resp="Xuzangjing" place="foot text" type="orig">成上疏作化成</note><note n="0246001" resp="CBETA" type="mod">成上疏作化成（CBETA按：本校注在原書391頁[01]）</note>
PS. CBETA按--若校注只出現在內文或是校注欄, 再由標記人員將轉出的 xml, 改成 place="text" 或是 place="foot"。

p0247
<note n="0247001" resp="Xuzangjing" place="foot text" type="orig">例二&unrec;初所述題</note> 

=cut
