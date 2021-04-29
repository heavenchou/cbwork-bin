# 產生 sutralist.txt , 這是主要的經名資料

use utf8;
#use File::Copy;
use Cwd;
use strict;

# 使用 p5a , 免得經名有 ext-b 以上的 unicode , 造成 mac 處理有問題
my $SourcePath = "d:/cbwork/bm";		# 初始目錄, 最後不用加斜線 /
my $OutputPath = "d:/cbwork/xml-p5b";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /
my $MakeOutputPath = 0;		# 1 : 產生對應的輸出目錄
my $IsIncludeSubDir = 1;	# 1 : 包含子目錄 0: 不含子目錄
my $FilePattern = "source.txt";		# 要找的檔案類型

open OUT, ">:utf8", "sutralist_by_bm.txt" or die "open error";
SearchDir($SourcePath, $OutputPath);
close OUT;

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
			SearchFile($NewFile , $NewOutputFile);
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

# 處理單一檔案

sub SearchFile 
{
	my $file = shift;
	my $name = "";	# 經名
	my $byline = "";	# 作譯者
	my $book = "";	# 藏經 T
	my $volnum = ""; 	# 冊數 01
	my $num = "";	# 標準經號
	my $stdnum = "";	# 標準經號2
	my $juan = 0;	# 卷數
	my $first_juan = 0;	# 第一卷的卷數
	my $first_lb = "";	# 
	my $new_xml_head_count = 0;
	local $_;

	my %hash = ();

	print STDERR $file . "\n";
	open IN, "<:utf8", $file or die "open error";
	while (<IN>)
	{
		#A1057-091-p0311  V1.0  2011/01/15  2  新譯大方廣佛華嚴經音義  【唐 慧菀述】

		if(/([A-Z]+)(a?\d+[a-zA-Z]?)[\-_]?(\d+)[\-_]p.*?\d{4}\/\d\d?\/\d\d?\s*(\d+)\s*(\S.*?) *【(.*?)】/)
		{
			$book = $1;
			$num = $2;
			$volnum = $3;
			$juan = $4;
			$name = $5;
			$byline = $6;
			if($book =~ /J([AB])/)
			{
				$num = $1 . $num;
				$book = "J";
			}

			# A,110,1490,2,1,0661b01,天聖釋教總錄,宋 惟淨等編修
			$hash{$num} = "$book,$volnum,$num,$juan,<>,$name,$byline";
		}
	}

	# 讀 new.txt
	$file =~ s/source\.txt/new\.txt/;
	open IN, "<:utf8", $file or die "open error";
	my $laststura = "";
	while (<IN>)
	{
		#J26nB177_p0001a01_##<mj 001><Q1>序
		if(/<mj 0*(\d+)>/)
		{
			my $firstjuan = $1;
			if(/^\D+\d+n(.\d+[a-zA-Z]?)_?p(.{7})/)
			{
				my $sutra = $1;
				my $pageline = $2;
				if($sutra ne $laststura)
				{
					my $data = "$firstjuan,$pageline";
					$hash{$sutra} =~ s/<>/$data/;
					print OUT $hash{$sutra} . "\n";
					$laststura = $sutra;
				}
			}
		}
	}
}


