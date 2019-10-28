##################################################################
# 依現有 XML 經文產生大藏經的目錄
#
# 產生 catalog.txt , 這是各經的主要資料庫, 也會產生 juandata 目錄, 這是各卷的資料.
# ★ 執行前要先準備好的檔案 : vols_list.txt , 這是所有冊數的列表
##################################################################

use utf8;
use File::Copy;
use Win32::ODBC;

##################################################################
# 常數
##################################################################

my $xml_path = "c:/cbwork/xml-p5";		# xml 經文的目錄

##################################################################
# 變數
##################################################################

my @vols;		# 全部的冊數列表
my $id;			# T01n0001
my $book;		# T
my $vol;		# T01
my $volnum;		# 01

##################################################################
# 主程式
##################################################################

#readGaiji();		# 讀取缺字檔
#readCbetaEnt();	# 讀取 ent 檔
read_vols();		# 取得所有的冊數

open OUT, ">:utf8", "catalog.txt" or die "open catalog.txt error";
mkdir("juandata");

# 處理各冊
foreach $vol (sort(@vols))
{
	$vol =~ /^(\D+)(.*)/;
	$book = $1;
	$volnum = $2;
	dodir($vol);
}

close OUT;

print "\nOK\n catalog.txt T05,T06,T07 please modify by youself!!";
<>;

##################################################################
# 由 vols_list.txt 將各冊推入 @vols 堆疊
##################################################################

sub read_vols
{
	open IN, "<:utf8", "vols_list.txt" or die "open vols_list.txt error. $!";
	while(<IN>)
	{
		# T01,T,01
		chomp;
		my @d = split(/\s*,\s*/,$_);
		my $vol = $d[0];		# "T01"
		push(@vols,$vol);
	}
	close IN;
}

##################################################################
# 處理各冊
##################################################################

sub dodir
{
	$vol = shift;
	my $dir = "$xml_path/$book/$vol/";
	if (not -e $dir) { return; }
	print STDERR "Run $dir ...\n";
	
	opendir INDIR, $dir or die "opendir $dir error: $dir $!";
	my @allfiles = grep(/^${vol}n.{4,5}\.xml$/i, readdir(INDIR));
	closedir INDIR;
	
	open JUAN , ">juandata/${vol}.txt" || die "open $vol juan line error!";
	foreach $file (sort @allfiles)
	{
		do1file($dir . $file);
	}
	close JUAN;
}

##################################################################
# 處理各檔案
##################################################################

sub do1file
{
	my $file = shift;
	
	my $number;		# 0001	經號
	my $juan;		# 卷數
	my $normal_juan = 1;	# 判斷是否是正常的連結卷
	my $name;	# 經名
	my $author;	# 作譯者
	my @lbs;	# 各卷的 頁欄行 資訊
	
	print STDERR "$file\n";
	open IN, "<:utf8", $file or die "open $file error. $!";
	
	$juan = 0;
	while (<IN>)
	{
		# <title>Taisho Tripitaka, Electronic version, No. 0001 長阿含經</title>
		if (/<title>.*No. ([AB]?)(\d+)([A-Za-z])?\s*(\S.*)<\/title/)
		{
			my $j = $1;			# 嘉興藏特有經號
			my $num  = $2;		# 經號
			my $other = $3;		# 別本
			$name = $4;			# 經名
			
			if($j)	#嘉興藏的經號
			{
				$number = $j . sprintf("%03d",$num) . $other;
			}
			else
			{
				$number = sprintf("%04d",$num) . $other;
				if($vol =~ /T0[5-7]/)
				{
					$number = "0220";	# 大般若經的特例, 不需要別本資訊
				}
			}
		}
		# <author>後秦 佛陀耶舍共竺佛念譯</author>
		if(/<author>(.*)<\/author>/)
		{
			$author = $1;
		}
		#<extent>22卷</extent>
		if (/<extent>(\d+?)卷<\/extent>/)
		{
			$juan = $1;
		}
		# 跳過註解
		if(/<!--/)
		{
			if($_ !~ /<!--.*?-->/)	# 註解不只一行
			{
				while(<IN>)
				{
					last if(/-->/);
				}
			}
		}
		
		# 遇到 <body> 就離開檔頭區的讀取
		if(/<body>/)
		{
			last;
		}
	}
	
	# 百品還沒有卷, 先手動處理
	if ($juan == 0) 
	{
		$juan = 1;
	}
	
	# 接著讀取各卷的資料 #########################################
	
	my $juan_count = 0;		# 卷的數量
	while (<IN>)
	{
		# <lb n="0001a02" ed="T"/>
		if (/^<lb\s[^>]*n="(\w{7})"/)
		{
			$lb = $1;
		}
		
		# <milestone unit="juan" n="10"/> , <milestone n="1" unit="juan"/>
		if (/<milestone\s[^>]*n="(.*?)"/)
		{
			my $ms = $1;
			$juan_count++;
			$normal_juan = 0 if($juan_count != $ms);	# 若卷數不同, 就表示為不連續卷
			
			print JUAN "${vol}n${number},$book,$volnum,$number,$juan_count,$ms,$lb\n";		# 列出每一卷的開頭頁欄行
		}
	}
	
	# 檢查一下卷數有沒有正確
	
	if($juan != $juan_count)
	{
		print STDERR "error : 卷數不合 $juan vs $juan_count";
		<>;
		$juan = $juan_count;
	}
	
	close IN;
	
	#while ($name=~ /&(.*?);/) {
	#	if (exists($nor{$1})) {
	#		my $n = $nor{$1};
	#		$name =~ s/&.*?;/$n/;
	#	} else {
	#		die "$1";
	#	}
	#}

	print OUT "${vol}n${number},$book,$volnum,$number,$juan,$normal_juan,$name,$author\n";
}

##################################################################
# The END
##################################################################