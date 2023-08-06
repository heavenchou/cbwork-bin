# 由 p5a 產生 spine.txt 檔案        ~ by heaven 2018/03/15
#

use utf8;
use Cwd;
use strict;

my $para = shift;	# 傳入的參數，主要是 see 是處理西蓮

my $SourcePath = "d:/cbwork/xml-p5b";			# 初始目錄, 最後不用加斜線 /
my $OutputPath = "d:/cbwork/xml-p5b/";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /
my $MakeOutputPath = 0;		# 1 : 產生對應的輸出目錄
my $IsIncludeSubDir = 1;	# 1 : 包含子目錄 0: 不含子目錄
my $FilePattern = "*.xml";		# 要找的檔案類型

my @all_files = ();		# 記錄所找到的檔案, 先記起來, 最後再處理.

# 處理藏經的順序
my @book_order = ("T","X","A","K","S","F","C","D","U","P","J","L","G","M","N","ZS","I","ZW","B","GA","GB","Y","LC","TX","CC");
my $outfile = "spine.txt";

# 處理西蓮淨苑
if($para eq "see") {
	@book_order = ("DA","ZY","HM");
	$outfile = "spine_see.txt"
}

open OUT, ">:utf8", $outfile;
open LOG, ">:utf8", "error.txt";
for(my $i=0; $i<=$#book_order; $i++)
{
	my $source = $SourcePath . "/" . $book_order[$i];
	SearchDir($source, $OutputPath);
}
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
		
		#if($book eq "T" && $volnum >=5 && $volnum <= 7)
		{
			my $text = ParserXML($all_files[$i]);
        	print OUT $text;
		}
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
	local $_;
    my $file = shift;
	my $text = "";
	my $filename = "";
	
	my $book = "";      # T
	my $volnum = "";    # 01
	my $sutra = "";     # 0001

	($book,$volnum,$sutra) = get_vol_sutra($file);
	
	open IN, "<:utf8", $file;
	while(<IN>)
	{
		# 處理 milestone
		#<milestone n="1" unit="juan"/>
		if(/(<milestone[^>]*>)/)
		{
			my $ms = $1;
			s/<milestone[^>]*>//;
			if($ms !~ /unit\s*=\s*"juan"/)
			{
				print "error: milestone no unit=juan : $ms\n";
				<>;
			}
			if($ms =~ /n\s*=\s*"(\d+)"/)
			{
				my $n = $1;
				my $newsutra = $sutra;
				if($book eq "T" && $volnum >= 5 && $volnum <= 7)
				{
					$newsutra =~ s/0220./0220/;
				}
				# 先記錄檔名的部份
				if($filename ne "")
				{
					print "error: why filename not empty: $filename\n";
					<>;
				}
                $filename = "XML/$book/$book$volnum/$book$volnum" . "n$newsutra" . "_";
                $filename .= sprintf("%03d",$n) . ".xml , ";
			}
			else
			{
				print "error: milestone no n : $ms\n";
				<>;
			}
		}

		# 處理 lb
		# <lb n="0922b01" ed="T"/>

		if($filename ne "")
		{
			while(/<lb [^>]*>/)
			{
				s/(<lb [^>]*>)//;
				my $lb = $1;

				# 先檢查 ed 和 type 是否符合要求
				if($lb =~ /ed\s*=\s*"$book"/ && $lb !~ /type\s*=\s*"old"/)
				{
					if($lb =~ /n\s*=\s*"(\S\d{3}[a-z]\d\d)"/)
					{
						my $n = $1;
						$text .= $filename . $n . "\n";
						$filename = "";
						last;
					}
					else
					{
						print "error: lb n format bad : $lb\n";
						<>;
					}
				}
			}
		}
	}
	close IN;
    return $text;
}

