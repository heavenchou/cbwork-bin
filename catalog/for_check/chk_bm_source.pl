##################################################################
# 檢查現有的 tripitaka.txt 是否和 BM 版內容相同
##################################################################

use File::Copy;
use Win32::ODBC;

##################################################################
# 常數
##################################################################

my $bm_path = "c:/cbwork/simple";		# xml 經文的目錄

##################################################################
# 變數
##################################################################

my @vols;	# 全部的冊數列表
my $id;			# T01n0001
my $book;		# T
my $vol;		# T01
my $volnum;		# 01
my $number;		# 0001

##################################################################
# 主程式
##################################################################

readGaiji();		# 讀取缺字檔
#readCbetaEnt();		# 讀取 ent 檔
read_vols();	# 取得所有的冊數
read_catalog();	# 讀入 catalog

open OUT, ">chk_bm_source.txt" or die "open chk_bm_source.txt error";

# 處理各冊
foreach $vol (sort(@vols))
{
	$vol =~ /^(\D+)(.*)/;
	$book = $1;
	$volnum = $2;
	dodir($vol);
}

# 看有沒有沒處理到的資料

foreach $key (sort(keys(%juan)))
{
	if($ok{$key} != 1)
	{
		print OUT "\n$key 沒有處理到";
	}
}
close OUT;

print "\nok\n";

##################################################################
# 由 vols_list.txt 將各冊推入 @vols 堆疊
##################################################################

sub read_vols
{
	open IN, "../vols_list.txt" or die "open vols_list.txt error. $!";
	while(<IN>)
	{
		chomp;
		my @d = split(/\s*,\s*/,$_);
		my $vol = $d[0] . $d[1];		# "T01"
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
	my $dir = "$bm_path/$vol/";
	if (not -e $dir) { return; }
	print STDERR "Run $dir ...\n";
	
	do1file($dir . "source.txt");
}

##################################################################
# 處理各檔案
##################################################################

sub do1file
{
	my $file = shift;
	
	my $juan;	# 卷數
	my $name;	# 經名
	my $author;	# 作譯者
	my $normal_juan = 1;	# 判斷是否是正常的連結卷
	my @lbs;	# 各卷的 頁欄行 資訊
	
	print STDERR "$file\n";
	open IN, $file or die "open $file error. $!";
	
	$juan = 0;
	while (<IN>)
	{
		#CR        L1651-157-p0815       V1.0   2010/10/08    1  五百羅漢尊號                     【明 高道素手錄】
		if (/([TXJHWIABCFGKLMNPQSU])(\S{5})(\d+)[\-_].*?\s+.*?\s+.*?\s+(\d+?)\s+(\S*?)\s+【(.*)】/)
		{
			if($book ne $1)	{ print OUT "error $book ne $1"; }
			my $number = $2;
			if($volnum != $3) { print OUT "error $volnum ne $3"; }
			
			$juan = $4;
			$name = $5;
			$author = $6;
			
			$number =~ s/[\-\_]$//;

			if ($name =~ /\)$/)
			{
			#	$name = cut_note($name);	#去除尾部的括號
			}
			
			my $id = $vol . "n" . $number;
			
			if(($juan{$id} ne $juan) || ($name{$id} ne $name) || ($author{$id} ne $author))
			{
				print OUT "$id" . "," . $juan{$id} . "," . $name{$id} . "," . $author{$id} . "\n";
				print OUT "$id" . "," . $juan . "," . $name . "," . $author . "\n";
				print OUT "===================================================================\n";
			}
			
			$ok{$id} = 1;
			
		}
	}
}

##################################################################
# 讀入 catalog
##################################################################

sub read_catalog
{
	open IN, "../catalog.txt";
	while(<IN>)
	{
		#A091n1066,A,091,1066,2,1,新譯大方廣佛華嚴經音義,唐 慧菀述
		chomp;
		
		# 先換成組字式
		while(/&CB(\d{5});/)
		{
			my $cb = $1;
			my $des = $gj_cb2des{$cb};
			s/&CB${cb};/$des/g;
		}
		
		my @d = split(/,/,$_);
		my $id = $d[0];
		$juan{$id} = $d[4];
		$name{$id} = $d[6];
		$author{$id} = $d[7];
	}
}

##################################################################
# 讀入 gaiji
##################################################################

sub readGaiji 
{
	my $cb,$des,$ent,$mojikyo,$nor;
	#print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		
		$cb      = $row{"cb"};		# cbeta code
		$des     = $row{"des"};		# 組字式
		$nor     = $row{"nor"};		# 通用字

		if($cb =~ /^x/)		# 通用詞
		{
			push (@key, $des);
			#push (@table2, $nor);
			$table2{$des} = $nor;
			next;
		}

		next if ($cb !~ /^\d/);
		$gj_cb2des{$cb} = $des;
		
		next if ($nor eq "");

		$table{$des} = $nor;
	}
	$db->Close();
	#print STDERR "ok\n";
}

#############################################################
# 去除字串尾部的括號
# 例 xxxx(yy) -> xxxx
# 小心 xxxx(yy[(zz)]) -> xxxx
#############################################################

sub cut_note()
{
	local $_ = $_[0];
	
	while (/\)$/)
	{
		while(not /\([^\)]*?\)$/)
		{
			s/\(([^\(]*?)\)/#1#$1#2#/g;
		}
	
		if (/\([^\)]*\)$/)
		{
			s/\([^\(]*\)$//;
		
		}
	
		s/#1#/\(/g;
		s/#2#/\)/g;
	}
	return $_;
}

##################################################################
# The END
##################################################################