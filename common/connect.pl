######################################################################################
# 程式說明：將指定目錄中的檔案合成一個大檔                        by heaven 2013/06/12
# 使用方法：
#       perl connect.pl -s 來源目錄及檔案種類 -o 輸出結果的檔案 [-c -v -d]
# 參數說明：
#       -s 來源目錄，要包含檔案的種類模式，例如 -s c:\temp\*.txt
#       -o 結果檔案，例如 -o c:\out.txt
#       -c 切除行首，如果行首是 T01n0001_a01║ 這種型格，皆一律移除
#       -v 檔案前十行若有 V1.0 這種版本格式，一律換成 Vv.v，以方便比對
#       -d 檔案前十行若有 2013/06/11 這種日期格式，一律換成 yyyy/mm/dd，以方便比對
# 範例：
#       perl connect.pl -s c:\release\bm\normal\T01\*.txt -o c:\temp\T01.txt -c -v -d
######################################################################################

#use utf8;	# 不要使用 utf8 來處理, 至少中文訊息方便呈現
use Encode;
use strict;
use autodie;
use Getopt::Std;
use vars qw($opt_s $opt_o $opt_c $opt_v $opt_d);		# 如果有使用 use strict; , 本行就要加上去

############################################################
# 變數
############################################################

my $code = "";	# 判斷編碼是 utf8 或 big5
my $endline = encode("utf8",decode("big5", "║"));	# ║符號的 utf8 編碼

############################################################
# 檢查參數
############################################################

getopts('s:o:cvd');

print "【檔案合併程式】\n";

if($opt_s eq "")
{
	print "錯誤：沒有使用 -s 參數\n";
	exit;
}
if($opt_o eq "")
{
	print "錯誤：沒有使用 -o 參數\n";
	exit;
}

print "來源位置 : $opt_s\n";
print "輸出檔案 : $opt_o\n";

############################################################
# 主程式
############################################################

my @file = <${opt_s}>;
open OUT, ">$opt_o";
foreach my $filename (sort (@file))
{
	print STDERR "處理中 ... => $filename\n";
	open IN, "$filename";
	my $linenum = 0;
	while (<IN>)
	{
		$linenum++;
		chomp ;
		if($code eq "")		# 還沒判斷編碼
		{
			$code = check_encoding($_);
		}
		
		# 是否要切掉行首
		if($opt_c) 
		{
			$_ = cut_head($_);
		}
		
		if($linenum <= 10)
		{
			# 處理版本記錄的日期與版本
			#【版本記錄】CBETA 電子佛典 V1.0 (Big5) 普及版，完成日期：2003/08/29
			#【版本記錄】CBETA 電子佛典 Vv.v (Big5) 普及版，完成日期：yyyy/mm/dd
			# CBETA Chinese Electronic Tripitaka V1.0 (Big5) Normalized Version, Release Date: 2003/08/29
			# CBETA Chinese Electronic Tripitaka Vv.v (Big5) Normalized Version, Release Date: yyyy/mm/dd
			
			# 是否修改版本格式
			if($opt_v)
			{
				s/V\d+\.\d+/Vv.v/g;
			}
			# 是否修改日期格式
			if($opt_d)
			{
				s/\d{4}\/\d+\/\d+/yyyy\/mm\/dd/g;
			}
		}
		
		print OUT "$_\n";
	}
	close IN;
}
close OUT;

print "處理完畢.\n\n";
############################################################
# 判斷編碼
############################################################

sub check_encoding
{
	local $_ = shift;
	return "" if($_ !~ /[\x81-\xFD]/);	# 判斷不出 big5 或 utf8
	
	my $tmp = encode("big5",decode("big5",$_));
	return "big5" if($tmp eq $_);
		
	$tmp = encode("utf8",decode("utf8",$_));
	return "utf8" if($tmp eq $_);
	
	return "";	# 判斷不出 big5 或 utf8
}

############################################################
# 切掉行首
############################################################

sub cut_head
{
	local $_ = shift;
	
	if($code eq "big5")
	{
		s/^\D*\d\dn.{5}p\d{4}.\d\d.*?║//;
	}
	
	if($code eq "utf8")
	{
		s/^\D*\d\dn.{5}p\d{4}.\d\d.*?${endline}//;
	}
	
	return $_;
}

############################################################
# End
############################################################