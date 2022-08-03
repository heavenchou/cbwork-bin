
# 別的程式要呼叫本程式, 可以先用 use lib "/cbwork/bin"; 來指定本程式的目錄

package Gaiji;
use utf8;
use Carp;
#use Win32::ODBC;
use Encode;
use Config::IniFiles;

=BEGIN

缺字物件的說明

宣告 :  
	use CBETA;
	$gaiji = new Gaiji();

使用法 :

cb	mojikyo	entity	uni_flag	unicode	uni		des						nor	cx	nor_uni
00001	M016085	M016085	1		6B35	6B35	[肄-聿+欠]				款
00006	M021123	M021123	0		249B2	249B2	[(王*巨)/木]			璩
00009	M072742	CB0009	0		21EB2			[阿-可+(山/(峻-山))]	峻		𡺲

#載入 MS Access 資料庫 gaiji-m.mdb
$gaiji->load_access_db();
#設定資料
$gaiji->cb2des("00001", "[肄-聿+欠]");
#取得資料
$data = $gaiji->cb2des("00001");

$gaiji->cb2des();			# 由 cb 碼找組字式.                 ex. $gaiji->cb2des("00001") => [肄-聿+欠]
$gaiji->cb2nor();			# 由 cb 碼找通用字 , 沒有則傳回 "". ex. $gaiji->cb2nor("00001") => 款
$gaiji->cb2uni();			# 由 cb 碼找 unicode , 沒有則傳回 "". ex. $gaiji->cb2uni("00001") => 6B35
$gaiji->cb2uniword();		# 由 cb 碼找 uni word , 沒有則傳回 "". ex. $gaiji->cb2uniword("00001") => 欵
$gaiji->cb2noruni();		# 由 cb 碼找 nor unicode , 沒有則傳回 "". ex. $gaiji->cb2noruni("00009") => 21EB2
$gaiji->cb2noruniword();	# 由 cb 碼找 nor uni word , 沒有則傳回 "". ex. $gaiji->cb2noruniword("00009") => 𡺲
$gaiji->des2cb();			# 由組字式找 cb 碼.                        ex. $gaiji->des2cb("[肄-聿+欠]") => "00001"
$gaiji->uni2cb();			# 由 unicode 找 cb 碼.                     ex. $gaiji->uni2cb("6B35") => "00001"

# 取得某 unicode 的版本, 傳回值有 1.0 , 3.0 , 3.1 .... , 若傳回 "" 則錯誤.
$gaiji->get_unicode_ver("4000");
Gaiji::get_unicode_ver("4000");

註: perl 處理 big5 與 utf8 互轉主要的問題:
1. 彝(B+C255) 用 perl 轉成 utf8 會有錯誤轉成 彞(U+5F5E), 要換回 彝(U+5F5D)
2. 彝(U+5F5D) 用 perl 轉成 big5 會錯誤, 要自行處理成 彝(B+C255) .
3. 卄(B+A2CD) 用 perl 轉成 utf8 會有錯誤轉成 〹(U+3039), 要換回 卄(U+5344)
4. 卄(U+5344) 用 perl 轉成 big5 會錯誤, 要自行處理成 卄(B+A2CD)

因此由 big5 讀入的資料第一時間就要先做如下轉換:

		s/彞/彝/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		s/〹/卄/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理

=END
=cut

my %field = (
	cb2des => undef,
	cb2nor => undef,
	cb2uni => undef,
	cb2uniword => undef,
	cb2noruni => undef,
	cb2noruniword => undef,
	des2cb => undef,
	uni2cb => undef,
);

# 建構式
sub new 
{
	my $type = shift;
	my $class = ref($type) || $type;

	my $self = {
        %field,
	};
	bless $self, $class;
	
	#$self->_initialize();	#初值化, 讀入資料庫
	
	return $self;
}

# 解構式
sub DESTROY {
	my $self = shift;
	#printf("$self dying at %s\n", scalar localtime);
}

# 自動載入, 若呼叫該物件沒有定義的函數, 則執行本函數, 底下是用來讀取及設定成員變數
sub AUTOLOAD
{
	my $self = shift;
	my $para = shift;
	my $data = shift;
	
	my $type = ref($self) || croak "$self is not an object";
	
	my $name = $AUTOLOAD;
	$name =~ s/.*:://;
	
	# 若傳入的方法不是成員變數就離開
	croak "No such attribute: $name" unless exists $self->{$name};
	
	# 若傳入一個參數 $para , 則傳回此參數的內容 $self->{$name}{$para}
	# 若傳入二個參數 $para, $data 則設定雜湊  $self->{$name}{$para} = $data
	
	# 若無第一個參數, 那就錯了, 不過因為曾用 $gaiji->cb2nor($gaiji->des2cb($1)) , 所以可能 $para 也是 "" , 就不 exit , 改成傳回 ""
	
	#croak "No parameter" unless $para;
	return "" unless $para;
	
	$self->{$name}{$para} = $data if($data);
	return $self->{$name}{$para};
  }

# 一般的成員函數
# 讀入資料庫
sub load_access_db
{
	my $self = shift;

	my $cfg = Config::IniFiles->new( -file => "/cbwork/bin/cbwork_bin.ini" );
	my $gaiji_file = $cfg->val('default', 'gaiji-m.mdb_file', '');
	$gaiji_file =~ s/gaiji\-m\.mdb/gaiji-m_u8.txt/;

	my $cb;
	my $des;
	my $nor;
	my $uni;
	my $uniword;
	my $noruni;
	my $noruniword;
	my $err = 0;

	open IN, "<:utf8", $gaiji_file || die "open $gaiji_file fail!";
	print "read gaiji ... ";
	while(<IN>)
	{
		# cb	mojikyo	entity	uni_flag	unicode	nor_unicode	des	nor	cx
		# 00001	M016085	M016085	1	6B35		[肄-聿+欠]	款
		# 00042	M001494	M001494	1		517E	[八/異]	冀	
		my @gaiji = split(/\t/,$_);

		$cb      = $gaiji[0];		# cbeta code
		$des     = $gaiji[6];		# 組字式
		$nor     = $gaiji[7];		# 通用字
		$uni     = $gaiji[4];		# unicode 字碼
		$noruni  = $gaiji[5];		# 通用 unicode 字碼
		
		next if ($cb !~ /^\d/);		# 先過濾掉羅馬轉寫字及非標準的缺字

		#1. 彝(B+C255) 用 perl 轉成 utf8 會有錯誤轉成 彞(U+5F5E), 要換回 彝(U+5F5D)
		#2. 彝(U+5F5D) 用 perl 轉成 big5 會錯誤, 要自行處理成 彝(B+C255) .
		#3. 卄(B+A2CD) 用 perl 轉成 utf8 會有錯誤轉成 〹(U+3039), 要換回 卄(U+5344)
		#4. 卄(U+5344) 用 perl 轉成 big5 會錯誤, 要自行處理成 卄(B+A2CD)

		#$des =~ s/彞/彝/g;
		#$nor =~ s/彞/彝/;
		
		#$des =~ s/〹/卄/g;
		#$nor =~ s/〹/卄/;

		$self->{"cb2des"}{$cb} = $des;
		$self->{"des2cb"}{$des} = $cb;
		$self->{"cb2nor"}{$cb} = $nor if($nor);
		if($uni)
		{
			$self->{"cb2uni"}{$cb} = $uni;
			$self->{"uni2cb"}{$uni} = $cb;
			$self->{"cb2uniword"}{$cb} = chr(hex($uni));
			if(not $self->get_unicode_ver($uni))
			{
				print "\nerror : unicode out of version! => cb: $cb , uni: $uni.";
				$err = 1;
			}
		}
		if($noruni and $uni eq "")
		{
			$self->{"cb2noruni"}{$cb} = $noruni;
			$self->{"cb2noruniword"}{$cb} = chr(hex($noruni));
			if(not $self->get_unicode_ver($noruni))
			{
				print "\nerror : unicode out of version! => cb: $cb , nor_uni: $noruni.";
				$err = 1;
			}
		}
	}
	
	if($err)
	{
		print "\n\nError : please call 'Heaven Chou' to add Unicode version.\n";
		exit;
	}
	else
	{
		print "ok\n";
	}
}

# 這是用 Access 的版本, 已經取消了, 用 csv 的版本比較快
# 一般的成員函數
# 讀入資料庫
sub load_access_db_old
{
	my $self = shift;
	my $cb;
	my $des;
	my $nor;
	my $uni;
	my $uniword;
	my $noruni;
	my $noruniword;
	my $err = 0;
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	print "read gaiji ... ";
	while($db->FetchRow()){
		my %row = ();
		%row = $db->DataHash();
		
		$cb      = Encode::decode("big5", $row{"cb"});		# cbeta code
		$des     = Encode::decode("big5", $row{"des"});		# 組字式
		$nor     = Encode::decode("big5", $row{"nor"});		# 通用字
		$uni     = Encode::decode("big5", $row{"unicode"});	# unicode 字碼
		$noruni  = Encode::decode("big5", $row{"uni"});		# 通用 unicode 字碼
		
		next if ($cb !~ /^\d/);		# 先過濾掉羅馬轉寫字及非標準的缺字

		#1. 彝(B+C255) 用 perl 轉成 utf8 會有錯誤轉成 彞(U+5F5E), 要換回 彝(U+5F5D)
		#2. 彝(U+5F5D) 用 perl 轉成 big5 會錯誤, 要自行處理成 彝(B+C255) .
		#3. 卄(B+A2CD) 用 perl 轉成 utf8 會有錯誤轉成 〹(U+3039), 要換回 卄(U+5344)
		#4. 卄(U+5344) 用 perl 轉成 big5 會錯誤, 要自行處理成 卄(B+A2CD)

		$des =~ s/彞/彝/g;
		$nor =~ s/彞/彝/;
		
		$des =~ s/〹/卄/g;
		$nor =~ s/〹/卄/;

		$self->{"cb2des"}{$cb} = $des;
		$self->{"des2cb"}{$des} = $cb;
		$self->{"cb2nor"}{$cb} = $nor if($nor);
		if($uni)
		{
			$self->{"cb2uni"}{$cb} = $uni;
			$self->{"uni2cb"}{$uni} = $cb;
			$self->{"cb2uniword"}{$cb} = chr(hex($uni));
			if(not $self->get_unicode_ver($uni))
			{
				print "\nerror : unicode out of version! => cb: $cb , uni: $uni.";
				$err = 1;
			}
		}
		if($noruni and $uni eq "")
		{
			$self->{"cb2noruni"}{$cb} = $noruni;
			$self->{"cb2noruniword"}{$cb} = chr(hex($noruni));
			if(not $self->get_unicode_ver($noruni))
			{
				print "\nerror : unicode out of version! => cb: $cb , nor_uni: $noruni.";
				$err = 1;
			}
		}
	}
	$db->Close();
	if($err)
	{
		print "\n\nError : please call 'Heaven Chou' to add Unicode version.\n";
		exit;
	}
	else
	{
		print "ok\n";
	}
}

=BEGIN
# 取得某 unicode 的版本
# 此處列出每一個字的版本 http://zh.wikibooks.org/wiki/Unicode 
# 各區段的文字, Unicode字元平面對映 http://zh.wikipedia.org/wiki/Unicode%E5%AD%97%E7%AC%A6%E5%B9%B3%E9%9D%A2%E6%98%A0%E5%B0%84
# 官方表格 http://unicode.org/charts/
# 左方有一些各版本的字 http://www.unicode.org/charts/About.html
# ray 提供 Unicode 1.1 的字 http://www.unicode.org/Public/1.1-Update/UnicodeData-1.1.5.txt

#各版本年份 http://zh.wikipedia.org/wiki/Unicode

Unicode 1.0：1991年10月
Unicode 1.0.1：1992年6月
Unicode 1.1：1993年6月
Unicode 2.0：1997年7月
Unicode 2.1：1998年5月
Unicode 2.1.2：1998年5月
Unicode 3.0：1999年9月；涵蓋了來自ISO 10646-1的十六位元通用字元集（UCS）基本多文種平面（Basic Multilingual Plane）
Unicode 3.1：2001年3月；新增從ISO 10646-2定義的輔助平面（Supplementary Planes）
Unicode 3.2：2002年3月
Unicode 4.0：2003年4月
Unicode 4.0.1：2004年3月
Unicode 4.1：2005年3月
Unicode 5.0：2006年7月
Unicode 5.1：2008年4月
Unicode 5.2：2009年10月
Unicode 6.0：2010年10月
Unicode 6.1：2012年1月31日
Unicode 6.2：2012年9月
Unicode 6.3：2013年9月30日
Unicode 7.0：2014年6月
Unicode 8.0：2015年6月
Unicode 9.0：2016年6月
Unicode 10.0：2017年6月
Unicode 11.0：2018年6月
Unicode 12.0：2019年3月
Unicode 12.1：2019年5月 https://www.unicode.org/versions/Unicode12.1.0/
Unicode 13.0：2020年3月10日 https://www.unicode.org/versions/Unicode13.0.0/
Unicode 14.0：2021年9月14日 https://www.unicode.org/versions/Unicode14.0.0/

# 底下用這符號■開頭的是來自 http://ubuntu-rubyonrails.blogspot.tw/2009/06/unicode.html
# 詳細資料


#0000～017E： (Unicode 1.0)
#017F： (Unicode 1.1)
#0180～01F0： (Unicode 1.0)
#01F1～01F5： (Unicode 1.1)
#01F6～01F9： (Unicode 3.0)
#01FA～0217： (Unicode 1.1)
#0218～021F： (Unicode 3.0)
#0220： (Unicode 3.2)
#0221： (Unicode 4.0)
#0222～0233： (Unicode 3.0)
#0234～0236： (Unicode 4.0)
#0237～0241： (Unicode 4.1)
#0242～024F： (Unicode 5.0)
#0250～02A8： (Unicode 1.0)
#02A9～02AD： (Unicode 3.0)
#02AE～02AF： (Unicode 4.0)
#02B0～02DE： (Unicode 1.0)
#02DF： (Unicode 3.0)
#02E0～02E9： (Unicode 1.0)
#02EA～02EE： (Unicode 3.0)
#02EF～02FF： (Unicode 4.0)
#0300～0341： (Unicode 1.0)
#....
#0401～040C： (Unicode 1.0)
#040D： (Unicode 3.0)
#040E～044F： (Unicode 1.0)
#....
#1E00～1E9A： (Unicode 1.1)
#1E9B： (Unicode 2.0)
#1E9C～1E9F： (Unicode 5.1)
#1EA0～1EF9： (Unicode 1.1)
#1EFA～1EFF： (Unicode 5.1)
# https://en.wikibooks.org/wiki/Unicode/Character_reference/2000-2FFF
#2000～202E： (Unicode 1.0)
#2045～2046： (Unicode 1.1)
#2047： (Unicode 3.2)
#2048～204F： (Unicode 3.0)
#...
#2100～2138： (Unicode 1.0)
#2153～2182： (Unicode 1.0)
#2190～21EA： (Unicode 1.0)
#2200～22F1： (Unicode 1.0)
#....
#2460～24EA：Enclosed Alphanumerics 括號及圓圈各種數字英文 (Unicode 1.0)
#24EB～24FE：Enclosed Alphanumerics 括號及圓圈各種數字英文 (Unicode 3.2)
#24FF： (Unicode 4.0)
#2500～2595： (Unicode 1.0)
#2596～259F： (Unicode 3.2)
#25A0～25EE： (Unicode 1.0)
#25EF： (Unicode 1.1)
#2600～2613： (Unicode 1.0)
#261A～266F： (Unicode 1.0)
■2E80～33FFh：中日韓符號區。收容康熙字典部首、中日韓輔助部首、注音符號、日本假名、韓文音符，中日韓的符號、標點、帶圈或帶括符文數字、月份，以及日本的假名組合、單位、年號、月份、日期、時間等。
#2E80～2EF3：CJK Radicals Supplement 部首補充 (128 字, Unicode 3.0 , 1999)
#2F00～2FD5：CJK Radicals / KangXi Radicals 部首 / 康熙字典部首 (224 字, Unicode 3.0 , 1999)
#2FF0～2FFB：Ideographic Description Characters 表意文字描述字符 (中研院的組字符號, Unicode 3.0 , 1999)
#3000～3036：CJK Symbols and Punctuation 符號和標點符號 (Unicode 1.0)
#3037：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 1.1 , 1993)
#3038～303A：CJK Symbols and Punctuation 符號和標點符號 (3 字, Unicode 3.0 , 1999)
#303B～303D：CJK Symbols and Punctuation 符號和標點符號 (3 字, Unicode 3.2 , 2002)
#303E：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 3.0 , 1999)
#303F：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 1.0)
#3041～3094：Hiragana 日文平假名 (Unicode 1.0)
#3095～3096：Hiragana 日文平假名 (Unicode 3.2)
#3099～309E：Hiragana 日文平假名 (Unicode 1.0)
#309F：Hiragana 日文平假名 (Unicode 3.2)
#30A0：Katakana 日文片假名 (Unicode 3.2)
#30A1～30F6：Katakana 日文片假名 (Unicode 1.0)
#30F7～30FA：Katakana 日文片假名 (Unicode 1.1)
#30FB～30FE：Katakana 日文片假名 (Unicode 1.0)
#30FF：Katakana 日文片假名 (Unicode 3.2)
#3105～312C：Bopomofo 注音符號 (Unicode 1.0)
#312D：Bopomofo 上下顛倒的 'ㄓ' (Unicode 5.1)
#3131～318E：Hangul Compatibility Jamo 韓文 (Unicode 1.0)
#3190～319F：Kanbun 在上方的小漢字 (Unicode 1.0)
#31A0～31B7：Bopomofo Extended 注音擴展 (Unicode 3.0)
#31B8～31BA：Bopomofo Extended 注音擴展 (Unicode 6.0)
#31C0～31CF：CJK Strokes 筆劃 (基本筆劃, 如撇, 勾, 點...) (Unicode 4.1)
#31D0～31E3：CJK Strokes 筆劃 (基本筆劃, 如撇, 勾, 點...) (Unicode 5.1)
#31F0～31FF：Katakana Phonetic Extensions 日文片假名語音擴展 (Unicode 3.2)
#3200～321C：Enclosed CJK Letters and Months 括號韓文 (Unicode 1.0)
#321D～321E：Enclosed CJK Letters and Months 括號韓文 (Unicode 4.0)
#3220～3243：Enclosed CJK Letters and Months 括號一~十及漢字 (Unicode 1.0)
#3244～324F：Enclosed CJK Letters and Months 圓圈中有字及10~80 (Unicode 5.2)
#3250：Enclosed CJK Letters and Months 'PTE' 組成一字 (Unicode 4.0)
#3251～325F：Enclosed CJK Letters and Months 圓圈 21~35 (Unicode 3.2)
#3260～327B：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 1.0)
#327C～327D：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 4.0)
#327E：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 4.1)
#327F～32B0：Enclosed CJK Letters and Months 圓圈一~十及漢字 (Unicode 1.0)
#32B1～32BF：Enclosed CJK Letters and Months 圓圈 36~50 (Unicode 3.2)
#32C0～32CB：Enclosed CJK Letters and Months 1月~12月 (Unicode 1.1)
#32CC～32CF：Enclosed CJK Letters and Months 多英文組成一個字 (Unicode 4.0)
#32D0～32FE：Enclosed CJK Letters and Months 圓圈日文 (Unicode 1.0)
#3300～3357：CJK Compatibility 多個日文組成一字 (Unicode 1.0)
#3358～3376：CJK Compatibility 0点~24点 及多英文組成一字 (Unicode 1.1)
#3377～337A：CJK Compatibility 多英文組成一字 (Unicode 4.0)
#337B～33DD：CJK Compatibility 多日本漢字及多英文組成一字 (Unicode 1.0)
#33DE～33DF：CJK Compatibility 多英文組成一字 (Unicode 4.0)
#33E0～33FE：CJK Compatibility 1日~31日 (Unicode 1.1)
#33FF：CJK Compatibility 'gal' 組成一字 (Unicode 4.0)

■3400～4DBF：中日韓認同表意文字擴充A區，總計收容6,592個中日韓漢字。
#3400～4DB5：CJK Extension A 中日韓統一表意文字擴充 A 區。(6582 字, Unicode 3.0 , 1999)
#4DB6～4DBF：CJK Extension A 中日韓統一表意文字擴充 A 區。(10 字, Unicode 13.0 , 2020)

#4DC0～4DFF：易經六十四卦符號。(64 字, Unicode 4.0)

■4E00～9FFF：中日韓認同表意文字區，總計收容20,992個中日韓漢字。
#4E00～9FA5：CJK Unified Ideographs (Han) 中日韓統一表意文字區。(20,902 字, Unicode 1.1 , 1993)
#9FA6～9FBB：14 個香港增補字符集的用字和 8 個 GB 18030 用字 (22 字, Unicode 4.1 , 2005)
#9FBC～9FC3：7 個日語漢字及 U+9FC3 (8 字, Unicode 5.1 , 2008)
#9FC4～9FCB：2 個日語用漢字, 1 個新增漢字, 5 個香港漢字 (8 字, Unicode 5.2 , 2009)
#9FCC：1 個漢字 (1 字, Unicode 6.1 , 2012)
#9FCD～9FD5：(9 字, Unicode 8.0 , 2015)
#9FD6～9FEA：(21 字, Unicode 10.0 , 2017)
#9FEB～9FEF：(5 字, Unicode 11.0 , 2018)
#9FF0～9FFC：(13 字, Unicode 13.0 , 2020)
#9FFD～9FFF：(3 字, Unicode 14.0 , 2021)

■A000～A4FF：彝族文字區，收容中國南方彝族文字和字根。
#A000～A48C：Yi Syllables 彝族文字區 (Unicode 3.0)
■AC00～D7FF：韓文拼音組合字區，收容以韓文音符拼成的文字。
#AC00～D7A3：Hangul Syllables 韓文拼音 (Unicode 2.0)
■E000～F8FF：私人造字區

■F900～FAD9：中日韓兼容表意文字區，總計收容472個中日韓漢字。
#F900～FA2D：CJK Compatibility Ideographs 相容表意字 (302 字, Unicode 1.1 , 1993)
#FA2E～FA2F：CJK Compatibility Ideographs 相容表意字 (2 字, Unicode 6.1)
#FA30～FA6A：CJK Compatibility Ideographs 相容表意字 (59 字, Unicode 3.2)
#FA6B～FA6D：CJK Compatibility Ideographs 相容表意字 (3 字, Unicode 5.2)
#FA70～FAD9：CJK Compatibility Ideographs 相容表意字 - 106個來自北韓的相容漢字 (106 字, Unicode 4.1 , 2005)

■FB00～FFFDh：文字表現形式區，收容組合拉丁文字、希伯來文、阿拉伯文、中日韓直式標點、小符號、半角符號、全角符號等。 
#FE10～FE19：Vertical Forms 中文直排標點 (Unicode 4.1)
#FE20～FE23：Combining Half Marks (Unicode 1.1)
#FE24～FE26：Combining Half Marks (Unicode 5.1)
#FE30～FE44：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 1.0)
#FE45～FE46：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 3.2)
#FE47～FE48：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 4.0)
#FE49～FE4F：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 1.0)
#FE50～FE52：Small Form Variants (Unicode 1.0)
#FE54～FE66：Small Form Variants (Unicode 1.0)
#FE68～FE6B：Small Form Variants (Unicode 1.0)
#FF01～FF5E：Halfwidth and Fullwidth Forms (Unicode 1.0)
#FF5F～FF60：Halfwidth and Fullwidth Forms (Unicode 3.2)
#FF61～FF9F：Halfwidth and Fullwidth Forms (Unicode 1.0)
■
#1F100～1F1FF：Enclosed Alphanumeric Supplement 括號及圓圈各種數字英文補充
■
#20000～2A6D6：CJK Unified Ideographs Extension B 中日韓統一表意文字擴展 B 區 (42711 字, Unicode 3.1 , 2001)
#2A6D7～2A6DD：CJK Unified Ideographs Extension B 中日韓統一表意文字擴展 B 區 (7 字, Unicode 13.0 , 2020)
#2A6DE～2A6DF：CJK Unified Ideographs Extension B 中日韓統一表意文字擴展 B 區 (2 字, Unicode 14.0 , 2021)

#2A700～2B734：CJK Unified Ideographs Extension C 中日韓統一表意文字擴展 C 區 (4149 字, Unicode 5.2 , 2009)
#2B735～2B738：CJK Unified Ideographs Extension C 中日韓統一表意文字擴展 C 區 (4 字, Unicode 14.0 , 2021)

#2B740～2B81D：CJK Unified Ideographs Extension D 中日韓統一表意文字擴展 D 區 (222 字, Unicode 6.0 , 2010)

#2B820～2CEA1：CJK Unified Ideographs Extension E 中日韓統一表意文字擴展 E 區 (5762 字, Unicode 8.0 , 2015)

#2CEB0～2EBE0：CJK Unified Ideographs Extension F 中日韓統一表意文字擴展 F 區 (7473 字, Unicode 10.0 , 2017)

#2F800～2FA1D：CJK Compatibility Ideographs Supplement 相容表意字補充 - 台灣的相容漢字 (542 字, Unicode 3.1 , 2001)

#30000～3134A：CJK Unified Ideographs Extension G 中日韓統一表意文字擴展 G 區 (4939 字, Unicode 13.0 , 2020)
  
=cut

sub get_unicode_ver
{
	my $self = shift;
	my $uni = uc(shift);
	
	# 若第一個傳入的不是物件參考, 則第一個參數就是程式需要的 unicode
	if(not ref($self))
	{
		$uni = uc($self);
	}
	$uni = hex($uni);
	
	# 底下程式碼來自 \cbwork\UnicodeCharVer\
	# 也就是 https://github.com/heavenchou/UnicodeCharVer
	# 有詳細完整的來源

    # 常用的先放前面
    return "1.1" if($uni >= 0x4E00 and $uni <= 0x9FA5);
	# 符號和標點符號
    return "1.1" if($uni >= 0x3000 and $uni <= 0x3037);
    return "1.1" if($uni <= 0x01F5);
    return "3.0" if($uni >= 0x3400 and $uni <= 0x4DB5);
    return "13.0" if($uni >= 0x4DB6 and $uni <= 0x4DBF);
    return "3.1" if($uni >= 0x20000 and $uni <= 0x2A6D6);
	# 相容表意字補充 - 台灣的相容漢字
	return "3.1" if($uni >= 0x2F800 and $uni <= 0x2FA1D);
	return "5.2" if($uni >= 0x2A700 and $uni <= 0x2B734);
	return "6.0" if($uni >= 0x2B740 and $uni <= 0x2B81D);
	return "8.0" if($uni >= 0x2B820 and $uni <= 0x2CEA1);
	return "10.0" if($uni >= 0x2CEB0 and $uni <= 0x2EBE0);
    
	return "1.1" if($uni >= 0x0000 and $uni <= 0x01F5);
	return "3.0" if($uni >= 0x01F6 and $uni <= 0x01F9);
	return "1.1" if($uni >= 0x01FA and $uni <= 0x0217);
	return "3.0" if($uni >= 0x0218 and $uni <= 0x021F);
	return "3.2" if($uni == 0x0220);
	return "4.0" if($uni == 0x0221);
	return "3.0" if($uni >= 0x0222 and $uni <= 0x0233);
	return "4.0" if($uni >= 0x0234 and $uni <= 0x0236);
	return "4.1" if($uni >= 0x0237 and $uni <= 0x0241);
	return "5.0" if($uni >= 0x0242 and $uni <= 0x024F);
	return "1.1" if($uni >= 0x0250 and $uni <= 0x02A8);
	return "3.0" if($uni >= 0x02A9 and $uni <= 0x02AD);
	return "4.0" if($uni >= 0x02AE and $uni <= 0x02AF);
	return "1.1" if($uni >= 0x02B0 and $uni <= 0x02DE);
	return "3.0" if($uni == 0x02DF);
	return "1.1" if($uni >= 0x02E0 and $uni <= 0x02E9);
	return "3.0" if($uni >= 0x02EA and $uni <= 0x02EE);
	return "4.0" if($uni >= 0x02EF and $uni <= 0x02FF);
	return "1.1" if($uni >= 0x0300 and $uni <= 0x0345);
	return "3.0" if($uni >= 0x0346 and $uni <= 0x034E);
	return "3.2" if($uni == 0x034F);
	return "4.0" if($uni >= 0x0350 and $uni <= 0x0357);
	return "4.1" if($uni >= 0x0358 and $uni <= 0x035C);
	return "4.0" if($uni >= 0x035D and $uni <= 0x035F);
	return "1.1" if($uni >= 0x0360 and $uni <= 0x0361);
	return "3.0" if($uni == 0x0362);
	return "3.2" if($uni >= 0x0363 and $uni <= 0x036F);
	return "5.1" if($uni >= 0x0370 and $uni <= 0x0373);
	return "1.1" if($uni >= 0x0374 and $uni <= 0x0375);
	return "5.1" if($uni >= 0x0376 and $uni <= 0x0377);
	return "1.1" if($uni == 0x037A);
	return "5.0" if($uni >= 0x037B and $uni <= 0x037D);
	return "1.1" if($uni == 0x037E);
	return "7.0" if($uni == 0x037F);
	return "1.1" if($uni >= 0x0384 and $uni <= 0x038A);
	return "1.1" if($uni == 0x038C);
	return "1.1" if($uni >= 0x038E and $uni <= 0x03A1);
	return "1.1" if($uni >= 0x03A3 and $uni <= 0x03CE);
	return "5.1" if($uni == 0x03CF);
	return "1.1" if($uni >= 0x03D0 and $uni <= 0x03D6);
	return "3.0" if($uni == 0x03D7);
	return "3.2" if($uni >= 0x03D8 and $uni <= 0x03D9);
	return "1.1" if($uni == 0x03DA);
	return "3.0" if($uni == 0x03DB);
	return "1.1" if($uni == 0x03DC);
	return "3.0" if($uni == 0x03DD);
	return "1.1" if($uni == 0x03DE);
	return "3.0" if($uni == 0x03DF);
	return "1.1" if($uni == 0x03E0);
	return "3.0" if($uni == 0x03E1);
	return "1.1" if($uni >= 0x03E2 and $uni <= 0x03F3);
	return "3.1" if($uni >= 0x03F4 and $uni <= 0x03F5);
	return "3.2" if($uni == 0x03F6);
	return "4.0" if($uni >= 0x03F7 and $uni <= 0x03FB);
	return "4.1" if($uni >= 0x03FC and $uni <= 0x03FF);
	return "3.0" if($uni == 0x0400);
	return "1.1" if($uni >= 0x0401 and $uni <= 0x040C);
	return "3.0" if($uni == 0x040D);
	return "1.1" if($uni >= 0x040E and $uni <= 0x044F);
	return "3.0" if($uni == 0x0450);
	return "1.1" if($uni >= 0x0451 and $uni <= 0x045C);
	return "3.0" if($uni == 0x045D);
	return "1.1" if($uni >= 0x045E and $uni <= 0x0486);
	return "5.1" if($uni == 0x0487);
	return "3.0" if($uni >= 0x0488 and $uni <= 0x0489);
	return "3.2" if($uni >= 0x048A and $uni <= 0x048B);
	return "3.0" if($uni >= 0x048C and $uni <= 0x048F);
	return "1.1" if($uni >= 0x0490 and $uni <= 0x04C4);
	return "3.2" if($uni >= 0x04C5 and $uni <= 0x04C6);
	return "1.1" if($uni >= 0x04C7 and $uni <= 0x04C8);
	return "3.2" if($uni >= 0x04C9 and $uni <= 0x04CA);
	return "1.1" if($uni >= 0x04CB and $uni <= 0x04CC);
	return "3.2" if($uni >= 0x04CD and $uni <= 0x04CE);
	return "5.0" if($uni == 0x04CF);
	return "1.1" if($uni >= 0x04D0 and $uni <= 0x04EB);
	return "3.0" if($uni >= 0x04EC and $uni <= 0x04ED);
	return "1.1" if($uni >= 0x04EE and $uni <= 0x04F5);
	return "4.1" if($uni >= 0x04F6 and $uni <= 0x04F7);
	return "1.1" if($uni >= 0x04F8 and $uni <= 0x04F9);
	return "5.0" if($uni >= 0x04FA and $uni <= 0x04FF);
	return "3.2" if($uni >= 0x0500 and $uni <= 0x050F);
	return "5.0" if($uni >= 0x0510 and $uni <= 0x0513);
	return "5.1" if($uni >= 0x0514 and $uni <= 0x0523);
	return "5.2" if($uni >= 0x0524 and $uni <= 0x0525);
	return "6.0" if($uni >= 0x0526 and $uni <= 0x0527);
	return "7.0" if($uni >= 0x0528 and $uni <= 0x052F);
	return "1.1" if($uni >= 0x0531 and $uni <= 0x0556);
	return "1.1" if($uni >= 0x0559 and $uni <= 0x055F);
	return "11.0" if($uni == 0x0560);
	return "1.1" if($uni >= 0x0561 and $uni <= 0x0587);
	return "11.0" if($uni == 0x0588);
	return "1.1" if($uni == 0x0589);
	return "3.0" if($uni == 0x058A);
	return "7.0" if($uni >= 0x058D and $uni <= 0x058E);
	return "6.1" if($uni == 0x058F);
	return "2.0" if($uni >= 0x0591 and $uni <= 0x05A1);
	return "4.1" if($uni == 0x05A2);
	return "2.0" if($uni >= 0x05A3 and $uni <= 0x05AF);
	return "1.1" if($uni >= 0x05B0 and $uni <= 0x05B9);
	return "5.0" if($uni == 0x05BA);
	return "1.1" if($uni >= 0x05BB and $uni <= 0x05C3);
	return "2.0" if($uni == 0x05C4);
	return "4.1" if($uni >= 0x05C5 and $uni <= 0x05C7);
	return "1.1" if($uni >= 0x05D0 and $uni <= 0x05EA);
	return "11.0" if($uni == 0x05EF);
	return "1.1" if($uni >= 0x05F0 and $uni <= 0x05F4);
	return "4.0" if($uni >= 0x0600 and $uni <= 0x0603);
	return "6.1" if($uni == 0x0604);
	return "7.0" if($uni == 0x0605);
	return "5.1" if($uni >= 0x0606 and $uni <= 0x060A);
	return "4.1" if($uni == 0x060B);
	return "1.1" if($uni == 0x060C);
	return "4.0" if($uni >= 0x060D and $uni <= 0x0615);
	return "5.1" if($uni >= 0x0616 and $uni <= 0x061A);
	return "1.1" if($uni == 0x061B);
	return "6.3" if($uni == 0x061C);
	return "4.1" if($uni == 0x061E);
	return "1.1" if($uni == 0x061F);
	return "6.0" if($uni == 0x0620);
	return "1.1" if($uni >= 0x0621 and $uni <= 0x063A);
	return "5.1" if($uni >= 0x063B and $uni <= 0x063F);
	return "1.1" if($uni >= 0x0640 and $uni <= 0x0652);
	return "3.0" if($uni >= 0x0653 and $uni <= 0x0655);
	return "4.0" if($uni >= 0x0656 and $uni <= 0x0658);
	return "4.1" if($uni >= 0x0659 and $uni <= 0x065E);
	return "6.0" if($uni == 0x065F);
	return "1.1" if($uni >= 0x0660 and $uni <= 0x066D);
	return "3.2" if($uni >= 0x066E and $uni <= 0x066F);
	return "1.1" if($uni >= 0x0670 and $uni <= 0x06B7);
	return "3.0" if($uni >= 0x06B8 and $uni <= 0x06B9);
	return "1.1" if($uni >= 0x06BA and $uni <= 0x06BE);
	return "3.0" if($uni == 0x06BF);
	return "1.1" if($uni >= 0x06C0 and $uni <= 0x06CE);
	return "3.0" if($uni == 0x06CF);
	return "1.1" if($uni >= 0x06D0 and $uni <= 0x06ED);
	return "4.0" if($uni >= 0x06EE and $uni <= 0x06EF);
	return "1.1" if($uni >= 0x06F0 and $uni <= 0x06F9);
	return "3.0" if($uni >= 0x06FA and $uni <= 0x06FE);
	return "4.0" if($uni == 0x06FF);
	return "3.0" if($uni >= 0x0700 and $uni <= 0x070D);
	return "3.0" if($uni >= 0x070F and $uni <= 0x072C);
	return "4.0" if($uni >= 0x072D and $uni <= 0x072F);
	return "3.0" if($uni >= 0x0730 and $uni <= 0x074A);
	return "4.0" if($uni >= 0x074D and $uni <= 0x074F);
	return "4.1" if($uni >= 0x0750 and $uni <= 0x076D);
	return "5.1" if($uni >= 0x076E and $uni <= 0x077F);
	return "3.0" if($uni >= 0x0780 and $uni <= 0x07B0);
	return "3.2" if($uni == 0x07B1);
	return "5.0" if($uni >= 0x07C0 and $uni <= 0x07FA);
	return "11.0" if($uni >= 0x07FD and $uni <= 0x07FF);
	return "5.2" if($uni >= 0x0800 and $uni <= 0x082D);
	return "5.2" if($uni >= 0x0830 and $uni <= 0x083E);
	return "6.0" if($uni >= 0x0840 and $uni <= 0x085B);
	return "6.0" if($uni == 0x085E);
	return "10.0" if($uni >= 0x0860 and $uni <= 0x086A);
	return "6.1" if($uni == 0x08A0);
	return "7.0" if($uni == 0x08A1);
	return "6.1" if($uni >= 0x08A2 and $uni <= 0x08AC);
	return "7.0" if($uni >= 0x08AD and $uni <= 0x08B2);
	return "8.0" if($uni >= 0x08B3 and $uni <= 0x08B4);
	return "9.0" if($uni >= 0x08B6 and $uni <= 0x08BD);
	return "11.0" if($uni == 0x08D3);
	return "9.0" if($uni >= 0x08D4 and $uni <= 0x08E2);
	return "8.0" if($uni == 0x08E3);
	return "6.1" if($uni >= 0x08E4 and $uni <= 0x08FE);
	return "7.0" if($uni == 0x08FF);
	return "5.2" if($uni == 0x0900);
	return "1.1" if($uni >= 0x0901 and $uni <= 0x0903);
	return "4.0" if($uni == 0x0904);
	return "1.1" if($uni >= 0x0905 and $uni <= 0x0939);
	return "6.0" if($uni >= 0x093A and $uni <= 0x093B);
	return "1.1" if($uni >= 0x093C and $uni <= 0x094D);
	return "5.2" if($uni == 0x094E);
	return "6.0" if($uni == 0x094F);
	return "1.1" if($uni >= 0x0950 and $uni <= 0x0954);
	return "5.2" if($uni == 0x0955);
	return "6.0" if($uni >= 0x0956 and $uni <= 0x0957);
	return "1.1" if($uni >= 0x0958 and $uni <= 0x0970);
	return "5.1" if($uni >= 0x0971 and $uni <= 0x0972);
	return "6.0" if($uni >= 0x0973 and $uni <= 0x0977);
	return "7.0" if($uni == 0x0978);
	return "5.2" if($uni >= 0x0979 and $uni <= 0x097A);
	return "5.0" if($uni >= 0x097B and $uni <= 0x097C);
	return "4.1" if($uni == 0x097D);
	return "5.0" if($uni >= 0x097E and $uni <= 0x097F);
	return "7.0" if($uni == 0x0980);
	return "1.1" if($uni >= 0x0981 and $uni <= 0x0983);
	return "1.1" if($uni >= 0x0985 and $uni <= 0x098C);
	return "1.1" if($uni >= 0x098F and $uni <= 0x0990);
	return "1.1" if($uni >= 0x0993 and $uni <= 0x09A8);
	return "1.1" if($uni >= 0x09AA and $uni <= 0x09B0);
	return "1.1" if($uni == 0x09B2);
	return "1.1" if($uni >= 0x09B6 and $uni <= 0x09B9);
	return "1.1" if($uni == 0x09BC);
	return "4.0" if($uni == 0x09BD);
	return "1.1" if($uni >= 0x09BE and $uni <= 0x09C4);
	return "1.1" if($uni >= 0x09C7 and $uni <= 0x09C8);
	return "1.1" if($uni >= 0x09CB and $uni <= 0x09CD);
	return "4.1" if($uni == 0x09CE);
	return "1.1" if($uni == 0x09D7);
	return "1.1" if($uni >= 0x09DC and $uni <= 0x09DD);
	return "1.1" if($uni >= 0x09DF and $uni <= 0x09E3);
	return "1.1" if($uni >= 0x09E6 and $uni <= 0x09FA);
	return "5.2" if($uni == 0x09FB);
	return "10.0" if($uni >= 0x09FC and $uni <= 0x09FD);
	return "11.0" if($uni == 0x09FE);
	return "4.0" if($uni == 0x0A01);
	return "1.1" if($uni == 0x0A02);
	return "4.0" if($uni == 0x0A03);
	return "1.1" if($uni >= 0x0A05 and $uni <= 0x0A0A);
	return "1.1" if($uni >= 0x0A0F and $uni <= 0x0A10);
	return "1.1" if($uni >= 0x0A13 and $uni <= 0x0A28);
	return "1.1" if($uni >= 0x0A2A and $uni <= 0x0A30);
	return "1.1" if($uni >= 0x0A32 and $uni <= 0x0A33);
	return "1.1" if($uni >= 0x0A35 and $uni <= 0x0A36);
	return "1.1" if($uni >= 0x0A38 and $uni <= 0x0A39);
	return "1.1" if($uni == 0x0A3C);
	return "1.1" if($uni >= 0x0A3E and $uni <= 0x0A42);
	return "1.1" if($uni >= 0x0A47 and $uni <= 0x0A48);
	return "1.1" if($uni >= 0x0A4B and $uni <= 0x0A4D);
	return "5.1" if($uni == 0x0A51);
	return "1.1" if($uni >= 0x0A59 and $uni <= 0x0A5C);
	return "1.1" if($uni == 0x0A5E);
	return "1.1" if($uni >= 0x0A66 and $uni <= 0x0A74);
	return "5.1" if($uni == 0x0A75);
	return "11.0" if($uni == 0x0A76);
	return "1.1" if($uni >= 0x0A81 and $uni <= 0x0A83);
	return "1.1" if($uni >= 0x0A85 and $uni <= 0x0A8B);
	return "4.0" if($uni == 0x0A8C);
	return "1.1" if($uni == 0x0A8D);
	return "1.1" if($uni >= 0x0A8F and $uni <= 0x0A91);
	return "1.1" if($uni >= 0x0A93 and $uni <= 0x0AA8);
	return "1.1" if($uni >= 0x0AAA and $uni <= 0x0AB0);
	return "1.1" if($uni >= 0x0AB2 and $uni <= 0x0AB3);
	return "1.1" if($uni >= 0x0AB5 and $uni <= 0x0AB9);
	return "1.1" if($uni >= 0x0ABC and $uni <= 0x0AC5);
	return "1.1" if($uni >= 0x0AC7 and $uni <= 0x0AC9);
	return "1.1" if($uni >= 0x0ACB and $uni <= 0x0ACD);
	return "1.1" if($uni == 0x0AD0);
	return "1.1" if($uni == 0x0AE0);
	return "4.0" if($uni >= 0x0AE1 and $uni <= 0x0AE3);
	return "1.1" if($uni >= 0x0AE6 and $uni <= 0x0AEF);
	return "6.1" if($uni == 0x0AF0);
	return "4.0" if($uni == 0x0AF1);
	return "8.0" if($uni == 0x0AF9);
	return "10.0" if($uni >= 0x0AFA and $uni <= 0x0AFF);
	return "1.1" if($uni >= 0x0B01 and $uni <= 0x0B03);
	return "1.1" if($uni >= 0x0B05 and $uni <= 0x0B0C);
	return "1.1" if($uni >= 0x0B0F and $uni <= 0x0B10);
	return "1.1" if($uni >= 0x0B13 and $uni <= 0x0B28);
	return "1.1" if($uni >= 0x0B2A and $uni <= 0x0B30);
	return "1.1" if($uni >= 0x0B32 and $uni <= 0x0B33);
	return "4.0" if($uni == 0x0B35);
	return "1.1" if($uni >= 0x0B36 and $uni <= 0x0B39);
	return "1.1" if($uni >= 0x0B3C and $uni <= 0x0B43);
	return "5.1" if($uni == 0x0B44);
	return "1.1" if($uni >= 0x0B47 and $uni <= 0x0B48);
	return "1.1" if($uni >= 0x0B4B and $uni <= 0x0B4D);
	return "1.1" if($uni >= 0x0B56 and $uni <= 0x0B57);
	return "1.1" if($uni >= 0x0B5C and $uni <= 0x0B5D);
	return "1.1" if($uni >= 0x0B5F and $uni <= 0x0B61);
	return "5.1" if($uni >= 0x0B62 and $uni <= 0x0B63);
	return "1.1" if($uni >= 0x0B66 and $uni <= 0x0B70);
	return "4.0" if($uni == 0x0B71);
	return "6.0" if($uni >= 0x0B72 and $uni <= 0x0B77);
	return "1.1" if($uni >= 0x0B82 and $uni <= 0x0B83);
	return "1.1" if($uni >= 0x0B85 and $uni <= 0x0B8A);
	return "1.1" if($uni >= 0x0B8E and $uni <= 0x0B90);
	return "1.1" if($uni >= 0x0B92 and $uni <= 0x0B95);
	return "1.1" if($uni >= 0x0B99 and $uni <= 0x0B9A);
	return "1.1" if($uni == 0x0B9C);
	return "1.1" if($uni >= 0x0B9E and $uni <= 0x0B9F);
	return "1.1" if($uni >= 0x0BA3 and $uni <= 0x0BA4);
	return "1.1" if($uni >= 0x0BA8 and $uni <= 0x0BAA);
	return "1.1" if($uni >= 0x0BAE and $uni <= 0x0BB5);
	return "4.1" if($uni == 0x0BB6);
	return "1.1" if($uni >= 0x0BB7 and $uni <= 0x0BB9);
	return "1.1" if($uni >= 0x0BBE and $uni <= 0x0BC2);
	return "1.1" if($uni >= 0x0BC6 and $uni <= 0x0BC8);
	return "1.1" if($uni >= 0x0BCA and $uni <= 0x0BCD);
	return "5.1" if($uni == 0x0BD0);
	return "1.1" if($uni == 0x0BD7);
	return "4.1" if($uni == 0x0BE6);
	return "1.1" if($uni >= 0x0BE7 and $uni <= 0x0BF2);
	return "4.0" if($uni >= 0x0BF3 and $uni <= 0x0BFA);
	return "7.0" if($uni == 0x0C00);
	return "1.1" if($uni >= 0x0C01 and $uni <= 0x0C03);
	return "11.0" if($uni == 0x0C04);
	return "1.1" if($uni >= 0x0C05 and $uni <= 0x0C0C);
	return "1.1" if($uni >= 0x0C0E and $uni <= 0x0C10);
	return "1.1" if($uni >= 0x0C12 and $uni <= 0x0C28);
	return "1.1" if($uni >= 0x0C2A and $uni <= 0x0C33);
	return "7.0" if($uni == 0x0C34);
	return "1.1" if($uni >= 0x0C35 and $uni <= 0x0C39);
	return "5.1" if($uni == 0x0C3D);
	return "1.1" if($uni >= 0x0C3E and $uni <= 0x0C44);
	return "1.1" if($uni >= 0x0C46 and $uni <= 0x0C48);
	return "1.1" if($uni >= 0x0C4A and $uni <= 0x0C4D);
	return "1.1" if($uni >= 0x0C55 and $uni <= 0x0C56);
	return "5.1" if($uni >= 0x0C58 and $uni <= 0x0C59);
	return "8.0" if($uni == 0x0C5A);
	return "1.1" if($uni >= 0x0C60 and $uni <= 0x0C61);
	return "5.1" if($uni >= 0x0C62 and $uni <= 0x0C63);
	return "1.1" if($uni >= 0x0C66 and $uni <= 0x0C6F);
	return "12.0" if($uni == 0x0C77);
	return "5.1" if($uni >= 0x0C78 and $uni <= 0x0C7F);
	return "9.0" if($uni == 0x0C80);
	return "7.0" if($uni == 0x0C81);
	return "1.1" if($uni >= 0x0C82 and $uni <= 0x0C83);
	return "11.0" if($uni == 0x0C84);
	return "1.1" if($uni >= 0x0C85 and $uni <= 0x0C8C);
	return "1.1" if($uni >= 0x0C8E and $uni <= 0x0C90);
	return "1.1" if($uni >= 0x0C92 and $uni <= 0x0CA8);
	return "1.1" if($uni >= 0x0CAA and $uni <= 0x0CB3);
	return "1.1" if($uni >= 0x0CB5 and $uni <= 0x0CB9);
	return "4.0" if($uni >= 0x0CBC and $uni <= 0x0CBD);
	return "1.1" if($uni >= 0x0CBE and $uni <= 0x0CC4);
	return "1.1" if($uni >= 0x0CC6 and $uni <= 0x0CC8);
	return "1.1" if($uni >= 0x0CCA and $uni <= 0x0CCD);
	return "1.1" if($uni >= 0x0CD5 and $uni <= 0x0CD6);
	return "1.1" if($uni == 0x0CDE);
	return "1.1" if($uni >= 0x0CE0 and $uni <= 0x0CE1);
	return "5.0" if($uni >= 0x0CE2 and $uni <= 0x0CE3);
	return "1.1" if($uni >= 0x0CE6 and $uni <= 0x0CEF);
	return "5.0" if($uni >= 0x0CF1 and $uni <= 0x0CF2);
	return "10.0" if($uni == 0x0D00);
	return "7.0" if($uni == 0x0D01);
	return "1.1" if($uni >= 0x0D02 and $uni <= 0x0D03);
	return "1.1" if($uni >= 0x0D05 and $uni <= 0x0D0C);
	return "1.1" if($uni >= 0x0D0E and $uni <= 0x0D10);
	return "1.1" if($uni >= 0x0D12 and $uni <= 0x0D28);
	return "6.0" if($uni == 0x0D29);
	return "1.1" if($uni >= 0x0D2A and $uni <= 0x0D39);
	return "6.0" if($uni == 0x0D3A);
	return "10.0" if($uni >= 0x0D3B and $uni <= 0x0D3C);
	return "5.1" if($uni == 0x0D3D);
	return "1.1" if($uni >= 0x0D3E and $uni <= 0x0D43);
	return "5.1" if($uni == 0x0D44);
	return "1.1" if($uni >= 0x0D46 and $uni <= 0x0D48);
	return "1.1" if($uni >= 0x0D4A and $uni <= 0x0D4D);
	return "6.0" if($uni == 0x0D4E);
	return "9.0" if($uni == 0x0D4F);
	return "9.0" if($uni >= 0x0D54 and $uni <= 0x0D56);
	return "1.1" if($uni == 0x0D57);
	return "9.0" if($uni >= 0x0D58 and $uni <= 0x0D5E);
	return "8.0" if($uni == 0x0D5F);
	return "1.1" if($uni >= 0x0D60 and $uni <= 0x0D61);
	return "5.1" if($uni >= 0x0D62 and $uni <= 0x0D63);
	return "1.1" if($uni >= 0x0D66 and $uni <= 0x0D6F);
	return "5.1" if($uni >= 0x0D70 and $uni <= 0x0D75);
	return "9.0" if($uni >= 0x0D76 and $uni <= 0x0D78);
	return "5.1" if($uni >= 0x0D79 and $uni <= 0x0D7F);
	return "3.0" if($uni >= 0x0D82 and $uni <= 0x0D83);
	return "3.0" if($uni >= 0x0D85 and $uni <= 0x0D96);
	return "3.0" if($uni >= 0x0D9A and $uni <= 0x0DB1);
	return "3.0" if($uni >= 0x0DB3 and $uni <= 0x0DBB);
	return "3.0" if($uni == 0x0DBD);
	return "3.0" if($uni >= 0x0DC0 and $uni <= 0x0DC6);
	return "3.0" if($uni == 0x0DCA);
	return "3.0" if($uni >= 0x0DCF and $uni <= 0x0DD4);
	return "3.0" if($uni == 0x0DD6);
	return "3.0" if($uni >= 0x0DD8 and $uni <= 0x0DDF);
	return "7.0" if($uni >= 0x0DE6 and $uni <= 0x0DEF);
	return "3.0" if($uni >= 0x0DF2 and $uni <= 0x0DF4);
	return "1.1" if($uni >= 0x0E01 and $uni <= 0x0E3A);
	return "1.1" if($uni >= 0x0E3F and $uni <= 0x0E5B);
	return "1.1" if($uni >= 0x0E81 and $uni <= 0x0E82);
	return "1.1" if($uni == 0x0E84);
	return "12.0" if($uni == 0x0E86);
	return "1.1" if($uni >= 0x0E87 and $uni <= 0x0E88);
	return "12.0" if($uni == 0x0E89);
	return "1.1" if($uni == 0x0E8A);
	return "12.0" if($uni == 0x0E8C);
	return "1.1" if($uni == 0x0E8D);
	return "12.0" if($uni >= 0x0E8E and $uni <= 0x0E93);
	return "1.1" if($uni >= 0x0E94 and $uni <= 0x0E97);
	return "12.0" if($uni == 0x0E98);
	return "1.1" if($uni >= 0x0E99 and $uni <= 0x0E9F);
	return "12.0" if($uni == 0x0EA0);
	return "1.1" if($uni >= 0x0EA1 and $uni <= 0x0EA3);
	return "1.1" if($uni == 0x0EA5);
	return "1.1" if($uni == 0x0EA7);
	return "12.0" if($uni >= 0x0EA8 and $uni <= 0x0EA9);
	return "1.1" if($uni >= 0x0EAA and $uni <= 0x0EAB);
	return "12.0" if($uni == 0x0EAC);
	return "1.1" if($uni >= 0x0EAD and $uni <= 0x0EB9);
	return "12.0" if($uni == 0x0EBA);
	return "1.1" if($uni >= 0x0EBB and $uni <= 0x0EBD);
	return "1.1" if($uni >= 0x0EC0 and $uni <= 0x0EC4);
	return "1.1" if($uni == 0x0EC6);
	return "1.1" if($uni >= 0x0EC8 and $uni <= 0x0ECD);
	return "1.1" if($uni >= 0x0ED0 and $uni <= 0x0ED9);
	return "1.1" if($uni >= 0x0EDC and $uni <= 0x0EDD);
	return "6.1" if($uni >= 0x0EDE and $uni <= 0x0EDF);
	return "2.0" if($uni >= 0x0F00 and $uni <= 0x0F47);
	return "2.0" if($uni >= 0x0F49 and $uni <= 0x0F69);
	return "3.0" if($uni == 0x0F6A);
	return "5.1" if($uni >= 0x0F6B and $uni <= 0x0F6C);
	return "2.0" if($uni >= 0x0F71 and $uni <= 0x0F8B);
	return "6.0" if($uni >= 0x0F8C and $uni <= 0x0F8F);
	return "2.0" if($uni >= 0x0F90 and $uni <= 0x0F95);
	return "3.0" if($uni == 0x0F96);
	return "2.0" if($uni == 0x0F97);
	return "2.0" if($uni >= 0x0F99 and $uni <= 0x0FAD);
	return "3.0" if($uni >= 0x0FAE and $uni <= 0x0FB0);
	return "2.0" if($uni >= 0x0FB1 and $uni <= 0x0FB7);
	return "3.0" if($uni == 0x0FB8);
	return "2.0" if($uni == 0x0FB9);
	return "3.0" if($uni >= 0x0FBA and $uni <= 0x0FBC);
	return "3.0" if($uni >= 0x0FBE and $uni <= 0x0FCC);
	return "5.1" if($uni == 0x0FCE);
	return "3.0" if($uni == 0x0FCF);
	return "4.1" if($uni >= 0x0FD0 and $uni <= 0x0FD1);
	return "5.1" if($uni >= 0x0FD2 and $uni <= 0x0FD4);
	return "5.2" if($uni >= 0x0FD5 and $uni <= 0x0FD8);
	return "6.0" if($uni >= 0x0FD9 and $uni <= 0x0FDA);
	return "3.0" if($uni >= 0x1000 and $uni <= 0x1021);
	return "5.1" if($uni == 0x1022);
	return "3.0" if($uni >= 0x1023 and $uni <= 0x1027);
	return "5.1" if($uni == 0x1028);
	return "3.0" if($uni >= 0x1029 and $uni <= 0x102A);
	return "5.1" if($uni == 0x102B);
	return "3.0" if($uni >= 0x102C and $uni <= 0x1032);
	return "5.1" if($uni >= 0x1033 and $uni <= 0x1035);
	return "3.0" if($uni >= 0x1036 and $uni <= 0x1039);
	return "5.1" if($uni >= 0x103A and $uni <= 0x103F);
	return "3.0" if($uni >= 0x1040 and $uni <= 0x1059);
	return "5.1" if($uni >= 0x105A and $uni <= 0x1099);
	return "5.2" if($uni >= 0x109A and $uni <= 0x109D);
	return "5.1" if($uni >= 0x109E and $uni <= 0x109F);
	return "1.1" if($uni >= 0x10A0 and $uni <= 0x10C5);
	return "6.1" if($uni == 0x10C7);
	return "6.1" if($uni == 0x10CD);
	return "1.1" if($uni >= 0x10D0 and $uni <= 0x10F6);
	return "3.2" if($uni >= 0x10F7 and $uni <= 0x10F8);
	return "4.1" if($uni >= 0x10F9 and $uni <= 0x10FA);
	return "1.1" if($uni == 0x10FB);
	return "4.1" if($uni == 0x10FC);
	return "6.1" if($uni >= 0x10FD and $uni <= 0x10FF);
	return "1.1" if($uni >= 0x1100 and $uni <= 0x1159);
	return "5.2" if($uni >= 0x115A and $uni <= 0x115E);
	return "1.1" if($uni >= 0x115F and $uni <= 0x11A2);
	return "5.2" if($uni >= 0x11A3 and $uni <= 0x11A7);
	return "1.1" if($uni >= 0x11A8 and $uni <= 0x11F9);
	return "5.2" if($uni >= 0x11FA and $uni <= 0x11FF);
	return "3.0" if($uni >= 0x1200 and $uni <= 0x1206);
	return "4.1" if($uni == 0x1207);
	return "3.0" if($uni >= 0x1208 and $uni <= 0x1246);
	return "4.1" if($uni == 0x1247);
	return "3.0" if($uni == 0x1248);
	return "3.0" if($uni >= 0x124A and $uni <= 0x124D);
	return "3.0" if($uni >= 0x1250 and $uni <= 0x1256);
	return "3.0" if($uni == 0x1258);
	return "3.0" if($uni >= 0x125A and $uni <= 0x125D);
	return "3.0" if($uni >= 0x1260 and $uni <= 0x1286);
	return "4.1" if($uni == 0x1287);
	return "3.0" if($uni == 0x1288);
	return "3.0" if($uni >= 0x128A and $uni <= 0x128D);
	return "3.0" if($uni >= 0x1290 and $uni <= 0x12AE);
	return "4.1" if($uni == 0x12AF);
	return "3.0" if($uni == 0x12B0);
	return "3.0" if($uni >= 0x12B2 and $uni <= 0x12B5);
	return "3.0" if($uni >= 0x12B8 and $uni <= 0x12BE);
	return "3.0" if($uni == 0x12C0);
	return "3.0" if($uni >= 0x12C2 and $uni <= 0x12C5);
	return "3.0" if($uni >= 0x12C8 and $uni <= 0x12CE);
	return "4.1" if($uni == 0x12CF);
	return "3.0" if($uni >= 0x12D0 and $uni <= 0x12D6);
	return "3.0" if($uni >= 0x12D8 and $uni <= 0x12EE);
	return "4.1" if($uni == 0x12EF);
	return "3.0" if($uni >= 0x12F0 and $uni <= 0x130E);
	return "4.1" if($uni == 0x130F);
	return "3.0" if($uni == 0x1310);
	return "3.0" if($uni >= 0x1312 and $uni <= 0x1315);
	return "3.0" if($uni >= 0x1318 and $uni <= 0x131E);
	return "4.1" if($uni == 0x131F);
	return "3.0" if($uni >= 0x1320 and $uni <= 0x1346);
	return "4.1" if($uni == 0x1347);
	return "3.0" if($uni >= 0x1348 and $uni <= 0x135A);
	return "6.0" if($uni >= 0x135D and $uni <= 0x135E);
	return "4.1" if($uni >= 0x135F and $uni <= 0x1360);
	return "3.0" if($uni >= 0x1361 and $uni <= 0x137C);
	return "4.1" if($uni >= 0x1380 and $uni <= 0x1399);
	return "3.0" if($uni >= 0x13A0 and $uni <= 0x13F4);
	return "8.0" if($uni == 0x13F5);
	return "8.0" if($uni >= 0x13F8 and $uni <= 0x13FD);
	return "5.2" if($uni == 0x1400);
	return "3.0" if($uni >= 0x1401 and $uni <= 0x1676);
	return "5.2" if($uni >= 0x1677 and $uni <= 0x167F);
	return "3.0" if($uni >= 0x1680 and $uni <= 0x169C);
	return "3.0" if($uni >= 0x16A0 and $uni <= 0x16F0);
	return "7.0" if($uni >= 0x16F1 and $uni <= 0x16F8);
	return "3.2" if($uni >= 0x1700 and $uni <= 0x170C);
	return "3.2" if($uni >= 0x170E and $uni <= 0x1714);
	return "3.2" if($uni >= 0x1720 and $uni <= 0x1736);
	return "3.2" if($uni >= 0x1740 and $uni <= 0x1753);
	return "3.2" if($uni >= 0x1760 and $uni <= 0x176C);
	return "3.2" if($uni >= 0x176E and $uni <= 0x1770);
	return "3.2" if($uni >= 0x1772 and $uni <= 0x1773);
	return "3.0" if($uni >= 0x1780 and $uni <= 0x17DC);
	return "4.0" if($uni == 0x17DD);
	return "3.0" if($uni >= 0x17E0 and $uni <= 0x17E9);
	return "4.0" if($uni >= 0x17F0 and $uni <= 0x17F9);
	return "3.0" if($uni >= 0x1800 and $uni <= 0x180E);
	return "3.0" if($uni >= 0x1810 and $uni <= 0x1819);
	return "3.0" if($uni >= 0x1820 and $uni <= 0x1877);
	return "11.0" if($uni == 0x1878);
	return "3.0" if($uni >= 0x1880 and $uni <= 0x18A9);
	return "5.1" if($uni == 0x18AA);
	return "5.2" if($uni >= 0x18B0 and $uni <= 0x18F5);
	return "4.0" if($uni >= 0x1900 and $uni <= 0x191C);
	return "7.0" if($uni >= 0x191D and $uni <= 0x191E);
	return "4.0" if($uni >= 0x1920 and $uni <= 0x192B);
	return "4.0" if($uni >= 0x1930 and $uni <= 0x193B);
	return "4.0" if($uni == 0x1940);
	return "4.0" if($uni >= 0x1944 and $uni <= 0x196D);
	return "4.0" if($uni >= 0x1970 and $uni <= 0x1974);
	return "4.1" if($uni >= 0x1980 and $uni <= 0x19A9);
	return "5.2" if($uni >= 0x19AA and $uni <= 0x19AB);
	return "4.1" if($uni >= 0x19B0 and $uni <= 0x19C9);
	return "4.1" if($uni >= 0x19D0 and $uni <= 0x19D9);
	return "5.2" if($uni == 0x19DA);
	return "4.1" if($uni >= 0x19DE and $uni <= 0x19DF);
	return "4.0" if($uni >= 0x19E0 and $uni <= 0x19FF);
	return "4.1" if($uni >= 0x1A00 and $uni <= 0x1A1B);
	return "4.1" if($uni >= 0x1A1E and $uni <= 0x1A1F);
	return "5.2" if($uni >= 0x1A20 and $uni <= 0x1A5E);
	return "5.2" if($uni >= 0x1A60 and $uni <= 0x1A7C);
	return "5.2" if($uni >= 0x1A7F and $uni <= 0x1A89);
	return "5.2" if($uni >= 0x1A90 and $uni <= 0x1A99);
	return "5.2" if($uni >= 0x1AA0 and $uni <= 0x1AAD);
	return "7.0" if($uni >= 0x1AB0 and $uni <= 0x1ABE);
	return "5.0" if($uni >= 0x1B00 and $uni <= 0x1B4B);
	return "5.0" if($uni >= 0x1B50 and $uni <= 0x1B7C);
	return "5.1" if($uni >= 0x1B80 and $uni <= 0x1BAA);
	return "6.1" if($uni >= 0x1BAB and $uni <= 0x1BAD);
	return "5.1" if($uni >= 0x1BAE and $uni <= 0x1BB9);
	return "6.1" if($uni >= 0x1BBA and $uni <= 0x1BBF);
	return "6.0" if($uni >= 0x1BC0 and $uni <= 0x1BF3);
	return "6.0" if($uni >= 0x1BFC and $uni <= 0x1BFF);
	return "5.1" if($uni >= 0x1C00 and $uni <= 0x1C37);
	return "5.1" if($uni >= 0x1C3B and $uni <= 0x1C49);
	return "5.1" if($uni >= 0x1C4D and $uni <= 0x1C7F);
	return "9.0" if($uni >= 0x1C80 and $uni <= 0x1C88);
	return "11.0" if($uni >= 0x1C90 and $uni <= 0x1CBA);
	return "11.0" if($uni >= 0x1CBD and $uni <= 0x1CBF);
	return "6.1" if($uni >= 0x1CC0 and $uni <= 0x1CC7);
	return "5.2" if($uni >= 0x1CD0 and $uni <= 0x1CF2);
	return "6.1" if($uni >= 0x1CF3 and $uni <= 0x1CF6);
	return "10.0" if($uni == 0x1CF7);
	return "7.0" if($uni >= 0x1CF8 and $uni <= 0x1CF9);
	return "12.0" if($uni == 0x1CFA);
	return "4.0" if($uni >= 0x1D00 and $uni <= 0x1D6B);
	return "4.1" if($uni >= 0x1D6C and $uni <= 0x1DC3);
	return "5.0" if($uni >= 0x1DC4 and $uni <= 0x1DCA);
	return "5.1" if($uni >= 0x1DCB and $uni <= 0x1DE6);
	return "7.0" if($uni >= 0x1DE7 and $uni <= 0x1DF5);
	return "10.0" if($uni >= 0x1DF6 and $uni <= 0x1DF9);
	return "9.0" if($uni == 0x1DFB);
	return "6.0" if($uni == 0x1DFC);
	return "5.2" if($uni == 0x1DFD);
	return "5.0" if($uni >= 0x1DFE and $uni <= 0x1DFF);
	return "1.1" if($uni >= 0x1E00 and $uni <= 0x1E9A);
	return "2.0" if($uni == 0x1E9B);
	return "5.1" if($uni >= 0x1E9C and $uni <= 0x1E9F);
	return "1.1" if($uni >= 0x1EA0 and $uni <= 0x1EF9);
	return "5.1" if($uni >= 0x1EFA and $uni <= 0x1EFF);
	return "1.1" if($uni >= 0x1F00 and $uni <= 0x1F15);
	return "1.1" if($uni >= 0x1F18 and $uni <= 0x1F1D);
	return "1.1" if($uni >= 0x1F20 and $uni <= 0x1F45);
	return "1.1" if($uni >= 0x1F48 and $uni <= 0x1F4D);
	return "1.1" if($uni >= 0x1F50 and $uni <= 0x1F57);
	return "1.1" if($uni == 0x1F59);
	return "1.1" if($uni == 0x1F5B);
	return "1.1" if($uni == 0x1F5D);
	return "1.1" if($uni >= 0x1F5F and $uni <= 0x1F7D);
	return "1.1" if($uni >= 0x1F80 and $uni <= 0x1FB4);
	return "1.1" if($uni >= 0x1FB6 and $uni <= 0x1FC4);
	return "1.1" if($uni >= 0x1FC6 and $uni <= 0x1FD3);
	return "1.1" if($uni >= 0x1FD6 and $uni <= 0x1FDB);
	return "1.1" if($uni >= 0x1FDD and $uni <= 0x1FEF);
	return "1.1" if($uni >= 0x1FF2 and $uni <= 0x1FF4);
	return "1.1" if($uni >= 0x1FF6 and $uni <= 0x1FFE);
	return "1.1" if($uni >= 0x2000 and $uni <= 0x202E);
	return "3.0" if($uni == 0x202F);
	return "1.1" if($uni >= 0x2030 and $uni <= 0x2046);
	return "3.2" if($uni == 0x2047);
	return "3.0" if($uni >= 0x2048 and $uni <= 0x204D);
	return "3.2" if($uni >= 0x204E and $uni <= 0x2052);
	return "4.0" if($uni >= 0x2053 and $uni <= 0x2054);
	return "4.1" if($uni >= 0x2055 and $uni <= 0x2056);
	return "3.2" if($uni == 0x2057);
	return "4.1" if($uni >= 0x2058 and $uni <= 0x205E);
	return "3.2" if($uni >= 0x205F and $uni <= 0x2063);
	return "5.1" if($uni == 0x2064);
	return "6.3" if($uni >= 0x2066 and $uni <= 0x2069);
	return "1.1" if($uni >= 0x206A and $uni <= 0x2070);
	return "3.2" if($uni == 0x2071);
	return "1.1" if($uni >= 0x2074 and $uni <= 0x208E);
	return "4.1" if($uni >= 0x2090 and $uni <= 0x2094);
	return "6.0" if($uni >= 0x2095 and $uni <= 0x209C);
	return "1.1" if($uni >= 0x20A0 and $uni <= 0x20AA);
	return "2.0" if($uni == 0x20AB);
	return "2.1" if($uni == 0x20AC);
	return "3.0" if($uni >= 0x20AD and $uni <= 0x20AF);
	return "3.2" if($uni >= 0x20B0 and $uni <= 0x20B1);
	return "4.1" if($uni >= 0x20B2 and $uni <= 0x20B5);
	return "5.2" if($uni >= 0x20B6 and $uni <= 0x20B8);
	return "6.0" if($uni == 0x20B9);
	return "6.2" if($uni == 0x20BA);
	return "7.0" if($uni >= 0x20BB and $uni <= 0x20BD);
	return "8.0" if($uni == 0x20BE);
	return "10.0" if($uni == 0x20BF);
	return "1.1" if($uni >= 0x20D0 and $uni <= 0x20E1);
	return "3.0" if($uni >= 0x20E2 and $uni <= 0x20E3);
	return "3.2" if($uni >= 0x20E4 and $uni <= 0x20EA);
	return "4.1" if($uni == 0x20EB);
	return "5.0" if($uni >= 0x20EC and $uni <= 0x20EF);
	return "5.1" if($uni == 0x20F0);
	return "1.1" if($uni >= 0x2100 and $uni <= 0x2138);
	return "3.0" if($uni >= 0x2139 and $uni <= 0x213A);
	return "4.0" if($uni == 0x213B);
	return "4.1" if($uni == 0x213C);
	return "3.2" if($uni >= 0x213D and $uni <= 0x214B);
	return "4.1" if($uni == 0x214C);
	return "5.0" if($uni >= 0x214D and $uni <= 0x214E);
	return "5.1" if($uni == 0x214F);
	return "5.2" if($uni >= 0x2150 and $uni <= 0x2152);
	return "1.1" if($uni >= 0x2153 and $uni <= 0x2182);
	return "3.0" if($uni == 0x2183);
	return "5.0" if($uni == 0x2184);
	return "5.1" if($uni >= 0x2185 and $uni <= 0x2188);
	return "5.2" if($uni == 0x2189);
	return "8.0" if($uni >= 0x218A and $uni <= 0x218B);
	return "1.1" if($uni >= 0x2190 and $uni <= 0x21EA);
	return "3.0" if($uni >= 0x21EB and $uni <= 0x21F3);
	return "3.2" if($uni >= 0x21F4 and $uni <= 0x21FF);
	return "1.1" if($uni >= 0x2200 and $uni <= 0x22F1);
	return "3.2" if($uni >= 0x22F2 and $uni <= 0x22FF);
	return "1.1" if($uni == 0x2300);
	return "3.0" if($uni == 0x2301);
	return "1.1" if($uni >= 0x2302 and $uni <= 0x237A);
	return "3.0" if($uni == 0x237B);
	return "3.2" if($uni == 0x237C);
	return "3.0" if($uni >= 0x237D and $uni <= 0x239A);
	return "3.2" if($uni >= 0x239B and $uni <= 0x23CE);
	return "4.0" if($uni >= 0x23CF and $uni <= 0x23D0);
	return "4.1" if($uni >= 0x23D1 and $uni <= 0x23DB);
	return "5.0" if($uni >= 0x23DC and $uni <= 0x23E7);
	return "5.2" if($uni == 0x23E8);
	return "6.0" if($uni >= 0x23E9 and $uni <= 0x23F3);
	return "7.0" if($uni >= 0x23F4 and $uni <= 0x23FA);
	return "9.0" if($uni >= 0x23FB and $uni <= 0x23FE);
	return "10.0" if($uni == 0x23FF);
	return "1.1" if($uni >= 0x2400 and $uni <= 0x2424);
	return "3.0" if($uni >= 0x2425 and $uni <= 0x2426);
	return "1.1" if($uni >= 0x2440 and $uni <= 0x244A);
	return "1.1" if($uni >= 0x2460 and $uni <= 0x24EA);
	return "3.2" if($uni >= 0x24EB and $uni <= 0x24FE);
	return "4.0" if($uni == 0x24FF);
	return "1.1" if($uni >= 0x2500 and $uni <= 0x2595);
	return "3.2" if($uni >= 0x2596 and $uni <= 0x259F);
	return "1.1" if($uni >= 0x25A0 and $uni <= 0x25EF);
	return "3.0" if($uni >= 0x25F0 and $uni <= 0x25F7);
	return "3.2" if($uni >= 0x25F8 and $uni <= 0x25FF);
	return "1.1" if($uni >= 0x2600 and $uni <= 0x2613);
	return "4.0" if($uni >= 0x2614 and $uni <= 0x2615);
	return "3.2" if($uni >= 0x2616 and $uni <= 0x2617);
	return "4.1" if($uni == 0x2618);
	return "3.0" if($uni == 0x2619);
	return "1.1" if($uni >= 0x261A and $uni <= 0x266F);
	return "3.0" if($uni >= 0x2670 and $uni <= 0x2671);
	return "3.2" if($uni >= 0x2672 and $uni <= 0x267D);
	return "4.1" if($uni >= 0x267E and $uni <= 0x267F);
	return "3.2" if($uni >= 0x2680 and $uni <= 0x2689);
	return "4.0" if($uni >= 0x268A and $uni <= 0x2691);
	return "4.1" if($uni >= 0x2692 and $uni <= 0x269C);
	return "5.1" if($uni == 0x269D);
	return "5.2" if($uni >= 0x269E and $uni <= 0x269F);
	return "4.0" if($uni >= 0x26A0 and $uni <= 0x26A1);
	return "4.1" if($uni >= 0x26A2 and $uni <= 0x26B1);
	return "5.0" if($uni == 0x26B2);
	return "5.1" if($uni >= 0x26B3 and $uni <= 0x26BC);
	return "5.2" if($uni >= 0x26BD and $uni <= 0x26BF);
	return "5.1" if($uni >= 0x26C0 and $uni <= 0x26C3);
	return "5.2" if($uni >= 0x26C4 and $uni <= 0x26CD);
	return "6.0" if($uni == 0x26CE);
	return "5.2" if($uni >= 0x26CF and $uni <= 0x26E1);
	return "6.0" if($uni == 0x26E2);
	return "5.2" if($uni == 0x26E3);
	return "6.0" if($uni >= 0x26E4 and $uni <= 0x26E7);
	return "5.2" if($uni >= 0x26E8 and $uni <= 0x26FF);
	return "7.0" if($uni == 0x2700);
	return "1.1" if($uni >= 0x2701 and $uni <= 0x2704);
	return "6.0" if($uni == 0x2705);
	return "1.1" if($uni >= 0x2706 and $uni <= 0x2709);
	return "6.0" if($uni >= 0x270A and $uni <= 0x270B);
	return "1.1" if($uni >= 0x270C and $uni <= 0x2727);
	return "6.0" if($uni == 0x2728);
	return "1.1" if($uni >= 0x2729 and $uni <= 0x274B);
	return "6.0" if($uni == 0x274C);
	return "1.1" if($uni == 0x274D);
	return "6.0" if($uni == 0x274E);
	return "1.1" if($uni >= 0x274F and $uni <= 0x2752);
	return "6.0" if($uni >= 0x2753 and $uni <= 0x2755);
	return "1.1" if($uni == 0x2756);
	return "5.2" if($uni == 0x2757);
	return "1.1" if($uni >= 0x2758 and $uni <= 0x275E);
	return "6.0" if($uni >= 0x275F and $uni <= 0x2760);
	return "1.1" if($uni >= 0x2761 and $uni <= 0x2767);
	return "3.2" if($uni >= 0x2768 and $uni <= 0x2775);
	return "1.1" if($uni >= 0x2776 and $uni <= 0x2794);
	return "6.0" if($uni >= 0x2795 and $uni <= 0x2797);
	return "1.1" if($uni >= 0x2798 and $uni <= 0x27AF);
	return "6.0" if($uni == 0x27B0);
	return "1.1" if($uni >= 0x27B1 and $uni <= 0x27BE);
	return "6.0" if($uni == 0x27BF);
	return "4.1" if($uni >= 0x27C0 and $uni <= 0x27C6);
	return "5.0" if($uni >= 0x27C7 and $uni <= 0x27CA);
	return "6.1" if($uni == 0x27CB);
	return "5.1" if($uni == 0x27CC);
	return "6.1" if($uni == 0x27CD);
	return "6.0" if($uni >= 0x27CE and $uni <= 0x27CF);
	return "3.2" if($uni >= 0x27D0 and $uni <= 0x27EB);
	return "5.1" if($uni >= 0x27EC and $uni <= 0x27EF);
	return "3.2" if($uni >= 0x27F0 and $uni <= 0x27FF);
	return "3.0" if($uni >= 0x2800 and $uni <= 0x28FF);
	return "3.2" if($uni >= 0x2900 and $uni <= 0x2AFF);
	return "4.0" if($uni >= 0x2B00 and $uni <= 0x2B0D);
	return "4.1" if($uni >= 0x2B0E and $uni <= 0x2B13);
	return "5.0" if($uni >= 0x2B14 and $uni <= 0x2B1A);
	return "5.1" if($uni >= 0x2B1B and $uni <= 0x2B1F);
	return "5.0" if($uni >= 0x2B20 and $uni <= 0x2B23);
	return "5.1" if($uni >= 0x2B24 and $uni <= 0x2B4C);
	return "7.0" if($uni >= 0x2B4D and $uni <= 0x2B4F);
	return "5.1" if($uni >= 0x2B50 and $uni <= 0x2B54);
	return "5.2" if($uni >= 0x2B55 and $uni <= 0x2B59);
	return "7.0" if($uni >= 0x2B5A and $uni <= 0x2B73);
	return "7.0" if($uni >= 0x2B76 and $uni <= 0x2B95);
	return "7.0" if($uni >= 0x2B98 and $uni <= 0x2BB9);
	return "11.0" if($uni >= 0x2BBA and $uni <= 0x2BBC);
	return "7.0" if($uni >= 0x2BBD and $uni <= 0x2BC8);
	return "12.0" if($uni == 0x2BC9);
	return "7.0" if($uni >= 0x2BCA and $uni <= 0x2BD1);
	return "10.0" if($uni == 0x2BD2);
	return "11.0" if($uni >= 0x2BD3 and $uni <= 0x2BEB);
	return "8.0" if($uni >= 0x2BEC and $uni <= 0x2BEF);
	return "11.0" if($uni >= 0x2BF0 and $uni <= 0x2BFE);
	return "12.0" if($uni == 0x2BFF);
	return "4.1" if($uni >= 0x2C00 and $uni <= 0x2C2E);
	return "4.1" if($uni >= 0x2C30 and $uni <= 0x2C5E);
	return "5.0" if($uni >= 0x2C60 and $uni <= 0x2C6C);
	return "5.1" if($uni >= 0x2C6D and $uni <= 0x2C6F);
	return "5.2" if($uni == 0x2C70);
	return "5.1" if($uni >= 0x2C71 and $uni <= 0x2C73);
	return "5.0" if($uni >= 0x2C74 and $uni <= 0x2C77);
	return "5.1" if($uni >= 0x2C78 and $uni <= 0x2C7D);
	return "5.2" if($uni >= 0x2C7E and $uni <= 0x2C7F);
	return "4.1" if($uni >= 0x2C80 and $uni <= 0x2CEA);
	return "5.2" if($uni >= 0x2CEB and $uni <= 0x2CF1);
	return "6.1" if($uni >= 0x2CF2 and $uni <= 0x2CF3);
	return "4.1" if($uni >= 0x2CF9 and $uni <= 0x2D25);
	return "6.1" if($uni == 0x2D27);
	return "6.1" if($uni == 0x2D2D);
	return "4.1" if($uni >= 0x2D30 and $uni <= 0x2D65);
	return "6.1" if($uni >= 0x2D66 and $uni <= 0x2D67);
	return "4.1" if($uni == 0x2D6F);
	return "6.0" if($uni == 0x2D70);
	return "6.0" if($uni == 0x2D7F);
	return "4.1" if($uni >= 0x2D80 and $uni <= 0x2D96);
	return "4.1" if($uni >= 0x2DA0 and $uni <= 0x2DA6);
	return "4.1" if($uni >= 0x2DA8 and $uni <= 0x2DAE);
	return "4.1" if($uni >= 0x2DB0 and $uni <= 0x2DB6);
	return "4.1" if($uni >= 0x2DB8 and $uni <= 0x2DBE);
	return "4.1" if($uni >= 0x2DC0 and $uni <= 0x2DC6);
	return "4.1" if($uni >= 0x2DC8 and $uni <= 0x2DCE);
	return "4.1" if($uni >= 0x2DD0 and $uni <= 0x2DD6);
	return "4.1" if($uni >= 0x2DD8 and $uni <= 0x2DDE);
	return "5.1" if($uni >= 0x2DE0 and $uni <= 0x2DFF);
	return "4.1" if($uni >= 0x2E00 and $uni <= 0x2E17);
	return "5.1" if($uni >= 0x2E18 and $uni <= 0x2E1B);
	return "4.1" if($uni >= 0x2E1C and $uni <= 0x2E1D);
	return "5.1" if($uni >= 0x2E1E and $uni <= 0x2E30);
	return "5.2" if($uni == 0x2E31);
	return "6.1" if($uni >= 0x2E32 and $uni <= 0x2E3B);
	return "7.0" if($uni >= 0x2E3C and $uni <= 0x2E42);
	return "9.0" if($uni >= 0x2E43 and $uni <= 0x2E44);
	return "10.0" if($uni >= 0x2E45 and $uni <= 0x2E49);
	return "11.0" if($uni >= 0x2E4A and $uni <= 0x2E4E);
	return "12.0" if($uni == 0x2E4F);
	return "3.0" if($uni >= 0x2E80 and $uni <= 0x2E99);
	return "3.0" if($uni >= 0x2E9B and $uni <= 0x2EF3);
	return "3.0" if($uni >= 0x2F00 and $uni <= 0x2FD5);
	return "3.0" if($uni >= 0x2FF0 and $uni <= 0x2FFB);
	return "1.1" if($uni >= 0x3000 and $uni <= 0x3037);
	return "3.0" if($uni >= 0x3038 and $uni <= 0x303A);
	return "3.2" if($uni >= 0x303B and $uni <= 0x303D);
	return "3.0" if($uni == 0x303E);
	return "1.1" if($uni == 0x303F);
	return "1.1" if($uni >= 0x3041 and $uni <= 0x3094);
	return "3.2" if($uni >= 0x3095 and $uni <= 0x3096);
	return "1.1" if($uni >= 0x3099 and $uni <= 0x309E);
	return "3.2" if($uni >= 0x309F and $uni <= 0x30A0);
	return "1.1" if($uni >= 0x30A1 and $uni <= 0x30FE);
	return "3.2" if($uni == 0x30FF);
	return "1.1" if($uni >= 0x3105 and $uni <= 0x312C);
	return "5.1" if($uni == 0x312D);
	return "10.0" if($uni == 0x312E);
	return "11.0" if($uni == 0x312F);
	return "1.1" if($uni >= 0x3131 and $uni <= 0x318E);
	return "1.1" if($uni >= 0x3190 and $uni <= 0x319F);
	return "3.0" if($uni >= 0x31A0 and $uni <= 0x31B7);
	return "6.0" if($uni >= 0x31B8 and $uni <= 0x31BA);
	return "4.1" if($uni >= 0x31C0 and $uni <= 0x31CF);
	return "5.1" if($uni >= 0x31D0 and $uni <= 0x31E3);
	return "3.2" if($uni >= 0x31F0 and $uni <= 0x31FF);
	return "1.1" if($uni >= 0x3200 and $uni <= 0x321C);
	return "4.0" if($uni >= 0x321D and $uni <= 0x321E);
	return "1.1" if($uni >= 0x3220 and $uni <= 0x3243);
	return "5.2" if($uni >= 0x3244 and $uni <= 0x324F);
	return "4.0" if($uni == 0x3250);
	return "3.2" if($uni >= 0x3251 and $uni <= 0x325F);
	return "1.1" if($uni >= 0x3260 and $uni <= 0x327B);
	return "4.0" if($uni >= 0x327C and $uni <= 0x327D);
	return "4.1" if($uni == 0x327E);
	return "1.1" if($uni >= 0x327F and $uni <= 0x32B0);
	return "3.2" if($uni >= 0x32B1 and $uni <= 0x32BF);
	return "1.1" if($uni >= 0x32C0 and $uni <= 0x32CB);
	return "4.0" if($uni >= 0x32CC and $uni <= 0x32CF);
	return "1.1" if($uni >= 0x32D0 and $uni <= 0x32FE);
	return "12.1" if($uni == 0x32FF);
	return "1.1" if($uni >= 0x3300 and $uni <= 0x3376);
	return "4.0" if($uni >= 0x3377 and $uni <= 0x337A);
	return "1.1" if($uni >= 0x337B and $uni <= 0x33DD);
	return "4.0" if($uni >= 0x33DE and $uni <= 0x33DF);
	return "1.1" if($uni >= 0x33E0 and $uni <= 0x33FE);
	return "4.0" if($uni == 0x33FF);
	return "3.0" if($uni >= 0x3400 and $uni <= 0x4DB5);
    return "13.0" if($uni >= 0x4DB6 and $uni <= 0x4DBF);
	return "4.0" if($uni >= 0x4DC0 and $uni <= 0x4DFF);
	return "1.1" if($uni >= 0x4E00 and $uni <= 0x9FA5);
	return "4.1" if($uni >= 0x9FA6 and $uni <= 0x9FBB);
	return "5.1" if($uni >= 0x9FBC and $uni <= 0x9FC3);
	return "5.2" if($uni >= 0x9FC4 and $uni <= 0x9FCB);
	return "6.1" if($uni == 0x9FCC);
	return "8.0" if($uni >= 0x9FCD and $uni <= 0x9FD5);
	return "10.0" if($uni >= 0x9FD6 and $uni <= 0x9FEA);
	return "11.0" if($uni >= 0x9FEB and $uni <= 0x9FEF);
	return "13.0" if($uni >= 0x9FF0 and $uni <= 0x9FFC);
	return "14.0" if($uni >= 0x9FFD and $uni <= 0x9FFF);
	return "3.0" if($uni >= 0xA000 and $uni <= 0xA48C);
	return "3.0" if($uni >= 0xA490 and $uni <= 0xA4A1);
	return "3.2" if($uni >= 0xA4A2 and $uni <= 0xA4A3);
	return "3.0" if($uni >= 0xA4A4 and $uni <= 0xA4B3);
	return "3.2" if($uni == 0xA4B4);
	return "3.0" if($uni >= 0xA4B5 and $uni <= 0xA4C0);
	return "3.2" if($uni == 0xA4C1);
	return "3.0" if($uni >= 0xA4C2 and $uni <= 0xA4C4);
	return "3.2" if($uni == 0xA4C5);
	return "3.0" if($uni == 0xA4C6);
	return "5.2" if($uni >= 0xA4D0 and $uni <= 0xA4FF);
	return "5.1" if($uni >= 0xA500 and $uni <= 0xA62B);
	return "5.1" if($uni >= 0xA640 and $uni <= 0xA65F);
	return "6.0" if($uni >= 0xA660 and $uni <= 0xA661);
	return "5.1" if($uni >= 0xA662 and $uni <= 0xA673);
	return "6.1" if($uni >= 0xA674 and $uni <= 0xA67B);
	return "5.1" if($uni >= 0xA67C and $uni <= 0xA697);
	return "7.0" if($uni >= 0xA698 and $uni <= 0xA69D);
	return "8.0" if($uni == 0xA69E);
	return "6.1" if($uni == 0xA69F);
	return "5.2" if($uni >= 0xA6A0 and $uni <= 0xA6F7);
	return "4.1" if($uni >= 0xA700 and $uni <= 0xA716);
	return "5.0" if($uni >= 0xA717 and $uni <= 0xA71A);
	return "5.1" if($uni >= 0xA71B and $uni <= 0xA71F);
	return "5.0" if($uni >= 0xA720 and $uni <= 0xA721);
	return "5.1" if($uni >= 0xA722 and $uni <= 0xA78C);
	return "6.0" if($uni >= 0xA78D and $uni <= 0xA78E);
	return "8.0" if($uni == 0xA78F);
	return "6.0" if($uni >= 0xA790 and $uni <= 0xA791);
	return "6.1" if($uni >= 0xA792 and $uni <= 0xA793);
	return "7.0" if($uni >= 0xA794 and $uni <= 0xA79F);
	return "6.0" if($uni >= 0xA7A0 and $uni <= 0xA7A9);
	return "6.1" if($uni == 0xA7AA);
	return "7.0" if($uni >= 0xA7AB and $uni <= 0xA7AD);
	return "9.0" if($uni == 0xA7AE);
	return "11.0" if($uni == 0xA7AF);
	return "7.0" if($uni >= 0xA7B0 and $uni <= 0xA7B1);
	return "8.0" if($uni >= 0xA7B2 and $uni <= 0xA7B7);
	return "11.0" if($uni >= 0xA7B8 and $uni <= 0xA7B9);
	return "12.0" if($uni >= 0xA7BA and $uni <= 0xA7BF);
	return "12.0" if($uni >= 0xA7C2 and $uni <= 0xA7C6);
	return "7.0" if($uni == 0xA7F7);
	return "6.1" if($uni >= 0xA7F8 and $uni <= 0xA7F9);
	return "6.0" if($uni == 0xA7FA);
	return "5.1" if($uni >= 0xA7FB and $uni <= 0xA7FF);
	return "4.1" if($uni >= 0xA800 and $uni <= 0xA82B);
	return "5.2" if($uni >= 0xA830 and $uni <= 0xA839);
	return "5.0" if($uni >= 0xA840 and $uni <= 0xA877);
	return "5.1" if($uni >= 0xA880 and $uni <= 0xA8C4);
	return "9.0" if($uni == 0xA8C5);
	return "5.1" if($uni >= 0xA8CE and $uni <= 0xA8D9);
	return "5.2" if($uni >= 0xA8E0 and $uni <= 0xA8FB);
	return "8.0" if($uni >= 0xA8FC and $uni <= 0xA8FD);
	return "11.0" if($uni >= 0xA8FE and $uni <= 0xA8FF);
	return "5.1" if($uni >= 0xA900 and $uni <= 0xA953);
	return "5.1" if($uni == 0xA95F);
	return "5.2" if($uni >= 0xA960 and $uni <= 0xA97C);
	return "5.2" if($uni >= 0xA980 and $uni <= 0xA9CD);
	return "5.2" if($uni >= 0xA9CF and $uni <= 0xA9D9);
	return "5.2" if($uni >= 0xA9DE and $uni <= 0xA9DF);
	return "7.0" if($uni >= 0xA9E0 and $uni <= 0xA9FE);
	return "5.1" if($uni >= 0xAA00 and $uni <= 0xAA36);
	return "5.1" if($uni >= 0xAA40 and $uni <= 0xAA4D);
	return "5.1" if($uni >= 0xAA50 and $uni <= 0xAA59);
	return "5.1" if($uni >= 0xAA5C and $uni <= 0xAA5F);
	return "5.2" if($uni >= 0xAA60 and $uni <= 0xAA7B);
	return "7.0" if($uni >= 0xAA7C and $uni <= 0xAA7F);
	return "5.2" if($uni >= 0xAA80 and $uni <= 0xAAC2);
	return "5.2" if($uni >= 0xAADB and $uni <= 0xAADF);
	return "6.1" if($uni >= 0xAAE0 and $uni <= 0xAAF6);
	return "6.0" if($uni >= 0xAB01 and $uni <= 0xAB06);
	return "6.0" if($uni >= 0xAB09 and $uni <= 0xAB0E);
	return "6.0" if($uni >= 0xAB11 and $uni <= 0xAB16);
	return "6.0" if($uni >= 0xAB20 and $uni <= 0xAB26);
	return "6.0" if($uni >= 0xAB28 and $uni <= 0xAB2E);
	return "7.0" if($uni >= 0xAB30 and $uni <= 0xAB5F);
	return "8.0" if($uni >= 0xAB60 and $uni <= 0xAB63);
	return "7.0" if($uni >= 0xAB64 and $uni <= 0xAB65);
	return "12.0" if($uni >= 0xAB66 and $uni <= 0xAB67);
	return "8.0" if($uni >= 0xAB70 and $uni <= 0xABBF);
	return "5.2" if($uni >= 0xABC0 and $uni <= 0xABED);
	return "5.2" if($uni >= 0xABF0 and $uni <= 0xABF9);
	return "2.0" if($uni >= 0xAC00 and $uni <= 0xD7A3);
	return "5.2" if($uni >= 0xD7B0 and $uni <= 0xD7C6);
	return "5.2" if($uni >= 0xD7CB and $uni <= 0xD7FB);
	return "2.0" if($uni >= 0xD800 and $uni <= 0xDFFF);
	return "1.1" if($uni >= 0xE000 and $uni <= 0xFA2D);
	return "6.1" if($uni >= 0xFA2E and $uni <= 0xFA2F);
	return "3.2" if($uni >= 0xFA30 and $uni <= 0xFA6A);
	return "5.2" if($uni >= 0xFA6B and $uni <= 0xFA6D);
	return "4.1" if($uni >= 0xFA70 and $uni <= 0xFAD9);
	return "1.1" if($uni >= 0xFB00 and $uni <= 0xFB06);
	return "1.1" if($uni >= 0xFB13 and $uni <= 0xFB17);
	return "3.0" if($uni == 0xFB1D);
	return "1.1" if($uni >= 0xFB1E and $uni <= 0xFB36);
	return "1.1" if($uni >= 0xFB38 and $uni <= 0xFB3C);
	return "1.1" if($uni == 0xFB3E);
	return "1.1" if($uni >= 0xFB40 and $uni <= 0xFB41);
	return "1.1" if($uni >= 0xFB43 and $uni <= 0xFB44);
	return "1.1" if($uni >= 0xFB46 and $uni <= 0xFBB1);
	return "6.0" if($uni >= 0xFBB2 and $uni <= 0xFBC1);
	return "1.1" if($uni >= 0xFBD3 and $uni <= 0xFD3F);
	return "1.1" if($uni >= 0xFD50 and $uni <= 0xFD8F);
	return "1.1" if($uni >= 0xFD92 and $uni <= 0xFDC7);
	return "3.1" if($uni >= 0xFDD0 and $uni <= 0xFDEF);
	return "1.1" if($uni >= 0xFDF0 and $uni <= 0xFDFB);
	return "3.2" if($uni == 0xFDFC);
	return "4.0" if($uni == 0xFDFD);
	return "3.2" if($uni >= 0xFE00 and $uni <= 0xFE0F);
	return "4.1" if($uni >= 0xFE10 and $uni <= 0xFE19);
	return "1.1" if($uni >= 0xFE20 and $uni <= 0xFE23);
	return "5.1" if($uni >= 0xFE24 and $uni <= 0xFE26);
	return "7.0" if($uni >= 0xFE27 and $uni <= 0xFE2D);
	return "8.0" if($uni >= 0xFE2E and $uni <= 0xFE2F);
	return "1.1" if($uni >= 0xFE30 and $uni <= 0xFE44);
	return "3.2" if($uni >= 0xFE45 and $uni <= 0xFE46);
	return "4.0" if($uni >= 0xFE47 and $uni <= 0xFE48);
	return "1.1" if($uni >= 0xFE49 and $uni <= 0xFE52);
	return "1.1" if($uni >= 0xFE54 and $uni <= 0xFE66);
	return "1.1" if($uni >= 0xFE68 and $uni <= 0xFE6B);
	return "1.1" if($uni >= 0xFE70 and $uni <= 0xFE72);
	return "3.2" if($uni == 0xFE73);
	return "1.1" if($uni == 0xFE74);
	return "1.1" if($uni >= 0xFE76 and $uni <= 0xFEFC);
	return "1.1" if($uni == 0xFEFF);
	return "1.1" if($uni >= 0xFF01 and $uni <= 0xFF5E);
	return "3.2" if($uni >= 0xFF5F and $uni <= 0xFF60);
	return "1.1" if($uni >= 0xFF61 and $uni <= 0xFFBE);
	return "1.1" if($uni >= 0xFFC2 and $uni <= 0xFFC7);
	return "1.1" if($uni >= 0xFFCA and $uni <= 0xFFCF);
	return "1.1" if($uni >= 0xFFD2 and $uni <= 0xFFD7);
	return "1.1" if($uni >= 0xFFDA and $uni <= 0xFFDC);
	return "1.1" if($uni >= 0xFFE0 and $uni <= 0xFFE6);
	return "1.1" if($uni >= 0xFFE8 and $uni <= 0xFFEE);
	return "3.0" if($uni >= 0xFFF9 and $uni <= 0xFFFB);
	return "2.1" if($uni == 0xFFFC);
	return "1.1" if($uni == 0xFFFD);
	return "1.1" if($uni >= 0xFFFE and $uni <= 0xFFFF);
	return "4.0" if($uni >= 0x10000 and $uni <= 0x1000B);
	return "4.0" if($uni >= 0x1000D and $uni <= 0x10026);
	return "4.0" if($uni >= 0x10028 and $uni <= 0x1003A);
	return "4.0" if($uni >= 0x1003C and $uni <= 0x1003D);
	return "4.0" if($uni >= 0x1003F and $uni <= 0x1004D);
	return "4.0" if($uni >= 0x10050 and $uni <= 0x1005D);
	return "4.0" if($uni >= 0x10080 and $uni <= 0x100FA);
	return "4.0" if($uni >= 0x10100 and $uni <= 0x10102);
	return "4.0" if($uni >= 0x10107 and $uni <= 0x10133);
	return "4.0" if($uni >= 0x10137 and $uni <= 0x1013F);
	return "4.1" if($uni >= 0x10140 and $uni <= 0x1018A);
	return "7.0" if($uni >= 0x1018B and $uni <= 0x1018C);
	return "9.0" if($uni >= 0x1018D and $uni <= 0x1018E);
	return "5.1" if($uni >= 0x10190 and $uni <= 0x1019B);
	return "7.0" if($uni == 0x101A0);
	return "5.1" if($uni >= 0x101D0 and $uni <= 0x101FD);
	return "5.1" if($uni >= 0x10280 and $uni <= 0x1029C);
	return "5.1" if($uni >= 0x102A0 and $uni <= 0x102D0);
	return "7.0" if($uni >= 0x102E0 and $uni <= 0x102FB);
	return "3.1" if($uni >= 0x10300 and $uni <= 0x1031E);
	return "7.0" if($uni == 0x1031F);
	return "3.1" if($uni >= 0x10320 and $uni <= 0x10323);
	return "10.0" if($uni >= 0x1032D and $uni <= 0x1032F);
	return "3.1" if($uni >= 0x10330 and $uni <= 0x1034A);
	return "7.0" if($uni >= 0x10350 and $uni <= 0x1037A);
	return "4.0" if($uni >= 0x10380 and $uni <= 0x1039D);
	return "4.0" if($uni == 0x1039F);
	return "4.1" if($uni >= 0x103A0 and $uni <= 0x103C3);
	return "4.1" if($uni >= 0x103C8 and $uni <= 0x103D5);
	return "3.1" if($uni >= 0x10400 and $uni <= 0x10425);
	return "4.0" if($uni >= 0x10426 and $uni <= 0x10427);
	return "3.1" if($uni >= 0x10428 and $uni <= 0x1044D);
	return "4.0" if($uni >= 0x1044E and $uni <= 0x1049D);
	return "4.0" if($uni >= 0x104A0 and $uni <= 0x104A9);
	return "9.0" if($uni >= 0x104B0 and $uni <= 0x104D3);
	return "9.0" if($uni >= 0x104D8 and $uni <= 0x104FB);
	return "7.0" if($uni >= 0x10500 and $uni <= 0x10527);
	return "7.0" if($uni >= 0x10530 and $uni <= 0x10563);
	return "7.0" if($uni == 0x1056F);
	return "7.0" if($uni >= 0x10600 and $uni <= 0x10736);
	return "7.0" if($uni >= 0x10740 and $uni <= 0x10755);
	return "7.0" if($uni >= 0x10760 and $uni <= 0x10767);
	return "4.0" if($uni >= 0x10800 and $uni <= 0x10805);
	return "4.0" if($uni == 0x10808);
	return "4.0" if($uni >= 0x1080A and $uni <= 0x10835);
	return "4.0" if($uni >= 0x10837 and $uni <= 0x10838);
	return "4.0" if($uni == 0x1083C);
	return "4.0" if($uni == 0x1083F);
	return "5.2" if($uni >= 0x10840 and $uni <= 0x10855);
	return "5.2" if($uni >= 0x10857 and $uni <= 0x1085F);
	return "7.0" if($uni >= 0x10860 and $uni <= 0x1089E);
	return "7.0" if($uni >= 0x108A7 and $uni <= 0x108AF);
	return "8.0" if($uni >= 0x108E0 and $uni <= 0x108F2);
	return "8.0" if($uni >= 0x108F4 and $uni <= 0x108F5);
	return "8.0" if($uni >= 0x108FB and $uni <= 0x108FF);
	return "5.0" if($uni >= 0x10900 and $uni <= 0x10919);
	return "5.2" if($uni >= 0x1091A and $uni <= 0x1091B);
	return "5.0" if($uni == 0x1091F);
	return "5.1" if($uni >= 0x10920 and $uni <= 0x10939);
	return "5.1" if($uni == 0x1093F);
	return "6.1" if($uni >= 0x10980 and $uni <= 0x109B7);
	return "8.0" if($uni >= 0x109BC and $uni <= 0x109BD);
	return "6.1" if($uni >= 0x109BE and $uni <= 0x109BF);
	return "8.0" if($uni >= 0x109C0 and $uni <= 0x109CF);
	return "8.0" if($uni >= 0x109D2 and $uni <= 0x109FF);
	return "4.1" if($uni >= 0x10A00 and $uni <= 0x10A03);
	return "4.1" if($uni >= 0x10A05 and $uni <= 0x10A06);
	return "4.1" if($uni >= 0x10A0C and $uni <= 0x10A13);
	return "4.1" if($uni >= 0x10A15 and $uni <= 0x10A17);
	return "4.1" if($uni >= 0x10A19 and $uni <= 0x10A33);
	return "11.0" if($uni >= 0x10A34 and $uni <= 0x10A35);
	return "4.1" if($uni >= 0x10A38 and $uni <= 0x10A3A);
	return "4.1" if($uni >= 0x10A3F and $uni <= 0x10A47);
	return "11.0" if($uni == 0x10A48);
	return "4.1" if($uni >= 0x10A50 and $uni <= 0x10A58);
	return "5.2" if($uni >= 0x10A60 and $uni <= 0x10A7F);
	return "7.0" if($uni >= 0x10A80 and $uni <= 0x10A9F);
	return "7.0" if($uni >= 0x10AC0 and $uni <= 0x10AE6);
	return "7.0" if($uni >= 0x10AEB and $uni <= 0x10AF6);
	return "5.2" if($uni >= 0x10B00 and $uni <= 0x10B35);
	return "5.2" if($uni >= 0x10B39 and $uni <= 0x10B55);
	return "5.2" if($uni >= 0x10B58 and $uni <= 0x10B72);
	return "5.2" if($uni >= 0x10B78 and $uni <= 0x10B7F);
	return "7.0" if($uni >= 0x10B80 and $uni <= 0x10B91);
	return "7.0" if($uni >= 0x10B99 and $uni <= 0x10B9C);
	return "7.0" if($uni >= 0x10BA9 and $uni <= 0x10BAF);
	return "5.2" if($uni >= 0x10C00 and $uni <= 0x10C48);
	return "8.0" if($uni >= 0x10C80 and $uni <= 0x10CB2);
	return "8.0" if($uni >= 0x10CC0 and $uni <= 0x10CF2);
	return "8.0" if($uni >= 0x10CFA and $uni <= 0x10CFF);
	return "11.0" if($uni >= 0x10D00 and $uni <= 0x10D27);
	return "11.0" if($uni >= 0x10D30 and $uni <= 0x10D39);
	return "5.2" if($uni >= 0x10E60 and $uni <= 0x10E7E);
	return "11.0" if($uni >= 0x10F00 and $uni <= 0x10F27);
	return "11.0" if($uni >= 0x10F30 and $uni <= 0x10F59);
	return "12.0" if($uni >= 0x10FE0 and $uni <= 0x10FF6);
	return "6.0" if($uni >= 0x11000 and $uni <= 0x1104D);
	return "6.0" if($uni >= 0x11052 and $uni <= 0x1106F);
	return "7.0" if($uni == 0x1107F);
	return "5.2" if($uni >= 0x11080 and $uni <= 0x110C1);
	return "11.0" if($uni == 0x110CD);
	return "6.1" if($uni >= 0x110D0 and $uni <= 0x110E8);
	return "6.1" if($uni >= 0x110F0 and $uni <= 0x110F9);
	return "6.1" if($uni >= 0x11100 and $uni <= 0x11134);
	return "6.1" if($uni >= 0x11136 and $uni <= 0x11143);
	return "11.0" if($uni >= 0x11144 and $uni <= 0x11146);
	return "7.0" if($uni >= 0x11150 and $uni <= 0x11176);
	return "6.1" if($uni >= 0x11180 and $uni <= 0x111C8);
	return "8.0" if($uni >= 0x111C9 and $uni <= 0x111CC);
	return "7.0" if($uni == 0x111CD);
	return "6.1" if($uni >= 0x111D0 and $uni <= 0x111D9);
	return "7.0" if($uni == 0x111DA);
	return "8.0" if($uni >= 0x111DB and $uni <= 0x111DF);
	return "7.0" if($uni >= 0x111E1 and $uni <= 0x111F4);
	return "7.0" if($uni >= 0x11200 and $uni <= 0x11211);
	return "7.0" if($uni >= 0x11213 and $uni <= 0x1123D);
	return "9.0" if($uni == 0x1123E);
	return "8.0" if($uni >= 0x11280 and $uni <= 0x11286);
	return "8.0" if($uni == 0x11288);
	return "8.0" if($uni >= 0x1128A and $uni <= 0x1128D);
	return "8.0" if($uni >= 0x1128F and $uni <= 0x1129D);
	return "8.0" if($uni >= 0x1129F and $uni <= 0x112A9);
	return "7.0" if($uni >= 0x112B0 and $uni <= 0x112EA);
	return "7.0" if($uni >= 0x112F0 and $uni <= 0x112F9);
	return "8.0" if($uni == 0x11300);
	return "7.0" if($uni >= 0x11301 and $uni <= 0x11303);
	return "7.0" if($uni >= 0x11305 and $uni <= 0x1130C);
	return "7.0" if($uni >= 0x1130F and $uni <= 0x11310);
	return "7.0" if($uni >= 0x11313 and $uni <= 0x11328);
	return "7.0" if($uni >= 0x1132A and $uni <= 0x11330);
	return "7.0" if($uni >= 0x11332 and $uni <= 0x11333);
	return "7.0" if($uni >= 0x11335 and $uni <= 0x11339);
	return "11.0" if($uni == 0x1133B);
	return "7.0" if($uni >= 0x1133C and $uni <= 0x11344);
	return "7.0" if($uni >= 0x11347 and $uni <= 0x11348);
	return "7.0" if($uni >= 0x1134B and $uni <= 0x1134D);
	return "8.0" if($uni == 0x11350);
	return "7.0" if($uni == 0x11357);
	return "7.0" if($uni >= 0x1135D and $uni <= 0x11363);
	return "7.0" if($uni >= 0x11366 and $uni <= 0x1136C);
	return "7.0" if($uni >= 0x11370 and $uni <= 0x11374);
	return "9.0" if($uni >= 0x11400 and $uni <= 0x11459);
	return "9.0" if($uni == 0x1145B);
	return "9.0" if($uni == 0x1145D);
	return "11.0" if($uni == 0x1145E);
	return "12.0" if($uni == 0x1145F);
	return "7.0" if($uni >= 0x11480 and $uni <= 0x114C7);
	return "7.0" if($uni >= 0x114D0 and $uni <= 0x114D9);
	return "7.0" if($uni >= 0x11580 and $uni <= 0x115B5);
	return "7.0" if($uni >= 0x115B8 and $uni <= 0x115C9);
	return "8.0" if($uni >= 0x115CA and $uni <= 0x115DD);
	return "7.0" if($uni >= 0x11600 and $uni <= 0x11644);
	return "7.0" if($uni >= 0x11650 and $uni <= 0x11659);
	return "9.0" if($uni >= 0x11660 and $uni <= 0x1166C);
	return "6.1" if($uni >= 0x11680 and $uni <= 0x116B7);
	return "12.0" if($uni == 0x116B8);
	return "6.1" if($uni >= 0x116C0 and $uni <= 0x116C9);
	return "8.0" if($uni >= 0x11700 and $uni <= 0x11719);
	return "11.0" if($uni == 0x1171A);
	return "8.0" if($uni >= 0x1171D and $uni <= 0x1172B);
	return "8.0" if($uni >= 0x11730 and $uni <= 0x1173F);
	return "11.0" if($uni >= 0x11800 and $uni <= 0x1183B);
	return "7.0" if($uni >= 0x118A0 and $uni <= 0x118F2);
	return "7.0" if($uni == 0x118FF);
	return "12.0" if($uni >= 0x119A0 and $uni <= 0x119A7);
	return "12.0" if($uni >= 0x119AA and $uni <= 0x119D7);
	return "12.0" if($uni >= 0x119DA and $uni <= 0x119E4);
	return "10.0" if($uni >= 0x11A00 and $uni <= 0x11A47);
	return "10.0" if($uni >= 0x11A50 and $uni <= 0x11A83);
	return "12.0" if($uni >= 0x11A84 and $uni <= 0x11A85);
	return "10.0" if($uni >= 0x11A86 and $uni <= 0x11A9C);
	return "11.0" if($uni == 0x11A9D);
	return "10.0" if($uni >= 0x11A9E and $uni <= 0x11AA2);
	return "7.0" if($uni >= 0x11AC0 and $uni <= 0x11AF8);
	return "9.0" if($uni >= 0x11C00 and $uni <= 0x11C08);
	return "9.0" if($uni >= 0x11C0A and $uni <= 0x11C36);
	return "9.0" if($uni >= 0x11C38 and $uni <= 0x11C45);
	return "9.0" if($uni >= 0x11C50 and $uni <= 0x11C6C);
	return "9.0" if($uni >= 0x11C70 and $uni <= 0x11C8F);
	return "9.0" if($uni >= 0x11C92 and $uni <= 0x11CA7);
	return "9.0" if($uni >= 0x11CA9 and $uni <= 0x11CB6);
	return "10.0" if($uni >= 0x11D00 and $uni <= 0x11D06);
	return "10.0" if($uni >= 0x11D08 and $uni <= 0x11D09);
	return "10.0" if($uni >= 0x11D0B and $uni <= 0x11D36);
	return "10.0" if($uni == 0x11D3A);
	return "10.0" if($uni >= 0x11D3C and $uni <= 0x11D3D);
	return "10.0" if($uni >= 0x11D3F and $uni <= 0x11D47);
	return "10.0" if($uni >= 0x11D50 and $uni <= 0x11D59);
	return "11.0" if($uni >= 0x11D60 and $uni <= 0x11D65);
	return "11.0" if($uni >= 0x11D67 and $uni <= 0x11D68);
	return "11.0" if($uni >= 0x11D6A and $uni <= 0x11D8E);
	return "11.0" if($uni >= 0x11D90 and $uni <= 0x11D91);
	return "11.0" if($uni >= 0x11D93 and $uni <= 0x11D98);
	return "11.0" if($uni >= 0x11DA0 and $uni <= 0x11DA9);
	return "11.0" if($uni >= 0x11EE0 and $uni <= 0x11EF8);
	return "12.0" if($uni >= 0x11FC0 and $uni <= 0x11FF1);
	return "12.0" if($uni == 0x11FFF);
	return "5.0" if($uni >= 0x12000 and $uni <= 0x1236E);
	return "7.0" if($uni >= 0x1236F and $uni <= 0x12398);
	return "8.0" if($uni == 0x12399);
	return "5.0" if($uni >= 0x12400 and $uni <= 0x12462);
	return "7.0" if($uni >= 0x12463 and $uni <= 0x1246E);
	return "5.0" if($uni >= 0x12470 and $uni <= 0x12473);
	return "7.0" if($uni == 0x12474);
	return "8.0" if($uni >= 0x12480 and $uni <= 0x12543);
	return "5.2" if($uni >= 0x13000 and $uni <= 0x1342E);
	return "12.0" if($uni >= 0x13430 and $uni <= 0x13438);
	return "8.0" if($uni >= 0x14400 and $uni <= 0x14646);
	return "6.0" if($uni >= 0x16800 and $uni <= 0x16A38);
	return "7.0" if($uni >= 0x16A40 and $uni <= 0x16A5E);
	return "7.0" if($uni >= 0x16A60 and $uni <= 0x16A69);
	return "7.0" if($uni >= 0x16A6E and $uni <= 0x16A6F);
	return "7.0" if($uni >= 0x16AD0 and $uni <= 0x16AED);
	return "7.0" if($uni >= 0x16AF0 and $uni <= 0x16AF5);
	return "7.0" if($uni >= 0x16B00 and $uni <= 0x16B45);
	return "7.0" if($uni >= 0x16B50 and $uni <= 0x16B59);
	return "7.0" if($uni >= 0x16B5B and $uni <= 0x16B61);
	return "7.0" if($uni >= 0x16B63 and $uni <= 0x16B77);
	return "7.0" if($uni >= 0x16B7D and $uni <= 0x16B8F);
	return "11.0" if($uni >= 0x16E40 and $uni <= 0x16E9A);
	return "6.1" if($uni >= 0x16F00 and $uni <= 0x16F44);
	return "12.0" if($uni >= 0x16F45 and $uni <= 0x16F4A);
	return "12.0" if($uni == 0x16F4F);
	return "6.1" if($uni >= 0x16F50 and $uni <= 0x16F7E);
	return "12.0" if($uni >= 0x16F7F and $uni <= 0x16F87);
	return "6.1" if($uni >= 0x16F8F and $uni <= 0x16F9F);
	return "9.0" if($uni == 0x16FE0);
	return "10.0" if($uni == 0x16FE1);
	return "12.0" if($uni >= 0x16FE2 and $uni <= 0x16FE3);
	return "9.0" if($uni >= 0x17000 and $uni <= 0x187EC);
	return "11.0" if($uni >= 0x187ED and $uni <= 0x187F1);
	return "12.0" if($uni >= 0x187F2 and $uni <= 0x187F7);
	return "9.0" if($uni >= 0x18800 and $uni <= 0x18AF2);
	return "6.0" if($uni >= 0x1B000 and $uni <= 0x1B001);
	return "10.0" if($uni >= 0x1B002 and $uni <= 0x1B11E);
	return "12.0" if($uni >= 0x1B150 and $uni <= 0x1B152);
	return "12.0" if($uni >= 0x1B164 and $uni <= 0x1B167);
	return "10.0" if($uni >= 0x1B170 and $uni <= 0x1B2FB);
	return "7.0" if($uni >= 0x1BC00 and $uni <= 0x1BC6A);
	return "7.0" if($uni >= 0x1BC70 and $uni <= 0x1BC7C);
	return "7.0" if($uni >= 0x1BC80 and $uni <= 0x1BC88);
	return "7.0" if($uni >= 0x1BC90 and $uni <= 0x1BC99);
	return "7.0" if($uni >= 0x1BC9C and $uni <= 0x1BCA3);
	return "3.1" if($uni >= 0x1D000 and $uni <= 0x1D0F5);
	return "3.1" if($uni >= 0x1D100 and $uni <= 0x1D126);
	return "5.1" if($uni == 0x1D129);
	return "3.1" if($uni >= 0x1D12A and $uni <= 0x1D1DD);
	return "8.0" if($uni >= 0x1D1DE and $uni <= 0x1D1E8);
	return "4.1" if($uni >= 0x1D200 and $uni <= 0x1D245);
	return "11.0" if($uni >= 0x1D2E0 and $uni <= 0x1D2F3);
	return "4.0" if($uni >= 0x1D300 and $uni <= 0x1D356);
	return "5.0" if($uni >= 0x1D360 and $uni <= 0x1D371);
	return "11.0" if($uni >= 0x1D372 and $uni <= 0x1D378);
	return "3.1" if($uni >= 0x1D400 and $uni <= 0x1D454);
	return "3.1" if($uni >= 0x1D456 and $uni <= 0x1D49C);
	return "3.1" if($uni >= 0x1D49E and $uni <= 0x1D49F);
	return "3.1" if($uni == 0x1D4A2);
	return "3.1" if($uni >= 0x1D4A5 and $uni <= 0x1D4A6);
	return "3.1" if($uni >= 0x1D4A9 and $uni <= 0x1D4AC);
	return "3.1" if($uni >= 0x1D4AE and $uni <= 0x1D4B9);
	return "3.1" if($uni == 0x1D4BB);
	return "3.1" if($uni >= 0x1D4BD and $uni <= 0x1D4C0);
	return "4.0" if($uni == 0x1D4C1);
	return "3.1" if($uni >= 0x1D4C2 and $uni <= 0x1D4C3);
	return "3.1" if($uni >= 0x1D4C5 and $uni <= 0x1D505);
	return "3.1" if($uni >= 0x1D507 and $uni <= 0x1D50A);
	return "3.1" if($uni >= 0x1D50D and $uni <= 0x1D514);
	return "3.1" if($uni >= 0x1D516 and $uni <= 0x1D51C);
	return "3.1" if($uni >= 0x1D51E and $uni <= 0x1D539);
	return "3.1" if($uni >= 0x1D53B and $uni <= 0x1D53E);
	return "3.1" if($uni >= 0x1D540 and $uni <= 0x1D544);
	return "3.1" if($uni == 0x1D546);
	return "3.1" if($uni >= 0x1D54A and $uni <= 0x1D550);
	return "3.1" if($uni >= 0x1D552 and $uni <= 0x1D6A3);
	return "4.1" if($uni >= 0x1D6A4 and $uni <= 0x1D6A5);
	return "3.1" if($uni >= 0x1D6A8 and $uni <= 0x1D7C9);
	return "5.0" if($uni >= 0x1D7CA and $uni <= 0x1D7CB);
	return "3.1" if($uni >= 0x1D7CE and $uni <= 0x1D7FF);
	return "8.0" if($uni >= 0x1D800 and $uni <= 0x1DA8B);
	return "8.0" if($uni >= 0x1DA9B and $uni <= 0x1DA9F);
	return "8.0" if($uni >= 0x1DAA1 and $uni <= 0x1DAAF);
	return "9.0" if($uni >= 0x1E000 and $uni <= 0x1E006);
	return "9.0" if($uni >= 0x1E008 and $uni <= 0x1E018);
	return "9.0" if($uni >= 0x1E01B and $uni <= 0x1E021);
	return "9.0" if($uni >= 0x1E023 and $uni <= 0x1E024);
	return "9.0" if($uni >= 0x1E026 and $uni <= 0x1E02A);
	return "12.0" if($uni >= 0x1E100 and $uni <= 0x1E12C);
	return "12.0" if($uni >= 0x1E130 and $uni <= 0x1E13D);
	return "12.0" if($uni >= 0x1E140 and $uni <= 0x1E149);
	return "12.0" if($uni >= 0x1E14E and $uni <= 0x1E14F);
	return "12.0" if($uni >= 0x1E2C0 and $uni <= 0x1E2F9);
	return "12.0" if($uni == 0x1E2FF);
	return "7.0" if($uni >= 0x1E800 and $uni <= 0x1E8C4);
	return "7.0" if($uni >= 0x1E8C7 and $uni <= 0x1E8D6);
	return "9.0" if($uni >= 0x1E900 and $uni <= 0x1E94A);
	return "12.0" if($uni == 0x1E94B);
	return "9.0" if($uni >= 0x1E950 and $uni <= 0x1E959);
	return "9.0" if($uni >= 0x1E95E and $uni <= 0x1E95F);
	return "11.0" if($uni >= 0x1EC71 and $uni <= 0x1ECB4);
	return "12.0" if($uni >= 0x1ED01 and $uni <= 0x1ED3D);
	return "6.1" if($uni >= 0x1EE00 and $uni <= 0x1EE03);
	return "6.1" if($uni >= 0x1EE05 and $uni <= 0x1EE1F);
	return "6.1" if($uni >= 0x1EE21 and $uni <= 0x1EE22);
	return "6.1" if($uni == 0x1EE24);
	return "6.1" if($uni == 0x1EE27);
	return "6.1" if($uni >= 0x1EE29 and $uni <= 0x1EE32);
	return "6.1" if($uni >= 0x1EE34 and $uni <= 0x1EE37);
	return "6.1" if($uni == 0x1EE39);
	return "6.1" if($uni == 0x1EE3B);
	return "6.1" if($uni == 0x1EE42);
	return "6.1" if($uni == 0x1EE47);
	return "6.1" if($uni == 0x1EE49);
	return "6.1" if($uni == 0x1EE4B);
	return "6.1" if($uni >= 0x1EE4D and $uni <= 0x1EE4F);
	return "6.1" if($uni >= 0x1EE51 and $uni <= 0x1EE52);
	return "6.1" if($uni == 0x1EE54);
	return "6.1" if($uni == 0x1EE57);
	return "6.1" if($uni == 0x1EE59);
	return "6.1" if($uni == 0x1EE5B);
	return "6.1" if($uni == 0x1EE5D);
	return "6.1" if($uni == 0x1EE5F);
	return "6.1" if($uni >= 0x1EE61 and $uni <= 0x1EE62);
	return "6.1" if($uni == 0x1EE64);
	return "6.1" if($uni >= 0x1EE67 and $uni <= 0x1EE6A);
	return "6.1" if($uni >= 0x1EE6C and $uni <= 0x1EE72);
	return "6.1" if($uni >= 0x1EE74 and $uni <= 0x1EE77);
	return "6.1" if($uni >= 0x1EE79 and $uni <= 0x1EE7C);
	return "6.1" if($uni == 0x1EE7E);
	return "6.1" if($uni >= 0x1EE80 and $uni <= 0x1EE89);
	return "6.1" if($uni >= 0x1EE8B and $uni <= 0x1EE9B);
	return "6.1" if($uni >= 0x1EEA1 and $uni <= 0x1EEA3);
	return "6.1" if($uni >= 0x1EEA5 and $uni <= 0x1EEA9);
	return "6.1" if($uni >= 0x1EEAB and $uni <= 0x1EEBB);
	return "6.1" if($uni >= 0x1EEF0 and $uni <= 0x1EEF1);
	return "5.1" if($uni >= 0x1F000 and $uni <= 0x1F02B);
	return "5.1" if($uni >= 0x1F030 and $uni <= 0x1F093);
	return "6.0" if($uni >= 0x1F0A0 and $uni <= 0x1F0AE);
	return "6.0" if($uni >= 0x1F0B1 and $uni <= 0x1F0BE);
	return "7.0" if($uni == 0x1F0BF);
	return "6.0" if($uni >= 0x1F0C1 and $uni <= 0x1F0CF);
	return "6.0" if($uni >= 0x1F0D1 and $uni <= 0x1F0DF);
	return "7.0" if($uni >= 0x1F0E0 and $uni <= 0x1F0F5);
	return "5.2" if($uni >= 0x1F100 and $uni <= 0x1F10A);
	return "7.0" if($uni >= 0x1F10B and $uni <= 0x1F10C);
	return "5.2" if($uni >= 0x1F110 and $uni <= 0x1F12E);
	return "11.0" if($uni == 0x1F12F);
	return "6.0" if($uni == 0x1F130);
	return "5.2" if($uni == 0x1F131);
	return "6.0" if($uni >= 0x1F132 and $uni <= 0x1F13C);
	return "5.2" if($uni == 0x1F13D);
	return "6.0" if($uni == 0x1F13E);
	return "5.2" if($uni == 0x1F13F);
	return "6.0" if($uni >= 0x1F140 and $uni <= 0x1F141);
	return "5.2" if($uni == 0x1F142);
	return "6.0" if($uni >= 0x1F143 and $uni <= 0x1F145);
	return "5.2" if($uni == 0x1F146);
	return "6.0" if($uni >= 0x1F147 and $uni <= 0x1F149);
	return "5.2" if($uni >= 0x1F14A and $uni <= 0x1F14E);
	return "6.0" if($uni >= 0x1F14F and $uni <= 0x1F156);
	return "5.2" if($uni == 0x1F157);
	return "6.0" if($uni >= 0x1F158 and $uni <= 0x1F15E);
	return "5.2" if($uni == 0x1F15F);
	return "6.0" if($uni >= 0x1F160 and $uni <= 0x1F169);
	return "6.1" if($uni >= 0x1F16A and $uni <= 0x1F16B);
	return "12.0" if($uni == 0x1F16C);
	return "6.0" if($uni >= 0x1F170 and $uni <= 0x1F178);
	return "5.2" if($uni == 0x1F179);
	return "6.0" if($uni == 0x1F17A);
	return "5.2" if($uni >= 0x1F17B and $uni <= 0x1F17C);
	return "6.0" if($uni >= 0x1F17D and $uni <= 0x1F17E);
	return "5.2" if($uni == 0x1F17F);
	return "6.0" if($uni >= 0x1F180 and $uni <= 0x1F189);
	return "5.2" if($uni >= 0x1F18A and $uni <= 0x1F18D);
	return "6.0" if($uni >= 0x1F18E and $uni <= 0x1F18F);
	return "5.2" if($uni == 0x1F190);
	return "6.0" if($uni >= 0x1F191 and $uni <= 0x1F19A);
	return "9.0" if($uni >= 0x1F19B and $uni <= 0x1F1AC);
	return "6.0" if($uni >= 0x1F1E6 and $uni <= 0x1F1FF);
	return "5.2" if($uni == 0x1F200);
	return "6.0" if($uni >= 0x1F201 and $uni <= 0x1F202);
	return "5.2" if($uni >= 0x1F210 and $uni <= 0x1F231);
	return "6.0" if($uni >= 0x1F232 and $uni <= 0x1F23A);
	return "9.0" if($uni == 0x1F23B);
	return "5.2" if($uni >= 0x1F240 and $uni <= 0x1F248);
	return "6.0" if($uni >= 0x1F250 and $uni <= 0x1F251);
	return "10.0" if($uni >= 0x1F260 and $uni <= 0x1F265);
	return "6.0" if($uni >= 0x1F300 and $uni <= 0x1F320);
	return "7.0" if($uni >= 0x1F321 and $uni <= 0x1F32C);
	return "8.0" if($uni >= 0x1F32D and $uni <= 0x1F32F);
	return "6.0" if($uni >= 0x1F330 and $uni <= 0x1F335);
	return "7.0" if($uni == 0x1F336);
	return "6.0" if($uni >= 0x1F337 and $uni <= 0x1F37C);
	return "7.0" if($uni == 0x1F37D);
	return "8.0" if($uni >= 0x1F37E and $uni <= 0x1F37F);
	return "6.0" if($uni >= 0x1F380 and $uni <= 0x1F393);
	return "7.0" if($uni >= 0x1F394 and $uni <= 0x1F39F);
	return "6.0" if($uni >= 0x1F3A0 and $uni <= 0x1F3C4);
	return "7.0" if($uni == 0x1F3C5);
	return "6.0" if($uni >= 0x1F3C6 and $uni <= 0x1F3CA);
	return "7.0" if($uni >= 0x1F3CB and $uni <= 0x1F3CE);
	return "8.0" if($uni >= 0x1F3CF and $uni <= 0x1F3D3);
	return "7.0" if($uni >= 0x1F3D4 and $uni <= 0x1F3DF);
	return "6.0" if($uni >= 0x1F3E0 and $uni <= 0x1F3F0);
	return "7.0" if($uni >= 0x1F3F1 and $uni <= 0x1F3F7);
	return "8.0" if($uni >= 0x1F3F8 and $uni <= 0x1F3FF);
	return "6.0" if($uni >= 0x1F400 and $uni <= 0x1F43E);
	return "7.0" if($uni == 0x1F43F);
	return "6.0" if($uni == 0x1F440);
	return "7.0" if($uni == 0x1F441);
	return "6.0" if($uni >= 0x1F442 and $uni <= 0x1F4F7);
	return "7.0" if($uni == 0x1F4F8);
	return "6.0" if($uni >= 0x1F4F9 and $uni <= 0x1F4FC);
	return "7.0" if($uni >= 0x1F4FD and $uni <= 0x1F4FE);
	return "8.0" if($uni == 0x1F4FF);
	return "6.0" if($uni >= 0x1F500 and $uni <= 0x1F53D);
	return "7.0" if($uni >= 0x1F53E and $uni <= 0x1F53F);
	return "6.1" if($uni >= 0x1F540 and $uni <= 0x1F543);
	return "7.0" if($uni >= 0x1F544 and $uni <= 0x1F54A);
	return "8.0" if($uni >= 0x1F54B and $uni <= 0x1F54F);
	return "6.0" if($uni >= 0x1F550 and $uni <= 0x1F567);
	return "7.0" if($uni >= 0x1F568 and $uni <= 0x1F579);
	return "9.0" if($uni == 0x1F57A);
	return "7.0" if($uni >= 0x1F57B and $uni <= 0x1F5A3);
	return "9.0" if($uni == 0x1F5A4);
	return "7.0" if($uni >= 0x1F5A5 and $uni <= 0x1F5FA);
	return "6.0" if($uni >= 0x1F5FB and $uni <= 0x1F5FF);
	return "6.1" if($uni == 0x1F600);
	return "6.0" if($uni >= 0x1F601 and $uni <= 0x1F610);
	return "6.1" if($uni == 0x1F611);
	return "6.0" if($uni >= 0x1F612 and $uni <= 0x1F614);
	return "6.1" if($uni == 0x1F615);
	return "6.0" if($uni == 0x1F616);
	return "6.1" if($uni == 0x1F617);
	return "6.0" if($uni == 0x1F618);
	return "6.1" if($uni == 0x1F619);
	return "6.0" if($uni == 0x1F61A);
	return "6.1" if($uni == 0x1F61B);
	return "6.0" if($uni >= 0x1F61C and $uni <= 0x1F61E);
	return "6.1" if($uni == 0x1F61F);
	return "6.0" if($uni >= 0x1F620 and $uni <= 0x1F625);
	return "6.1" if($uni >= 0x1F626 and $uni <= 0x1F627);
	return "6.0" if($uni >= 0x1F628 and $uni <= 0x1F62B);
	return "6.1" if($uni == 0x1F62C);
	return "6.0" if($uni == 0x1F62D);
	return "6.1" if($uni >= 0x1F62E and $uni <= 0x1F62F);
	return "6.0" if($uni >= 0x1F630 and $uni <= 0x1F633);
	return "6.1" if($uni == 0x1F634);
	return "6.0" if($uni >= 0x1F635 and $uni <= 0x1F640);
	return "7.0" if($uni >= 0x1F641 and $uni <= 0x1F642);
	return "8.0" if($uni >= 0x1F643 and $uni <= 0x1F644);
	return "6.0" if($uni >= 0x1F645 and $uni <= 0x1F64F);
	return "7.0" if($uni >= 0x1F650 and $uni <= 0x1F67F);
	return "6.0" if($uni >= 0x1F680 and $uni <= 0x1F6C5);
	return "7.0" if($uni >= 0x1F6C6 and $uni <= 0x1F6CF);
	return "8.0" if($uni == 0x1F6D0);
	return "9.0" if($uni >= 0x1F6D1 and $uni <= 0x1F6D2);
	return "10.0" if($uni >= 0x1F6D3 and $uni <= 0x1F6D4);
	return "12.0" if($uni == 0x1F6D5);
	return "7.0" if($uni >= 0x1F6E0 and $uni <= 0x1F6EC);
	return "7.0" if($uni >= 0x1F6F0 and $uni <= 0x1F6F3);
	return "9.0" if($uni >= 0x1F6F4 and $uni <= 0x1F6F6);
	return "10.0" if($uni >= 0x1F6F7 and $uni <= 0x1F6F8);
	return "11.0" if($uni == 0x1F6F9);
	return "12.0" if($uni == 0x1F6FA);
	return "6.0" if($uni >= 0x1F700 and $uni <= 0x1F773);
	return "7.0" if($uni >= 0x1F780 and $uni <= 0x1F7D4);
	return "11.0" if($uni >= 0x1F7D5 and $uni <= 0x1F7D8);
	return "12.0" if($uni >= 0x1F7E0 and $uni <= 0x1F7EB);
	return "7.0" if($uni >= 0x1F800 and $uni <= 0x1F80B);
	return "7.0" if($uni >= 0x1F810 and $uni <= 0x1F847);
	return "7.0" if($uni >= 0x1F850 and $uni <= 0x1F859);
	return "7.0" if($uni >= 0x1F860 and $uni <= 0x1F887);
	return "7.0" if($uni >= 0x1F890 and $uni <= 0x1F8AD);
	return "10.0" if($uni >= 0x1F900 and $uni <= 0x1F90B);
	return "12.0" if($uni >= 0x1F90D and $uni <= 0x1F90F);
	return "8.0" if($uni >= 0x1F910 and $uni <= 0x1F918);
	return "9.0" if($uni >= 0x1F919 and $uni <= 0x1F91E);
	return "10.0" if($uni == 0x1F91F);
	return "9.0" if($uni >= 0x1F920 and $uni <= 0x1F927);
	return "10.0" if($uni >= 0x1F928 and $uni <= 0x1F92F);
	return "9.0" if($uni == 0x1F930);
	return "10.0" if($uni >= 0x1F931 and $uni <= 0x1F932);
	return "9.0" if($uni >= 0x1F933 and $uni <= 0x1F93E);
	return "12.0" if($uni == 0x1F93F);
	return "9.0" if($uni >= 0x1F940 and $uni <= 0x1F94B);
	return "10.0" if($uni == 0x1F94C);
	return "11.0" if($uni >= 0x1F94D and $uni <= 0x1F94F);
	return "9.0" if($uni >= 0x1F950 and $uni <= 0x1F95E);
	return "10.0" if($uni >= 0x1F95F and $uni <= 0x1F96B);
	return "11.0" if($uni >= 0x1F96C and $uni <= 0x1F970);
	return "12.0" if($uni == 0x1F971);
	return "11.0" if($uni >= 0x1F973 and $uni <= 0x1F976);
	return "11.0" if($uni == 0x1F97A);
	return "12.0" if($uni == 0x1F97B);
	return "11.0" if($uni >= 0x1F97C and $uni <= 0x1F97F);
	return "8.0" if($uni >= 0x1F980 and $uni <= 0x1F984);
	return "9.0" if($uni >= 0x1F985 and $uni <= 0x1F991);
	return "10.0" if($uni >= 0x1F992 and $uni <= 0x1F997);
	return "11.0" if($uni >= 0x1F998 and $uni <= 0x1F9A2);
	return "12.0" if($uni >= 0x1F9A5 and $uni <= 0x1F9AA);
	return "12.0" if($uni >= 0x1F9AE and $uni <= 0x1F9AF);
	return "11.0" if($uni >= 0x1F9B0 and $uni <= 0x1F9B9);
	return "12.0" if($uni >= 0x1F9BA and $uni <= 0x1F9BF);
	return "8.0" if($uni == 0x1F9C0);
	return "11.0" if($uni >= 0x1F9C1 and $uni <= 0x1F9C2);
	return "12.0" if($uni >= 0x1F9C3 and $uni <= 0x1F9CA);
	return "12.0" if($uni >= 0x1F9CD and $uni <= 0x1F9CF);
	return "10.0" if($uni >= 0x1F9D0 and $uni <= 0x1F9E6);
	return "11.0" if($uni >= 0x1F9E7 and $uni <= 0x1F9FF);
	return "12.0" if($uni >= 0x1FA00 and $uni <= 0x1FA53);
	return "11.0" if($uni >= 0x1FA60 and $uni <= 0x1FA6D);
	return "12.0" if($uni >= 0x1FA70 and $uni <= 0x1FA73);
	return "12.0" if($uni >= 0x1FA78 and $uni <= 0x1FA7A);
	return "12.0" if($uni >= 0x1FA80 and $uni <= 0x1FA82);
	return "12.0" if($uni >= 0x1FA90 and $uni <= 0x1FA95);
	return "2.0" if($uni >= 0x1FFFE and $uni <= 0x1FFFF);
	return "3.1" if($uni >= 0x20000 and $uni <= 0x2A6D6);
	return "13.0" if($uni >= 0x2A6D7 and $uni <= 0x2A6DD);
	return "14.0" if($uni >= 0x2A6DE and $uni <= 0x2A6DF);
	return "5.2" if($uni >= 0x2A700 and $uni <= 0x2B734);
	return "14.0" if($uni >= 0x2B735 and $uni <= 0x2B738);
	return "6.0" if($uni >= 0x2B740 and $uni <= 0x2B81D);
	return "8.0" if($uni >= 0x2B820 and $uni <= 0x2CEA1);
	return "10.0" if($uni >= 0x2CEB0 and $uni <= 0x2EBE0);
	return "3.1" if($uni >= 0x2F800 and $uni <= 0x2FA1D);
	return "13.0" if($uni >= 0x30000 and $uni <= 0x3134A);

	return "2.0" if($uni >= 0x2FFFE and $uni <= 0x2FFFF);
	return "2.0" if($uni >= 0x3FFFE and $uni <= 0x3FFFF);
	return "2.0" if($uni >= 0x4FFFE and $uni <= 0x4FFFF);
	return "2.0" if($uni >= 0x5FFFE and $uni <= 0x5FFFF);
	return "2.0" if($uni >= 0x6FFFE and $uni <= 0x6FFFF);
	return "2.0" if($uni >= 0x7FFFE and $uni <= 0x7FFFF);
	return "2.0" if($uni >= 0x8FFFE and $uni <= 0x8FFFF);
	return "2.0" if($uni >= 0x9FFFE and $uni <= 0x9FFFF);
	return "2.0" if($uni >= 0xAFFFE and $uni <= 0xAFFFF);
	return "2.0" if($uni >= 0xBFFFE and $uni <= 0xBFFFF);
	return "2.0" if($uni >= 0xCFFFE and $uni <= 0xCFFFF);
	return "2.0" if($uni >= 0xDFFFE and $uni <= 0xDFFFF);
	return "3.1" if($uni == 0xE0001);
	return "3.1" if($uni >= 0xE0020 and $uni <= 0xE007F);
	return "4.0" if($uni >= 0xE0100 and $uni <= 0xE01EF);
	return "2.0" if($uni >= 0xEFFFE and $uni <= 0xEFFFF);
	return "2.0" if($uni >= 0xF0000 and $uni <= 0xFFFFD);
	return "2.0" if($uni >= 0xFFFFE and $uni <= 0xFFFFF);
	return "2.0" if($uni >= 0x100000 and $uni <= 0x10FFFD);
	return "2.0" if($uni >= 0x10FFFE and $uni <= 0x10FFFF);
	return "999";
}


package CB_xml;
use Carp;

=BEGIN

儲存 XML 的資訊

宣告 : $xmltag = new cb_xml();

使用法 :

$self->pushtag($tag, %att);			# 將 tag 資訊推入陣列
($tag , %att) = $self->poptag();	# 將陣列資料 pop 出來
$self->intag("div");				# 目前是否在 div 標記之內, 正確傳回 1, 否則傳回 0

資料結構 :

$self->tags[0]{"tag"}
$self->tags[0]{"att"}{"type"}
$self->tags[0]{"margin-left"}
$self->tags[0]{"text-indent"}

=END
=cut

my %field = (
	tags => [],	# 裡面是陣列, 陣列中是雜湊
	data => "",	# 暫存的資料區
);

# 建構式
sub new 
{
	my $type = shift;
	my $class = ref($type) || $type;

	my $self = {
        %field,
	};
	bless $self, $class;
	
	$self->_initialize();	#初值化, 讀入資料庫
	
	return $self;
}

# 解構式
sub DESTROY {
	my $self = shift;
	#printf("$self dying at %s\n", scalar localtime);
}

# 自動載入, 若呼叫該物件沒有定義的函數, 則執行本函數, 底下是用來讀取及設定成員變數
sub AUTOLOAD
{
	my $self = shift;
	my $type = ref($self) || croak "$self is not an object";
	
	my $name = $AUTOLOAD;
	$name =~ s/.*:://;
	
	# 若傳入的方法不是成員變數就離開
	croak "No such attribute: $name" unless exists $self->{$name};
	
	$self->{$name} = shift if(@_);
	return $self->{$name};
}

# 一般的成員函數
# 初值化, 讀入資料庫
sub _initialize
{
}

# 傳入二個參數 $tag 及 %att , 要存入變數中
sub pushtag
{
	my $self = shift;
	my $tag = shift;
	my %att = @_;

	# 判斷有沒有 rend="margin-left:1em;text-indent:2em"
	my $margin_left = 0;
	my $text_indent = 0;
	if($att{"rend"})
	{
		if($att{"rend"} =~ /margin\-left:(.*?)em/)
		{
			$margin_left = $1;
		}
		if($att{"rend"} =~ /text\-indent:(.*?)em/)
		{
			$text_indent = $1;
		}
	}

	my %hash = ("tag" => $tag , "att" => \%att , "margin-left" => $margin_left , "text-indent" => $text_indent);
	push(@{$self->{"tags"}} , \%hash);
}

# 取出 $tag 及 %att , 要存入變數中
sub poptag
{
	my $self = shift;
	my $hash = pop(@{$self->{"tags"}});
	return ($hash->{"tag"} , $hash->{"margin-left"} , $hash->{"text-indent"} , %{$hash->{"att"}});
}

# 是否有 $tag 變數在陣列中, 若有傳回在第幾層, 最外層是 1 , 不是 0 喔.
sub intag
{
	my $self = shift;
	my $tag = shift;
	
	for($i=0; $i<=$#{$self->{"tags"}}; $i++)
	{
		return $i+1 if($self->{"tags"}[$i]{"tag"} eq $tag);
	}
	
	return 0;
}

package SutraID;
use Moo;
use utf8;

=BEGIN

傳入經號 ID , 有二種

T01n0001
T01n0001_001

使用法:
	my $id = SutraID->new();
	$id->init("T01n0001");

成功的話 $id->ok = 1
取得屬性 $id->ed

相關屬性

ed : T
vol : T01
vol_num : 01
sutra_id : T01n0001 , T02n0128a
sutra_id_ : T01n0001_ , T02n0128a
sutra_num : 0001 , 0128a
sutra_num_ : 0001 , 0128a
juan : 001

=END
=cut
has 'source' => (is => 'rw');
has 'ok' => (is => 'rw');

has 'ed' => (is => 'rw');
has 'vol' => (is => 'rw');
has 'vol_num' => (is => 'rw');
has 'sutra_id' => (is => 'rw');
has 'sutra_id_' => (is => 'rw');
has 'sutra_num' => (is => 'rw');
has 'sutra_num_' => (is => 'rw');
has 'juan' => (is => 'rw');

sub init
{
    my $self = shift;
    local $_ = shift;

	$self->source($_);

	#T01n0001_ , T02n0128a
	#T01n0001_001 , T02n0128a_001

	if(/^(\D+)(\d+)n([^_]{4,5})(?:_(\d{3}))?$/)
	{
		$self->ed($1);
		$self->vol_num($2);
		$self->sutra_num($3);
		$self->juan($4);

		$self->vol($1 . $2);
		$self->sutra_num_($3);
		if(length($self->sutra_num) == 4)
		{
			$self->sutra_num_($self->sutra_num . "_");
		}
		else
		{
			$self->sutra_num_($self->sutra_num);	
		}
		$self->sutra_id_($1.$2."n".$self->sutra_num_);
		$self->sutra_id($1.$2."n".$self->sutra_num);
		if(!defined($self->juan)) {$self->juan("");}
		$self->ok(1);
	}
	else
	{
		$self->ok(0);
	}
}

# 測試結果
sub show_all
{
    my $self = shift;

	if($self->ok == 0)
	{
		print "source : " . $self->source . "\n";
		print "format error\n";
		return;
	}
	print "source : " . $self->source . "\n";
	print "ed : " . $self->ed . "\n";
	print "vol : " . $self->vol . "\n";
	print "vol_num : " . $self->vol_num . "\n";
	print "sutra_num_ : " . $self->sutra_num_ . "\n";
	print "sutra_num : " . $self->sutra_num . "\n";
	print "sutra_id_ : " . $self->sutra_id_ . "\n";
	print "sutra_id : " . $self->sutra_id . "\n";
	print "juan : " . $self->juan . "\n";
}


package Taisho;
use utf8;

=BEGIN

取得大正藏部別

get_part("0001") => "阿含部";

=END
=cut

# 由經號傳回部別
sub get_part_by_sutranum
{
	my $id = shift;
	if($id !~ /^\d{4}[a-z]?$/i)
	{
		$id =~ s/^T//;
		$id = "00000" . $id;
		$id =~ s/^.*(\d{4}[a-z]?)$/$1/i;
	}
	if(($id ge "0001") && ($id le "0151")) { return("阿含部"); }
	if(($id ge "0152") && ($id le "0219")) { return("本緣部"); }
	if(($id ge "0220") && ($id le "0261")) { return("般若部"); }
	if(($id ge "0262") && ($id le "0277")) { return("法華部"); }
	if(($id ge "0278") && ($id le "0309")) { return("華嚴部"); }
	if(($id ge "0310") && ($id le "0373")) { return("寶積部"); }
	if(($id ge "0374") && ($id le "0396")) { return("涅槃部"); }
	if(($id ge "0397") && ($id le "0424")) { return("大集部"); }
	if(($id ge "0425") && ($id le "0847")) { return("經集部"); }
	if(($id ge "0848") && ($id le "1420")) { return("密教部"); }
	if(($id ge "1421") && ($id le "1504")) { return("律部"); }
	if(($id ge "1505") && ($id le "1535")) { return("釋經論部"); }
	if(($id ge "1536") && ($id le "1563")) { return("毘曇部"); }
	if(($id ge "1564") && ($id le "1578")) { return("中觀部"); }
	if(($id ge "1579") && ($id le "1627")) { return("瑜伽部"); }
	if(($id ge "1628") && ($id le "1692")) { return("論集部"); }
	if(($id ge "1693") && ($id le "1803")) { return("經疏部"); }
	if(($id ge "1804") && ($id le "1815")) { return("律疏部"); }
	if(($id ge "1816") && ($id le "1850")) { return("論疏部"); }
	if(($id ge "1851") && ($id le "2025")) { return("諸宗部"); }
	if(($id ge "2026") && ($id le "2120")) { return("史傳部"); }
	if(($id ge "2121") && ($id le "2136")) { return("事彙部"); }
	if(($id ge "2137") && ($id le "2144")) { return("外教部"); }
	if(($id ge "2145") && ($id le "2184")) { return("目錄部"); }
	if(($id ge "2732") && ($id le "2864")) { return("古逸部"); }
	if(($id ge "2865") && ($id le "2920")) { return("疑似部"); }
	return "";
}

=BEGIN
T , 阿含部類 , 阿含部 , 01 , 0001 , 22 , 長阿含經 , 後秦 佛陀耶舍共竺佛念譯
T , 阿含部類 , 阿含部 , 02 , 0151 , 1 , 佛說阿含正行經 , 後漢 安世高譯
T , 本緣部類 , 本緣部 , 03 , 0152 , 8 , 六度集經 , 吳 康僧會譯
T , 本緣部類 , 本緣部 , 04 , 0219 , 1 , 醫喻經 , 宋 施護譯
T , 般若部類 , 般若部 , 05 , 0220 , 200 , 大般若波羅蜜多經(第1卷-第200卷) , 唐 玄奘譯
T , 般若部類 , 般若部 , 08 , 0261 , 10 , 大乘理趣六波羅蜜多經 , 唐 般若譯
T , 法華部類 , 法華部 , 09 , 0262 , 7 , 妙法蓮華經 , 姚秦 鳩摩羅什譯
T , 法華部類 , 法華部 , 09 , 0277 , 1 , 佛說觀普賢菩薩行法經 , 劉宋 曇無蜜多譯
T , 華嚴部類 , 華嚴部 , 09 , 0278 , 60 , 大方廣佛華嚴經 , 東晉 佛馱跋陀羅譯
T , 華嚴部類 , 華嚴部 , 10 , 0309 , 10 , 最勝問菩薩十住除垢斷結經 , 姚秦 竺佛念譯
T , 寶積部類 , 寶積部 , 11 , 0310 , 120 , 大寶積經 , 唐 菩提流志譯
T , 淨土宗部類 , 寶積部 , 12 , 0373 , 1 , 後出阿彌陀佛偈 , 失譯
T , 涅槃部類 , 涅槃部 , 12 , 0374 , 40 , 大般涅槃經 , 北涼 曇無讖譯
T , 涅槃部類 , 涅槃部 , 12 , 0396 , 1 , 佛說法滅盡經 , 失譯
T , 大集部類 , 大集部 , 13 , 0397 , 60 , 大方等大集經 , 北涼 曇無讖譯
T , 大集部類 , 大集部 , 13 , 0424 , 5 , 大集會正法經 , 宋 施護譯
T , 經集部類 , 經集部 , 14 , 0425 , 8 , 賢劫經 , 西晉 竺法護譯
T , 經集部類 , 經集部 , 17 , 0847 , 3 , 大乘修行菩薩行門諸經要集 , 唐 智嚴譯
T , 密教部類 , 密教部 , 18 , 0848 , 7 , 大毘盧遮那成佛神變加持經 , 唐 善無畏．一行譯
T , 密教部類 , 密教部 , 21 , 1420 , 2 , 龍樹五明論 , 
T , 律部類 , 律部 , 22 , 1421 , 30 , 彌沙塞部和醯五分律 , 劉宋 佛陀什共竺道生等譯
T , 律部類 , 律部 , 24 , 1504 , 1 , 菩薩五法懺悔文 , 失譯
T , 阿含部類 , 釋經論部 , 25 , 1505 , 2 , 四阿鋡暮抄解 , 婆素跋陀造  符秦 鳩摩羅佛提等譯
T , 經集部類 , 釋經論部 , 26 , 1535 , 1 , 大乘四法經釋 , 
T , 毘曇部類 , 毘曇部 , 26 , 1536 , 20 , 阿毘達磨集異門足論 , 尊者舍利子說  唐 玄奘譯
T , 毘曇部類 , 毘曇部 , 29 , 1563 , 40 , 阿毘達磨藏顯宗論 , 尊者眾賢造  唐 玄奘譯
T , 中觀部類 , 中觀部 , 30 , 1564 , 4 , 中論 , 龍樹菩薩造  梵志青目釋  姚秦 鳩摩羅什譯
T , 中觀部類 , 中觀部 , 30 , 1578 , 2 , 大乘掌珍論 , 清辯菩薩造  唐 玄奘譯
T , 瑜伽部類 , 瑜伽部 , 30 , 1579 , 100 , 瑜伽師地論 , 彌勒菩薩說  唐 玄奘譯
T , 瑜伽部類 , 瑜伽部 , 31 , 1627 , 1 , 大乘法界無差別論 , 堅慧菩薩造  唐 提雲般若譯
T , 論集部類 , 論集部 , 32 , 1628 , 1 , 因明正理門論本 , 大域龍菩薩造  唐 玄奘譯
T , 論集部類 , 論集部 , 32 , 1692 , 1 , 勝軍化世百喻伽他經 , 宋 天息災譯
T , 阿含部類 , 經疏部 , 33 , 1693 , 1 , 人本欲生經註 , 東晉 道安撰
T , 密教部類 , 經疏部 , 39 , 1803 , 2 , 佛頂尊勝陀羅尼經教跡義記 , 唐 法崇述
T , 律部類 , 律疏部 , 40 , 1804 , 3 , 四分律刪繁補闕行事鈔 , 唐 道宣撰
T , 律部類 , 律疏部 , 40 , 1815 , 2 , 梵網經古迹記 , 新羅 太賢集
T , 般若部類 , 論疏部 , 40 , 1816 , 3 , 金剛般若論會釋 , 唐 窺基撰
T , 論集部類 , 論疏部 , 44 , 1850 , 6 , 大乘起信論裂網疏 , 明 智旭述
T , 瑜伽部類 , 諸宗部 , 44 , 1851 , 20 , 大乘義章 , 隋 慧遠撰
T , 禪宗部類 , 諸宗部 , 48 , 2025 , 8 , 勅修百丈清規 , 元 德煇重編
T , 史傳部類 , 史傳部 , 49 , 2026 , 1 , 撰集三藏及雜藏傳 , 失譯
T , 史傳部類 , 史傳部 , 52 , 2120 , 6 , 代宗朝贈司空大辨正廣智三藏和上表制集 , 唐 圓照集
T , 事彙部類 , 事彙部 , 53 , 2121 , 50 , 經律異相 , 梁 寶唱等集
T , 事彙部類 , 事彙部 , 54 , 2136 , 1 , 唐梵兩語雙對集 , 唐 僧怛多蘖多．波羅瞿那彌捨沙集
T , 事彙部類 , 外教部 , 54 , 2137 , 3 , 金七十論 , 陳 真諦譯
T , 事彙部類 , 外教部 , 54 , 2144 , 1 , 大秦景教流行中國碑頌 , 唐 景淨述
T , 事彙部類 , 目錄部 , 55 , 2145 , 15 , 出三藏記集 , 梁 僧祐撰
T , 事彙部類 , 目錄部 , 55 , 2184 , 3 , 新編諸宗教藏總錄 , 高麗 義天錄
T , 敦煌寫本部類 , 古逸部 , 85 , 2732 , 1 , 梁朝傅大士頌金剛經 , 
T , 敦煌寫本部類 , 古逸部 , 85 , 2864 , 1 , 進旨 , 
T , 敦煌寫本部類 , 疑似部 , 85 , 2865 , 1 , 護身命經 , 界　比丘道真
T , 敦煌寫本部類 , 疑似部 , 85 , 2920 , 1 , 僧伽和尚欲入涅槃說六度經 , 
=END
=cut

1;