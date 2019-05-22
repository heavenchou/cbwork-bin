################################################################
#
# 處理修訂的差異  by heaven                2019/03/11
# 標點版內容為 : ABC，DE，FG
# BM  版內容為 : AB[XY>CD]EFG
# 標點版處理成 : AB[XY>C，D]E，FG
#
# 使用方法：
# modi_corr.pl 標點版.txt 原始的BM.txt 新的標點版.txt > 記錄檔.txt
#
################################################################
=Begin
新標(NS)邊際效應探討

NS : AB，CD，EFG
BM : ABCD<mj>EFG

NS : AB，CDEFG
BM : AB[XY>CD]EFG
OK : AB，[XY>CD]EFG
OK : AB[XY>，CD]EFG

NS : ABC，DEFG
BM : AB[XY>CD]EFG
OK : AB[XY>C，D]EFG

NS : ABCD，EFG
BM : AB[XY>CD]EFG
OK : AB[XY>CD]，EFG
OK : AB[XY>CD，]EFG

NS : AB，CDEFG
BM : AB[XY>]CDEFG
OK : AB，[XY>]CDEFG
OK : AB[XY>]，CDEFG
OK : AB[XY>，]CDEFG

NS : AB，CDEFG
BM : AB[>CD]EFG
OK : AB，[>CD]EFG
OK : AB[>，CD]EFG

NS : ABCD，EFG
BM : AB[>CD]EFG
OK : AB[>CD，]EFG
OK : AB[>CD]，EFG

=End
=cut

use utf8;
use strict;
use Encode;

my $debug = 0;

local *INTxt;
local *INBM;
local *OUT;

my $utf8='(?:.)';
my $loseutf8='(?:[^\[\]> \d])';

=begin
	為了避免組字式與模糊字 <□> 的干擾, 尤其是二者混用 [<□>>[羽*惠]]
	所以要用 unicode U+D0000 字面來取代
	U+D0000 = <□>
	其他組字式就陸續推入 @gaiji 陣列

	$word = get_word("[羽*惠]"); # 將組字式推入, 並傳回對應的 unicode
	$des = get_des($word);	# 傳入文字, 傳回原來的組字式
=end
=cut

my @des = ();	# 遇到組字式就放入
my %des_hash = ();	# 如果此字存在, 就有 $des_hash{"[xxx]"} = 3 , 表示此字為 U+D0003 

$des[0] = "<□>";
$des_hash{"<□>"} = 0;

########################################################
# 判斷參數
########################################################

if($#ARGV != 2)
{
	print "Usage :\n";
	print "    perl modi_corr.pl new_sign.txt old_bm.txt new_sign_out.txt\n";
	exit;
}

########################################################
# 主參數
########################################################

my $InTxtFile = shift;
my $InBMFile = shift;
my $OutBMFile = shift;

my $hasdot_txt = "";		# 用來判斷是否有 dot , 0: 沒有, 1:句讀, 2:小黑點 , 新式標點版直接用該符號
my $hasdot_bm = "";		# 用來判斷是否有 dot , 0: 沒有, 1:句讀, 2:小黑點 , 新式標點版直接用該符號
my $tagbuff = "";		# 暫存讀取 BM 遇到的 tag 的 buff

my $firstword = 0;		# 若遇到 [TX]xxn.... 則 $firstword = 1 , 此時若遇到 <P> 則是行首, 否則設為 0 , 變成行中的 <P>

########################################################
# 主程式
########################################################
=begin

處理流程

1. 讀取 bm 一個字, 此字之前的標記放在 $tagbuff , 而標點則放在 $hasdot_bm
2. 讀取 txt 一個字, 此字之前的標點則放在 $hasdot_txt
3. 比較二字是否相同?
3-1. 若相同, 則比較二邊的標點
   a.二邊標點相同, 沒事.
   b.標點不同, 則 txt 標點放到 bm 中.
   c.bm 無標點, txt 有標點, 則 txt 標點放到 bm 中.
   d.bm 有標點, txt 無標點, 則 bm 標點要移除.
3-2. 若不同, 印出錯誤訊息

=end
=cut

open INTxt, "<:utf8", "$InTxtFile" or die "open $InTxtFile error$!";
open INBM, "<:utf8", "$InBMFile" or die "open $InBMFile error$!";
open OUT, ">:utf8", "$OutBMFile" or die "open $OutBMFile error$!";

# 不用陣列, 全部接成一行
#my @lines_txt = <INTxt>;
#my @lines_bm = <INBM>;
#my @lines_out = "";

my $all_txt = "";
my $all_bm = "";
my $all_out = "";

while(<INTxt>) 
{
	s/(\[$loseutf8+?\])/get_word($1)/ge;
	$all_txt .= $_; 
}
while(<INBM>) 
{
	# 先把 <□> 換成 \x{D0000} , 最後再換回來
	s/<□>/\x{D0000}/g;
	s/(\[$loseutf8+?\])/get_word($1)/ge;
	$all_bm .= $_;
}

$all_txt =~ s/\n{2,}/\n<P>\n/sg;	# 二行以上的段落插入 <p>

close INTxt;
close INBM;

# 不用陣列, 所以不用 index 了
#my $index_txt = 0;	# 目前在 @lines_txt 的行位置
#my $index_bm = 0;	# 目前在 @lines_bm 的行位置
#my $index_out = 0;	# 目前在 @lines_out 的行位置

while(1)
{
	
	# ------------------------ 各取一個字
	
	# 讀取 txt 一個字, 此字之前的標點放在 $hasdot_txt
	my $word_txt = get_word_txt();

	# 讀取 bm 一個字, 此字之前的標記放在 $tagbuff , 而標點則放在 $hasdot_bm
	my $word_bm = get_word_bm();
	
	if($word_txt ne "" and $word_bm eq "")
	{
		print "Error: $InBMFile no data\n";
		#print OUTBM "<?>Out of data";
		printout("<?>Out of data");
		last;
	}
	
	# ------------------------ 判斷二個字是否相同
	
	my $result = check_2_word($word_txt, $word_bm);

	if($result == 1)	# 二邊同步
	{
		if($debug)
		{
			print Encode::encode("big5","hasdot_txt : $hasdot_txt  hasdot_bm : $hasdot_bm\n");
		}
		
		printout($hasdot_txt);
		printout($word_txt);
	}
	# 有修訂
	elsif($word_bm =~ /\[.*?>.*?\]/)
	{
		run_corr($word_bm, $hasdot_txt, $word_txt);
	}
	# 二邊文字不同步, 印出錯誤訊息
	else
	{
		#print OUTBM "<?><bm:$word_txt,xml:$word_bm>$tagbuff$word_bm";
		#print OUTBM $lines_bm[$index_bm];
		printout("<?><txt:$word_txt,bm:$word_bm>$word_txt");
		#printout($lines_bm[$index_bm]);
		#$index_txt++;
		#$index_bm++;
		#$index_out++;
	}
	
	if($word_txt eq "" and $word_bm eq "")
	{
		last;
	}
}

# 輸出結果

if($#des >= 0)
{
	my $patten = "[\x{D0000}" . "-" . chr(0xD0000+$#des) . "]";
	$all_out =~ s/($patten)/get_des($1)/ge;
}

print OUT $all_out;
close OUT;

########################################################
# 取得純文字的字
########################################################

sub get_word_txt
{	
	local $_;
	
	$hasdot_txt = "";		# 用來判斷是否有 dot

	while(1)
	{
		if($all_txt eq "")		# 結束了
		{
			return "";
		}
		
		if($all_txt =~ /^([\n　。、，．；：「」『』（）？！—…《》〈〉“”])/s)
		{
			$hasdot_txt .= $1;		
			$all_txt =~ s/^([\n　。、，．；：「」『』（）？！—…《》〈〉“”])//s;
			next;
		}
		if($all_txt =~ /^(<P>)/s)
		{
			$hasdot_txt .= $1;		
			$all_txt =~ s/^(<P>)//s;
			next;
		}
				
		last;
	}
	
	if($all_txt =~ /^\[($loseutf8+?)\]/s)	# 缺字
	{
		$all_txt =~ s/^(\[($loseutf8+?)\])//s;
		return $1;
	}
	
	if($all_txt =~ /^\[[^>\d]*?>[^>\d]*?\]/s)	# 修訂 [A>B]
	{
		$all_txt =~ s/^(\[[^>\d]*?>[^>\d]*?\])//s;
		return $1;	# 特殊修訂格式
	}

	if($all_txt =~ /^$utf8/s)     # 一般字
	{
		$all_txt =~ s/^($utf8)//s;
		return $1;
	}
}

###########################################
# 取回 bm 的一個字
###########################################

sub get_word_bm
{
	local $_;
	
	$hasdot_bm = "";		# 用來判斷是否有 dot
	$tagbuff = "";			# BM 暫存 tag 的 buff

	while(1)
	{
		if($all_bm eq "")		# 結束了
		{
			return "";
		}

		# 行首
		if($all_bm =~ /^([A-Z]+\d+n.{5}p.{7})(.{3})/s)
		{
			$all_bm =~ s/^([A-Z]+\d+n.{5}p.{7})(.{3})//s;
			$tagbuff .= $1 . $2;
			next;
		}

		# ----- 需要處理的標記在放在此之前

		if($all_bm =~ /^((<.*?>)|(\[＊\])|(\[A?\d+[a-zA-Z]?\]))/s)
		{
			$all_bm =~ s/^((<.*?>)|(\[＊\])|(\[A?\d+[a-zA-Z]?\]))//s;
			$tagbuff .= $1;
			
			next;
		}

		# [[01]>] [>[＊]] 這類要處理掉
		
		if($all_bm =~ /^((\[>?\[＊\]>?\])|(\[>?\[A?\d+[a-zA-Z]?\]>?\]))/s)
		{
			$all_bm =~ s/^((\[>?\[＊\]>?\])|(\[>?\[A?\d+[a-zA-Z]?\]>?\]))//s;
			$tagbuff .= $1;
			
			next;
		}

		if($all_bm =~ /^([\n　ＰＳｓＷＺＩＭＲｊＴＤＱＡＹＢＥ])/s)
		{
			$all_bm =~ s/^([\n　ＰＳｓＷＺＩＭＲｊＴＤＱＡＹＢＥ])//s;
			$tagbuff .= $1;
			
			next;
		}
		
		# 標點處理
		if($all_bm =~ /^([。、，．；：「」『』（）？！—…《》〈〉“”])/s)
		{
			$all_bm =~ s/^([。、，．；：「」『』（）？！—…《》〈〉“”])//s;
			$tagbuff .= $1;
			$hasdot_bm .= $1;
			
			next;
		}

		last;
	}
		
	if($all_bm =~ /^\[($loseutf8+?)\]/s)			# 組字式
	{
		$all_bm =~ s/^(\[($loseutf8+?)\])//s;
		return $1;
	}
	
	#if(/^\[[^>\d]*?>[^>\d]*?\]/)	# 修訂 [A>B]
	#{
	#	$lines_bm[$index_bm] =~ s/^(\[[^>\d]*?>[^>\d]*?\])//;
	#	return "$1";	# 特殊修訂格式
	#}

	if($all_bm =~ /^\[[^>\d]*?>[^>\d]*?\]/s)	# 修訂 [A>B]
	{
		$all_bm =~ s/^(\[[^>\d]*?>[^>\d]*?\])//s;
		return $1;	# 特殊修訂格式
	}

	if($all_bm =~ /^$utf8/s)			# 一般字
	{
		$all_bm =~ s/^($utf8)//s;
		return $1;
	}
}

################################################################
# 判斷二者是否相同
################################################################

sub check_2_word
{
	my $word_txt = shift;
	my $word_bm = shift;
	
	if($debug)
	{
		print Encode::encode("big5","word_txt : $word_txt  word_bm : $word_bm\n");
	}
	
	if($word_txt eq $word_bm)
	{
		return 1;
	}

	# 組字式算過關
	if(($word_txt =~ /^\[[^>]*?\]/) || ($word_bm =~ /^\[[^>]*?\]/))
	{
		return 1;
	}

	# 修訂格式

	#if($word_bm =~ /\[([^>]*)>([^>]*)\]/)
	#{
	#	my $w1 = $1;
	#	my $w2 = $2;
		
	#	if(($word_txt eq $w1) || ($word_txt eq $w2))
	#	{
	#		return 1;
	#	}
	#}

	return 0;
}

# 把傳入的資料推入 @lines , 若有換行就要處理
sub printout
{
	local $_ = shift;
	$all_out .= $_;
}

## 特殊情況, bm 有修訂, 要額外處理了
sub run_corr
{
	my $word_bm = shift;
	my $hasdot_txt_orig = shift;
	my $word_txt_orig = shift;

	# 備份

	my $all_bm_orig = $all_bm;
	my $all_txt_orig = $all_txt;

	# 先取出 BM 修訂的兩端

	$word_bm =~ /^\[(.*?)>(.*?)\]/;
	my $word_bm_left = $1;
	my $word_bm_right = $2;

	my $len_word_bm_left = length($word_bm_left);
	my $len_word_bm_right = length($word_bm_right);

	if($len_word_bm_left == 0)
	{
		# [>xyz] bm 左邊沒字
		
		# 取出等長度的 txt 
		my $word_txt = $word_txt_orig;
		my $word_txt_with_dot = $word_txt_orig;	# 有字有標點
		for(my $i=0; $i<$len_word_bm_right-1; $i++)	# 因為已取出一個字, 所以要 -1
		{
			my $word = get_word_txt();
			$word_txt .= $word;
			$word_txt_with_dot .= $hasdot_txt . $word;
		}

		# 比較二個字串是否相同
		if(comp_2_string($word_txt, $word_bm_right))
		{
			# 相同, 當成 txt 選用的版本是修訂後有文字的版本
			# txt : abc
			# bm : [>abc]
			printout("${hasdot_txt_orig}[>$word_txt_with_dot]");
		}
		else
		{
			# 不同, 當成 txt 選用的版本是修訂前沒有文字的版本
			# txt : xyz
			# bm : [>abc]xyz
			printout("$word_bm");
			$all_txt = $hasdot_txt_orig . $word_txt_with_dot . $all_txt;
		}
	}
	elsif($len_word_bm_right == 0)
	{
		#[xyz>]
		
		# 取出等長度的 txt 
		my $word_txt = $word_txt_orig;
		my $word_txt_with_dot = $word_txt_orig;	# 有字有標點
		for(my $i=0; $i<$len_word_bm_left-1; $i++)	# 因為已取出一個字, 所以要 -1
		{
			my $word = get_word_txt();
			$word_txt .= $word;
			$word_txt_with_dot .= $hasdot_txt . $word;
		}

		# 比較二個字串是否相同
		if(comp_2_string($word_txt, $word_bm_left))
		{
			# 相同, 當成 txt 選用的版本是修訂前有文字的版本
			# txt : abc
			# bm : [abc>]
			printout("${hasdot_txt_orig}[$word_txt_with_dot>]");
		}
		else
		{
			# 不同, 當成 txt 選用的版本是修訂後沒有文字的版本
			# txt : xyz
			# bm : [abc>]xyz
			printout($word_bm);
			$all_txt = $hasdot_txt_orig . $word_txt_with_dot . $all_txt;
		}
	}
	else
	{
		#[abcd>xyz]

		# 取出二組等長度的 txt 
		my $word_txt_left = $word_txt_orig;
		my $word_txt_with_dot_left = $word_txt_orig;	# 有字有標點

		my $word_txt_right = $word_txt_left;
		my $word_txt_with_dot_right = $word_txt_with_dot_left;	# 有字有標點

		# 取出和左邊等長的文字
		for(my $i=0; $i<$len_word_bm_left-1; $i++)	# 因為已取出一個字, 所以要 -1
		{
			my $word = get_word_txt();
			$word_txt_left .= $word;
			$word_txt_with_dot_left .= $hasdot_txt . $word;
		}
			
		# 取出和右邊等長的文字
		if($len_word_bm_left == $len_word_bm_right)
		{
			# 左右等長, 直接用
			$word_txt_right = $word_txt_left;
			$word_txt_with_dot_right = $word_txt_with_dot_left;
		}
		else
		{
			# 先還原 $all_txt
			$all_txt = $all_txt_orig;
			
			# 取出和右邊等長的文字
			for(my $i=0; $i<$len_word_bm_right-1; $i++)	# 因為已取出一個字, 所以要 -1
			{
				my $word = get_word_txt();
				$word_txt_right .= $word;
				$word_txt_with_dot_right .= $hasdot_txt . $word;
			}
		}

		# 比對囉

		# 先比左邊
		if(comp_2_string($word_txt_left, $word_bm_left))
		{
			# 左邊相同
			printout("${hasdot_txt_orig}[$word_txt_with_dot_left>$word_bm_right]");
			# 還原 $all_txt
			$all_txt = $all_txt_orig;
			for(my $i=0; $i<$len_word_bm_left-1; $i++)	# 因為已取出一個字, 所以要 -1
			{
				my $word = get_word_txt();
				#$word_txt_left .= $word;
				#$word_txt_with_dot_left .= $hasdot_txt . $word;
			}
		}
		elsif(comp_2_string($word_txt_right, $word_bm_right))
		{
			# 右邊相同
			printout("${hasdot_txt_orig}[$word_bm_left>$word_txt_with_dot_right]");
			# 還原 $all_txt
			$all_txt = $all_txt_orig;
			for(my $i=0; $i<$len_word_bm_right-1; $i++)	# 因為已取出一個字, 所以要 -1
			{
				my $word = get_word_txt();
				#$word_txt_left .= $word;
				#$word_txt_with_dot_left .= $hasdot_txt . $word;
			}
		}
		else
		{
			# 都不相同...
			printout("$hasdot_txt_orig<?><txt:$word_txt_orig,bm:$word_bm>$word_txt_orig");
			# 還原 $all_txt
			$all_txt = $all_txt_orig;
		}
	}
}

# 比較二個字串是否相同, 相同傳回 1
sub comp_2_string
{
	my $str1 = shift;
	my $str2 = shift;

	$str1 =~ s/[。、，．；：「」『』（）？！—…《》〈〉“”]//g;
	$str2 =~ s/[。、，．；：「」『』（）？！—…《》〈〉“”]//g;

	if($str1 eq $str2)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

#############################

=begin
	為了避免組字式與模糊字 <□> 的干擾, 尤其是二者混用 [<□>>[羽*惠]]
	所以要用 unicode U+D0000 字面來取代
	U+D0000 = <□>
	其他組字式就陸續推入 @gaiji 陣列

	$word = get_word("[羽*惠]"); # 將組字式推入, 並傳回對應的 unicode
	$des = get_des($word);	# 傳入文字, 傳回原來的組字式

my @des = ();	# 遇到組字式就放入
my %des_hash = ();	# 如果此字存在, 就有 $des_hash{"[xxx]"} = 3 , 表示此字為 U+D0003 
=end
=cut

# 傳入組字式, 傳回對應的 unicode 文字
sub get_word
{
	local $_ = shift;
	if(!$des_hash{$_})
	{
		push(@des, $_);
		$des_hash{$_} = $#des;
	}
	return chr(0xD0000 + $des_hash{$_});
}

# 傳入 unicode 文字, 傳回組字式
sub get_des
{
	local $_ = shift;
	my $i = ord($_) - 0xD0000;
	return $des[$i];
}