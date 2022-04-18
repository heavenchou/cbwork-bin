#############################################
# 比對 CBReader 2X 產生的 TXT VS P5 產生的 TXT
# perl comp_cbr_txt.pl			# 處理全部
# perl comp_cbr_txt.pl T		# 處理大正藏
# perl comp_cbr_txt.pl T01		# 處理大正藏 T01
#############################################

use utf8;
use strict;
use File::Find;

# 來源目錄, 也就是 cbreader 產生的 html 檔目錄
my $cbr_path = "d:/temp/cbr_out_txt/";
my $txt_path = "d:/temp/p5xml-p5noru8/";

my $vol = shift;	# T01
my $ed = $vol;
$ed =~ s/\d//g;	# T

my $path;

if($vol eq "")
{
	$path = $cbr_path;
}
elsif($vol eq $ed )
{
	$path = $cbr_path . $ed . "/";					# /T/
}
else
{
	$path = $cbr_path . $ed . "/" . $vol . "/";		# /T/T01
}

my $output = "";
my $runningpath = "";
find(\&findfile, $path);	# 處理所有檔案
if($vol)
{
	open OUT, ">:utf8", "__comp_result_${vol}.txt";
}
else
{
	open OUT, ">:utf8", "__comp_result.txt";	
}
print OUT $output;
close OUT;

##########################

sub findfile
{
	local $_;
	my $thispath = $File::Find::dir;
	my $cbr_file = $File::Find::name;
	my $txt_file = $cbr_file;
	$txt_file =~ s#$cbr_path#$txt_path#;

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
		$output .= "檔案長度不同 : $cbr_file vs $txt_file\n\n";
	}

	my $count = $#cbr_lines;
	if($count > $#txt_lines) {$count = $#txt_lines;}
	for(my $i=0; $i<=$count; $i++)
	{
		if($cbr_lines[$i] ne $txt_lines[$i])
		{
			my $a = $cbr_lines[$i];
			my $b = $txt_lines[$i];
			
			if($a =~ /◇◇/)
			{
				$a =~ s/◇◇+/【◇】/g;
				if($a ne $b)
				{
					$output .= $cbr_lines[$i] . "\n" . $txt_lines[$i] . "\n\n";
				}
			}
			else
			{
				$output .= $cbr_lines[$i] . "\n" . $txt_lines[$i] . "\n\n";
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
		s/　//g;	# 忽略全型空白
		if($vol =~ /^Y/ || $vol =~ /^TX/ ) {
			# Y, TX 沒有修訂
			s/\[A\d+\]//g;	# 忽略自訂校勘
		} else {
			s/\[A\d+\]/[A]/g;	# 忽略自訂校勘
		}
		
		s/\[(\d+)-\d+\]/[$1]/g;	# [01-1] 轉成 [01] 以方便比對

		# p5 轉 TXT 有些悉曇字要換成文字才方便比對
		s/&SD\-D953;/掱/g;
		s/&SD\-E35A;/劄/g;
		s/&SD\-E35B;/箙/g;
		s/&SD\-D7C4;/袎/g;
		s/&SD\-D5B4;/桭/g;
		s/&SD\-E347;/稯/g;
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
		s/&SD\-E3BA;/蒪/g;
		s/&SD\-E36C;/緄/g;
		s/&SD\-E3BE;/蒝/g;
		s/&SD\-E36D;/緆/g;
		s/&SD\-D7FE;/釪/g;
		s/&SD\-E37D;/翥/g;
		s/&SD\-E3C0;/蒻/g;
		s/&SD\-E459;/跿/g;
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

		push(@$lines, $_);
	}
	close IN;
}