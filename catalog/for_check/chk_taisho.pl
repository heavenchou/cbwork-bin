##################################################################
# 檢查現有的 tripitaka.txt 是否和 BM 版內容相同
##################################################################

use File::Copy;
use Win32::ODBC;

require "c:/cbwork/work/bin/b52utf8.plx";

##################################################################
# 常數
##################################################################


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
read_catalog();	# 讀入 catalog

open OUT, ">chk_taisho.txt" or die "open chk_taisho.txt error";


do1file("../taisho.txt");

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
		chomp;
		next if /^#/;
		
		#  阿含部類                        阿含部上      T0001-01-p0001 K0647-17  22  長阿含經(22卷)     【後秦 佛陀耶舍共竺佛念譯】
		
		if(/\s+(.*?)\s+(.*?)\s+T(.{5})(\d\d)\-.*\s+(.*?)\s+(\d+?)\s+(.*?)\s+(.*)/)
		{
			$book = "T";
			$number = $3;
			$vol = $4;
			$juan = $6;
			$name = $7;
			$author = $8;
			
			$number =~ s/\-//;
			#$name =~ s/\(${juan}卷\)//;
			$author =~ s/【(.*)】/$1/;
			#$name =~ s/\(.*?\)$//;
	
			my $id = $book . $vol . "n" . $number;
			
			if(($juan{$id} ne $juan) || ($name{$id} ne $name) || ($author{$id} ne $author))
			{
				print OUT "$id" . "," . $juan{$id} . "," . $name{$id} . "," . $author{$id} . "\n";
				print OUT "$id" . "," . $juan . "," . $name . "," . $author . "\n";
				print OUT "===================================================================\n";
			}
			
			$ok{$id} = 1;
		}
		else
		{
			print OUT "format error : $_\n";
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
			$word = $gj_cb2des{$cb};
			s/&CB${cb};/$word/g;
		}
		
		my @d = split(/,/,$_);
		next if $d[1] ne "T";	# 只要大正藏
		
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
		$flag    = $row{"uni_flag"};
		$uni     = $row{"uni"};

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

		$gj_cb2nor{$cb} = $nor;
		$gj_des2nor{$des} = $nor;
	}
	$db->Close();
	#print STDERR "ok\n";
}

##################################################################
# The END
##################################################################