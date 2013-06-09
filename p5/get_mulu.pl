#######################################################
# 程式名稱：get_mulu.pl
# 程式位置：c:\cbwork\bin\p5
# 程式用途：由 由 XML 經文的 <mulu> 標記產生目錄樹
# 程式步驟：c:\cbwork\bin\p5\perl get_mulu.pl T01
# 設定檔：相關設定由 ../cbwork_bin.ini 取得
# 結果會在輸出目錄下產生 T01_tree.txt
#######################################################

use utf8;
use autodie;
use Encode;
use XML::Parser;
use Config::IniFiles;

my $vol = shift;				# $vol = T01 , 冊數
exit if($vol eq "");			# 沒參數就結束
my $ed = substr($vol,0,1);		# $ed = T

my $cfg = Config::IniFiles->new( -file => "../cbwork_bin.ini" );

my $cbwork_dir = $cfg->val('default', 'cbwork', '/cbwork');	# 讀取 cbwork 目錄
my $output_dir = $cfg->val('get_mulu', 'tree_dir', '/cbwork/bin/p5/tree');	# 讀取 cbwork 目錄
my $xml_path = $cbwork_dir . "/xml-p5a/$ed/$vol/";

my $tree = "";			# 目錄樹全文
my $inTitleStmt = 0;
my $inTitle = 0;
my $inMulu = 0;			# 判斷是否在 <cb:mulu> 標記中
my $mulu_level = 0;		# 目錄的層次
my $mulu_type = "";		# 目錄的總類
my $juan_num = ""; 		# 目前的卷數
my $mulu_tree = "";		# 非卷的目錄樹
my $juan_tree = "";		# 卷的目錄樹

# 開啟目錄, 找出所有檔案

opendir (INDIR, $xml_path);
@files = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @files;

# 逐檔 parse

my $ent;
my $val;
my $parser = new XML::Parser(NoExpand => True);
$parser->setHandlers (
	Init => \&init_handler,
	Final => \&final_handler,
	Start => \&start_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default);

for $file (sort(@files))
{
	my $filename = $xml_path . $file;
	print "\n" . $file . "..." ;
	$parser->parsefile($filename);
}

mkdir($output_dir) if(not -d $output_dir);

open (OUT, ">:encoding(big5)", "${output_dir}/${vol}_tree.txt");
print OUT $tree;	# 印出樹狀目錄
close OUT;

#######################################
# XML Parser
#######################################

#use XML::Parser;
#my $parser = new XML::Parser(NoExpand => True);
#my $ent;
#my $val;

sub init_handler
{
	$inTitleStmt = 0;
	$inTitle = 0;
	$inMulu = 0;		# 判斷是否在 <cb:mulu> 標記中
	$mulu_level = 0;	# 目錄的層次
	$mulu_type = "";	# 目錄的總類
	$juan_num = ""; 	# 目前的卷數
	$mulu_tree = "";	# 非卷的目錄樹
	$juan_tree = "";	# 卷的目錄樹
}

sub final_handler 
{
	if($mulu_tree)
	{
		$tree .= "\n\t目錄" . $mulu_tree;
	}
	$tree .= "\n\t卷數" . $juan_tree;
}

sub start_handler 
{
	my $p = shift;
	$tag = shift;
	my (%att) = @_;

	$inTitleStmt = 1 if($tag eq "titleStmt");
	$inTitle = 1 if($tag eq "title");
	
	### <cb:juan> ###
	# <cb:juan n="008" fun="open">
	#if ($tag eq "cb:juan")
	#{
	#	if($att{"fun"} eq "open")
	#	{
	#		$juan_num = $att{"n"};
	#	}
	#}
	
	### <cb:mulu> ###
	# <cb:mulu level="1" type="序">序</cb:mulu>
	# <cb:mulu type="卷"></cb:mulu>
	if ($tag eq "cb:mulu")
	{
		$inMulu = 1;
		$mulu_type = $att{"type"};	# 目錄的總類
		if($mulu_type eq "卷")
		{
			$juan_num = $att{"n"};
			$juan_tree .= "\n\t\t" . "第 " . $juan_num . " 卷 ";
		}
		else
		{
			$mulu_level = $att{"level"};
			$mulu_tree .= "\n" . "\t" x ($mulu_level + 1);	# 第 n 層就要空 n+1 個 tab
		}
	}
}

sub end_handler {
	my $p = shift;
	my $tag = shift;
	
	$inTitleStmt = 0 if($tag eq "titleStmt");
	$inTitle = 0 if($tag eq "title");
	
	### <cb:mulu> ###
	#<cb:mulu level="1" type="序">序</cb:mulu>
	if ($tag eq "cb:mulu")
	{
		$inMulu = 0;
	}
}

sub char_handler {
	my $p = shift;
	my $char = shift;
	
	if($inTitleStmt == 1 and $inTitle == 1)
	{
		#<titleStmt><title>Taisho Tripitaka, Electronic version, No. 0001 長阿含經</title>
		$char =~ s/^.*?No./No./;
		$tree .= "\n" if ($tree ne "");
		$tree .= $char;
	}
	
	if($inMulu == 1)
	{
		if($mulu_type eq "卷")
		{
			$juan_tree .= $char;
		}
		else
		{
			$mulu_tree .= $char;
		}
	}
}

# 遇到這二行
# [<!ENTITY % ENTY  SYSTEM "X01n0001.ent" >
# <!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
# $ent 分別是 ENTY 及 CBENT
# $entval 皆為空白
# next 分別是 X01n0001.ent 及 ../dtd/cbeta.ent
sub entity {
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	
}

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

##################################################

