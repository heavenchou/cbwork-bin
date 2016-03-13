########################################################
#
# 移動 </p> 的程式  by heaven                2006/12/18
#
# 使用方法：
# mv_p.pl 舊的xml.xml 結果檔xml.xml
# 或直接在程式寫入參數, 直接執行
# mv_p.pl
#
# 這是在 pushsign.pl 之後的協助檢查程式
#
# 如果有 <lb ....></p> 這種格式, 則 </p> 移到前一行行尾
# 若前一行是 <pb> 則 </p> 移到前二行行尾, 當然那行應該是<lb> 開頭的
#
########################################################

use strict;
use utf8;

########################################################
# 主參數
########################################################

#my $infile = "out.txt";		# 輸入檔, 若是改成 shift, 則是傳入的參數
#my $outfile = "otuout.txt";	# 輸出檔, 若是改成 shift, 則是傳入的參數
my $infile = shift;		# 輸入檔, 若是改成 shift, 則是傳入的參數
my $outfile = shift;	# 輸出檔, 若是改成 shift, 則是傳入的參數
########################################################

local *IN;
local *OUT;

open IN, "<:utf8",  "$infile" or die "open $infile error$!";
open OUT, ">:utf8", "$outfile" or die "open $outfile error$!";
my @lines = <IN>;
close IN;

my $i;
for($i=0; $i<=$#lines; $i++)
{
	if($lines[$i] =~ /^<lb[^>]*?><\/p>/)
	{
		$lines[$i] =~ s/^(<lb[^>]*?>)<\/p>/$1/;
		if($lines[$i-1] =~ /^<lb/)
		{
			$lines[$i-1] =~ s/^(.*)\n/$1<\/p>\n/;
		}
		elsif($lines[$i-1] =~ /^<pb/ and $lines[$i-2] =~ /^<lb/)
		{
			$lines[$i-2] =~ s/^(.*)\n/$1<\/p>\n/;
		}
		else
		{
			$lines[$i-1] =~ s/^(.*)\n/$1<?><\/p>\n/;
		}
	}
}
for($i=0; $i<=$#lines; $i++)
{
	print OUT $lines[$i];
}
close OUT;

	