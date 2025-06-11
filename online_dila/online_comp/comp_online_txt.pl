#############################################
# 比對 CBETa Online 產生的 TXT VS P5 產生的 TXT
# perl comp_online_txt.pl			# 處理全部
# perl comp_online_txt.pl T			# 處理大正藏
# perl comp_online_txt.pl T01		# 處理大正藏 T01
#############################################

use utf8;
use strict;
use File::Find;
use lib "/cbwork/bin";
use CBETA;
my $gaiji = new Gaiji();
$gaiji->load_access_db();

# 來源目錄, 也就是 cbreader 產生的 html 檔目錄
my $cbr_path = "d:/temp/online_out_txt/";
my $txt_path = "d:/temp/p5xml-p5noru8/";

my $vol = shift;	# T01
my $ed = $vol;
$ed =~ s/\d//g;	# T

my $path;

if($vol eq "")
{
	$path = $txt_path;
}
elsif($vol eq $ed )
{
	$path = $txt_path . $ed . "/";					# /T/
}
else
{
	$path = $txt_path . $ed . "/" . $vol . "/";		# /T/T01
}

my $output = "";
my $runningpath = "";
find(\&findfile, $path);	# 處理所有檔案
open OUT, ">:utf8", "__comp_result_$vol.txt";
print OUT $output;
close OUT;

##########################

sub findfile
{
	local $_;
	my $thispath = $File::Find::dir;
	my $txt_file = $File::Find::name;
	my $cbr_file = $txt_file;
	$cbr_file =~ s#$txt_path#$cbr_path#;

	if($runningpath ne $thispath)
	{
		$runningpath = $thispath;
		print $runningpath . "\n";
	}
	comp_file($cbr_file, $txt_file);
}

# 比較二個檔案
sub comp_file
{
	local $_;
	my $cbr_file = shift;
	my $txt_file = shift;

	my @cbr_lines;
	my @txt_lines;
	getfile($cbr_file, \@cbr_lines);
	getfile($txt_file, \@txt_lines);

	if($#cbr_lines != $#txt_lines)
	{
		$output .= "檔案長度不同 : $cbr_file ($#cbr_lines) vs $txt_file ($#txt_lines) \n\n";
	}

	my $count = $#cbr_lines;
	if($count > $#txt_lines) {$count = $#txt_lines;}
	for(my $i=0; $i<=$count; $i++)
	{
		if($cbr_lines[$i] ne $txt_lines[$i])
		{
			my $a = $cbr_lines[$i];
			my $b = $txt_lines[$i];

			#$a =~ s/㲉 /㲉/g;
			
			# 把組字式換成 unicode
			if($b =~ /\[/)
			{
				$b =~ s/(\[.*?\])/des2uni($1)/ge;
			}
			if($a =~ /\[/)
			{
				$a =~ s/(\[.*?\])/des2uni($1)/ge;
			}
			next if($a eq $b);
			#next if($b =~ /\[解\d/);

			# 移除 ) 符號, 因為 HTML 版判斷雙行小註不精準

			$a =~ s/\)//g;
			$b =~ s/\)//g;
			#$a =~ s/\(//g;
			#$b =~ s/\(//g;
			next if($a eq $b);
			
			#$b =~ s/║（[一二三四五六七八九〇]+）/║/;
			if($ed eq "N")
			{
				#$b =~ s/║ \d+ /║/;	# 南傳移除 PTS 頁碼
				#$b =~ s/\[＊\]//g;	# 南傳移除星號
			}
			next if($a eq $b);

			if($a =~ /◇◇/ || $b =~ /◇◇/)
			{
				$a =~ s/◇◇+/【◇】/g;
				$b =~ s/◇◇+/【◇】/g;
			}
			next if($a eq $b);

			$output .= $cbr_lines[$i] . "\n" . $txt_lines[$i] . "\n";
			$output .= $a . "\n" . $b . "\n\n";
		}
	}
}

sub des2uni
{
	local $_ = shift;
	my $cb = $gaiji->des2cb($_);
	if($cb)
	{
		my $uniword = $gaiji->cb2uniword($cb);
		if($uniword)
		{
			# 不要超過 unicode 10.0
			my $ver = $gaiji->get_unicode_ver($gaiji->cb2uni($cb));
			#if($ver !~ /^1[1-9]/) {
			#	if($ver !~ /^[2-9][0-9]/) {
					return $uniword;
			#	}
			#}
			
		}
		my $noruniword = $gaiji->cb2noruniword($cb);
		if($noruniword)
		{
			# 不要超過 unicode 10.0
			my $ver = $gaiji->get_unicode_ver($gaiji->cb2noruni($cb));
			#if($ver !~ /^1[1-9]/) {
			#	if($ver !~ /^[2-9][0-9]/) {
					return $noruniword;
			#	}
			#}
		}
		my $norword = $gaiji->cb2nor($cb);
		if($norword)
		{
			return $norword;
		}
		if($uniword)
		{
			return $uniword;
		}
		if($noruniword)
		{
			return $noruniword;
		}
	}
	return $_;
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
		s/\[王\*　\]/⺩/g;	# 先處理有空白的組字
		s/　//g;	# 忽略全型空白

		#s/\[A\d+\]/[A]/g;	# 忽略自訂校勘
		if($vol =~ /^Y/ || $vol =~ /^TX/ ) {
			# Y, TX 沒有修訂
			s/\[A\d*\]//g;	# 忽略自訂校勘
		} else {
			s/\[A\d+\]/[A]/g;	# 忽略自訂校勘
		}

		s/\[(\d+)-\d+\]/[$1]/g;	# [01-1] 轉成 [01] 以方便比對

		# p5 轉 TXT 有些悉曇字要換成文字才方便比對
		s/&SD\-D953;/…/g;
		s/&SD\-E35A;/（/g;
		s/&SD\-E35B;/）/g;
		s/&SD\-D7C4;/袎/g;
		s/&SD\-D5B4;/桭/g;
		s/&SD\-E347;/□/g;
		s/&SD\-D957;/揨/g;
		s/&SD\-E2BD;/熀/g;
		s/&SD\-D9C6;/棐/g;
		s/&SD\-D5B5;/桮/g;
		s/&SD\-E152;/嘝/g;
		s/&SD\-E14D;/嘜/g;
		s/&SD\-D950;/愋/g;
		s/&SD\-E167;/墔/g;
		s/&SD\-E0F9;/僓/g;
		s/&SD\-E275;/漉/g;
		s/&SD\-E341;/禈/g;
		s/&SD\-CFC3;/狪/g;
		s/&SD\-D9D9;/棇/g;
		s/&SD\-E378;/綡/g;
		s/&SD\-D959;/揃/g;
		s/&SD\-E355;/箌/g;
		s/&SD\-E377;/綩/g;
		s/&SD\-D95B;/揳/g;
		s/&SD\-CFC2;/狟/g;
		s/&SD\-E3BA;/‧/g;
		s/&SD\-E36C;/〔/g;
		s/&SD\-E3BE;/蒝/g;
		s/&SD\-E36D;/〕/g;
		s/&SD\-D7FE;/釪/g;
		s/&SD\-E37D;/翥/g;
		s/&SD\-E3C0;/蒻/g;
		s/&SD\-E459;/？/g;
		s/&SD\-E3E6;/蜪/g;
		s/&SD\-E3F0;/蜸/g;
		s/&SD\-E463;/踄/g;
		s/&SD\-E4C6;/鞄/g;
		s/&SD\-E4CB;/頖/g;
		s/&SD\-E4D0;/餇/g;
		s/&SD\-E4E3;/鳲/g;
		s/&SD\-E4E5;/麧/g;
		s/&SD\-E4EB;/儇/g;
		s/&SD\-E4EF;/儌/g;
		s/&SD\-E4F0;/僽/g;
		s/&SD\-E470;/鄡/g;
		s/&SD\-E46E;/鄚/g;
		s/&RJ\-E041;/觠/g;
		s/&RJ\-E042;/觢/g;
		s/&RJ\-E044;/触/g;
		s/&SD\-E4A1;/銦/g;

		if($ed eq "N")
		{
			s/║ \d+ ?/║/;	# 移除 PTS 頁碼
		}

		#next if(/\D+.*?║$/);

		push(@$lines, $_);
	}
	close IN;
}