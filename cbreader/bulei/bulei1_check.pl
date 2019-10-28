# 檢查 bulei1_orig.txt 是否有重覆或缺少.
# 參考來源是 TaishoMenu_b5.txt 及 XuzangjingMenu_b5.txt , JiaXingZangMenu_b5.txt , ZhengShiMenu_b5.txt , ZangWaiMenu_b5.txt

#程式原理很簡單, 先讀入上述參考來源的 big5 版, 每讀一次, 各經記錄加 1 .
#再讀 bulie1_orig.txt , 每讀到一經的資料, 各經記錄加 10.
#所以若某一經記錄是 11 , 表示它是標準的.
#若只有 1, 表示此經沒有出現在 bule1_orig.txt 中.
#如果沒有 1 , 只有 10, 20 .... , 表示它只出現在 bule1_orig.txt
#如果大於 11 , 表示此經重覆了.

# 要修改的參數

my $bulei1 = "BuLei1_orig.txt";	# bulei4.txt 的位置
my $taisho = "../TaishoMenu_b5.txt";		# 要 big5 的格式
my $xuzangjing = "../XuzangjingMenu_b5.txt";		# 要 big5 的格式
my $jiaxingzang = "../JiaXingZangMenu_b5.txt";		# 要 big5 的格式
my $zhengshi = "../ZhengShiMenu_b5.txt";		# 要 big5 的格式
my $zangwai = "../ZangWaiMenu_b5.txt";		# 要 big5 的格式
my $baipin = "../BaiPinMenu_b5.txt";		# 要 big5 的格式
my $out = "bulei1_chk_out.txt"; # 輸出檔

# 主程式

my %jing;		# 以各經號為引數, 在 taisho 及 xuzangjing 出現的經文, 加 1 , 在 bulei4.txt 出現的 加 10
my %vol;		# 各經的冊數

###############################
# 讀入各藏目錄
###############################

#大正藏
open IN, $taisho or die "open $taisho error.$!";
while(<IN>)
{
	#54,諸宗著述部,0866 ,  2,肇論疏                                   ,【晉 惠達撰】
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"T$2"} = $jing{"T$2"} + 1;
		$vol{"T$2"} = "T$1";
	}
}
close IN;
#卍續藏
open IN, $xuzangjing or die "open $xuzangjing error.$!";
while(<IN>)
{
	#54,諸宗著述部,0866 ,  2,肇論疏                                   ,【晉 惠達撰】
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"X$2"} = $jing{"X$2"} + 1;
		$vol{"X$2"} = "X$1";
	}
}
close IN;
#嘉興藏
open IN, $jiaxingzang or die "open $jiaxingzang error.$!";
while(<IN>)
{
	#54,諸宗著述部,0866 ,  2,肇論疏                                   ,【晉 惠達撰】
	if(/^([AB]?\d+),.*?,(.*?)\s*,/)
	{
		$jing{"J$2"} = $jing{"J$2"} + 1;
		$vol{"J$2"} = "J$1";
	}
}
close IN;
# 正史
open IN, $zhengshi or die "open $zhengshi error.$!";
while(<IN>)
{
	#54,諸宗著述部,0866 ,  2,肇論疏                                   ,【晉 惠達撰】
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"H$2"} = $jing{"H$2"} + 1;
		$vol{"H$2"} = "H$1";
	}
}
close IN;
#藏外
open IN, $zangwai or die "open $zangwai error.$!";
while(<IN>)
{
	#54,諸宗著述部,0866 ,  2,肇論疏                                   ,【晉 惠達撰】
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"W$2"} = $jing{"W$2"} + 1;
		$vol{"W$2"} = "W$1";
	}
}
close IN;
#百品
open IN, $baipin or die "open $baipin error.$!";
while(<IN>)
{
	#54,諸宗著述部,0866 ,  2,肇論疏                                   ,【晉 惠達撰】
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"I$2"} = $jing{"I$2"} + 1;
		$vol{"I$2"} = "I$1";
	}
}
close IN;

####################
# 讀入部類
####################

open IN, $bulei1 or die "open $bulei1 error.$!";
while(<IN>)
{
	#54,諸宗著述部,0866 ,  2,肇論疏                                   ,【晉 惠達撰】
	if(/^\s*([TXJWHI][AB]?\d{3,4}[A-Za-z]?)\s/)
	{
		$jing{"$1"} = $jing{"$1"} + 10;
	}
	if(/^\s*(((ZW)|(ZS))\d{3,4}[A-Za-z]?)\s/)	# 正史與藏外有可能用 Hxxxx , Wxxxx 或 ZSxxxx , ZWxxxx (還沒統一)
	{
		# 不用 ZS, ZW , 只用 HW
		#$jing{"$1"} = $jing{"$1"} + 10;
	}
}
close IN;

open OUT, ">$out" or die "open $out error $!";

	print OUT "======= 不在 bulie4.txt ===========\n";
foreach $key (sort(keys(%jing)))
{
	print OUT "$vol{$key} , $key = $jing{$key}\n" if($jing{$key} < 10);
}
	print OUT "======= 不知何處來的經文? ===========\n";
foreach $key (sort(keys(%jing)))
{
	print OUT "$key = $jing{$key}\n" if($jing{$key} =~ /0$/);	# 個位數不是 1
}
	print OUT "======= 重覆出現.txt ===========\n";
foreach $key (sort(keys(%jing)))
{
	print OUT "$vol{$key} , $key = $jing{$key}\n" if($jing{$key}) > 11;
}

close OUT;