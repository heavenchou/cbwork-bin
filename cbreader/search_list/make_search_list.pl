# 這是要做出 bulei_sutra_sch.lst 及 sutra_sch.lst , 這二個要放在 CBReader 主目錄, 
# 主要是全文檢索單經選擇的列表.

# 作法:
# 先讀取 ../TaishoMenu_u8.txt 及 ../XuzangjingMenu_u8.txt
# 1. 一邊記錄各經的資料 $sutra{"Txxxx"} , 一邊依格式做出 sutra_sch.lst
# 2. 再讀取 ../bulei/bulei1_orig.txt , 依此格式再配合 $sutra{"Txxnxxxx"} 資料, 做出 bulei_sutra_sch.lst

use utf8;
use Encode;

require "../../common/cbeta_sub.pl";

open OUT , ">:utf8" , "sutra_sch.lst";

make_vol("TaishoMenu_u8.txt",3);	# "T", "大正藏", 最後一個參數是有幾層, 若有部別, 則有 3 層, 沒部的就二層
make_vol("XuzangjingMenu_u8.txt",3); #"X", "新纂卍續藏", 
make_vol("OthersMenu_u8.txt",2); #"", "補輯", 
make_vol("GuoTuMenu_u8.txt",2); #"D", "國圖善本佛典", 
make_vol("NanChuanMenu_u8.txt",3); #"N", "南傳大藏經", 
make_vol("ModernMenu_u8.txt",2); #"", "新編", 

#make_vol("SeelandMenu_u8.txt",2); #"ZY, DA", "西蓮", 


close OUT;

open OUT , ">:utf8", "bulei_sutra_sch.lst";
make_bulei();
close OUT;
print "\nOK, any key exit\n";
<>;

sub make_vol
{
	my $source = shift;
	my $level = shift;
	my $space_bu, $space_vol, $space_sutra;
	
	# 有部別
	if($level == 3)
	{
		$space_bu = "\t";
		$space_vol = "\t\t";
		$space_sutra = "\t\t\t";
	}
	elsif($level == 2)
	{
		# 只有二層, 沒有部
		$space_bu = "";
		$space_vol = "\t";
		$space_sutra = "\t\t";
	}
	
	#print OUT "$bookname\n";
	
	my $book = "";
	my $bookname = "";
	my $bu = "";
	my $vol = "";
	
	open IN, "<:utf8", "$source" or die "open $source error. $!";
	<IN>;	# 第一行是數量, 不要理他
	
	while(<IN>)
	{
		chomp;
		# 01,阿含部,0001 , 22,長阿含經 ,【後秦 佛陀耶舍共竺佛念譯】
		# 01,印度撰述 ,0001, 1  ,圓覺經佚文 ,【】
		# T,01,阿含部,0001 , 22,長阿含經 ,【後秦 佛陀耶舍共竺佛念譯】
		# X,01,印度撰述 ,0001, 1  ,圓覺經佚文 ,【】
		@data = split(/\s*,\s*/);
		$samebook = 1;
		$samebu = 1;
		if($data[0] ne $book)
		{
			$samebook = 0;	# 書有更新, 全部要更新
			$book = $data[0];
			$bookname = get_book_short_name_by_TX($book);	# cbetasub.pl
			print OUT "$bookname\n";
		}		
		if(($data[2] ne $bu) or ($samebook == 0))	# 換部, 或是換書
		{
			$samebu = 0;	# 部有更新, 冊一定要更新
			$bu = $data[2];
			print OUT "$space_bu$bu\n" if($bu ne "");
		}
		if(($data[1] ne $vol) or ($samebu == 0))
		{
			$vol = $data[1];
			print OUT "$space_vol${book}${vol}\n";
		}
		# 記錄下來
		$sutra = $book . $data[3];
		$data = $data[5] . " (" . $data[4] . "卷)" . $data[6];
		
		$vol{$sutra} = $book . $data[1];
		$sutra{$sutra} = $data;

		print OUT "$space_sutra${book}" . $data[1] . "n" . $data[3] . " " . $data . "\n";
	}
	close IN;
}

sub make_bulei
{
	open IN, "<:utf8", "../bulei/buleiBL_orig.txt";

	while(<IN>)
	{	
		$j = 0;
		$k = 0;
		chomp;
		
		$k=1 if(/^\s+[TXJHWIABCDFGKLMNPQSU][AB]?\d{3,4}[a-z]?\s/i);

		/^(\s*)(\S+)(.*)/;
		$space = $1;
		$sutra = $2;
		$tail = $3;
		
		if($vol{$sutra} && $sutra{$sutra})	# 表示這是單經, 不是樹狀的上層
		{
			#print OUT $space . $sutra . "" . $tail . "\n";
			$tmp = substr($sutra,1);
			print OUT $space . $vol{$sutra} . "n" . $tmp . " " . $sutra{$sutra} . "\n";
			$j=1;
		}
		else
		{
			print OUT "$_\n";
		}
		if($j != $k)
		{
			print Encode::encode("big5", "$j : $k : $_\n");	# $j=1 表示此經有相關資料, $k=1 表示 bulei1_orig.txt 格式是 [TX]xxxx[a-z] 這類, 二者應同步
		}
	}
	close IN;
}



