# 產生 sutralist.txt , 這是主要的經名資料

use utf8;
#use File::Copy;
use Cwd;
use strict;

my $para = shift;	# 傳入的參數，主要是 see 是處理西蓮

# 使用 p5a , 免得經名有 ext-b 以上的 unicode , 造成 mac 處理有問題
my $SourcePath = "d:/cbwork/xml-p5b";		# 初始目錄, 最後不用加斜線 /
my $OutputPath = "d:/cbwork/xml-p5b";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /
my $MakeOutputPath = 0;		# 1 : 產生對應的輸出目錄
my $IsIncludeSubDir = 1;	# 1 : 包含子目錄 0: 不含子目錄
my $FilePattern = "*.xml";		# 要找的檔案類型

my %list_hash = ();         # 用來放某一冊的結果, 要使用頁欄行排序
my $outfile = "sutralist.txt";

# 處理西蓮淨苑
if($para eq "see") {
	$outfile = "sutralist_see.txt"
}

open OUT, ">:utf8", $outfile or die "open error";
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
	
	%list_hash = ();         # 用來放某一冊的結果, 要使用頁欄行排序
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

	# 輸出 %list_hash

	for my $key (sort(keys(%list_hash))) { 
		print OUT $list_hash{$key};
	}

	return unless($IsIncludeSubDir);	# 若不搜尋子目錄就離開
	
	opendir (DIR, "$ThisDir");
	@files = readdir(DIR);
	closedir(DIR);
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);

		# 判斷是不是西蓮
		if($para eq "see") {
			if($file !~ /DA|ZY|HM/) {
				next;
			}
		} else {
			if($file =~ /DA|ZY|HM/) {
				next;
			}
		}
		# CB01 是測試用的資料
		if($file =~ /CB/) {
			next;
		}

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
	my $findbody = 0;	# 找到 <body> 才設為 1, 才開始檢查 <lb> , 以免查到註解中的 <lb>
	my $name = "";	# 經名
	my $name2 = "";	# 經名
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

	if($file =~ /([A-Z]+)(\d+)n(.{4,5})\.xml/)
	{
		$book = $1;
		$volnum = $2;
		$stdnum = $3;
	}
	else
	{
		print STDERR "$file format error!";
		<>;
	}

	print STDERR $file . "\n";
	open IN, "<:utf8", $file or die "open error";
	while (<IN>)
	{
		if($findbody == 0)
		{
			if (/title.*No. ([ABa]?)(\d+)([A-Za-z])?\s*(.*)<\/title/) 
			{
				my $j = $1;
				my $number  = $2;
				my $other = $3;
				$name = $4;

				if($j)	# A,B 嘉興藏的經號, 或是 a 是 CBETA 新增經號
				{
					$num = $j . sprintf("%03d",$number) . $other;
				}
				else
				{
					$num = sprintf("%04d",$number) . $other;
				}

				if($num ne $stdnum)
				{
					print STDERR "sutra num diff $book $volnum $num vs $stdnum\n";
					<>;
				}
			}
			if(/<author>(.*?)<\/author>/)
			{
				$byline = $1;
			}
			if (m#<extent>(\d+?)卷</extent>#) 
			{
				$juan = $1;
			}
			if (/<body>/) 
			{
				$findbody = 1;
			}
			# 新版檔頭的額外檢查
			# <idno type="canon">T</idno>
			# <idno type="vol">1</idno>
			# <idno type="no">6</idno>
			if(/<idno type="canon">(.*?)<\/idno>/)
			{
				my $ed = $1;
				if($book ne $ed)
				{
					print STDERR "error : book ne ed : $book $ed\n";
					<>;
				}
				$new_xml_head_count++;
			}
			if(/<idno type="vol">(.*?)<\/idno>/)
			{
				my $v = $1;
				if($volnum != $v)
				{
					print STDERR "error : vol ne v : $volnum $v\n";
					<>;
				}
				$new_xml_head_count++;
			}
			if(/<idno type="no">(.*?)<\/idno>/)
			{
				my $n = $1;

				if(length($n)<5 && $n !~ /^[ABa]\d{3}$/)
				{
					$n = "00000" . $n;
					$n =~ s/^.*?(\d{4}\D?)$/$1/;
				}
				if($num ne $n)
				{
					print STDERR "error : num ne n : $num $n\n";
					<>;
				}
				$new_xml_head_count++;
			}
			# <title level="m" xml:lang="zh-Hant">般泥洹經</title>
			if(/<title level="m" xml:lang="zh-Hant">(.*?)<\/title>/)
			{
				$name2 = $1;
				$new_xml_head_count++;
			}
		}
		if($findbody == 1)
		{
			if($name ne $name2)
			{
				print STDERR "error : name ne name2 : $name vs $name2\n";
				<>;
			}
			if($new_xml_head_count != 4)
			{
				print STDERR "new XML head error, count != 4: $new_xml_head_count\n";
				<>;
			}
			if($first_lb eq "")
			{
				s/<lb[^>]*"old"[^>]*>//g;	# 先把 type="old" 去掉不算
				if (/(<lb\s[^>]*ed\s*=\s*"${book}"[^>]*>)/) 
				{
					my $tag = $1;
					if ($tag =~ /n\s*=\s*"(.{7})"/) 
					{
						$first_lb = $1;
					}
				}
			}
			if($first_juan == 0)
			{
				# <milestone unit="juan" n="1"/>
				if(/<milestone\s[^>]*?n="(\d+)"[^>]*>/)
				{
					$first_juan = $1;
				}
			}
		}

		if($first_juan > 0 && $first_lb ne "")
		{
			last;
		}
	}
	close IN;

	if ($juan == 0 || $first_juan == 0) 
	{
		#$juan = 1;
		print STDERR "error : no juan : $book $volnum $num $juan $first_juan\n";
		<>;
	}
	
	if ($name eq "") 
	{
		print STDERR "error : no sutra name : $book $volnum $num \n";
		<>;
	}

	if ($first_lb eq "") 
	{
		print STDERR "error : no first lb : $book $volnum $num \n";
		<>;
	}
	
	if($book eq "" || $volnum eq "" || $num eq "")
	{
		print STDERR "error sutra : $book $volnum $num \n"; 
		<>;
	}

	my $list = "$book,$volnum,$num,$juan,$first_juan,$first_lb,$name,$byline\n";
	my $key = $first_lb;
	if($first_lb =~ /^[a-m]/i) {
		$first_lb = "1" . $first_lb;
	} elsif($first_lb =~ /^[n-z]/i) {
		$first_lb = "3" . $first_lb;
	} else {
		$first_lb = "2" . $first_lb;
	}
	$list_hash{$first_lb} = $list;
}


