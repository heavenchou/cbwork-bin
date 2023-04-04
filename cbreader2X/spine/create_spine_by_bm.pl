# 由 BM 產生 spine.txt 檔案        ~ by heaven 2018/03/15
#

use utf8;
use Cwd;
use strict;

my $para = shift;	# 傳入的參數，主要是 see 是處理西蓮

my $SourcePath = "d:/cbwork/bm";			# 初始目錄, 最後不用加斜線 /
my $OutputPath = "d:/cbwork/bm";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /
my $MakeOutputPath = 0;		# 1 : 產生對應的輸出目錄
my $IsIncludeSubDir = 1;	# 1 : 包含子目錄 0: 不含子目錄
my $FilePattern = "new.txt";		# 要找的檔案類型

my @all_files = ();		# 記錄所找到的檔案, 先記起來, 最後再處理.

# 處理藏經的順序
my @book_order = ("T","X","A","K","S","F","C","D","U","P","J","L","G","M","N","ZS","I","ZW","B","GA","GB","Y","LC","TX");

my $outfile = "spine_by_bm.txt";

# 處理西蓮淨苑
if($para eq "see") {
	@book_order = ("DA","ZY","HM");
	$outfile = "spine_see_by_bm.txt"
}

open OUT, ">:utf8", $outfile;
open LOG, ">:utf8", "error_by_bm.txt";
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
	my $pageline = "";	# 0001a01

	open IN, "<:utf8", $file;
	while(<IN>)
	{
		# 處理 milestone
		# T01n0001_p0001a01_##<mj 001><N>No. 1
		if(/<mj (\d+)>/)
		{
			my $juan = $1;

			if(/^(?:\x{FEFF})?(\D+)(\d+)n(.\d+[a-zA-Z]?)_?p(.\d{3}[a-z]\d\d)/)
			{
				$book = $1;
				$volnum = $2;
				$sutra = $3;
				$pageline = $4;

				my $newsutra = $sutra;
				if($book eq "T" && $volnum >= 5 && $volnum <= 7)
				{
					$newsutra =~ s/0220./0220/;
				}

                $filename = "XML/$book/$book$volnum/$book$volnum" . "n$newsutra" . "_";
                $filename .= sprintf("%03d",$juan) . ".xml , $pageline\n";
				$text .= $filename;
			}
			else
			{
				print "error: linehead error : $_\n";
				<>;
			}
		}
	}
	close IN;
    return $text;
}

