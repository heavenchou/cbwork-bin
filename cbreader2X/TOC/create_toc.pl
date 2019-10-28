# create_toc.pl  		   ~by heaven 2018/03/10
#
# 程式說明：產生 CBReader 2X 版所使用的各經目錄
# 使用方法：自行修改前幾個變數
# 或傳入參數
#			perl create_toc.pl T	只處理大正藏 T
#			perl create_toc.pl T01	只處理 T01 , 不過若有跨冊的經文要小心
#############################################################################

use utf8;
use Cwd;
use strict;
use XML::DOM;

use lib '.';
use toc_tree;	# 自己寫的樹狀目錄操作

my $input_vol = shift;	# 傳入的參數, 可能有二種 1. T 2. T01
if($input_vol =~ /^(\D+)(\d+)$/)
{
	$input_vol = "/" . $1 . "/" . $input_vol;
}
elsif($input_vol =~ /^\D+$/)
{
	$input_vol = "/" . $input_vol;
}
else
{
	$input_vol = "";
}

my $SourcePath = "c:/cbwork/xml-p5b" . $input_vol;		# 初始目錄, 最後不用加斜線 /
my $OutputPath = "c:/cbwork/bin/cbreader2X/toc/toc_gaiji";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /
my $logfile = "errlog.txt";				# 錯誤記錄檔
my $MakeOutputPath = 0;		# 1 : 產生對應的輸出目錄
my $IsIncludeSubDir = 1;	# 1 : 包含子目錄 0: 不含子目錄
my $FilePattern = "*.xml";		# 要找的檔案類型

my $book = "";
my $volnum = "";
my $sutra = "";

my @all_files = ();		# 記錄所找到的檔案, 先記起來, 最後再處理.

# 資料用外部的 @mulu_tree , 裡面每一筆有 層次, 內容, 連結位置 , 例 :
# 1,第一分,T01n0001_001.xml#p0001a01
# 2,第一誦,T01n0001_001.xml#p0002a02
#
# 另一個是卷 @juan_tree , 應該只有一層
# 1,第一卷,T01n0001_001.xml#p0001a01
# 1,第二卷,T01n0001_001.xml#p0002a02
our @mulu_tree = ();			# 樹狀目錄結構, 操作在 $toc 物件中 
our @juan_tree = ();			# 卷結構, 操作在 $toc 物件中 

my $parser = new XML::DOM::Parser;
my $toc = toc_tree->new;
$toc->initial();
$toc->outpath($OutputPath);	# 記錄輸出目錄

open LOG, ">:utf8", $logfile;
SearchDir($SourcePath, $OutputPath);    # 搜尋全部檔案
run_all_files();    # 處理所有檔案
close LOG;

##########################################################################

sub SearchDir
{
	my $ThisDir = shift;		# 新的所在的目錄
	my $ThisOutputDir = shift;	# 新的的輸出目錄
	
	print "find dir <$ThisDir>\n";
	
	if($MakeOutputPath)	# 如果需要建立對應子目錄
	{
		mkdir($ThisOutputDir) unless(-d $ThisOutputDir);
	}
	
	my $myPath = getcwd();		# 目前路徑
	chdir($ThisDir);
	my @files = glob($FilePattern);
	chdir($myPath);				# 回到目前路徑
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);		# 不要 . 與 ..
		my $NewFile = $ThisDir . "/" . $file ;
		if (-f $NewFile)
		{
            push(@all_files, $NewFile);
		}
	}
	return unless($IsIncludeSubDir);	# 若不搜尋子目錄就離開
	
	opendir (DIR, "$ThisDir");
	my @files = readdir(DIR);
	closedir(DIR);
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);
		my $NewDir = $ThisDir . "/" . $file ;
		my $NewOutputDir = $ThisOutputDir . "/" . $file ; 
		if (-d $NewDir)
		{
			SearchDir($NewDir, $NewOutputDir);
		}
	}	
}

##########################################################################
# 處理全部檔案, 都在 @all_files 裡面

sub run_all_files
{
	my $pre_sutra = "";
	my $pre_book = "";

    for(my $i=0; $i<=$#all_files; $i++)
    {
        print $all_files[$i] . "\n";
		($book,$volnum,$sutra) = get_vol_sutra($all_files[$i]);

		if($book eq "T" && $volnum >= 5 && $volnum <= 7)
		{
			$sutra =~ s/^0220./0220/;
		}

		# 如果經號不同了, 則前面處理的要產生結果, 然後重新處理
		if($sutra ne $pre_sutra || $book ne $pre_book)
		{
			if($pre_sutra ne "")
			{
				$toc->output();
				if($toc->errmsg)
				{
					print LOG $toc->errmsg;
					$toc->errmsg("");
				}
			}
		}
		$toc->book($book);
		$toc->volnum($volnum);
		$toc->sutra($sutra);

		print LOG  $all_files[$i] . "\n";
		ParserXML($all_files[$i]);

		$pre_book = $book;
		$pre_sutra = $sutra;
    }
	$toc->output();
	if($toc->errmsg)
	{
		print LOG $toc->errmsg;
		$toc->errmsg("");
	}
}

sub get_vol_sutra
{
	local $_ = shift;
	if(/([A-Z]+)(\d+)n(.*?)\.xml/)
	{
		return ($1,$2,$3);
	}
	else
	{
		print LOG "error 檔名格式有問題 : $_\n";
		return ("","","");
	}
}


##########################################################################
# 處理 XML
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
        if($tag_name eq "lb") { $text = tag_lb($node); }
        if($tag_name eq "cb:mulu") { $text = tag_mulu($node); }
        if($tag_name eq "milestone") { $text = tag_milestone($node); }
        else { $text = tag_default($node); }				# 處理一般標記
    }
	elsif ($nodeTypeName eq "TEXT_NODE") 
    {
        # 處理文字
        $text = text_handler($node);
    }
	elsif ($nodeTypeName eq "COMMENT_NODE") 
    {
        # 處理註解
        $text = "<!--" . $node->getNodeValue() . "-->";
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

# 處理 xx 標記

# <lb>
# <lb n="0001a02" ed="T"/>
sub tag_lb
{
    my $node = shift;
    
    # 處理標記

    my $att_ed = $node->getAttributeNode("ed");	# 取得屬性
    if($att_ed)
    {
		my $ed = $att_ed->getValue();	# 取得屬性內容
        if($ed ne $book)
        {
            return "";  # 非本藏經
        }
    }
    
    my $att_type = $node->getAttributeNode("type");	# 取得屬性
    if($att_type)
    {
		my $type = $att_type->getValue();	# 取得屬性內容
        if($type eq "old")
        {
            return "";
        }
    }

    my $att_n = $node->getAttributeNode("n");	# 取得屬性
    if($att_n)
    {
		my $n = $att_n->getValue();	# 取得屬性內容
		$toc->lb($n);
    }
}

# <mulu>
# <cb:mulu level="1" type="序">序</cb:mulu>
# <cb:mulu n="001" type="卷"/>
sub tag_mulu
{
    my $node = shift;
    
    # 處理標記
    my $att_level = $node->getAttributeNode("level");	# 取得屬性
	my $level = "";
    if($att_level)
    {
		$level = $att_level->getValue();	# 取得屬性內容
    }
	
    my $att_type = $node->getAttributeNode("type");	# 取得屬性
	my $type = "";
    if($att_type)
    {
		$type = $att_type->getValue();	# 取得屬性內容
    }

    my $att_n = $node->getAttributeNode("n");	# 取得屬性
	my $n = "";
    if($att_n)
    {
		$n = $att_n->getValue();	# 取得屬性內容
    }
    
    # 處理內容
    my $text = parseChild($node);

	if($n ne "" && $type eq "卷")
	{
		# 處理卷
		if($toc->juan != $n)
		{
			print LOG "error juan not equal : $n vs " . $toc->juan . "\n";
		}
		my $data;

		if($text eq "")
		{
			# 標準卷數, 就存入 
			# 1,T01n0001_001.xml#p0001a01
			$data = $toc->juan . "," . $toc->get_link();
		}
		else
		{
			# 特殊卷數, 就存入 
			# 卷上之一,T01n0001_001.xml#p0001a01
			$data = $text . "," . $toc->get_link();
		}
		push(@juan_tree, $data);
	}
	elsif($level ne "") # && $type ne "" 
	{
		# 處理一般目錄
		my $data = $level . "," . $text . "," . $toc->get_link();
		push(@mulu_tree, $data);
		if($text eq "")
		{
			print LOG "error 空目錄 : " . tag_default($node) . "\n";
		}
	}
	else
	{
		print LOG "other 怪目錄 : " . tag_default($node) . "\n";
	}
}

# <milestone n="8" unit="juan"/>
sub tag_milestone
{
    my $node = shift;
    
    # 處理標記
    my $att_unit = $node->getAttributeNode("unit");	# 取得屬性
	my $unit = "";
    if($att_unit)
    {
		$unit = $att_unit->getValue();	# 取得屬性內容
		if($unit eq "juan")
		{
			my $att_n = $node->getAttributeNode("n");	# 取得屬性
			my $n = "";
			if($att_n)
			{
				$n = $att_n->getValue();	# 取得屬性內容
				$toc->juan($n);
			}
			else
			{
				print LOG "error milestone no n : " . tag_default($node) . "\n";
			}
		}
		else
		{
			print LOG "error milestone unit not juan : " . tag_default($node) . "\n";
		}
    }
	else
	{
		print LOG "error milestone no unit : " . tag_default($node) . "\n";
	}
}

# 處理預設標記
# <tag a="x">abc</tag>
sub tag_default
{
    my $node = shift;
	# 處理標記 <tag>
    my $tag_name = $node->getNodeName();
	# 處理屬性 a="x"
	my $attr_text = node_get_attr_text($node); 
    # 處理內容
    my $child_text = parseChild($node);
	# 處理標記結束 </tag>
	my $text = get_full_tag($tag_name,$attr_text,$child_text);
    return $text;
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

# 組合成標準標記 <tag a="x">abc</tag>
sub get_full_tag 
{
	my $tag_name = shift;
	my $attr_text = shift;
	my $child_text = shift;
	my $text = "";
	
    if($child_text eq "")
	{
		$text = "<" . $tag_name . $attr_text . "/>";
	}
	else
	{
		$text = "<" . $tag_name . $attr_text . ">" . $child_text . "</$tag_name>";
	}
	return $text;
}

# 做出 node 的屬性字串, 如: a="x" b="y" c="z"
sub node_get_attr_text
{
	my $node = shift;
    my $attr_text = "";
	my $attr_map = $node->getAttributes;	# 取出所有屬性
	for my $tag_attr ($attr_map->getValues) # 取出單一屬性
	{
		my $attr_name = $tag_attr->getName;	# 取出單一屬性名稱
		my $attr_value = $tag_attr->getValue;	# 取出單一屬性內容
		$attr_value =~ s/&/&amp;/g;
		$attr_value =~ s/</&lt;/g;
		$attr_value =~ s/&amp;amp;/&amp;/g;
		$attr_value =~ s/&amp;lt;/&lt;/g;
		$attr_text .= " $attr_name=\"$attr_value\"";
	}
	return $attr_text;
}