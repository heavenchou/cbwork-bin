################################################################
#
# BM 簡單標記版標點插入程式  by heaven                2019/02/19
#
# 使用方法：
# pushsign_bm.pl 標點版.txt 原始的BM.txt 成果檔BM.txt > 記錄檔.txt
#
################################################################
# 2019/02/19 : 開始動工

use utf8;
use strict;
use Encode;

my $debug = 0;

local *INTxt;
local *INBM;
local *OUTBM;

my $utf8='(?:.)';
my $loseutf8='(?:[^\[\]> ])';

########################################################
# 判斷參數
########################################################

if($#ARGV != 2)
{
	print "Usage :\n";
	print "    perl pushsign_bm.pl new_sign.txt old_bm.txt new_bm.txt > log.txt\n";
	exit;
}

########################################################
# 主參數
########################################################

# 等同 <p> 標記的符號
# <P>遇到 <p 或 P#，則保留 bm 的 <p 或 P#。
# <P>遇到 A# 或 <A>，則保留 bm 的 A# 或 <A>。
# <P>遇到 S# 或 s# 或 <S>，則保留 bm 的 S# 或 s# 或 <S>。
# <P>遇到 T# 或 t# 或 <T，則保留 bm 的 <T。
# <P>沒遇到 bm 標記，則將<P>置入 bm。
my @p_tag = ("<p ", "<p>", "P#", "<A>", "A#", "<S>", "S#", "s#", "<T", "T#", "t#");

my $InTxtFile = shift;
my $InBMFile = shift;
my $OutBMFile = shift;

my $hasdot_txt = "";		# 用來判斷是否有 dot , 0: 沒有, 1:句讀, 2:小黑點 , 新式標點版直接用該符號
my $hasdot_bm = "";		# 用來判斷是否有 dot , 0: 沒有, 1:句讀, 2:小黑點 , 新式標點版直接用該符號
my $tagbuff = "";		# 暫存讀取 xml 遇到的 tag 的 buff

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
open OUTBM, ">:utf8", "$OutBMFile" or die "open $OutBMFile error$!";

my @lines_txt = <INTxt>;
my @lines_bm = <INBM>;
my @lines_out = "";

close INTxt;
close INBM;

my $index_txt = 0;	# 目前在 @lines_txt 的行位置
my $index_bm = 0;	# 目前在 @lines_bm 的行位置
my $index_out = 0;	# 目前在 @lines_out 的行位置

while(1)
{
	$hasdot_txt = "";		# 用來判斷是否有 dot
	$hasdot_bm = "";		# 用來判斷是否有 dot
	
	# ------------------------ 各取一個字
	
	# 讀取 bm 一個字, 此字之前的標記放在 $tagbuff , 而標點則放在 $hasdot_bm
	my $word_bm = get_word_bm();

	# 讀取 txt 一個字, 此字之前的標點放在 $hasdot_txt
	my $word_txt = get_word_txt();
	
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
		
		############ 處理 <P> 標記
		if($hasdot_txt =~ /<P>/)
		{
			# <P>遇到 <p 或 P#，則保留 bm 的 <p 或 P#。
			# <P>遇到 A# 或 <A>，則保留 bm 的 A# 或 <A>。
			# <P>遇到 S# 或 s# 或 <S>，則保留 bm 的 S# 或 s# 或 <S>。
			# <P>遇到 T# 或 t# 或 <T，則保留 bm 的 <T。
			# <P>沒遇到 bm 標記，則將<P>置入 bm。
			
			foreach my $tag (@p_tag)
			{
				if($tagbuff =~ /$tag/)
				{
					$hasdot_txt =~ s/<P>//sg;
					last;
				}
			}
		}
		
		############

		if($hasdot_txt eq $hasdot_bm)	# 二邊標點同步
		{
			#print OUTBM $tagbuff;
			printout($tagbuff);
		}
		elsif($hasdot_txt ne "" and $hasdot_bm ne "")	# 二邊都有標點, 但不同步
		{
			if($debug)
			{
				print Encode::encode("big5","tagbuff : $tagbuff\n");
			}
			
			# 有一種情況 tagbuff 找不到 hasdot_bm
			# 例如 tagbuff = "。<tag>「" , hasdot_bm = "。「"
			if($tagbuff =~ /^(.*)$hasdot_bm/)
			{
				$tagbuff =~ s/^(.*)$hasdot_bm/$1$hasdot_txt/;
				$tagbuff =~ s/((?:(?:「)|(?:『)|(?:（)|(?:《)|(?:〈)|(?:“)|(?:<[p]>))+)(<.*>)/$2$1/;	# 有點暴力了...要改...
			}
			else
			{
				#print OUTBM "<?><bm:$hasdot_txt,xml:$hasdot_bm>";
				printout("<?><bm:$hasdot_txt,xml:$hasdot_bm>");
			}
			#print OUTBM $tagbuff;
			printout($tagbuff);
		}
		elsif($hasdot_txt ne "" and $hasdot_bm eq "")		# xml 沒標點, 所以要加上去
		{
			if($hasdot_txt =~ /(((?:「)|(?:『)|(?:（)|(?:《)|(?:〈)|(?:“)|(<P>))+)/)		# 這些標記要移到後面
			{
				my $tmp = $1;
				$hasdot_txt =~ s/(((?:「)|(?:『)|(?:（)|(?:《)|(?:〈)|(?:“)|(<P>))+)//;
				#print OUTBM "$hasdot_txt$tagbuff$tmp";
				printout("$hasdot_txt$tagbuff$tmp");
			}
			else
			{
				#print OUTBM "$hasdot_txt$tagbuff";
				printout("$hasdot_txt$tagbuff");
			}
		}
		# xml 有標點, bm 無標點, 則 xml 標點要移除.
		elsif($hasdot_txt eq "" and $hasdot_bm ne "")
		{
			if($tagbuff =~ /$hasdot_bm/)
			{
				$tagbuff =~ s/$hasdot_bm//;
				#print OUTBM "$tagbuff";
				printout($tagbuff);
			}
			else
			{
				# 找不到
				printout("<?><bm:$hasdot_txt,xml:$hasdot_bm>");
			}
		}
		else
		{
			#print OUTBM "<??>$tagbuff";		# 大概用不上了
			printout("<??>$tagbuff");
		}

		#print OUTBM "$word_bm";
		printout($word_bm);
	}
	# 二邊文字不同步, 印出錯誤訊息
	else
	{
		#print OUTBM "<?><bm:$word_txt,xml:$word_bm>$tagbuff$word_bm";
		#print OUTBM $lines_bm[$index_bm];
		printout("<?><txt:$word_txt,bm:$word_bm>$tagbuff$word_bm");
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
for(my $i=0; $i<=$#lines_out; $i++)
{
	print OUTBM $lines_out[$i];
}
close OUTBM;

########################################################
# 取得純文字的字
########################################################

sub get_word_txt
{	
	local $_;
	
	while(1)
	{
		if($index_txt > $#lines_txt)		# 結束了
		{
			return "";
		}
		
		if($lines_txt[$index_txt] eq "\n") 
		{
			$index_txt ++;
			next;
		}

		# 忽略空格
		$lines_txt[$index_txt] =~ s/^(　)*//;

		if($lines_txt[$index_txt] =~ /^([。、，．；：「」『』（）？！—…《》〈〉“”])/)
		{
			$hasdot_txt .= $1;		
			$lines_txt[$index_txt] =~ s/^([。、，．；：「」『』（）？！—…《》〈〉“”])//;
			next;
		}
		if($lines_txt[$index_txt] =~ /^(<P>)/)
		{
			$hasdot_txt .= $1;		
			$lines_txt[$index_txt] =~ s/^(<P>)//;
			next;
		}
				
		last;
	}
	
	$_ = $lines_txt[$index_txt];
	
	if(/^\[($loseutf8+?)\]/)	# 缺字
	{
		$lines_txt[$index_txt] =~ s/^(\[($loseutf8+?)\])//;
		return $1;
	}
	
	if(/^\[[^>\d]*?>[^>\d]*?\]/)	# 修訂 [A>B]
	{
		$lines_txt[$index_txt] =~ s/^(\[[^>\d]*?>[^>\d]*?\])//;
		return $1;	# 特殊修訂格式
	}

	if(/^$utf8/)     # 一般字
	{
		$lines_txt[$index_txt] =~ s/^($utf8)//;
		return $1;
	}
}

###########################################
# 取回 bm 的一個字
###########################################

sub get_word_bm
{
	local $_;
	$tagbuff = "";	# 暫存 tag 的 buff

	while(1)
	{
		if($index_bm > $#lines_bm)		# 結束了
		{
			return "";
		}

		if($lines_bm[$index_bm] eq "\n")		# 先處理換行
		{
			$tagbuff .= "\n";
			$index_bm ++;
			next;
		}

		# 行首
		if($lines_bm[$index_bm] =~ /^(\D+\d+n.{5}p.{7})(.{3})/)
		{
			$lines_bm[$index_bm] =~ s/^(\D+\d+n.{5}p.{7})(.{3})//;
			$tagbuff .= $1 . $2;
			next;
		}

		# ----- 需要處理的標記在放在此之前

		if($lines_bm[$index_bm] =~ /^((<[^□]*?>)|(\[＊\])|(\[A?\d+[a-zA-Z]?\]))/)
		{
			$lines_bm[$index_bm] =~ s/^((<[^□]*?>)|(\[＊\])|(\[A?\d+[a-zA-Z]?\]))//;
			$tagbuff .= $1;
			next;
		}
		
		# [[01]>] [>[＊]] 這類要處理掉
		
		if($lines_bm[$index_bm] =~ /^((\[>?\[＊\]>?\])|(\[>?\[A?\d+[a-zA-Z]?\]>?\]))/s)
		{
			$lines_bm[$index_bm] =~ s/^((\[>?\[＊\]>?\])|(\[>?\[A?\d+[a-zA-Z]?\]>?\]))//s;
			$tagbuff .= $1;
			
			next;
		}

		if($lines_bm[$index_bm] =~ /^([　ＰＳｓＷＺＩＭＲｊＴＤＱＡＹＢＥ])/)
		{
			$lines_bm[$index_bm] =~ s/^([　ＰＳｓＷＺＩＭＲｊＴＤＱＡＹＢＥ])//;
			$tagbuff .= $1;
			next;
		}
		
		# 標點處理
		if($lines_bm[$index_bm] =~ /^([。、，．；：「」『』（）？！—…《》〈〉“”])/)
		{
			$lines_bm[$index_bm] =~ s/^([。、，．；：「」『』（）？！—…《》〈〉“”])//;
			$tagbuff .= $1;
			$hasdot_bm .= $1;
			next;
		}

		last;
	}
	
	$_ = $lines_bm[$index_bm];
	
	if(/^\[($loseutf8+?)\]/)			# 組字式
	{
		$lines_bm[$index_bm] =~ s/^(\[($loseutf8+?)\])//;
		return $1;
	}
	
	if(/^\[[^>\d]*?>[^>\d]*?\]/)	# 修訂 [A>B]
	{
		$lines_bm[$index_bm] =~ s/^(\[[^>\d]*?>[^>\d]*?\])//;
		return $1;	# 特殊修訂格式
	}

	if(/^$utf8/)			# 一般字
	{
		$lines_bm[$index_bm] =~ s/^($utf8)//;
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

	# 修訂格式

	if($word_bm =~ /\[([^>]*)>([^>]*)\]/)
	{
		my $w1 = $1;
		my $w2 = $2;
		
		if(($word_txt eq $w1) || ($word_txt eq $w2))
		{
			return 1;
		}
	}

	return 0;
}

# 把傳入的資料推入 @lines , 若有換行就要處理
sub printout
{
	local $_ = shift;

	while(/^(.*?\n)(.*)/s)
	{
		$lines_out[$index_out] .= $1;
		$index_out++;
		$_ = $2;
	}
	$lines_out[$index_out] .= $_;
}
