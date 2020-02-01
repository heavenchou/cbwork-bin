########################################################
#
# 標點插入程式  by heaven                2004/09/17
#
# 使用方法：
# pushsign.pl 簡單標記版.txt 舊的xml.xml 結果檔xml.xml > 記錄檔.txt
#
########################################################
# 2020/02/02 : 將行首下引號移到前一行行尾的 </p> 之前
# 2020/01/30 : 增加新版悉曇格式，增加 <note type="add"> 處理格式。
# 2020/01/29 : 根據標記的不同，調整標點的位置。
# 2020/01/28 : 程式配合部份標記的修改。例: sg -> cb:sg , lang -> xml:lang ...
# 2019/12/20 : 圖形的處理標記由 <figure> 擴大為 <figure>...</figure>
# 2019/12/19 : 處理 6/27 </L> 的後遺症，若沒有出現 <I><P>，就不處理沒有接著 <P> 的 </L>
# 2019/09/26 : 部份悉曇標記要當成標點處理：
# 				<g ref="#SD-D953"/> = …
# 				<g ref="#SD-E35A"/> = （
# 				<g ref="#SD-E35B"/> = ）
# 2019/09/25 : 處理 <item n="..."..> 的情況, 先前沒考慮標記中有其他屬性
# 2019/06/17 : 1.修改有 </L> 沒有接著 <P> 的情況
#              2.note type=org,mod,add 標記之後的標點要移到 note 之前
# 2019/06/04 : 1.處理模糊字比對
#              2.p 的 rend=inline 改成 cb:place=inline, 
#              3.rend=margin-left 改成 style=margin-left
# 2019/05/20 : 處理 note 中包含 note 的誤判
# 2019/05/18 : 原本大正藏的修訂還有比對, 現在連大正藏也不比對了, [A>B] 全部都只比對 B。
# 2019/05/14 : 因為修訂的標記已經換成 app 校勘標記, 所以BM的 [A>B] 只處理 B 了。
# 2018/01/14 : 因為校勘可能有重覆的 <lb> 標記, 第二次以上就忽略.
# 2017/12/22 : 處理 1.</t> 忘了改成 </cb:t> 2.<g> 可能會對應 Unicode , 不一定是組字式
# 2017/05/29 : 處理有 </L> 沒有接著 <P> 的情況
# 2017/05/27 : 將 </p> 等行首的結束標記移到前一行 (沒有全部, 只有指定的結束標記)
# 2017/05/27 : 支援 <I><P> 和 </L><P> 標記
# 2016/05/18 : 修訂某些標點無法置換的錯誤
# 2016/05/09 : 原來的 XML 也可以是新標檔
# 2016/05/08 : 處理 <anchor type="circle"/> = ◎
# 2016/05/07 : 還原上一版的暫時移除梵漢對照
# 2016/05/06 : 這一版是暫時移除梵漢對照
# 2016/05/05 : 將 <tt> 改成 <cb:tt> , <t> 改成 <cb:t>
# 2016/05/04 : 處理 <cb:mulu> , <note> 之中有 <g> 標記, 處理 rdg 標記有 type = "correctionRemark" 及 "variantRemark"
# 2016/05/03 : 行中的 p 原本是 <p place="inline">, 改成 <p rend="inline">
# 2016/03/12 : 改成 utf8 版, 支援 P5a 的 XML 經文 (之前 的 big5 版是支援 P4 版的 XML)
# 2011/12/30 : 處理模糊字 BM:□ , XML:&unrec;
# 2008/12/11 : 雜阿含BM版也有（）這些標記，故加入判斷中。
# 2007/07/04 : 大智度論支援 <o><P> 這種格式, 轉出來的 XML 為 <!-- <o> --><p> , 此類標記有 <ouwsa> 
# 2006/12/18 : 直接把行首 <P> 變成 </p><p> , 行中變成 </p><p place="inline"> , 若有 <P,n> 也處理 n 數字
# 2006/12/15 : 處理 <anchor type="◎"/> = ◎
# 2005/05/23 : 新標 <P> 放入 XML 中, 行首的變成 <!-- P1 -->，行首的變成 <!-- P2 -->。 (在 2006/12/18 的版本已修改)
# 2005/05/20 : 忽略 CBETA 自己加上的說明，不過此說明不要跨行　<note resp="CBETA.say">CBET 的說明</note>
# 2005/05/15 : 若 「『（《〈 這五個標點和其它標點在一起，例如：「則只有「『（《〈移到標記後。例如：</p><p>「
# 2005/04/26 : 將 「『（《〈 這五個標點符號移到標記之後, 例如 「<p> => <p>「
# 2005/04/26 : 改成可以處理新式標點
# 10/15 : 處理一些日文
# 10/15 : 處理悉曇字的 …（）三個符號及 <item>
# 10/15 : 更換 <tt> 的處理法
# 10/14 : 加強 <tt> , 容許第二行有【圖】及其它文字
# 10/14 : 加強 <tt> , 容許第二行有【圖】 (還要再加強)
# 10/13 : 處理 <tt> 梵漢隔行對照 及 <sg>
# 10/10 : 處理 <foreign>...</foreign>
# 10/10 : 處理 <head type="added">....</head> 及 &SD-...; 悉曇字
# 10/8 : 將忽略 <t lang="san|pli|..." 改成忽略 <t ... place="foot" 
# 10/8 : 處理 <l lang="unknow" 及校勘數字的修訂 [[04]>]
# 10/6 : 加強昨日的判斷
# 10/5 : 移動不適當的句讀與小黑點. 例如應該移至校勘 <lem> <t> 的範圍之外.
# 10/4 : 處理檔尾的 0x0d 字元
# 10/4 : 處理巴利文轉寫字, <foreign>
# 10/3 : 處理大正的校勘, 星號, <tt>
# 9/8 : 處理二檔一為「。」一為「．」的 bug
# 9/5 : 處理通用詞, 圖, 忽略其它全型英文, 標點不同時一律以 SM 為主

use utf8;
use strict;
use Encode;

my $debug = 0;
my $debug2 = 0;

local *INTxt;
local *INXml;
local *OUTXml;

# my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
# my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[+\-*\/\(\)\@\?:0-9])';
my $utf8='(?:.)';
my $loseutf8='(?:[^\[\]> ])';

########################################################
# 判斷參數
########################################################

if($#ARGV != 2)
{
	print "Usage :\n";
	print "    pushsign.pl bm.txt old_xml.xml new_xml.xml\n";
	print "\nany key exit....\n";
	<STDIN>;
	exit;
}

########################################################
# 主參數
########################################################

my $InTxtFile = shift;
my $InXmlFile = shift;
my $OutXmlFile = shift;

my $hasdot1 = "";		# 用來判斷是否有 dot , 0: 沒有, 1:句讀, 2:小黑點 , 新式標點版直接用該符號
my $hasdot2 = "";		# 用來判斷是否有 dot , 0: 沒有, 1:句讀, 2:小黑點 , 新式標點版直接用該符號
my $tagbuff = "";		# 暫存讀取 xml 遇到的 tag 的 buff

my $istt = 0;           # 判斷是不是 <tt> 隔行對照, 0:一般狀況, 1:xml 發現 <tt> 2:sm 版已處理成 <tt> 格式(梵漢間格)
my $whicht = 0;         # 目前是在哪一個 <t> 裡面? 梵 : 1 , 漢 : 2 

my $firstword = 0;		# 若遇到 [TX]xxn.... 則 $firstword = 1 , 此時若遇到 <P> 則是行首, 否則設為 0 , 變成行中的 <P>
my $firstitem = 1;		# 判斷是否是第一個 item , 用來處理 <I><P>, </L><P> 的情況

my %same_lb = ();	# 記錄相同的 <lb> , 因為 XML 會因為校勘有重覆的 <lb> 第二個之後要略去.

########################################################
# 主程式
########################################################
=begin

處理流程

1. 讀取 xml 一個字, 此字之前的標記放在 $tagbuff , 而標點則放在 $hasdot2
2. 讀取 bm 一個字, 此字之前的標點則放在 $hasdot1
3. 比較二字是否相同?
3-1. 若相同, 則比較二邊的標點
   a.二邊標點相同, 沒事.
   b.標點不同, 則 bm 標點放到 xml 中.
   c.xml 無標點, bm 有標點, 則 bm 標點放到 xml 中.
   d.xml 有標點, bm 無標點, 則 xml 標點要移除.
3-2. 若不同, 印出錯誤訊息

=end
=cut

open INTxt, "<:utf8", "$InTxtFile" or die "open $InTxtFile error$!";
open INXml, "<:utf8", "$InXmlFile" or die "open $InXmlFile error$!";
open OUTXml, ">:utf8", "$OutXmlFile" or die "open $OutXmlFile error$!";

my @lines1 = <INTxt>;
my @lines2 = <INXml>;
my @lines3 = "";

for my $line (@lines1)
{
	$line =~ s/<□>/<unclear\/>/g;
}

close INTxt;
close INXml;

my $index1 = 0;	# 目前在 @lines1 的行位置
my $index2 = 0;	# 目前在 @lines2 的行位置
my $index3 = 0;	# 目前在 @lines3 的行位置

# 1. 先將不重要的 XML copy 過去

while(1)
{
	#print OUTXml "$lines2[$index2]";
	push(@lines3, "$lines2[$index2]");
	last if($lines2[$index2] =~ /<body>/);
	$index2++;
	$index3++;
}
$index2++;
$index3++;

my $hasIP = 0;	# 如果有出現 <I><P> 這類的標記, 單獨的 </L> 才要處理, 以免和舊標記 </L> 重複

while(1)
{
	$hasdot1 = "";		# 用來判斷是否有 dot
	$hasdot2 = "";		# 用來判斷是否有 dot
	
	# ------------------------ 各取一個字
	
	# 讀取 xml 一個字, 此字之前的標記放在 $tagbuff , 而標點則放在 $hasdot2

	my $word2 = get_word2();
	if($istt == 1)
	{
	    make_tt();
	    $istt = 2;
	}
	if($istt == 2 and $whicht == 2)
	{
	    $index1++;      # <tt> 中的漢字, 所以讀下一行
	}
	
	# 讀取 bm 一個字, 此字之前的標點放在 $hasdot1

	my $word1 = get_word1();
	
	if($word1 eq 'n="0756c01"')
	{
		$debug = 0;
	}
	
	if($istt == 2 and $whicht == 2)
	{
	    $index1--;      # 還原
	}	
	if($word1 ne "" and $word2 eq "")
	{
		print "Error: $InXmlFile no data\n";
		#print OUTXml "<?>Out of data";
		printout("<?>Out of data");
		last;
	}
	
	# ------------------------ 判斷二個字是否相同
	
	my $result = check_2_word($word1, $word2);
	
	if($debug2)
	{
		print Encode::encode("big5","hasdot1 : $hasdot1\n");
		print Encode::encode("big5","hasdot2 : $hasdot2\n");
		print Encode::encode("big5","tagbuff : $tagbuff\n");
		print Encode::encode("big5","word1 : $word1\n");
		print Encode::encode("big5","word2 : $word2\n");
		print Encode::encode("big5","1:".$lines1[$index1] . "\n");
		print Encode::encode("big5","a:".$lines1[$index1+1] . "\n");
		print Encode::encode("big5","2:".$lines2[$index2] . "\n\n");
	}

	if($result == 1)	# 二邊同步
	{
		if($debug)
		{
			print Encode::encode("big5","hasdot1 : $hasdot1  hasdot2 : $hasdot2\n");
			print Encode::encode("big5","tagbuff : $tagbuff\n");
		}
		
		if($hasdot1 eq $hasdot2)	# 二邊標點同步
		{
			#print OUTXml $tagbuff;
			printout($tagbuff);
		}
		# 悉曇特有標點
		elsif(($hasdot2 eq "<g ref=\"#SD\-D953\"/>" && $hasdot2 eq "…") ||
			($hasdot2 eq "<g ref=\"#SD\-E35A\"/>" && $hasdot2 eq "（") ||
			($hasdot2 eq "<g ref=\"#SD\-E35B\"/>" && $hasdot2 eq "）"))
		{
			# <g ref="#SD-D953"/> = …
			# <g ref="#SD-E35A"/> = （
			# <g ref="#SD-E35B"/> = ）
			printout($tagbuff);
		}
		elsif($hasdot1 ne "" and $hasdot2 ne "")		# 二邊都有標點, 但不同步
		{
			if($debug)
			{
				print Encode::encode("big5","tagbuff : $tagbuff\n");
			}
			
			# 有一種情況 tagbuff 找不到 hasdot2
			# 例如 tagbuff = "。<tag>「" , hasdot2 = "。<tag>「"
			if($tagbuff =~ /^(.*)$hasdot2/)
			{
				$tagbuff =~ s/^(.*)$hasdot2/$1$hasdot1/;
				$tagbuff =~ s/((?:「)|(?:『)|(?:（)|(?:《)|(?:〈)|(?:“))(<.*>)/$2$1/;	# 有點暴力了...要改...
			}
			else
			{
				#print OUTXml "<?><bm:$hasdot1,xml:$hasdot2>";
				printout("<?><bm:$hasdot1,xml:$hasdot2>");
			}
			#print OUTXml $tagbuff;
			printout($tagbuff);
		}
		elsif($hasdot1 ne "" and $hasdot2 eq "")		# xml 沒標點, 所以要加上去
		{
			if($debug)
			{
				print Encode::encode("big5","hasdot1 : $hasdot1  hasdot2 : $hasdot2\n");
				print Encode::encode("big5","tagbuff : $tagbuff\n");
			}
			# $tagbuff =~ s/((。)|(．))//;
			# <rdg wit="【大】">阿。</rdg></app> ==> <rdg wit="【大】">阿</rdg></app>。
			if($tagbuff =~ /^<((\/rdg)|(\/lem)|(\/t)|(note\s+resp="CBETA[^"]*">)|(app.*?))>/)
			{
			    if($tagbuff =~ /^.*<\/((app)|(cb:tt)|(note))>/)
			    {
				    $tagbuff =~ s/^(.*<\/(?:(?:app)|(?:cb:tt)|(?:note))>)/$1$hasdot1/;
				    #print OUTXml "$tagbuff";
					printout($tagbuff);
				}
				else
				{
				    #print OUTXml "$hasdot1<<?>:<在 rdg,lem,t,note 之前的句讀應該處理掉>>$tagbuff";
					printout("$hasdot1<<?>:<在 rdg,lem,t,note 之前的句讀應該處理掉>>$tagbuff");
				}
			}
			# 如果標點在 <lem...> 標記之後，標點要移到前面，不管是不是上引號 (下一個 elsif)
			elsif($tagbuff =~ /<lem [^>]*>$/)
			{
				printout("$hasdot1$tagbuff");
			}
			# 這些標記要移到後面
			elsif($hasdot1 =~ /(((?:「)|(?:『)|(?:（)|(?:《)|(?:〈)|(?:“))+)/)		
			{
				my $tmp = $1;
				$hasdot1 =~ s/(((?:「)|(?:『)|(?:（)|(?:《)|(?:〈)|(?:“))+)//;
				#print OUTXml "$hasdot1$tagbuff$tmp";
				printout("$hasdot1$tagbuff$tmp");
			}
			elsif($tagbuff =~ /^<foreign.*?>.*?<\/foreign>/)
			{
			    $tagbuff =~ s/^(<foreign.*?>.*?<\/foreign>)/$1$hasdot1/;
				#print OUTXml "$tagbuff";
				printout($tagbuff);
			}
			else
			{
				#print OUTXml "$hasdot1$tagbuff";
				printout("$hasdot1$tagbuff");
			}
		}
		# xml 有標點, bm 無標點, 則 xml 標點要移除.
		elsif($hasdot1 eq "" and $hasdot2 ne "")
		{
			$tagbuff =~ s/$hasdot2//;
			#print OUTXml "$tagbuff";
			printout($tagbuff);
		}
		else
		{
			#print OUTXml "<??>$tagbuff";		# 大概用不上了
			printout("<??>$tagbuff");
		}

		#print OUTXml "$word2";
		printout("$word2");
	}
	# 二邊文字不同步, 印出錯誤訊息
	else
	{
		#print OUTXml "<?><bm:$word1,xml:$word2>$tagbuff$word2";
		#print OUTXml $lines2[$index2];
		printout("<?><bm:$word1,xml:$word2>$tagbuff$word2");
		printout($lines2[$index2]);
		$index1++;
		$index2++;
		$index3++;
		#exit;
	}
	
	if($word1 eq "" and $word2 eq "")
	{
		last;
	}
}

# 將行首的 </p> 移到前一行行尾
mv_endtag_to_pre_line();

# 將行首下引號移到前一行行尾的 </p> 之前
# .........</cb:t></cb:tt></p>
# <lb n="0254a26" ed="T"/>」
# 變成
# .........</cb:t></cb:tt>」</p>
# <lb n="0254a26" ed="T"/>
mv_under_quotes_to_pre_line();

# 輸出結果
for(my $i=0; $i<=$#lines3; $i++)
{
	print OUTXml $lines3[$i];
}
close OUTXml;

########################################################
#
# XML 版遇到 <tt> 隔行對照，所以 sm 版要處理成和 xml 版一樣的格式
#例如
#T18n0859_p0178c23Z#H◇◇◇◇◇◇◇◇◇
#T18n0859_p0178c24_##[41]南　麼　三　曼　多　伐　折囉(二合)　赧(一)　唵(二)
#變成
#T18n0859_p0178c23Z#H◇◇◇◇◇◇◇◇◇
#[41]南　麼　三　曼　多　伐　折囉(二合)　赧(一)　唵(二)T18n0859_p0178c24_##
#
# 第一個 <t> 就取第一行, 第二個 <t> 取第二行, 第一行結束後, 再將第二行的 Txxn... 移到前面對
########################################################

sub make_tt
{
    my $data;
    if($index1 == $#lines1)
    {
        return;     #最後一行了, 不用玩了
    }
    
    my $line1 = $lines1[$index1];
    my $line2 = $lines1[$index1+1];
    my $line3 = $lines1[$index1+2];
    
    # 處理修訂與移位

    if($line2 =~ />/)
    {
        if($line3 =~ />>/ and $line2 =~ />>/)
        {
            while($line3 =~ /^$utf8*?\[($loseutf8+?)\]/)
            {
        	    $line3 =~ s/^($utf8*?)\[($loseutf8+?)\]/$1:1:$2:2:/;
	        }
	        $line3 =~ s/\[($loseutf8*?)>>($loseutf8*?)\]/$2/g;
	        $line3 =~ s/\[($loseutf8*?)>($loseutf8*?)\]/$2/g;
	        $line3 =~ s/:1:/\[/g;
	        $line3 =~ s/:2:/\]/g;
	    }

        while($line2 =~ /^$utf8*?\[($loseutf8+?)\]/)
        {
    	    $line2 =~ s/^($utf8*?)\[($loseutf8+?)\]/$1:1:$2:2:/;
	    }
	    $line2 =~ s/\[($loseutf8*?)>>($loseutf8*?)\]/$2/g;
	    $line2 =~ s/\[($loseutf8*?)>($loseutf8*?)\]/$2/g;
	    $line2 =~ s/:1:/\[/g;
	    $line2 =~ s/:2:/\]/g;
	}

    if($line2 =~ /^[A-Z]+\d+n.{5}p.{7}.{3}(.*)/)
    {
        $line2 =~ s/^([A-Z]+\d+n.{5}p.{7}.{3})(.*)/$2$1/;
    }
    else
    {
        return;     # 第二行沒有行首
    }
    $lines1[$index1+1] = $line2;
    $lines1[$index1+2] = $line3;
}

########################################################
#
# 取得純文字的字
#
########################################################

sub get_word1
{	
	local $_;
	
	while(1)
	{
		if($index1 > $#lines1)		# 結束了
		{
			return "";
		}
		
		if($lines1[$index1] eq "\n") 
		{
			$index1 ++;
			next;
		}
		# <[ouwsa]> 是為大智度論新標增加的段落格式 2007/07/04
		# <I></L> 是新增的標記 2017/05/27
		#   第一個 <I><P> 要轉成 </p><list><item><p>
		#   第二個 <I><P> 要轉成 </p></item><item><p> 
		#   最後的 </L><P> 要轉成 </p></item></list><p>
		if($lines1[$index1] =~ /^((?:。)|(?:、)|(?:，)|(?:．)|(?:；)|(?:：)|(?:「)|(?:」)|(?:『)|(?:』)|(?:（)|(?:）)|(?:？)|(?:！)|(?:—)|(?:…)|(?:《)|(?:》)|(?:〈)|(?:〉)|(?:“)|(?:”)|(?:★)|(?:(?:<\/?[ouwsaIL]>)?<P(?:,\d+)?>))/)
		{
			my $tmp = $1;
			if($tmp =~ /(<\/?[ouwsaIL]>)?(<P(?:,\d+)?>)/)
			{
				my $tag1 = $1;
				my $tag2 = $2;

				# 1. <[ouwsa]> => <!-- <[ouwsa]> --> 
				# ex. <o> => <!-- <o> -->

				if($tag1 =~ /(<[ouwsa]>)/)
				{
					$tag1 = "<!-- $1 -->";
				}

				# 2. 第一個 <I> => <list><item>
				#    第二個 <I> => </item><item>
				#    </L> => </item></list>

				if($tag1 eq "<I>")
				{
					$hasIP = 1;
					if($firstitem)
					{
						$tag1 = "<list><item>";
						$firstitem = 0;
					}
					else
					{
						$tag1 = "</item><item>";
					}
				}
				elsif($tag1 eq "</L>")
				{
					$tag1 = "</item></list>";
					$firstitem = 1;
				}

				# 3. <P> => <p>
				#    <P,x> => <p style="margin-left:xem">
				#    行中 P 則加上 cb:place="inline"

				if($tag2 =~ /<P>/)
				{
					if($firstword)
					{
						$tag2 = "<p>";
					}
					else
					{
						$tag2 = "<p cb:place=\"inline\">";
					}
				}
				if($tag2 =~ /<P,(\d+)>/)
				{
					my $tmpnum = $1;
					if($firstword)
					{
						$tag2 = "<p style=\"margin-left:${tmpnum}em\">";
					}
					else
					{
						$tag2 = "<p style=\"margin-left:${tmpnum}em;\" cb:place=\"inline\">";
					}
				}

				# 整合
				$tmp = "</p>" . $tag1 . $tag2;
			}
				
			$hasdot1 .= $tmp;		
			$lines1[$index1] =~ s/^((?:。)|(?:、)|(?:，)|(?:．)|(?:；)|(?:：)|(?:「)|(?:」)|(?:『)|(?:』)|(?:（)|(?:）)|(?:？)|(?:！)|(?:—)|(?:…)|(?:《)|(?:》)|(?:〈)|(?:〉)|(?:“)|(?:”)|(?:★)|(?:(?:<\/?[ouwsaIL]>)?<P(?:,\d+)?>))//;
			next;
		}
		elsif($lines1[$index1] =~ /^(<\/L>)/ and $hasIP == 1)
		{
			# 單獨處理 </L>	
			$firstitem = 1;
			$hasdot1 .= "</item></list>";
			$lines1[$index1] =~ s/^(<\/L>)//;
			next;
		}
		
		if($lines1[$index1] =~ /^((?:　)|(?:Ｐ)|(?:Ｓ)|(?:ｓ)|(?:Ｗ)|(?:Ｚ)|(?:Ｉ)|(?:Ｍ)|(?:Ｒ)|(?:ｊ)|(?:Ｔ)|(?:Ｄ)|(?:Ｑ)|(?:Ａ)|(?:Ｙ)|(?:Ｂ)|(?:Ｅ))/)
		{
			$lines1[$index1] =~ s/^((?:　)|(?:Ｐ)|(?:Ｓ)|(?:ｓ)|(?:Ｗ)|(?:Ｚ)|(?:Ｉ)|(?:Ｍ)|(?:Ｒ)|(?:ｊ)|(?:Ｔ)|(?:Ｄ)|(?:Ｑ)|(?:Ａ)|(?:Ｙ)|(?:Ｂ)|(?:Ｅ))//;
			next;
		}
		if($lines1[$index1] =~ /^<unclear\/>/)
		{
			last;
		}
		if($lines1[$index1] =~ /^<.*?>/)
		{
			$lines1[$index1] =~ s/^<.*?>//;
			next;
		}
		last;
	}
	
	$_ = $lines1[$index1];	# 處理修訂與移位
	# 取行首  X79n1563_p0657a09_##
	$firstword = 0;
	if(/^[A-Z]+\d+n.{5}p(.{7}).{3}/)
	{
		$firstword = 1;	# 若遇到 [TX]xxn.... 則 $firstword = 1 , 此時若遇到 <P> 則是行首, 否則設為 0 , 變成行中的 <P>
		# 處理修訂與移位
		
		while(/^$utf8*?\[($loseutf8+?)\]/)
		{
			s/^($utf8*?)\[($loseutf8+?)\]/$1:1:$2:2:/;
		}
		s/<unclear\/>/:=3=:/g;
		s/\[($loseutf8*?)>>($loseutf8*?)\]/$2$1/g;
		s/\[($loseutf8*?)>($loseutf8*?)\]/$2/g;
		s/:1:/\[/g;
		s/:2:/\]/g;
		s/:=3=:/<unclear\/>/g;
		
		# 處理通用詞
		
		#s=\Q髣髣[髟/弗][髟/弗]\E=&CIxxx;=g;
		#s=\Q髣[髟/弗]\E=&CIxxx;=g;
		#s=\Q[髟/弗]髣\E=&CIxxx;=g;
		#s/\Q搪[打-丁+突]\E/&CIxxx;/g;
		#s/\Q礔[石*歷]\E/&CIxxx;/g;
		#s/\Q琅[王*耶]\E/&CIxxx;/g;
	
		#s/\Q[跍*月]跪\E/&CIxxx;/g;
		#s/\Q[立*令]竮\E/&CIxxx;/g;
		#s=\Q[辟/石][石*歷]\E=&CIxxx;=g;
		#s=\Q[王*頗][王*梨]\E=&CIxxx;=g;
		#s=\Q鴶[亢*鳥]\E=&CIxxx;=g;
		
		$lines1[$index1] = $_;
		
		$lines1[$index1] =~ s/^[A-Z]+\d+n.{5}p(.{7}).{3}(║)?//;
		
		return "n=\"$1\"";
	}
	elsif(/^\[\d+[A-Za-z]?\]/)	# 校勘數字
	{
		$lines1[$index1] =~ s/^(\[\d+[A-Za-z]?\])//;
		return "$1";
	}
	elsif(/^\[＊\]/)	# 星號
	{
		$lines1[$index1] =~ s/^(\[＊\])//;
		return "$1";
	}
	elsif(/^\[($loseutf8+?)\]/)	# 缺字
	{
		$lines1[$index1] =~ s/^(\[($loseutf8+?)\])//;
		return "$1";
	}
	elsif(/^&CIxxx;/)	# 通用詞
	{
		$lines1[$index1] =~ s/^(&CIxxx;)//;
		return "$1";
	}
	elsif(/^【圖】/)	# 【圖】
	{
		$lines1[$index1] =~ s/^(【圖】)//;
		return "$1";
	}
	elsif(/^([Aaiu])\1/)	# 巴利文
	{
		$lines1[$index1] =~ s/^([Aaiu])\1//;
		return "&$1macron;";
	}
	elsif(/^\.[dDhlLmnNrsStT]/)	# 巴利文
	{
		$lines1[$index1] =~ s/^\.([dDhlLmnNrsStT])//;
		return "&$1dotblw;";
	}
	elsif(/^\^[mn]/)	# 巴利文
	{
		$lines1[$index1] =~ s/^\^([mn])//;
		return "&$1dotabv;";
	}
	elsif(/^~n/)        # 巴利文
	{
		$lines1[$index1] =~ s/^~n//;
		return "&ntilde;";
	}
	elsif(/^\`[sS]/)	# 巴利文
	{
		$lines1[$index1] =~ s/^\`([sS])//;
		return "&$1acute;";
	}
	elsif(/^【MA】/)	# 日文&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^【MA】//;
		return "&M062462;";
	}
	elsif(/^【TA】/)	# 日文&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^【TA】//;
		return "&M062431;";
	}
	elsif(/^【RA】/)	# 日文&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^【RA】//;
		return "&M062473;";
	}
	elsif(/^<unclear\/>/)     # 模糊字
	{
		$lines1[$index1] =~ s/^(<unclear\/>)//;
		return "$1";
	}
	elsif(/^$utf8/)     # 一般字
	{
		$lines1[$index1] =~ s/^($utf8)//;
		
		return "$1";
	}
	else
	{
		print "不懂的字:\n";
		print "line = $index1\n";
		print "word = $lines1[$index1]\n";
		print "length = " . length($lines1[$index1]) . "\n";
		print STDERR "Error, see logfile , any key to exit!\n";
		<>;
		exit;
	}
}

# 取回 xml 的一個字

sub get_word2
{
	local $_;
	$tagbuff = "";	# 暫存 tag 的 buff

	while(1)
	{
		if($index2 > $#lines2)		# 結束了
		{
			return "";
		}

		if($lines2[$index2] eq "\n")		# 先處理換行
		{
			$tagbuff .= "\n";
			$index2 ++;
			next;
		}

		if($lines2[$index2] =~ /^(<lb.*?>)/)
		{
			# 要判斷有沒有重覆的 <lb>
			my $lb = $1;
			if($same_lb{$lb})	# 重覆就略過
			{
				$lines2[$index2] =~ s/^(<lb.*?>)//;
				$tagbuff .= $1;
				next;
			}
			else
			{
				$same_lb{$lb} = 1;
				last;
			}
		}

	    #<head type="added">...</head>
	    if($lines2[$index2] =~ /^<head[^>]*type="added"[^>]*>.*?<\/head>/)
		{
			$lines2[$index2] =~ s/^(<head[^>]*type="added"[^>]*>.*?<\/head>)//;
			$tagbuff .= $1;
			next;
		}
		
		# XML : <item n="（一）">....
		# SM  : （一）
		if($lines2[$index2] =~ /^<item [^>]*?n="(.*?)"[^>]*>/)
		{
		    my $tmp = $1;
		    $lines1[$index1] =~ s/^\Q${tmp}\E//;
			$lines2[$index2] =~ s/^(<item [^>]*?n="(.*?)"[^>]*>)//;
			$tagbuff .= $1;
			next;
		}

        # rdg 有二種, 一種要過濾(校勘), 一種要通過(修訂) (修訂也不要通過了 2019/05/18)
		# 還有一種雖然有 wit="【大】" , 還是要過濾, 就是
		# <rdg resp="Taisho" wit="【大】" type="correctionRemark">之因</rdg>
		# <rdg resp="Taisho" wit="【大】" type="variantRemark">之因</rdg>


		# <rdg resp="Taisho" wit="【大】" type="correctionRemark">之因</rdg> (correctionRemark)
		# 不用了, 修訂都不檢查了 2019/05/18
	    #if($lines2[$index2] =~ /^<rdg[^>]*wit="【大】"[^>]*>/ && $lines2[$index2] =~ /^<rdg[^>]*type="(correction)|(variant)Remark"[^>]*>/)
		#{
		#    $lines2[$index2] =~ s/^(<rdg.*?>.*?<\/rdg>)//;
		#	$tagbuff .= $1;
		#	next;
	    #}

	    # <rdg wit="【大】">叟</rdg>(修訂) 
		# 2019/05/18 修訂都不要檢查了, 因為版本太多, 不易處理
	    #if($lines2[$index2] =~ /^<rdg[^>]*wit="【大】"[^>]*>/)
		#{
		#	$lines2[$index2] =~ s/^(<rdg[^>]*wit="【大】"[^>]*>)//;
		#	$tagbuff .= $1;
		#	next;
		#}
		
	    # 過濾(校勘)
	    if($lines2[$index2] =~ /^<rdg.*?>.*?<\/rdg>/)			
	    {
		    $lines2[$index2] =~ s/^(<rdg.*?>.*?<\/rdg>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    # 過濾 <t lang="san" resp="Taisho" place="foot">D&imacron;rgha-&amacron;gama</t>
	    #if($lines2[$index2] =~ /^<t[^>]*lang="(?:(?:san)|(?:pli)|(?:unknown))"[^>]*>.*?<\/t>/)			
	    if($lines2[$index2] =~ /^<cb:t[^>]*place="foot"[^>]*>.*?<\/cb:t>/)	
	    {
            # $lines2[$index2] =~ s/^(<t[^>]*lang="(?:(?:san)|(?:pli)|(?:unknown))"[^>]*>.*?<\/t>)//;
            $lines2[$index2] =~ s/^(<cb:t[^>]*place="foot"[^>]*>.*?<\/cb:t>)//;
			$tagbuff .= $1;
			next;
	    }
	    #<note n="0011004" place="foot" type="equivalent">遊行經...</note>
	    if($lines2[$index2] =~ /^<note[^>]*?type="equivalent"[^>]*?>.*?<\/note>/)
	    {
		    #$lines2[$index2] =~ s/^(<note[^>]*?type="equivalent"[^>]*?>.*?<\/note>)//;
			#$tagbuff .= $1;
			
			my $note = "";
			($lines2[$index2], $note) = get_all_note($lines2[$index2]);
			$tagbuff .= $note;

			next;
			
	    }
	    #<note n="0578006" place="foot" type="rest">品末題在卷末題前行【宋】【元】【明】</note>
	    if($lines2[$index2] =~ /^<note[^>]*?type="rest"[^>]*?>.*?<\/note>/)			
	    {
		    #$lines2[$index2] =~ s/^(<note[^>]*?type="rest"[^>]*?>.*?<\/note>)//;
			#$tagbuff .= $1;
			
			my $note = "";
			($lines2[$index2], $note) = get_all_note($lines2[$index2]);
			$tagbuff .= $note;

			next;
	    }
	    
	    #<foreign n="0434012" lang="pli" resp="Taisho" place="foot">Niga&ndotblw...</foreign>
	    if($lines2[$index2] =~ /^<foreign .*?>.*?<\/foreign>/)			
	    {
		    $lines2[$index2] =~ s/^(<foreign .*?>.*?<\/foreign>)//;
			$tagbuff .= $1;
			next;
	    }
	    #<note n="0030012" place="foot" type="cf.">
	    if($lines2[$index2] =~ /^<note[^>]*?type="cf\."[^>]*?>.*?<\/note>/)			
	    {
		    #$lines2[$index2] =~ s/^(<note[^>]*?type="cf\."[^>]*?>.*?<\/note>)//;
			#$tagbuff .= $1;
			
			my $note = "";
			($lines2[$index2], $note) = get_all_note($lines2[$index2]);
			$tagbuff .= $note;

			next;
	    }
	    
	    # <note n="0150002" resp="CBETA" type="mod">傳＝明【宋】【元】【明】</note>
	    if($lines2[$index2] =~ /^<note[^>]*?resp="CBETA"[^>]*?>.*?<\/note>/)
	    {
		    #$lines2[$index2] =~ s/^(<note[^>]*?resp="CBETA"[^>]*?>.*?<\/note>)//;
			#$tagbuff .= $1;
			
			my $note = "";
			($lines2[$index2], $note) = get_all_note($lines2[$index2]);
			$tagbuff .= $note;
			next;
	    }
	    # <note resp="CBETA.say">CBET 的說明</note> # 05/20
		# <note n="0272c0301" resp="CBETA.maha" type="add">...
	    if($lines2[$index2] =~ /^<note[^>]*?resp="CBETA\S*?"[^>]*?>.*?<\/note>/)			
	    {
		    #$lines2[$index2] =~ s/^(^<note resp="CBETA\S*?">.*?<\/note>)//;
			#$tagbuff .= $1;
			
			my $note = "";
			($lines2[$index2], $note) = get_all_note($lines2[$index2]);
			$tagbuff .= $note;

			next;
	    }
	    # <note type="cf1">K19n0652_p0175c15</note>
	    if($lines2[$index2] =~ /^<note type="cf\d">.*?<\/note>/)			
	    {
		    #$lines2[$index2] =~ s/^(^<note type="cf\d">.*?<\/note>)//;
			#$tagbuff .= $1;
			
			my $note = "";
			($lines2[$index2], $note) = get_all_note($lines2[$index2]);
			$tagbuff .= $note;

			next;
	    }
		# <cb:mulu level="1" n="3" type="品">2 方便品</cb:mulu>
	    if($lines2[$index2] =~ /^<cb:mulu .*?<\/cb:mulu>/)			
	    {
		    $lines2[$index2] =~ s/^(<cb:mulu .*?<\/cb:mulu>)//;
			$tagbuff .= $1;
			next;
	    }	    
	    
	    # 上面的順序要在前
	    # 底下這筆的順序要在後
	    
		if($lines2[$index2] =~ /^<note.*?>/ or $lines2[$index2] =~ /^<\/note>/)
		{
			last;
		}
	
		if($lines2[$index2] =~ /^<anchor.*?>/ or $lines2[$index2] =~ /^<app[^>]*type="star"[^>]*>/)
		{
			last;
		}
		
		#if($lines2[$index2] =~ /^<p[^>]*?cb:place="inline"[^>]*?>/)
		#{
		#	last;
		#}
		
		if($lines2[$index2] =~ /^<figure.*?>.*?<\/figure>/)
		{
			last;
		}
		# 某些 <g> 是標點, 要先處理
		
		# <g ref="#SD-D953"/> = …
		# <g ref="#SD-E35A"/> = （
		# <g ref="#SD-E35B"/> = ）
		
		if($lines2[$index2] =~ /^<g ref="#SD\-(D953|E35A|E35B)"\/>/)
		{
			$lines2[$index2] =~ s/^(<g ref="#SD\-(D953|E35A|E35B)"\/>)//;
			$tagbuff .= $1;
			$hasdot2 .= $1;
			next;
		}

		if($lines2[$index2] =~ /^<g .*?>/)
		{
			last;
		}
	
		if($lines2[$index2] =~ /^<cb:tt>/)
		{
		    $lines2[$index2] =~ s/^(<cb:tt>)//;
			$tagbuff .= $1;
			if($istt == 0)
			{
			    $istt = 1;	# 註:這一版是暫時移除梵漢對照, 應該是 $istt = 1;
			}
			next;
		}
		
		if($lines2[$index2] =~ /^<cb:t xml:lang="sa-Sidd">/)
		{
		    $whicht = 1;
		    $lines2[$index2] =~ s/^(<cb:t xml:lang="sa-Sidd">)//;
			$tagbuff .= $1;
			next;
		}
		if($lines2[$index2] =~ /^<cb:t xml:lang="zh-Hant">/)
		{
		    $whicht = 2;
		    $lines2[$index2] =~ s/^(<cb:t xml:lang="zh-Hant">)//;
			$tagbuff .= $1;
			next;
		}
		
		if($lines2[$index2] =~ /^<cb:sg.*?>/)
		{
			last;
		}
		if($lines2[$index2] =~ /^<\/cb:sg>/)
		{
			last;
		}
		
		if($lines2[$index2] =~ /^<!\-\- <[ouwsa]> \-\->/)
		{
		    $lines2[$index2] =~ s/^(<!\-\- <[ouwsa]> \-\->)//;
			$tagbuff .= $1;
			next;
		}

		if($lines2[$index2] =~ /^<unclear\/>/)
		{
			last;
		}
		
		# ----- 需要處理的標記在放在此之前

		if($lines2[$index2] =~ /^<.*?>/)
		{
			$lines2[$index2] =~ s/^(<.*?>)//;
			$tagbuff .= $1;
			next;
		}

		if($lines2[$index2] =~ /^　/)
		{
			$lines2[$index2] =~ s/^(　)//;
			$tagbuff .= $1;
			next;
		}
		
		if($lines2[$index2] =~ /^&lac;/)
		{
			$lines2[$index2] =~ s/^(&lac;)//;
			$tagbuff .= $1;
			next;
		}

		if($lines2[$index2] =~ /^。/)
		{
			$lines2[$index2] =~ s/^(。)//;
			$tagbuff .= $1;
			$hasdot2 .= "。";
			next;
		}

		if($lines2[$index2] =~ /^．/)
		{
			$lines2[$index2] =~ s/^(．)//;
			$tagbuff .= $1;
			$hasdot2 .= "．";
			next;
		}
		
		if($lines2[$index2] =~ /^（/)
		{
			$lines2[$index2] =~ s/^(（)//;
			$tagbuff .= $1;
			$hasdot2 .= "（";
			next;
		}
		
		if($lines2[$index2] =~ /^）/)
		{
			$lines2[$index2] =~ s/^(）)//;
			$tagbuff .= $1;
			$hasdot2 .= "）";
			next;
		}
		
		# 上面是只處理舊標的版本, 底下是新標也要處理
		if($lines2[$index2] =~ /^((?:。)|(?:、)|(?:，)|(?:．)|(?:；)|(?:：)|(?:「)|(?:」)|(?:『)|(?:』)|(?:（)|(?:）)|(?:？)|(?:！)|(?:—)|(?:…)|(?:《)|(?:》)|(?:〈)|(?:〉)|(?:“)|(?:”)|(?:★))/)
		{
			$lines2[$index2] =~ s/^((?:。)|(?:、)|(?:，)|(?:．)|(?:；)|(?:：)|(?:「)|(?:」)|(?:『)|(?:』)|(?:（)|(?:）)|(?:？)|(?:！)|(?:—)|(?:…)|(?:《)|(?:》)|(?:〈)|(?:〉)|(?:“)|(?:”)|(?:★))//;
			$tagbuff .= $1;
			$hasdot2 .= $1;
			next;
		}		
		
		if($lines2[$index2] =~ /^\x0d/)
		{
			$lines2[$index2] =~ s/^(\x0d)//;
			$tagbuff .= $1;
			next;
		}

		last;
	}
	
	$_ = $lines2[$index2];
	
	# 取行首  X79n1563_p0657a09_##

	if(/^<lb.*?\/>/)
	{
		$lines2[$index2] =~ s/^(<lb.*?\/>)//;
		if($istt == 2 and $index1 < $#lines1)
		{
		    # 把第二行還原
		    $lines1[$index1+1] =~ s/^(.*?)([A-Z]+\d+n.{5}p.{7}.{3})/$2$1/;
		}
		$istt = 0;
		return "$1";
	}
	
	# <note n="0150001" resp="Taisho" type="orig" place="foot text">西天譯經三藏＝宋【明】</note>
	# if(/^<note[^>]*?resp="Taisho"[^>]*?>[^<]*?<\/note>/)
	# 不能用上面的, 因為 <note> 標記中會有 <g ref..> 這種缺字標記, 要改用如下:
	if(/^<note[^>]*?type="orig"[^>]*?>.*?<\/note>/)			
	{
		#$lines2[$index2] =~ s/^(<note[^>]*?type="orig"[^>]*?>.*?<\/note>)//;
		
		my $note = "";
		($lines2[$index2], $note) = get_all_note($lines2[$index2]);

		return $note;
	}

	if(/^<note.*?>/)			# <note place="inline">...</note>
	{
		$lines2[$index2] =~ s/^(<note.*?>)//;
		return $1;
	}
	if(/^<\/note>/)				# <note place="inline">...</note>
	{
		$lines2[$index2] =~ s/^(<\/note>)//;
		return $1;
	}
	if(/^<anchor.*?>/)
	{
		$lines2[$index2] =~ s/^(<anchor.*?>)//;
		return $1;
	}
	if(/^<app[^>]*type="star"[^>]*>/)
	{
		$lines2[$index2] =~ s/^(<app[^>]*type="star"[^>]*>)//;
		return $1;
	}
	
	#if(/^<p[^>]*?cb:place="inline"[^>]*?>/)
	#{
	#	$lines2[$index2] =~ s/^(<p[^>]*?cb:place="inline"[^>]*?>)//;
	#	return "$1";
	#}
	# p4 版缺字
	if(/^&((CB)|(CI)|(M)|(SD)).*?;/)		# 缺字
	{
		$lines2[$index2] =~ s/^(&((CB)|(CI)|(M)|(SD)).*?;)//;
		return "$1";
	}
	# P5 版缺字 <g ref="#CB02436"/> , 悉曇字 <g ref="#SD-ABA6"/>
	if(/^<g ref="#((CB)|(SD)|(RJ)).*?"\/>/)		# 缺字
	{
		$lines2[$index2] =~ s/^(<g ref="#((CB)|(SD)|(RJ)).*?"\/>)//;
		return "$1";
	}
	
	if(/^&unrec;/)		# 模糊字
	{
		$lines2[$index2] =~ s/^(&unrec;)//;
		return "$1";
	}
	if(/^&.((macron)|(dotblw)|(dotabv)|(tilde)|(acute));/)		# 巴利文
	{
		$lines2[$index2] =~ s/^(&.((macron)|(dotblw)|(dotabv)|(tilde)|(acute));)//;
		return "$1";
	}
	if(/^<figure.*?>.*?<\/figure>/)		# 圖
	{
		$lines2[$index2] =~ s/^(<figure.*?>.*?<\/figure>)//;
		return "$1";
	}
	if(/^<cb:sg.*?>/)		# <cb:sg>
	{
		$lines2[$index2] =~ s/^(<cb:sg.*?>)//;
		return "$1";
	}
	if(/^<\/cb:sg>/)		# <cb:sg>
	{
		$lines2[$index2] =~ s/^(<\/cb:sg>)//;
		return "$1";
	}
	
	if(/^\[＊\]/)		# <app><lem resp="CBETA.say"></lem><rdg wit="【大】">[＊]</rdg></app>
	{
		$lines2[$index2] =~ s/^(\[＊\])//;
		return "$1";
	}	
	if(/^\[\d+[A-Za-z]?]/)		# T01n0026 : <lb n="0433a23"/>....rdg wit="【大】">[11]</rdg></app>
	{
		$lines2[$index2] =~ s/^(\[\d+[A-Za-z]?\])//;
		return "$1";
	}
	if(/^<unclear\/>/)     # 模糊字
	{
		$lines2[$index2] =~ s/^(<unclear\/>)//;
		return "$1";
	}
	if(/^$utf8/)			# 一般字
	{
		$lines2[$index2] =~ s/^($utf8)//;
		return "$1";
	}
}

################################################################
# 判斷二者是否相同
################################################################

sub check_2_word
{
	my $word1 = shift;
	my $word2 = shift;
	
	if($debug)
	{
		print Encode::encode("big5","word1 : $word1  word2 : $word2\n");
	}
	
	if($word1 eq $word2) { return 1; }
	
	# 檢查是不是行首
	
	if($word2 =~ /<lb/ and $word2 =~ /$word1/) { return 1; }
	if($word2 =~ /&CB.*?;/ and $word1 =~ /\[/) { return 1; }		# P4 版缺字, 待判斷
	if($word2 =~ /<g ref="#CB\d{5}"\/>/ and $word1 =~ /\[/) { return 1; }		# P5 版缺字, 待判斷	
	if($word2 =~ /<g ref="#CB\d{5}"\/>/ and $word1 =~ /./) { return 1; }	# BM 可能是unicode
	if($word2 =~ /&unrec;/ and $word1 =~ /□/) { return 1; }		# 模糊字
	
	if($word2 =~ /&SD.*?;/ and $word1 =~ /◇/) { return 1; }		# P4 悉曇字
	if($word2 =~ /<g ref="#((SD)|(RJ)).*?"\/>/ and $word1 =~ /◇/) { return 1; }		# P5 悉曇字
	
	if($word2 =~ /<g ref="#SD\-D953"\/>/ and $word1 =~ /…/) { return 1; }		# 悉曇字
	if($word2 =~ /<g ref="#SD\-E35A"\/>/ and $word1 =~ /（/) { return 1; }	# 悉曇字
	if($word2 =~ /<g ref="#SD\-E35B"\/>/ and $word1 =~ /\Q）\E/) { return 1; }	# 悉曇字
	if($word2 =~ /<g ref="#SD\-E347"\/>/ and $word1 =~ /\Q□\E/) { return 1; }	# 悉曇字
	
	if($word2 =~ /&SD\-D953;/ and $word1 =~ /…/) { return 1; }		# 悉曇字
	if($word2 =~ /&SD\-E35A;/ and $word1 =~ /（/) { return 1; }	# 悉曇字
	if($word2 =~ /&SD\-E35B;/ and $word1 =~ /\Q）\E/) { return 1; }	# 悉曇字
	if($word2 =~ /&SD\-E347;/ and $word1 =~ /\Q□\E/) { return 1; }	# 悉曇字
	
	
	if($word2 =~ /&CI.*?;/ and $word1 eq "&CIxxx;")		# 通用詞
	{
		return 1;
	}
	
	if($word2 =~ /&M.*?;/ and $word1 =~ /(恒)|(墻)|(裏)|(碁)|(銹)|(嫺)|(粧)/)		# 缺字, 待判斷
	{
		return 1;
	}
	
	if($word2 =~ /<note[^>]*?resp="Taisho"[^>]*?>.*?<\/note>/ and $word1 =~ /\[((\d+[A-Za-z]?)|(＊))\]/)
	{
		return 1;
	}	
	
	if($word2 =~ /<anchor.*?>/ and $word1 =~ /\[((\d+[A-Za-z]?)|(＊))\]/)
	{
		return 1;
	}	
	
	if($word2 eq "<anchor type=\"◎\"/>" and $word1 eq "◎") # p4 雙圈
	{
		return 1;
	}
	if($word2 eq "<anchor type=\"circle\"/>" and $word1 eq "◎") # p5 雙圈
	{
		return 1;
	}
	
	if($word2 =~ /<app[^>]*type="star"[^>]*>/ and $word1 =~ /\[＊\]/)
	{
		return 1;
	}
	
	if($word2 =~ /<note.*?>/ and $word1 eq "(")
	{
		return 1;
	}
	
	if($word2 eq "</note>" and $word1 eq ")")
	{
		return 1;
	}
	
	if($word2 =~ /<cb:sg.*?>/ and $word1 eq "(")
	{
		return 1;
	}
	
	if($word2 eq "</cb:sg>" and $word1 eq ")")
	{
		return 1;
	}
	
	#if($word2 =~ /<p[^>]*?cb:place="inline"[^>]*?>/ and $word1 eq "Ｐ")
	#{
	#	return 1;
	#}

	if($word2 =~ /<figure.*?>.*?<\/figure>/ and $word1 eq "【圖】")
	{
		return 1;
	}	

	return 0;
}

# 把傳入的資料推入 @lines , 若有換行就要處理
sub printout
{
	local $_ = shift;

	while(/^(.*?\n)(.*)/s)
	{
		$lines3[$index3] .= $1;
		$index3++;
		$_ = $2;
	}
	$lines3[$index3] .= $_;
}

# 將行首的 </p> 移到前一行行尾

sub mv_endtag_to_pre_line
{
	for(my $i=1; $i<=$#lines3; $i++)
	{
		if($lines3[$i] =~ /^<[lp]b[^>]*?>(<\/((p)|(item)|(list)|(cb:div))>)/)
		{
			my $tag = $1;
			$lines3[$i-1] =~ s/\n/$tag\n/;
			$lines3[$i] =~ s/^(<[lp]b[^>]*?>)(<\/((p)|(item)|(list)|(cb:div))>)/$1/;
			$i = $i - 2;
			if($i < 0) {$i = 0;}
		}
	}
}

# 將行首下引號移到前一行行尾的 </p> 之前
# .........</cb:t></cb:tt></p>
# <lb n="0254a26" ed="T"/>」
# 變成
# .........</cb:t></cb:tt>」</p>
# <lb n="0254a26" ed="T"/>
sub mv_under_quotes_to_pre_line
{
	for(my $i=1; $i<=$#lines3; $i++)
	{
		if($lines3[$i] =~ /^<[lp]b[^>]*?>」/)
		{
			if($lines3[$i-1] =~ /<\/p>(<\/cb:div>)?$/)
			{
				$lines3[$i-1] =~ s/(<\/p>(<\/cb:div>)?)$/」$1/;
				$lines3[$i] =~ s/^(<[lp]b[^>]*?>)」/$1/;
				$i = $i - 1;
				if($i < 0) {$i = 0;}
			} 
			elsif ($lines3[$i-1] =~ /^<pb/ && $lines3[$i-2] =~ /<\/p>(<\/cb:div>)?$/)
			{
				$lines3[$i-2] =~ s/(<\/p>(<\/cb:div>)?)$/」$1/;
				$lines3[$i] =~ s/^(<[lp]b[^>]*?>)」/$1/;
				$i = $i - 1;
				if($i < 0) {$i = 0;}
			}
		}
	}
}

# 傳入字串, 把全部的 note 取出, 尤其是中間會包 note
# <note n="0603c2001" resp="CBETA" type="add"><note place="inline">誦三遍</note>【CB】，誦三遍【大】</note>

sub get_all_note
{
	local $_ = shift;
	my $note = "";
	my $notecount = 0;

	while($_)
	{
		if(/^<note [^>]*>/)
		{
			s/^(<note [^>]*>)//;
			$note .= $1;
			$notecount++;
		}
		elsif(/^<\/note>/)
		{
			s/^(<\/note>)//;
			$note .= $1;
			$notecount--;
			last if($notecount == 0);
		}
		elsif(/^<.*?>/)
		{
			s/^(<[^>]*>)//;
			$note .= $1;
		}
		elsif(/^[^<]*/)
		{
			s/^([^<]*)//;
			$note .= $1;
		}
		else
		{
			$note .= $_;
			$_ = "";
		}
	}

	return ($_, $note);
}