#############################################
# 比對 BM 產生 TXT VS P5 產生的 TXT
# perl comp_normal.pl			# 處理全部
# perl comp_normal.pl T			# 處理大正藏
# perl comp_normal.pl T01		# 處理大正藏 T01
#############################################

use utf8;
use strict;
use File::Find;

# 來源目錄, 也就是 cbreader 產生的 html 檔目錄
my $bm_path = "d:/temp/bm/normal/";
my $p5_path = "d:/temp/p5xml-p5noru8/";

my $vol = shift;	# T01
my $ed = $vol;
$ed =~ s/\d//g;	# T

my $path;

if($vol eq "")
{
	$path = $bm_path;
}
elsif($vol eq $ed )
{
	$path = $bm_path . $ed . "/";					# /T/
}
else
{
	$path = $bm_path . $ed . "/" . $vol . "/";		# /T/T01
}

my @output = ();
my $runningpath = "";
find(\&findfile, $path);	# 處理所有檔案
if($vol)
{
	open OUT, ">:utf8", "comp_result_${vol}.txt";
}
else
{
	open OUT, ">:utf8", "comp_result.txt";
}

move_skip();	# 移除可忽略的

for my $line (@output) {
	print OUT $line;
}
close OUT;

##########################

sub findfile
{
	local $_;
	my $thispath = $File::Find::dir;
	my $bm_file = $File::Find::name;
	my $p5_file = $bm_file;
	$p5_file =~ s#$bm_path#$p5_path#;

	if($runningpath ne $thispath)
	{
		$runningpath = $thispath;
		print $runningpath . "\n";
	}
	comp_file($bm_file, $p5_file);
}

# 比較二個檔案
sub comp_file
{
	local $_;
	my $bm_file = shift;
	my $p5_file = shift;

	my @bm_lines;
	my @p5_lines;
	getfile($bm_file, \@bm_lines);
	getfile($p5_file, \@p5_lines);

	if($#bm_lines != $#p5_lines)
	{
		push(@output , "檔案長度不同 : $bm_file vs $p5_file\n\n");
	}

	my $count = $#bm_lines;
	if($count > $#p5_lines) {$count = $#p5_lines;}
	for(my $i=0; $i<=$count; $i++)
	{
		if($bm_lines[$i] ne $p5_lines[$i])
		{
			my $a = $bm_lines[$i];
			my $b = $p5_lines[$i];
			
			if($a =~ /◇◇/)
			{
				$a =~ s/◇◇+/【◇】/g;
				if($a ne $b)
				{
					#$a = rm_punc($a);	# 移除標點
					#$b = rm_punc($b);
					if($a ne $b)
					{
						push(@output , $bm_lines[$i] . "\n" . $p5_lines[$i] . "\n\n");
					}
				}
			}
			else
			{
				#$a = rm_punc($a);	# 移除標點
				#$b = rm_punc($b);

				# TX 有二種狀況，一種是外框要先移除
				# 一種是 BM 的修訂有修訂前和修訂後，二者要分別試試 => 【剌,刺】

				if($ed eq "TX") {
					my $a1 = $a;
					my $a2 = $a;
					$a1 =~ s/【([^】]*?),([^】]*?)】/$1/g;
					$a2 =~ s/【([^】]*?),([^】]*?)】/$2/g;
					# $a1 =~ s/【([^】]*?)】/$1/g;
					# $a2 =~ s/【([^】]*?)】/$2/g;
					# $a1 =~ s/《([^》]*?)》/$1/g;
					# $a2 =~ s/《([^》]*?)》/$2/g;

					if($b ne $a1 && $b ne $a2)
					{
						push(@output , $bm_lines[$i] . "\n" . $p5_lines[$i] . "\n\n");
					}
				}
				elsif($a ne $b)
				{
					push(@output , $bm_lines[$i] . "\n" . $p5_lines[$i] . "\n\n");
				}
			}
		}
	}
}

# 檔案讀入陣列
sub getfile
{
	local $_;
	my $file = shift;
	my $lines = shift;

	open IN, "<:utf8", $file;
	while(<IN>)
	{
		chomp;
		next if($_ eq "");	# 忽略空白行
		next if($_ !~ /^[A-Z]/);	# 忽略卷首
		s/　//g;	# 忽略全型空白
		s/\[A\d+\]//g;	# 忽略自訂校勘
		s/\[(\d+)-\d+\]/[$1]/g;	# [01-1] 轉成 [01] 以方便比對

		if(/^(.*?║)(.*)/)
		{
			my $head = $1;
			$_ = $2;
			# 移除 bm 悉曇
			s/【◇】//g;
			s/[◇□]//g;
			# 移除 p5 梵巴
			s/[ÄÇÉÑÔÖÜàáâãäçèéêëíñóôöúûüĀāĊċčĒēĕęĪīŌōŚśŠŨũŪūŭŽǴȦȧḄḌḍḤḥḳḶḷṀṁṃṄṅṆṇṚṛṠṢṣṬṭẖạụṝḹ]//g;
			s/&SD\-[A-F0-9]{4};//g;	# 悉曇
			s/&RJ\-[A-F0-9]{4};//g;	# 悉曇
			s/[a-z]//gi;
			$_ = $head . $_;
		}

		# bm 的 【標01】轉成 [標01]
		s/【([科標解]\d\d)】/[$1]/g;
		
		# p5 轉 TXT 有些悉曇字要換成文字才方便比對
		#s/&SD\-D953;/掱/g;
		#s/&SD\-E35A;/劄/g;
		#s/&SD\-E35B;/箙/g;
		#s/&SD\-D7C4;/袎/g;
		#s/&SD\-D5B4;/桭/g;
		#s/&SD\-E347;/稯/g;
		#s/&SD\-D957;/揨/g;
		#s/&SD\-E2BD;/熀/g;
		#s/&SD\-D9C6;/棐/g;
		#s/&SD\-D5B5;/桮/g;
		#s/&SD\-E152;/嘝/g;
		#s/&SD\-E14D;/嘜/g;
		#s/&SD\-D950;/愋/g;
		#s/&SD\-E167;/墔/g;
		#s/&SD\-E0F9;/僓/g;
		#s/&SD\-E275;/漉/g;
		#s/&SD\-E341;/禈/g;
		#s/&SD\-CFC3;/狪/g;
		#s/&SD\-D9D9;/棇/g;
		#s/&SD\-E378;/綡/g;
		#s/&SD\-D959;/揃/g;
		#s/&SD\-E355;/箌/g;
		#s/&SD\-E377;/綩/g;
		#s/&SD\-D95B;/揳/g;
		#s/&SD\-CFC2;/狟/g;
		#s/&SD\-E3BA;/蒪/g;
		#s/&SD\-E36C;/緄/g;
		#s/&SD\-E3BE;/蒝/g;
		#s/&SD\-E36D;/緆/g;
		#s/&SD\-D7FE;/釪/g;
		#s/&SD\-E37D;/翥/g;
		#s/&SD\-E3C0;/蒻/g;
		#s/&SD\-E459;/跿/g;
		#s/&SD\-E3E6;/蜪/g;
		#s/&SD\-E3F0;/蜸/g;
		#s/&SD\-E463;/踄/g;
		#s/&SD\-E4C6;/鞄/g;
		#s/&SD\-E4CB;/頖/g;
		#s/&SD\-E4D0;/餇/g;
		#s/&SD\-E4E3;/鳲/g;
		#s/&SD\-E4E5;/麧/g;
		#s/&SD\-E4EB;/儇/g;
		#s/&SD\-E4EF;/儌/g;
		#s/&SD\-E4F0;/僽/g;
		#s/&SD\-E470;/鄡/g;
		#s/&SD\-E46E;/鄚/g;
		#s/&RJ\-E041;/觠/g;
		#s/&RJ\-E042;/觢/g;
		#s/&RJ\-E044;/触/g;
		#s/&SD\-E4A1;/銦/g;

		push(@$lines, $_);
	}
	close IN;
}

# 移除標點
sub rm_punc
{
	local $_ = shift;
	s/[．、，：；。？！—…「」『』〈〉《》“”（）【】〔〕\(\)]//g;
	return $_;
}

# 移除可忽略的
sub move_skip
{
	for (my $i=0; $i<=$#output; $i++) {

		if($output[$i] =~ /^T18n/) { 
			# T18n0850_p0087b23║（一九）[03]
			# T18n0850_p0087b23║（一九）[03]…
			
			if($output[$i] =~ /^(.*?║（[一二三四五六七八九〇]+）(?:\[\d+\])?)\n\1…\n\n$/) {
				$output[$i] = "";
			}
			# T18n0850_p0089b05║（一二二）
			# T18n0850_p0089b05║（一二二）（）
			if($output[$i] =~ /^(.*?║（[一二三四五六七八九〇]+）)\n\1（）\n\n$/) {
				$output[$i] = "";
			}
			# T18n0877_p0331b22║涅哩荼(堅牢)[20]跋折羅底瑟吒(一切如來正等菩提金剛堅牢安住我心)
			# T18n0877_p0331b22║涅哩荼(堅牢)[20]跋折羅底瑟吒(一切如來正等菩提金剛堅牢安住我心)」
			# T18n0877_p0331b23║」
			# T18n0877_p0331b23║
			if($output[$i] =~ /^(.*?║.*?)\n\1」\n\n$/) {
				# if(($i < $#output) && ($output[$i+1] =~ /^(.*?║)」\n\1\n\n$/)) {
				# 	$output[$i] = "";
				# 	$output[$i+1] = "";
				# }
				
				# T18n0914_p0937b25║」[27]
				# T18n0914_p0937b25║[27]
				if(($i < $#output) && ($output[$i+1] =~ /^(.*?║)」((?:\[\d+\])?)\n\1\2\n\n$/)) {
					$output[$i] = "";
					$output[$i+1] = "";
				}
			}
		}

		# X23n0446_p0778a20║
		# X23n0446_p0778a20║?
		if($output[$i] eq "X23n0446_p0778a20║\nX23n0446_p0778a20║?\n\n") {
			$output[$i] = "";
		}

	}
}	