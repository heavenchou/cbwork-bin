##############################################################################
# 程式名稱：p5totxt.pl                                    by heaven 2019/01/16
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
#     -gaiji1 缺字第一志願為何? 有 normal 及 unicode 可選
#     -gaiji2 缺字第二志願為何? 有 normal 及 unicode 可選
#     -unicode_ver unicode 的版本, 預設是支援 1.0
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
# 2019/01/16 V0.1 終於有機會拿來用, 處理了 lb , p , milestone 標記
#                 可處理原書格式與段落格式, 可輸出單經或單卷
# 2013/07/02 V0.1 最原始的程式樣版, 可供未來程式參考, 目前只能印出檔名列表
##############################################################################

use utf8;
use autodie;
use Encode;
use strict;
use feature "switch";
use XML::Parser;
use Config::IniFiles;
use Getopt::Long;
use File::Find;
use XML::DOM;
use lib '../';
use cbeta;

# 如果有使用 use strict; , 本行就要加上去
use vars qw($opt_h $opt_v $opt_type $opt_jingfile $opt_gaiji1 $opt_gaiji2 $opt_unicode_ver);

#######################################
# 變數
#######################################

my $gaiji = new Gaiji;		# 缺字處理物件
my $xmltree = new CB_xml;	# xml 處理物件
my $parser = new XML::DOM::Parser;

my $ID = "";		# T01n0001 , T01n0001_001

my $file_type;		# 經文格式, 計有 line (行格式), para(段落格式), 預設是 line
my $cut_type;		# 切檔的方法 , 有 "jing" 一經一檔 及 "juan" 一卷一檔, 預設是一卷一檔.

my @files = ();			# 所有的 xml 檔案檔名
my @full_files = ();	# 所有的 xml 檔案全名

my $cbwork_dir;		# cbwork 目錄, 預設會讀取 ../cbwork_bin.ini 的內容, 也可以由 -release 來指定
my $release_dir;	# release 目錄, 預設會讀取 ../cbwork_bin.ini 的內容, 也可以由 -release 來指定
my $xml_dir;		# xml 目錄 = $cbwork_dir . "/xml-p5/$vol_ed/$vol/";
my $out_dir;		# 輸出結果的目錄 $out_dir = $release_dir . "/${file_type}-utf8/$vol/";

#my $text = "";		# 儲存產生的經文
my $juan_num = 0;	# 處理中的卷數

my %chardecl = ();	# 用來放置 xml 中 <charDecl> 中的資料, 以利加到缺字資料庫中
					# 儲存格式如下
					# $chardecl{"cb"} = "00001"
					# $chardecl{"type"} = "cb2des"
					# $chardecl{"val"} = "[xxx]"

#my $vol;			# $vol = T01 , 主要在執行的冊數
##my $vol_ed;			# $vol_ed = T
#my $vol_num;		# $vol_num = 01

#my $sutra_id;		# 經文 id, T01n0001 , T02n0128a
#my $sutra_id_;		# 經文 id, T01n0001_ , T02n0128a
#my $sutra_num;		# 經號, 0001 , 0128a
#my $sutra_num_;		# 經號, 0001_ , 0128a
#######################################
# 主程式
#######################################

read_ini_file();			# 讀取主要的 ini 檔內容
check_opt();				# 檢查參數
initial_para();				# 參數設定
show_main_message();		# 在 DOS 視窗秀出主要的訊息
get_all_xml_files("$xml_dir/T/T01");	# 取得全部 xml 檔名

$ID = SutraID->new;

# 逐檔處理
for(my $i=0; $i<$#files; $i++)
{
	my $file = $files[$i];
	if($file =~ /^(\D+\d+n(.{4,5}))\.xml/)
	{
		my $filename = $1;
		if(($opt_v =~ /^\D+$/ && $file =~ /^${opt_v}\d/) ||	# 只輸入英文, 表示是藏經
		   ($opt_v =~ /\d/ && $file =~ /^${opt_v}/))	# T01, T01n0001
		{
			$ID->init($filename);
			print "\n" . $file . "..." ;
			my $text = ParserXML($full_files[$i]);
			print_file(\$text);
		}
	}
}

#######################################
# 讀取主要的 ini 檔內容
#######################################

sub read_ini_file
{
	my $cfg = Config::IniFiles->new( -file => "../cbwork_bin.ini" );
	
	$cbwork_dir = $cfg->val('default', 'cbwork', '/cbwork');	# 讀取 cbwork 目錄
	$release_dir = $cfg->val('default', 'release', '/release');	# 讀取 release 目錄
}

#######################################
# 檢查參數
#######################################

sub check_opt
{
	# -h 不用引數, 所以用 !
	# -v 需要引數, 所以用 v=s, 並放入 $opt_v (s : 字串 , i : 整數 , f : 浮點)
	GetOptions("h!", "v=s", "type=s", "jingfile!", "gaiji1=s", "gaiji2=s", "unicode_ver=s");

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
	
	# 經文格式, 預設是 line , 也有 html 及 para
	$file_type = $opt_type;	
	if($file_type eq "")
	{
		$file_type = "line";	# 預設值
	}
	
	# 切檔方式, 預設是一卷一檔, 若使用 -jingfile 參數, 則是一經一檔
	$cut_type = "juan";
	if($opt_jingfile) { $cut_type = "jing";}
	
	$opt_unicode_ver = "1.0" if($opt_unicode_ver eq "");
}

#######################################
# 參數設定
#######################################

sub initial_para
{
	# xml 來源目錄
	$xml_dir = $cbwork_dir . "/xml-p5/";
	
	# 輸出目錄
	mkdir($release_dir) if(not -d $release_dir);	# c:/temp
	$out_dir = $release_dir . "/p5totxt/";
	mkdir($out_dir) if(not -d $out_dir);	# c:/temp/p5totxt/
	$out_dir .= $file_type . "/";
	mkdir($out_dir) if(not -d $out_dir);	# c:/temp/p5totxt/line/ (or para, html)
	$out_dir .=  $cut_type . "/";
	mkdir($out_dir) if(not -d $out_dir);	# c:/temp/p5totxt/line/juan/ (or jing)
}

#######################################
# 在 DOS 視窗秀出主要的訊息
#######################################

sub show_main_message
{
	print tobig5("\n【 XML P5 轉檔程式 】\n");
	print tobig5("處理資料：$opt_v\n");
	print tobig5("資料來源：$xml_dir\n");
	print tobig5("輸出目錄：$out_dir\n");
	print tobig5("輸出格式：$file_type\n");
	print tobig5("切檔方式：");
	print tobig5("一卷一檔\n") if ($cut_type eq "juan");
	print tobig5("一經一檔\n") if ($cut_type eq "jing");
}

#######################################
# 取得全部 xml 檔名
#######################################
sub get_all_xml_files
{
	my $path = shift;
	find(\&findfile, $path);	# 處理所有檔案
}
sub findfile
{
	push(@files, $_);	# 檔名
	push(@full_files , $File::Find::name);	# 全名
}
#######################################
# 將 utf8 編碼的文字轉成 big5 編碼
#######################################

sub tobig5
{
	my $utf8 = shift;
	return encode("big5", $utf8);
}

#######################################
# 印出說明
# 印出本檔最前面的內容, 直到遇到 use
#######################################

sub print_help
{
	open IN, "<:utf8", $0;
	while(<IN>)
	{
		last if(/^# head end #/);
		print tobig5($_);
	}
}

#######################################
# 將結果印出來
#######################################

sub print_file
{
	my $txt_ref = shift;
	my $outpath = $out_dir;
	$outpath .= $ID->ed . "/";
	mkdir($outpath) if(not -d $outpath);	# c:/temp/p5totxt/line/juan/T/
	$outpath .= $ID->vol . "/";
	mkdir($outpath) if(not -d $outpath);	# c:/temp/p5totxt/line/juan/T/T01/
	
	if($cut_type eq "jing")
	{
		my $outfile = get_file_name($outpath,0);
		print_out_file($outfile, $txt_ref);
	}
	else
	{
		# 一卷一檔
		# 每一卷之前都有 <juan xx> 做為切卷
		
		my @lines = split(/\n/, $$txt_ref);
		my $text = "";
		my $juan_num = 0;
		my $outfile = "";
		for(my $i=0; $i<=$#lines; $i++)
		{
			if($lines[$i] =~ /^<juan (\d+)>/)
			{
				# 遇到新的一卷
				my $juan = $1;
				if($juan_num != 0)
				{
					# 舊的先儲存
					$outfile = get_file_name($outpath, $juan_num);
					print_out_file($outfile, \$text);
					$text = "";
				}
				$juan_num = $juan;
				$lines[$i] =~ s/^<juan (\d+)>//;
			}
			$text .= $lines[$i] . "\n";
		}
		# 結束後還要印最後一卷
		$outfile = get_file_name($outpath, $juan_num);
		print_out_file($outfile, \$text);
	}
}

# 取得檔名
# $ID 是通用的, 
sub get_file_name
{
	my $outpath = shift;
	my $juan_num = shift;
	my $outfile = $outpath . $ID->sutra_id;	# .../T/T01/T01n0001
	if($cut_type eq "juan")
	{
		$outfile .= sprintf("_%03d",$juan_num); # .../T01n0001_001
	}
	if($file_type eq "html") { $outfile .= ".htm"; } # .../T01n0001_001.htm
	else { $outfile .= ".txt"; } # .../T01n0001_001.txt

	return $outfile;
}

# 真正印出結果
sub print_out_file
{
	my $file = shift;
	my $txt_ref = shift;
	open OUT, ">utf8:", $file;
	print OUT $$txt_ref;
	close OUT;
}

#####################################################
# 將 xml 裡面 <charDecl> 讀到的資訊加到 $gaiji 資料庫中
#####################################################
sub add_new_gaiji
{
=begin
	given ($chardecl{'type'})
	{
		when ("composition")	# 組字式
		{
			$gaiji->cb2des($chardecl{'cb'}, $chardecl{'val'});
			$gaiji->des2cb($chardecl{'val'}, $chardecl{'cb'});
		}
		when ("normalized form")	# 通用字
		{
			$gaiji->cb2nor($chardecl{'cb'}, $chardecl{'val'});
		}
		when ("unicode")	# unicode
		{
			$gaiji->cb2uni($chardecl{'cb'}, $chardecl{'val'});
			$gaiji->cb2uniword($chardecl{'cb'}, chr(hex($chardecl{'val'})));
		}
		when ("normal unicode")	# normal unicode
		{
			$gaiji->cb2noruni($chardecl{'cb'}, $chardecl{'val'});
			$gaiji->cb2noruniword($chardecl{'cb'}, chr(hex($chardecl{'val'})));
		}
		default { die "error! found unknow <charDecl> type : $chardecl{'type'} , call Heaven Chou!!";}
	}
=cut
}

##############################################################################
# 處理 XML
##############################################################################

sub ParserXML
{
    my $file = shift;
	my $doc = $parser->parsefile($file);
	
	# my $root = $doc->getDocumentElement();
	# my $text = parseNode($root);	# 全部進行分析
	
	my @body = $doc->getElementsByTagName("body");
	my $text = parseNode($body[0]);	# 進行分析指定的 <body> 內容
	
	$doc->dispose;
    return $text;
}

# 處理節點
sub parseNode
{
    my $node = shift;
    my $text = "";
    my $nodeTypeName = $node->getNodeTypeName;
	if ($nodeTypeName eq "ELEMENT_NODE") 
    {
        # 處理標記
        my $tag_name = $node->getNodeName();	# 取得標記名稱

		if ($tag_name eq "anchor")			{} #$text = tag_anchor($node); }	
		# elsif ($tag_name eq "app")		{ $text = tag_app($node); }	
		# elsif ($tag_name eq "biblScope")	{ $text = tag_biblScope($node); }	
		# elsif ($tag_name eq "byline")		{ $text = tag_byline($node); }	
		# elsif ($tag_name eq "cell")		{ $text = tag_cell($node); }	
		# elsif ($tag_name eq "cb:div")		{ $text = tag_div($node); }	
		# elsif ($tag_name eq "cb:docNumber")	{ $text = tag_docNumber($node); }	
		# elsif ($tag_name eq "entry")		{ $text = tag_entry($node); }	
		# elsif ($tag_name eq "figDesc")	{ $text = tag_figdesc($node); }	
		# elsif ($tag_name eq "foreign")	{ $text = tag_foreign($node); }	
		# elsif ($tag_name eq "form")		{ $text = tag_form($node); }	
		# elsif ($tag_name eq "formula")	{ $text = tag_formula($node); }	
		# elsif ($tag_name eq "g")			{ $text = tag_g($node); }	
		# elsif ($tag_name eq "graphic")	{ $text = tag_graphic($node); }	
		# elsif ($tag_name eq "head")		{ $text = tag_head($node); }	
		# elsif ($tag_name eq "hi")			{ $text = tag_formula($node); }	  # 二標記處理法相同
		# elsif ($tag_name eq "item")		{ $text = tag_item($node); }	
		# elsif ($tag_name eq "cb:juan") 	{ $text = tag_juan($node); }	
		# elsif ($tag_name eq "l")			{ $text = tag_l($node); }	
		elsif ($tag_name eq "lb")			{ $text = tag_lb($node); }	
		# elsif ($tag_name eq "lem")		{ $text = tag_lem($node); }	
		# elsif ($tag_name eq "lg")			{ $text = tag_lg($node); }	
		# elsif ($tag_name eq "list")		{ $text = tag_list($node); }	
		elsif ($tag_name eq "milestone")	{ $text = tag_milestone($node); }	
		# elsif ($tag_name eq "cb:mulu")	{ $text = tag_mulu($node); }	
		# elsif ($tag_name eq "note")		{ $text = tag_note($node); }	
		elsif ($tag_name eq "p")			{ $text = tag_p($node); }	
		# elsif ($tag_name eq "pb")			{ $text = tag_pb($node); }	
		# elsif ($tag_name eq "rdg")		{ $text = tag_rdg($node); }	
		# elsif ($tag_name eq "ref")		{ $text = tag_ref($node); }	
		# elsif ($tag_name eq "row")		{ $text = tag_row($node); }	
		# elsif ($tag_name eq "seg")		{ $text = tag_seg($node); }	
		# elsif ($tag_name eq "cb:sg")		{ $text = tag_sg($node); }	
		# elsif ($tag_name eq "space")		{ $text = tag_space($node); }	
		# elsif ($tag_name eq "cb:t")		{ $text = tag_t($node); }	
		# elsif ($tag_name eq "table")		{ $text = tag_table($node); }	
		# elsif ($tag_name eq "term")		{ $text = tag_term($node); }	
		# elsif ($tag_name eq "text")		{ $text = tag_term($node); } # text 和 term 處理法相同
		# elsif ($tag_name eq "trailer")	{ $text = tag_trailer($node); }	
		# elsif ($tag_name eq "cb:tt")		{ $text = tag_tt($node); }	
		# elsif ($tag_name eq "unclear")	{ $text = tag_unclear($node); }	
		else                      			{ $text = tag_default($node); }	

    }
	elsif ($nodeTypeName eq "TEXT_NODE") 
    {
        # 處理文字
        $text = text_handler($node);
    }
	elsif ($nodeTypeName eq "COMMENT_NODE") 
    {
        # 處理註解
        # $text = "<!--" . $node->getNodeValue() . "-->";
    }   
	else
	{
	    # 警告沒有處理到的
		print $node;
		print "find some data no run!!! call heaven!!!";
		exit;
	}
    return $text; 
}

# 處理子程序
sub parseChild
{
    my $node = shift;
    my $text = "";
    for my $kid ($node->getChildNodes) 
    {
        $text .= parseNode($kid);
    }
    return $text;    
}

# 處理文字
sub text_handler
{
    my $node = shift;
    my $text = $node->getNodeValue();   # 取得文字
    $text =~ s/\n//g;   # 移除換行
    return $text;     
}

################################
# 處理各種標記
################################

#<lb n="0030a13" ed="T"/>
#<lb n="0030a13" ed="R"/>				不是同一個版本的 ed 不處理
#<lb n="0030a13" ed="T" type="old"/>	type="old" 不處理
#<lb ed="X" n="0070b01" type="honorific"/> 強迫切行
#???? 隔行對照待處理

sub tag_lb
{
    my $node = shift;
    my $text = "";
	
	if($file_type eq "line")	# 原書模式才處理
	{
		# 處理標記
		my $att_n = node_get_attr($node,"n");	# 取得屬性
		my $att_ed = node_get_attr($node,"ed");	# 取得屬性
		my $att_type = node_get_attr($node,"type");	# 取得屬性
		return "" if($att_type eq "old");
		return "" if($att_ed ne $ID->ed);

		$text = "\n" . $ID->sutra_id_ . "p" . $att_n . "║";
	}
	elsif($file_type eq "para")
	{
		if($att_type eq "honorific")	#強迫切行
		{
			$text = "\n";
		}
	}
    return $text;
}

#<milestone n="1" unit="juan"/>
# 一卷一檔在經文中插入 <juan 1> , 做為切卷的標記
sub tag_milestone
{
    my $node = shift;
    my $text = "";
	
	if($cut_type eq "juan")	# 一卷一檔才處理
	{
		# 處理標記
		my $att_n = node_get_attr($node,"n");	# 取得屬性
		if($att_n)
		{
			$text = "\n<juan $att_n>";
		}
	}
    return $text;
}

sub tag_p
{
    my $node = shift;
    my $text = "";
    
    # 處理內容
	$text .= "\n" if($file_type eq "para");
	$text .= parseChild($node);
	$text .= "\n" if($file_type eq "para");
    
    # 處理標記結束
    return $text;
}

# 處理預設標記
# <tag a="x">abc</tag>
sub tag_default
{
    my $node = shift;
	# 處理標記 <tag>
    # my $tag_name = $node->getNodeName();
	# 處理屬性 a="x"
	# my $attr_text = node_get_attr_text($node); 
    # 處理內容
    my $child_text = parseChild($node);
	# 處理標記結束 </tag>
	# my $text = get_full_tag($tag_name,$attr_text,$child_text);
    return $child_text;
}

# node 取回指定屬性
# 用法 $attr_n = node_get_attr($node,"n");
sub node_get_attr
{
	my $node = shift;
	my $attr = shift;
	my $att_n = $node->getAttributeNode($attr);	# 取得屬性
    if($att_n)
    {
		my $n = $att_n->getValue();	# 取得屬性內容
		$n =~ s/&/&amp;/g;
		$n =~ s/</&lt;/g;
		$n =~ s/&amp;amp;/&amp;/g;
		$n =~ s/&amp;lt;/&lt;/g;
		return $n;
    }
	else
	{
		return "";
	}
}
##############################################################################