##############################################################################
# 程式名稱：p5totxt.pl                                    by heaven 2013/07/02
# 程式位置：c:\cbwork\bin\p5
# 程式說明：         
#     由 P5 XML 轉出各種版本的結果
# 使用方法：
#     perl p5totxt.pl [ -h -v 要執行的冊數 ]
# 參數說明：
#     -h 列出說明
#     -v 要比對的冊數
#     -type 輸出的格式, 計有 normal, html, pda , 預設是 normal
#     -jingfile 採用一經一檔, 預設則是一卷一檔
#
#     * 以下僅供參考 *
#     -c 內碼轉換表路徑
#     -e output encoding
#     -g 去除行首(或段首)資訊的選項
#     -h 不要檔頭資訊
#     -i input directory
#     -j normalize for Japanese
#     -k 顯示校勘符號、＊、◎
#     -n 要執行的經號 例：c:\cbwork\xml\T01>xml2txt -n T01n0001.xml
#     -o output directory
#     -p ++精簡版
#     -s 精簡版
#     -u 一卷一檔, 預設是一經一檔
#     -v 要執行的冊數, 例：c:\cbwork\xml\T01>xml2txt -v T01
#     -x 悉曇字呈現方法: (預設使用轉寫)
#           -x 1 使用 entity &SD-xxxx;
#           -x 2 使用 ◇【◇】 
#     -z 不使用通用字
# 設定檔：相關設定由 ../cbwork_bin.ini 取得
# 範例：
#     perl p5totxt.pl -h
#     perl p5totxt.pl -v T01
##############################################################################
# head end # 本行不可刪, 不可改, 這是用來判斷說明檔的結束
##############################################################################
# 版本資訊
# 2013/07/02 V0.1 最原始的程式樣版, 可供未來程式參考, 目前只能印出檔名列表
##############################################################################

use utf8;
use autodie;
use Encode;
use strict;
use XML::Parser;
use Config::IniFiles;
use Getopt::Long;

# 如果有使用 use strict; , 本行就要加上去
use vars qw($opt_h $opt_v $opt_type $opt_jingfile);		

##############################################################################
# 變數
##############################################################################

my $vol;			# $vol = T01 , 主要在執行的冊數
my $vol_ed;			# $vol_ed = T
my $vol_num;		# $vol_num = 01
my $sutra_id;		# 經文 id, T01n0001 , T02n0128a
my $sutra_id_;		# 經文 id, T01n0001_ , T02n0128a
my $sutra_num;		# 經號, 0001 , 0128a
my $sutra_num_;		# 經號, 0001_ , 0128a

my $file_type;		# 經文格式, 計有 normal, html, pda, 預設是 normal
my $cut_type;		# 切檔的方法 , 有 "jing" 一經一檔 及 "juan" 一卷一檔, 預設是一卷一檔.

my @files = ();		# $vol 底下所有的 xml 檔案檔名

my $cbwork_dir;		# cbwork 目錄, 預設會讀取 ../cbwork_bin.ini 的內容, 也可以由 -release 來指定
my $release_dir;	# release 目錄, 預設會讀取 ../cbwork_bin.ini 的內容, 也可以由 -release 來指定
my $xml_dir;		# xml 目錄 = $cbwork_dir . "/xml-p5/$vol_ed/$vol/";
my $out_dir;		# 輸出結果的目錄 $out_dir = $release_dir . "/${file_type}-utf8/$vol/";

my $text;			# 儲存產生的經文
my $juan_num;		# 處理中的卷數

##############################################################################
# 主程式
##############################################################################

read_ini_file();		# 讀取主要的 ini 檔內容
check_opt();			# 檢查參數
initial_para();			# 參數設定
show_main_message();	# 在 DOS 視窗秀出主要的訊息

# 開啟目錄, 找出所有檔案

opendir (INDIR, $xml_dir);
@files = grep(/\.xml$/i, readdir(INDIR));
if(not @files)
{
	print tobig5("錯誤：$xml_dir 找不到任何 xml 檔案，程式結束！\n");
	exit;
}

# 宣告 parse 程式

my $ent;
my $val;
my $parser = new XML::Parser(NoExpand => 1);
$parser->setHandlers (
	Init => \&init_handler,
	Final => \&final_handler,
	Start => \&start_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default);

# 逐檔處理

for my $file (sort(@files))
{
	if($file =~ /^(${vol}n(.{4,5}))\.xml/)
	{
		# 由檔名取出相關資料
		$sutra_id = $sutra_id_ = $1;
		$sutra_num = $sutra_num_ = $2;
		if(length($sutra_num) == 4)
		{
			$sutra_id_ .= "_";
			$sutra_num_ .= "_";
		}
		print $sutra_id_ . " " . $sutra_num_
	}
	else
	{
		# 檔名不符合標準格式
		print tobig5("錯誤：發現奇怪檔名 $file！\n");
		exit;
	}
	my $filename = $xml_dir . $file;
	print "\n" . $file . "..." ;
	$parser->parsefile($filename);
}

##############################################################################
# 讀取主要的 ini 檔內容
##############################################################################

sub read_ini_file
{
	my $cfg = Config::IniFiles->new( -file => "../cbwork_bin.ini" );
	
	$cbwork_dir = $cfg->val('default', 'cbwork', '/cbwork');	# 讀取 cbwork 目錄
	$release_dir = $cfg->val('default', 'release', '/release');	# 讀取 release 目錄
}

##############################################################################
# 檢查參數
##############################################################################

sub check_opt
{
	# -h 不用引數, 所以用 !
	# -v 需要引數, 所以用 v=s, 並放入 $opt_v (s : 字串 , i : 整數 , f : 浮點)
	GetOptions("h!", "v=s", "type=s", "jingfile!");

	if($opt_h == 1)
	{
		print_help();
		exit;
	}

	if($opt_v eq "")
	{
		print tobig5("錯誤：沒有使用 -v 參數\n");
		print_help();
		exit;
	}
	
	# 經文格式, 預設是 normal , 也有 html 及 pda
	$file_type = "normal";	# 預設值
	if(($opt_type eq "html") or ($opt_type eq "pda"))
	{
		$file_type = $opt_type;
	}
	
	# 切檔方式, 預設是一卷一檔, 若使用 -jingfile 參數, 則是一經一檔
	$cut_type = "juan";
	if($opt_jingfile) { $cut_type = "jing";}
}

##############################################################################
# 參數設定
##############################################################################

sub initial_para
{
	$vol = $opt_v;
	if($vol =~ /^(\D+)(\d+)$/)
	{
		$vol_ed = $1;
		$vol_num = $2;
	}
	else
	{
		print tobig5("錯誤：$vol 這不是冊數！\n");
		exit;
	}
	
	# xml 來源目錄
	$xml_dir = $cbwork_dir . "/xml-p5/$vol_ed/$vol/";
	
	# 輸出目錄
	mkdir($release_dir) if(not -d $release_dir);
	if($cut_type eq "juan")
	{
		$out_dir = $release_dir . "/${file_type}-utf8/";
	}
	else
	{
		# 一經一檔的目錄不同, 例如 normal 一經一檔目錄是 normal1
		$out_dir = $release_dir . "/${file_type}1-utf8/";
	}
	mkdir($out_dir) if(not -d $out_dir);
	$out_dir .= "$vol/";
	mkdir($out_dir) if(not -d $out_dir);
}

##############################################################################
# 在 DOS 視窗秀出主要的訊息
##############################################################################

sub show_main_message
{
	print tobig5("\n【 XML P5 轉檔程式 】\n");
	print tobig5("處理冊數：$vol\n");
	print tobig5("資料來源：$xml_dir\n");
	print tobig5("輸出目錄：$out_dir\n");
	print tobig5("輸出格式：$file_type\n");
	print tobig5("切檔方式：");
	print tobig5("一卷一檔\n") if ($cut_type eq "juan");
	print tobig5("一經一檔\n") if ($cut_type eq "jing");
}

##############################################################################
# 將 utf8 編碼的文字轉成 big5 編碼
##############################################################################

sub tobig5
{
	my $utf8 = shift;
	return encode("big5", $utf8);
}

##############################################################################
# 印出說明
# 印出本檔最前面的內容, 直到遇到 use
##############################################################################

sub print_help
{
	open IN, "<:utf8", $0;
	while(<IN>)
	{
		last if(/^# head end #/);
		print tobig5($_);
	}
}

##############################################################################
# 將結果印出來
##############################################################################

sub print_file
{
	my $txt_ref = shift;
	
	open OUT, ">utf8:", "$out_dir" . $vol . "n" . $sutra_num . ".txt";
	print OUT $$txt_ref;
	close OUT;
}


##############################################################################
# XML Parser
##############################################################################

# 初值化的工作
sub init_handler
{
	$text = "";			# 儲存產生的經文
}

#-----------------------------------------------------------------------------

sub final_handler 
{
	# 輸出結果
	print_file(\$text);
}

#-----------------------------------------------------------------------------

sub start_handler 
{
	my $p = shift;
	my $tag = shift;
	my (%att) = @_;
	
	### <lb ed="N" n="0001a01"/>
	if ($tag eq "lb")
	{
		my $n = $att{"n"};
		$text .= $sutra_id_ . "p" . $n . "║";
		return;
	}
	
	### <pb ed="N" xml:id="N01.0001.0001a" n="0001a"/>
	
	if ($tag eq "pb")
	{
		return;
	}
	
	### <milestone unit="juan" n="1"/>
	
	if ($tag eq "milestone" and $att{"unit"} eq "juan")
	{
		# 先記錄 <heaven:juan 1> , 留待未來分卷的標記
		$text .= "<heaven:juan " . $att{"n"} . ">";
	}
}

#-----------------------------------------------------------------------------

sub end_handler
{
	my $p = shift;
	my $tag = shift;

	#$inTitleStmt = 0 if($tag eq "titleStmt");
	#$inTitle = 0 if($tag eq "title");
	
	### <cb:mulu> ###
	#<cb:mulu level="1" type="序">序</cb:mulu>
	if ($tag eq "cb:mulu")
	{
	}
}

#-----------------------------------------------------------------------------

sub char_handler
{
	my $p = shift;
	my $char = shift;

	$text .= $char;
}

#-----------------------------------------------------------------------------

# 遇到這二行
# [<!ENTITY % ENTY  SYSTEM "X01n0001.ent" >
# <!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
# $ent 分別是 ENTY 及 CBENT
# $entval 皆為空白
# next 分別是 X01n0001.ent 及 ../dtd/cbeta.ent
sub entity
{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;

}

#-----------------------------------------------------------------------------

# 我看到的 default 是註解, 以及這些
# <?xml version="1.0" encoding="UTF-8" ?>
# <?xml-stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
# <!DOCTYPE TEI.2 SYSTEM
# [
# ]>

sub default {
    my $p = shift;
    my $string = shift;
}

##############################################################################