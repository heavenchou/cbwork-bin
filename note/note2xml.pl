######################################################################################
# 處理校勘, 把純文字資料變成 XML 格式  by heaven 2007/04/11
# 格式介紹在最底下
######################################################################################

use utf8;
use autodie;
use Encode;
use Win32::ODBC;

######################################################################################
# 參數
######################################################################################

my $vol = shift;						# 傳入冊數 N01

my $ed = substr($vol,0,1);				# 取出 $vol 第一個英文字
my $infile = $vol . ".txt";				# 來源檔名, N01.txt
my $outfile = "out_" . $infile;		# 輸出檔名 , 也就是在輸入檔名前加上 out_ 
my $errfile = "err_" . $infile;		# 錯誤檔名 , 也就是在輸入檔名前加上 err_ 

my $source_ename = "";				# resp="xxx" 的名稱
my $source_cname = "";				#<rdg wit="xxxx"> 的名稱
if($ed eq "N")
{
	$source_ename = "NanChuan";		# resp="xxx" 的名稱
	$source_cname = "南傳";			#<rdg wit="xxxx"> 的名稱
}
else
{
	print "Error : No this book => $ed";
	<>;
}

######################################################################################
# 變數
######################################################################################

my $page = "";		# 頁碼
my $kbj = "";		# 特殊的 "科,標,解"
my $kbj1 = "";		# 特殊的 "科,標,解" , 分別為 k , b , j , 用在 <note n="0245k01" .....
my $kbj2 = "";		# 特殊的 "科,標,解" , 分別為 ke , biao , jie , 用在 <type="orig ke">
my $notenum = "";	# 校勘號碼
my $noteABC = "";	# 校勘號碼後面的英文字, 不一定有
my $note_sub_num = "";	# 校勘號碼後面的小編號, 例如 01-01, 01-02 , ....
my $notedata = "";	# 校勘文字
my $notemod = ""; 	# 修訂後的校勘文字
my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
my $loseutf8='(?:[^\d>\[\]])';	# 不要數字,>[]
my $errlog = "";	# 放置錯誤的內容

######################################################################################
# 主程式
######################################################################################

open IN , "<:utf8", $infile;
open OUT , ">:utf8", $outfile;
readGaiji();

while(<IN>)
{
	chomp;
	next if(/^[A-Z]\d\d$/i);			# 第一行的 X01 這類不管它
	
	#p0002
	if(/^p(\d{4})/)		# 頁碼
	{
		$page = $1;
		print OUT "p" . $page . "\n";
		next;
	}
	#  01 省略觀無量壽佛經文
	if(/^\s+(\d+)([a-zA-Z]?)(\-[a-zA-Z]?\d+)?\s+(.*)$/)		# 經文資料
	{
		$notenum = $1;
		$noteABC = $2;
		$note_sub_num = $3;
		$notedata = $4;
		$kbj = "";		# 非 "科,標,解" , 乃標準模式
		$kbj1 = "";		# 特殊的 "科,標,解" , 分別為 k , b , j , 用在 <note n="0245k01" .....
		$kbj2 = "";		# 特殊的 "科,標,解" , 分別為 ke , biao , jie , 用在 <type="orig ke">
		
		$notenum = "0" . $notenum if(length($notenum) == 2);
	}
	#  【科01】釋止觀義例二初所述題目
	if(/^\s+【((?:科)|(?:標)|(?:解))(\d+)([a-zA-Z]?)(\-[a-zA-Z]?\d+)?】\s*(.*)$/)
	{
		$kbj = $1;
		$notenum = $2;
		$noteABC = $3;
		$note_sub_num = $4;
		$notedata = $5;
		
		# 處理一些因為科標解的變數
		if($kbj eq "科")
		{
			$kbj1 = "k";		# 特殊的 "科,標,解" , 分別為 k , b , j , 用在 <note n="0245k01" .....
			$kbj2 = " ke";		# 特殊的 "科,標,解" , 分別為 ke , biao , jie , 用在 <type="orig ke">
		}
		elsif($kbj eq "標")
		{
			$kbj1 = "b";		# 特殊的 "科,標,解" , 分別為 k , b , j , 用在 <note n="0245k01" .....
			$kbj2 = " biao";		# 特殊的 "科,標,解" , 分別為 ke , biao , jie , 用在 <type="orig ke">
		}
		elsif($kbj eq "解")
		{
			$kbj1 = "j";		# 特殊的 "科,標,解" , 分別為 k , b , j , 用在 <note n="0245k01" .....
			$kbj2 = " jie";		# 特殊的 "科,標,解" , 分別為 ke , biao , jie , 用在 <type="orig ke">
		}
	}
	
	$notedata = run_corr($notedata);	# 處理修訂
	$notedata = run_des($notedata);		# 處理組字式及●符號
	$notedata =~ s/<([^>]*?).gif>/<figure entity="Fig$1"\/>/g;	# <B06p0461_05.gif> 換成 <figure entity="FigB06p0461_05"/>
	
	# 檢查有沒有分成 orig 與 mod
	if($notedata =~ /^(.*)，<o>(.*)$/)
	{
		$notemod = $1;
		$notedata = $2;
	}
	else
	{
		$notemod = "";		# 無修訂的校勘
	}
	
	# 如果有 <p> 標記, 則全部轉成 </p><p> , 但第一個 </p> 要移除, 最後再加一個 </p>
	# <p,1> 要處理成 <p rend="margin-left:1em">
	
	if($notemod =~ /<p(,\d+)?>/)
	{
		$notemod =~ s/(<p(,\d+)?>)/<\/p>\1/g;
		$notemod =~ s/<\/p>//;
		$notemod .= "</p>";
		$notemod =~ s/<p,(\d+)>/<p rend="margin-left:\1em">/g;
	}
	
	if($notedata =~ /<p(,\d+)?>/)
	{
		$notedata =~ s/(<p(,\d+)?>)/<\/p>\1/g;
		$notedata =~ s/<\/p>//;
		$notedata .= "</p>";
		$notedata =~ s/<p,(\d+)>/<p rend="margin-left:\1em">/g;
	}
	
	# 印出資料
	#<note n="0008002" resp="Xuzangjing" place="foot text" type="orig">省略普賢行願品文</note>
	#<note n="0245k01" resp="Xuzangjing" place="foot text" type="orig ke">釋止觀義例二初所述題目</note>
	
	print OUT "<note n=\"${page}${kbj1}${notenum}${noteABC}${note_sub_num}\" resp=\"${source_ename}\" place=\"foot text\" type=\"orig${kbj2}\">${notedata}</note>";
	
	# 印出有 mod 的資料
	# <note n="0240001A" resp="CBETA" type="mod">冷疑作細</note>
	if($notemod)
	{
		print OUT "<note n=\"${page}${kbj1}${notenum}${noteABC}${note_sub_num}\" resp=\"CBETA\" type=\"mod${kbj2}\">${notemod}</note>";
	}
	
	print OUT "\n";
}
close IN;
close OUT;

if($errlog)
{
	open OUT , ">:utf8", $errfile;
	print OUT $errlog;
	close OUT;
}


######################################################################################
# END
######################################################################################

# 處理修訂
sub run_corr
{
	local $_ = shift;
	my $orig = $_;
	my $str1 = "";
	my $str2 = "";
	
	if(/>/)
	{
		#要先將組字式 [xxx] 換成 :!:xxx:=:
		#最後再換回來
		s/\[($loseutf8+?)\]/:!:$1:=:/g;
		
		if(/\[$loseutf8*?>$loseutf8*?\]<resp=".*?">/)
		{
			# 至此, 確定有 "修訂"
			
			if(/^(.*)，<o>(.*)/)		# 有原始的資料
			{
				$strmod = $1;
				$strorig = $2;

				$strmod =~ s/\[($loseutf8*?)>($loseutf8*?)\]<resp="(.*?)">/<app><lem wit="【CBETA】" resp="$3">$2<\/lem><rdg wit="【${source_cname}】">$1<\/rdg><\/app>/g;
			}
			else		# 無原始資料, 要自己產生
			{
				$strorig = $_;
				$strmod = $_;
				
				# 要分成二組, 第一組還原, 第二組做成 XML 格式
				
				$strorig =~ s/\[($loseutf8*?)>$loseutf8*?\]<resp=".*?">/$1/g;
				
				$strmod =~ s/\[($loseutf8*?)>($loseutf8*?)\]<resp="(.*?)">/<app><lem wit="【CBETA】" resp="$3">$2<\/lem><rdg wit="【${source_cname}】">$1<\/rdg><\/app>/g;
			}
				
			$strorig =~ s/:!:/\[/g;
			$strorig =~ s/:=:/\]/g;
			$strmod =~ s/:!:/\[/g;
			$strmod =~ s/:=:/\]/g;
				
			return "$strmod，<o>$strorig";
		}
		else
		{
			return $orig;		# 沒有修訂
		}
		s/:!:/\[/g;
		s/:=:/\]/g;
	}
	else
	{
		return $orig;		# 沒有修訂
	}
}

# 處理組字式及●符號
sub run_des
{
	local $_ = shift;
	while(/(\[$loseutf8+?\])/)
	{
		my $des = $1;
		if($des2cb{$des})
		{
			my $tmp = "&CB" . $des2cb{$des} . ";";
			s/\Q$des\E/$tmp/g;
		}
		else
		{
			$errlog = $errlog . "錯誤, $des 無法換成 CB 碼\n";
			last;
		}
	}
	
	s/●/&unrec;/g;
	
	return $_;
}

# 讀入缺字資料庫
sub readGaiji {
	my $cb,$des;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = Encode::decode("big5", $row{"cb"});		# cbeta code
		$des     = Encode::decode("big5", $row{"des"});		# 組字式
		next if ($cb !~ /^\d/);
		# 處理特殊的 unicode
		$des =~ s/〸/十/g;	# 其實這個十不太可能發生, 除非 big5 的 "十" 使用 B+A2CC , 正確的 "十" 是使用 B+A451
		$des =~ s/〹/卄/g;	# 卄 的 Big5 是 B+A2CD , 應該要轉成 U+5344 , 但 Perl 會轉成 U+3039 , 所以要處理
		$des =~ s/〺/卅/g;	# 其實這個卅不太可能發生, 除非 big5 的 "卅" 使用 B+A2CE , 正確的 "卅" 是使用 B+A4CA
		$des =~ s/彞/彝/g;	# 彝 的 Big5 是 B+C255 , 應該要轉成 U+5F5D , 但 Perl 會轉成 U+5F5E , 所以要處理
		
		$des2cb{$des} = $cb;
	}
	$db->Close();
	print STDERR "ok\n";
}

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
