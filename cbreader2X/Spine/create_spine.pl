# 由 p5a 產生 spine.txt 檔案        ~ by heaven 2018/03/15
#

use utf8;
use Cwd;
use strict;
use XML::DOM;
my $parser = new XML::DOM::Parser;

my $SourcePath = "c:/cbwork/xml-p5a/J/J15";			# 初始目錄, 最後不用加斜線 /
my $OutputPath = "c:/cbwork/xml-p5a/";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /
my $MakeOutputPath = 0;		# 1 : 產生對應的輸出目錄
my $IsIncludeSubDir = 1;	# 1 : 包含子目錄 0: 不含子目錄
my $FilePattern = "*.xml";		# 要找的檔案類型

my @all_files = ();		# 記錄所找到的檔案, 先記起來, 最後再處理.

my $book = "";      # T
my $volnum = "";    # 01
my $sutra = "";     # 0001

my $lb = "";    #

open OUT, ">>:utf8", "spineX.txt";
open LOG, ">:utf8", "error.txt";
SearchDir($SourcePath, $OutputPath);
run_all_files();    # 處理所有檔案
close OUT;
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
		my $NewOutputFile = $ThisOutputDir . "/" . $file ;
		if (-f $NewFile)
		{
			push(@all_files, $NewFile);
		}
	}
	return unless($IsIncludeSubDir);	# 若不搜尋子目錄就離開
	
	opendir (DIR, "$ThisDir");
	@files = readdir(DIR);
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
    for(my $i=0; $i<=$#all_files; $i++)
    {
        print $all_files[$i] . "\n";
		($book,$volnum,$sutra) = get_vol_sutra($all_files[$i]);
		my $text = ParserXML($all_files[$i]);
        print OUT $text;
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
        elsif($tag_name eq "milestone") { $text = tag_milestone($node); }
        else { $text = tag_default($node); }				# 處理一般標記
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

################################
# 處理各種標記
################################

# 處理 xx 標記
sub tag_default
{
    my $node = shift;
    my $text = parseChild($node);
    return $text;
}

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
        $lb = $n;
    }
    return "";
}

# <milestone n="8" unit="juan"/>
sub tag_milestone
{
    my $node = shift;
    my $text = "";
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
                $text = "XML/$book/$book$volnum/$book$volnum" . "n$sutra" . "_";
                $text .= sprintf("%03d",$n) . ".xml , $lb\n";
			}
			else
			{
				print "error milestone no n \n";
                <>;
			}
		}
		else
		{
			print "error milestone unit not juan \n";
            <>;
		}
    }
	else
	{
		print "error milestone no unit \n";
        <>;
	}
    return $text;
}

