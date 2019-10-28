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

open OUT, ">chk_epub_tripitaka.txt" or die "open chk_menu.txt error";


do1file("epub_tripitaka.txt");

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
		#T,01,阿含部,0001 , 22,長阿含經                                 ,【後秦 佛陀耶舍共竺佛念譯】
		($book, $vol, $part, $number, $juan, $name, $author) = split(/\s*,\s*/,$_);
		$author =~ s/【(.*)】/$1/;
	
	
			my $id = $book . $vol . "n" . $number;
			
			if(($juan{$id} ne $juan) || ($name{$id} ne $name) || ($author{$id} ne $author))
			{
				print OUT "$id" . "," . $juan{$id} . "," . $name{$id} . "," . $author{$id} . "\n";
				print OUT "$id" . "," . $juan . "," . $name . "," . $author . "\n";
				print OUT "===================================================================\n";
			}
			
			$ok{$id} = 1;
	}
}

##################################################################
# 讀入 catalog
##################################################################

sub read_catalog
{
	open IN, "../catalog_u8.txt";
	while(<IN>)
	{
		#A091n1066,A,091,1066,2,1,新譯大方廣佛華嚴經音義,唐 慧菀述
		chomp;
		
		# 先換成組字式
		while(/&CB(\d{5});/)
		{
			my $cb = $1;
			if($gj_cb2uni{$cb})
			{
				$word = $gj_cb2uni{$cb};
				#$word =~ s/呪/咒/g;
				#$word =~ s/鉢/缽/g;
			}
			elsif($gj_cb2nor{$cb})
			{
				$word = $gj_cb2nor{$cb};
			}
			else
			{
				$word = $gj_cb2des{$cb};
			}
			s/&CB${cb};/$word/g;
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
		
		$gj_cb2des{$cb} = b52utf8($des);
		if(length($uni) == 4)
		{
			my $u16 = pack("H4",$uni);
			my $u8 = utf1632toutf8($u16);
			$gj_cb2uni{$cb} = $u8;
		}
		
		next if ($nor eq "");

		$gj_cb2nor{$cb} = b52utf8($nor);
		$gj_des2nor{$des} = $nor;
	}
	$db->Close();
	#print STDERR "ok\n";
}


sub b52utf8 {
	my $in = shift;
	my $big5 = "[\x00-\x7f]|[\x80-\xff][\x00-\xff]";
	my @a;
	my $temp='';
	push(@a, $in =~ /$big5/gs);
	my $s='', $c;
	foreach $c (@a) { 
		if ($b52utf8{$c} ne "") { 
			$temp .= $c;
			$c =  $b52utf8{$c}; 
		} else { 
			print STDERR "83 $in\n";
			print STDERR "84 $temp\n";
			die "subutf8.pl 85 Error: not in big52utf8 table. char:[$c] hex:" . unpack("H4",$c) ; 
		}
		$s.=$c; 
	}
	return $s;
}


sub utf1632toutf8
{
	my $in = $_[0];
	my $old;
	# encode UTF-8
	my $uc;
	if(length($in)<=2)
	{
		$patten = "n*";
	}
	else
	{
		$patten = "N*";
	}
	for $uc (unpack($patten, $in)) {
#        print "$uc\n";
	    if ($uc < 0x80) {
		# 1 byte representation
		$old .= chr($uc);
	    } elsif ($uc < 0x800) {
		# 2 byte representation
		$old .= chr(0xC0 | ($uc >> 6)) .
	                chr(0x80 | ($uc & 0x3F));
	    } elsif ($uc < 0xFFFF) {
		# 3 byte representation
		$old .= chr(0xE0 | ($uc >> 12)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			chr(0x80 | ($uc & 0x3F));
	    } else {
		# 4 byte representation
		$old .= chr(0xF0 | ($uc >> 18)) .
                chr(0x80 | (($uc >> 12) & 0x3F)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			    chr(0x80 | ($uc & 0x3F));
	    }
	}
	return $old;
}

##################################################################
# The END
##################################################################