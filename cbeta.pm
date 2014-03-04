
package Gaiji;
use utf8;
use Carp;
use Win32::ODBC;
use Encode;

=BEGIN

缺字物件的說明

宣告 : $gaiji = new Gaiji();

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
	my $cb,$des,$nor,$uni,$uniword,$noruni,$noruniword;
	my $err = 0;
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	print "read gaiji ... ";
	while($db->FetchRow()){
		undef %row;
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
■3400～4DFFh：中日韓認同表意文字擴充A區，總計收容6,582個中日韓漢字。
#3400～4DB5：CJK Extension A 中日韓統一表意文字擴充 A 區。(6582 字, Unicode 3.0 , 1999)
#4DC0～4DFF：易經六十四卦符號。(64 字, Unicode 4.0)
■4E00～9FFFh：中日韓認同表意文字區，總計收容20,902個中日韓漢字。
#4E00～9FA5：CJK Unified Ideographs (Han) 中日韓統一表意文字區 (原本標準是到 9FCC)。(20,902 字, Unicode 1.0 , 1993)
#9FA6～9FBB：14 個香港增補字符集的用字和 8 個 GB 18030 用字 (22 字, Unicode 4.1 , 2005)
#9FBC～9FC3：7 個日語漢字及 U+9FC3 (8 字, Unicode 5.1 , 2008)
#9FC4～9FCB：2 個日語用漢字, 1 個新增漢字, 5 個香港漢字 (8 字, Unicode 5.2 , 2009)
#9FCC：1 個漢字 (1 字, Unicode 6.1 , 2012)
■A000～A4FFh：彝族文字區，收容中國南方彝族文字和字根。
#A000～A48C：Yi Syllables 彝族文字區 (Unicode 3.0)
■AC00～D7FFh：韓文拼音組合字區，收容以韓文音符拼成的文字。
#AC00～D7A3：Hangul Syllables 韓文拼音 (Unicode 2.0)
■E000～F8FF：私人造字區
■F900～FAFFh：中日韓兼容表意文字區，總計收容302個中日韓漢字。
#F900～FA2D：CJK Compatibility Ideographs 相容表意字 (Unicode 1.0 , 1993)
#FA30～FA6A：CJK Compatibility Ideographs 相容表意字 (Unicode 3.2)
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
#2A700～2B734：CJK Unified Ideographs Extension C 中日韓統一表意文字擴展 C 區 (4149 字, Unicode 5.2 , 2009)
#2B740～2B81D：CJK Unified Ideographs Extension D 中日韓統一表意文字擴展 D 區 (222 字, Unicode 6.0 , 2010)
#2B820～2F7FF：CJK Unified Ideographs Extension E 中日韓統一表意文字擴展 E 區 
#2F800～2FA1D：CJK Compatibility Ideographs Supplement 相容表意字補充 - 台灣的相容漢字 (542 字, Unicode 3.1 , 2001)
  
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
	
	#這幾個移到前面, 速度看會不會快一點
	return "1.0" if($uni >= 0x4E00 and $uni <= 0x9FA5);	#4E00～9FA5：CJK Unified Ideographs (Han) 中日韓統一表意文字區 (原本標準是到 9FCC)。(20,902 字, Unicode 1.0 , 1993)
	return "1.0" if($uni >= 0x3000 and $uni <= 0x3036);	#3000～3036：CJK Symbols and Punctuation 符號和標點符號 (Unicode 1.0)
	return "3.0" if($uni >= 0x3400 and $uni <= 0x4DB5);	#3400～4DB5：CJK Extension A 中日韓統一表意文字擴充 A 區。(6582 字, Unicode 3.0 , 1999)
	return "3.1" if($uni >= 0x20000 and $uni <= 0x2A6D6);	#20000～2A6D6：CJK Unified Ideographs Extension B 中日韓統一表意文字擴展 B 區 (42711 字, Unicode 3.1 , 2001)
	
	#底下是完整的
	return "1.0" if($uni >= 0x0000 and $uni <= 0x017E);	#0000～017E： (Unicode 1.0)
	return "1.1" if($uni == 0x017F);	#017F： (Unicode 1.1)
	return "1.0" if($uni >= 0x0180 and $uni <= 0x01F0);	#0180～01F0： (Unicode 1.0)
	return "1.1" if($uni >= 0x01F1 and $uni <= 0x01F5);	#01F1～01F5： (Unicode 1.1)
	return "3.0" if($uni >= 0x01F6 and $uni <= 0x01F9);	#01F6～01F9： (Unicode 3.0)
	return "1.1" if($uni >= 0x01FA and $uni <= 0x0217);	#01FA～0217： (Unicode 1.1)
	return "3.0" if($uni >= 0x0218 and $uni <= 0x021F);	#0218～021F： (Unicode 3.0)
	return "3.2" if($uni == 0x0220);	#0220： (Unicode 3.2)
	return "4.0" if($uni == 0x0221);	#0221： (Unicode 4.0)
	return "3.0" if($uni >= 0x0222 and $uni <= 0x0233);	#0222～0233： (Unicode 3.0)
	return "4.0" if($uni >= 0x0234 and $uni <= 0x0236);	#0234～0236： (Unicode 4.0)
	return "4.1" if($uni >= 0x0237 and $uni <= 0x0241);	#0237～0241： (Unicode 4.1)
	return "5.0" if($uni >= 0x0242 and $uni <= 0x024F);	#0242～024F： (Unicode 5.0)
	return "1.0" if($uni >= 0x0250 and $uni <= 0x02A8);	#0250～02A8： (Unicode 1.0)
	return "3.0" if($uni >= 0x02A9 and $uni <= 0x02AD);	#02A9～02AD： (Unicode 3.0)
	return "4.0" if($uni >= 0x02AE and $uni <= 0x02AF);	#02AE～02AF： (Unicode 4.0)
	return "1.0" if($uni >= 0x02B0 and $uni <= 0x02DE);	#02B0～02DE： (Unicode 1.0)
	return "3.0" if($uni == 0x02DF);	#02DF： (Unicode 3.0)
	return "1.0" if($uni >= 0x02E0 and $uni <= 0x02E9);	#02E0～02E9： (Unicode 1.0)
	return "3.0" if($uni >= 0x02EA and $uni <= 0x02EE);	#02EA～02EE： (Unicode 3.0)
	return "4.0" if($uni >= 0x02EF and $uni <= 0x02FF);	#02EF～02FF： (Unicode 4.0)
	return "1.0" if($uni >= 0x0300 and $uni <= 0x0341);	#0300～0341： (Unicode 1.0)
	return "1.0" if($uni >= 0x0401 and $uni <= 0x040C);	#0401～040C： (Unicode 1.0)
	return "3.0" if($uni == 0x040D);	#040D： (Unicode 3.0)
	return "1.0" if($uni >= 0x040E and $uni <= 0x044F);	#040E～044F： (Unicode 1.0)
	return "1.1" if($uni >= 0x1E00 and $uni <= 0x1E9A);	#1E00～1E9A： (Unicode 1.1)
	return "2.0" if($uni == 0x1E9B);	#1E9B： (Unicode 2.0)
	return "5.1" if($uni >= 0x1E9C and $uni <= 0x1E9F);	#1E9C～1E9F： (Unicode 5.1)
	return "1.1" if($uni >= 0x1EA0 and $uni <= 0x1EF9);	#1EA0～1EF9： (Unicode 1.1)
	return "5.1" if($uni >= 0x1EFA and $uni <= 0x1EFF);	#1EFA～1EFF： (Unicode 5.1)
	return "1.0" if($uni >= 0x2100 and $uni <= 0x2138);	#2100～2138： (Unicode 1.0)
	return "1.0" if($uni >= 0x2153 and $uni <= 0x2182);	#2153～2182： (Unicode 1.0)
	return "1.0" if($uni >= 0x2190 and $uni <= 0x21EA);	#2190～21EA： (Unicode 1.0)
	return "1.0" if($uni >= 0x2200 and $uni <= 0x22F1);	#2200～22F1： (Unicode 1.0)
	return "1.0" if($uni >= 0x2460 and $uni <= 0x24EA);	#2460～24EA：Enclosed Alphanumerics 括號及圓圈各種數字英文 (Unicode 1.0)
	return "3.2" if($uni >= 0x24EB and $uni <= 0x24FE);	#24EB～24FE：Enclosed Alphanumerics 括號及圓圈各種數字英文 (Unicode 3.2)
	return "4.0" if($uni == 0x24FF);	#24FF： (Unicode 4.0)
	return "1.0" if($uni >= 0x2500 and $uni <= 0x2595);	#2500～2595： (Unicode 1.0)
	return "3.2" if($uni >= 0x2596 and $uni <= 0x259F);	#2596～259F： (Unicode 3.2)
	return "1.0" if($uni >= 0x25A0 and $uni <= 0x25EE);	#25A0～25EE： (Unicode 1.0)
	return "1.1" if($uni == 0x25EF);	#25EF： (Unicode 1.1)
	return "1.0" if($uni >= 0x2600 and $uni <= 0x2613);	#2600～2613： (Unicode 1.0)
	return "1.0" if($uni >= 0x261A and $uni <= 0x266F);	#261A～266F： (Unicode 1.0)
	return "3.0" if($uni >= 0x2E80 and $uni <= 0x2EF3);	#2E80～2EF3：CJK Radicals Supplement 部首補充 (128 字, Unicode 3.0 , 1999)
	return "3.0" if($uni >= 0x2F00 and $uni <= 0x2FD5);	#2F00～2FD5：CJK Radicals / KangXi Radicals 部首 / 康熙字典部首 (224 字, Unicode 3.0 , 1999)
	return "3.0" if($uni >= 0x2FF0 and $uni <= 0x2FFB);	#2FF0～2FFB：Ideographic Description Characters 表意文字描述字符 (中研院的組字符號, Unicode 3.0 , 1999)
	#return "1.0" if($uni >= 0x3000 and $uni <= 0x3036);	#3000～3036：CJK Symbols and Punctuation 符號和標點符號 (Unicode 1.0)
	return "1.1" if($uni == 0x3037);	#3037：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 1.1 , 1993)
	return "3.0" if($uni >= 0x3038 and $uni <= 0x303A);	#3038～303A：CJK Symbols and Punctuation 符號和標點符號 (3 字, Unicode 3.0 , 1999)
	return "3.2" if($uni >= 0x303B and $uni <= 0x303D);	#303B～303D：CJK Symbols and Punctuation 符號和標點符號 (3 字, Unicode 3.2 , 2002)
	return "3.0" if($uni == 0x303E);	#303E：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 3.0 , 1999)
	return "1.0" if($uni == 0x303F);	#303F：CJK Symbols and Punctuation 符號和標點符號 (1 字, Unicode 1.0)
	return "1.0" if($uni >= 0x3041 and $uni <= 0x3094);	#3041～3094：Hiragana 日文平假名 (Unicode 1.0)
	return "3.2" if($uni >= 0x3095 and $uni <= 0x3096);	#3095～3096：Hiragana 日文平假名 (Unicode 3.2)
	return "1.0" if($uni >= 0x3099 and $uni <= 0x309E);	#3099～309E：Hiragana 日文平假名 (Unicode 1.0)
	return "3.2" if($uni == 0x309F);	#309F：Hiragana 日文平假名 (Unicode 3.2)
	return "3.2" if($uni == 0x30A0);	#30A0：Katakana 日文片假名 (Unicode 3.2)
	return "1.0" if($uni >= 0x30A1 and $uni <= 0x30F6);	#30A1～30F6：Katakana 日文片假名 (Unicode 1.0)
	return "1.1" if($uni >= 0x30F7 and $uni <= 0x30FA);	#30F7～30FA：Katakana 日文片假名 (Unicode 1.1)
	return "1.0" if($uni >= 0x30FB and $uni <= 0x30FE);	#30FB～30FE：Katakana 日文片假名 (Unicode 1.0)
	return "3.2" if($uni == 0x30FF);	#30FF：Katakana 日文片假名 (Unicode 3.2)
	return "1.0" if($uni >= 0x3105 and $uni <= 0x312C);	#3105～312C：Bopomofo 注音符號 (Unicode 1.0)
	return "5.1" if($uni == 0x312D);	#312D：Bopomofo 上下顛倒的 'ㄓ' (Unicode 5.1)
	return "1.0" if($uni >= 0x3131 and $uni <= 0x318E);	#3131～318E：Hangul Compatibility Jamo 韓文 (Unicode 1.0)
	return "1.0" if($uni >= 0x3190 and $uni <= 0x319F);	#3190～319F：Kanbun 在上方的小漢字 (Unicode 1.0)
	return "3.0" if($uni >= 0x31A0 and $uni <= 0x31B7);	#31A0～31B7：Bopomofo Extended 注音擴展 (Unicode 3.0)
	return "6.0" if($uni >= 0x31B8 and $uni <= 0x31BA);	#31B8～31BA：Bopomofo Extended 注音擴展 (Unicode 6.0)
	return "4.1" if($uni >= 0x31C0 and $uni <= 0x31CF);	#31C0～31CF：CJK Strokes 筆劃 (基本筆劃, 如撇, 勾, 點...) (Unicode 4.1)
	return "5.1" if($uni >= 0x31D0 and $uni <= 0x31E3);	#31D0～31E3：CJK Strokes 筆劃 (基本筆劃, 如撇, 勾, 點...) (Unicode 5.1)
	return "3.2" if($uni >= 0x31F0 and $uni <= 0x31FF);	#31F0～31FF：Katakana Phonetic Extensions 日文片假名語音擴展 (Unicode 3.2)
	return "1.0" if($uni >= 0x3200 and $uni <= 0x321C);	#3200～321C：Enclosed CJK Letters and Months 括號韓文 (Unicode 1.0)
	return "4.0" if($uni >= 0x321D and $uni <= 0x321E);	#321D～321E：Enclosed CJK Letters and Months 括號韓文 (Unicode 4.0)
	return "1.0" if($uni >= 0x3220 and $uni <= 0x3243);	#3220～3243：Enclosed CJK Letters and Months 括號一~十及漢字 (Unicode 1.0)
	return "5.2" if($uni >= 0x3244 and $uni <= 0x324F);	#3244～324F：Enclosed CJK Letters and Months 圓圈中有字及10~80 (Unicode 5.2)
	return "4.0" if($uni == 0x3250);	#3250：Enclosed CJK Letters and Months 'PTE' 組成一字 (Unicode 4.0)
	return "3.2" if($uni >= 0x3251 and $uni <= 0x325F);	#3251～325F：Enclosed CJK Letters and Months 圓圈 21~35 (Unicode 3.2)
	return "1.0" if($uni >= 0x3260 and $uni <= 0x327B);	#3260～327B：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 1.0)
	return "4.0" if($uni >= 0x327C and $uni <= 0x327D);	#327C～327D：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 4.0)
	return "4.1" if($uni == 0x327E);	#327E：Enclosed CJK Letters and Months 圓圈韓文 (Unicode 4.1)
	return "1.0" if($uni >= 0x327F and $uni <= 0x32B0);	#327F～32B0：Enclosed CJK Letters and Months 圓圈一~十及漢字 (Unicode 1.0)
	return "3.2" if($uni >= 0x32B1 and $uni <= 0x32BF);	#32B1～32BF：Enclosed CJK Letters and Months 圓圈 36~50 (Unicode 3.2)
	return "1.1" if($uni >= 0x32C0 and $uni <= 0x32CB);	#32C0～32CB：Enclosed CJK Letters and Months 1月~12月 (Unicode 1.1)
	return "4.0" if($uni >= 0x32CC and $uni <= 0x32CF);	#32CC～32CF：Enclosed CJK Letters and Months 多英文組成一個字 (Unicode 4.0)
	return "1.0" if($uni >= 0x32D0 and $uni <= 0x32FE);	#32D0～32FE：Enclosed CJK Letters and Months 圓圈日文 (Unicode 1.0)
	return "1.0" if($uni >= 0x3300 and $uni <= 0x3357);	#3300～3357：CJK Compatibility 多個日文組成一字 (Unicode 1.0)
	return "1.1" if($uni >= 0x3358 and $uni <= 0x3376);	#3358～3376：CJK Compatibility 0奌~24奌 及多英文組成一字 (Unicode 1.1)
	return "4.0" if($uni >= 0x3377 and $uni <= 0x337A);	#3377～337A：CJK Compatibility 多英文組成一字 (Unicode 4.0)
	return "1.0" if($uni >= 0x337B and $uni <= 0x33DD);	#337B～33DD：CJK Compatibility 多日本漢字及多英文組成一字 (Unicode 1.0)
	return "4.0" if($uni >= 0x33DE and $uni <= 0x33DF);	#33DE～33DF：CJK Compatibility 多英文組成一字 (Unicode 4.0)
	return "1.1" if($uni >= 0x33E0 and $uni <= 0x33FE);	#33E0～33FE：CJK Compatibility 1日~31日 (Unicode 1.1)
	return "4.0" if($uni == 0x33FF);	#33FF：CJK Compatibility 'gal' 組成一字 (Unicode 4.0)
	#return "3.0" if($uni >= 0x3400 and $uni <= 0x4DB5);	#3400～4DB5：CJK Extension A 中日韓統一表意文字擴充 A 區。(6582 字, Unicode 3.0 , 1999)
	return "4.0" if($uni >= 0x4DC0 and $uni <= 0x4DFF);	#4DC0～4DFF：易經六十四卦符號。(64 字, Unicode 4.0)
	#return "1.0" if($uni >= 0x4E00 and $uni <= 0x9FA5);	#4E00～9FA5：CJK Unified Ideographs (Han) 中日韓統一表意文字區 (原本標準是到 9FCC)。(20,902 字, Unicode 1.0 , 1993)
	return "4.1" if($uni >= 0x9FA6 and $uni <= 0x9FBB);	#9FA6～9FBB：14 個香港增補字符集的用字和 8 個 GB 18030 用字 (22 字, Unicode 4.1 , 2005)
	return "5.1" if($uni >= 0x9FBC and $uni <= 0x9FC3);	#9FBC～9FC3：7 個日語漢字及 U+9FC3 (8 字, Unicode 5.1 , 2008)
	return "5.2" if($uni >= 0x9FC4 and $uni <= 0x9FCB);	#9FC4～9FCB：2 個日語用漢字, 1 個新增漢字, 5 個香港漢字 (8 字, Unicode 5.2 , 2009)
	return "6.1" if($uni == 0x9FCC);	#9FCC：1 個漢字 (1 字, Unicode 6.1 , 2012)
	return "3.0" if($uni >= 0xA000 and $uni <= 0xA48C);	#A000～A48C：Yi Syllables 彝族文字區 (Unicode 3.0)
	return "2.0" if($uni >= 0xAC00 and $uni <= 0xD7A3);	#AC00～D7A3：Hangul Syllables 韓文拼音 (Unicode 2.0)
	return "1.0" if($uni >= 0xF900 and $uni <= 0xFA2D);	#F900～FA2D：CJK Compatibility Ideographs 相容表意字 (Unicode 1.0 , 1993)
	return "3.2" if($uni >= 0xFA30 and $uni <= 0xFA6A);	#FA30～FA6A：CJK Compatibility Ideographs 相容表意字 (Unicode 3.2)
	return "4.1" if($uni >= 0xFA70 and $uni <= 0xFAD9);	#FA70～FAD9：CJK Compatibility Ideographs 相容表意字 - 106個來自北韓的相容漢字 (106 字, Unicode 4.1 , 2005)
	return "4.1" if($uni >= 0xFE10 and $uni <= 0xFE19);	#FE10～FE19：Vertical Forms 中文直排標點 (Unicode 4.1)
	return "1.1" if($uni >= 0xFE20 and $uni <= 0xFE23);	#FE20～FE23：Combining Half Marks (Unicode 1.1)
	return "5.1" if($uni >= 0xFE24 and $uni <= 0xFE26);	#FE24～FE26：Combining Half Marks (Unicode 5.1)
	return "1.0" if($uni >= 0xFE30 and $uni <= 0xFE44);	#FE30～FE44：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 1.0)
	return "3.2" if($uni >= 0xFE45 and $uni <= 0xFE46);	#FE45～FE46：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 3.2)
	return "4.0" if($uni >= 0xFE47 and $uni <= 0xFE48);	#FE47～FE48：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 4.0)
	return "1.0" if($uni >= 0xFE49 and $uni <= 0xFE4F);	#FE49～FE4F：CJK Compatibility Forms 兼容性表格 (看起來像直排用的符號) (Unicode 1.0)
	return "1.0" if($uni >= 0xFE50 and $uni <= 0xFE52);	#FE50～FE52：Small Form Variants (Unicode 1.0)
	return "1.0" if($uni >= 0xFE54 and $uni <= 0xFE66);	#FE54～FE66：Small Form Variants (Unicode 1.0)
	return "1.0" if($uni >= 0xFE68 and $uni <= 0xFE6B);	#FE68～FE6B：Small Form Variants (Unicode 1.0)
	return "1.0" if($uni >= 0xFF01 and $uni <= 0xFF5E);	#FF01～FF5E：Halfwidth and Fullwidth Forms (Unicode 1.0)
	return "3.2" if($uni >= 0xFF5F and $uni <= 0xFF60);	#FF5F～FF60：Halfwidth and Fullwidth Forms (Unicode 3.2)
	return "1.0" if($uni >= 0xFF61 and $uni <= 0xFF9F);	#FF61～FF9F：Halfwidth and Fullwidth Forms (Unicode 1.0)
	#return "3.1" if($uni >= 0x20000 and $uni <= 0x2A6D6);	#20000～2A6D6：CJK Unified Ideographs Extension B 中日韓統一表意文字擴展 B 區 (42711 字, Unicode 3.1 , 2001)
	return "5.2" if($uni >= 0x2A700 and $uni <= 0x2B734);	#2A700～2B734：CJK Unified Ideographs Extension C 中日韓統一表意文字擴展 C 區 (4149 字, Unicode 5.2 , 2009)
	return "6.0" if($uni >= 0x2B740 and $uni <= 0x2B81D);	#2B740～2B81D：CJK Unified Ideographs Extension D 中日韓統一表意文字擴展 D 區 (222 字, Unicode 6.0 , 2010)
	return "3.1" if($uni >= 0x2F800 and $uni <= 0x2FA1D);	#2F800～2FA1D：CJK Compatibility Ideographs Supplement 相容表意字補充 - 台灣的相容漢字 (542 字, Unicode 3.1 , 2001)

	return "";
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
	push($self->{"tags"} , \%hash);
}

# 取出 $tag 及 %att , 要存入變數中
sub poptag
{
	my $self = shift;
	my $hash = pop($self->{"tags"});
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


1;