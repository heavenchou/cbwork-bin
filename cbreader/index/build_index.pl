####################################################
#  建立 Index 全文檢索檔的程式 V2.0 by heaven
# 
# normal : 不要通用字, 不要檔頭, 不要校勘
# utf8 normal 產生的方法:
#
#   1. 用 p5totxt.py 產生 utf8 的 normal 版, 不要檔頭, 不要校勘, 不要通用, 一卷一檔, 悉曇字用 &SD-xxxx;
#      例 : p5totxt.py -a -u -x 1 -z -v T01
#   2. 再用 u8-b5.py 轉成 big5 normal , 不要使用通用字, 非 big5 的字會轉成組字式. 要記得用特別處理過日文的 u8-b5 版本, 日文就會轉成 &#Xxxxx; , 而不是【A】這種無法檢索的拼音.
#      例 : u8-b5_japan.py -s c:/temp/u8 -o c:/temp/u8_to_b5
#
# 2002/09/30 V0.1 陽春版
# 2002/10/09 V0.2 修改 index 的方式
# 2002/11/02 V0.3 這一版是改成以二進位的方式儲存資料, 以便 c 語言程式讀取, 
#                 這一版之後就無法配合 perl  的 search.pl 了
# 2002/11/03 V0.4 改良產生索引的速度, 不會因為大檔而處理太慢了
# 2002/12/03 V0.5 可以處理組字式, 但組字式不是重點, 日後重點是 &CB 碼吧!
# 2003/07/23 V0.6 將資料壓縮, 以省空間
# 2003/11/08 V0.7 遇到缺字時, 同時處理通用字, 組字及 unicode , 也就是一字有三個資料
# 2003/12/14 V0.8 計算字數及時間
# 2004/01/14 V0.9 處理呈現畫面
# 2005/06/29 V1.0 要忽略全型星號, 並且處理通用詞的索引記錄 (通用字, 組字式, unicode 都要記錄)
# 2006/01/06 V1.1 1.修改組字式判斷的方法,用 gaiji-m 裡面的標準組字式 (因為有些字如 [、廾、],沒有+-*/@)
#                 2.處理新標檔,要多忽略一些標點　．、，：；。？！—…「」『』〈〉《》“” （）【】〔〕
#                 3.忽略【圖】
# 2014/03/22 V2.0 1. P5 版
#                 2. 不再使用通用詞
#                 3. unicode 1.1 為基本字集, unicode 1.1 (uni_flag = 1) 以內的字不處理組字式及通用字.
#                 4. 本版是搭配 CBReader V5.1
# 2014/05/08 V2.1 1. 上一版把 nor_uni 當成了 unicode , 因此造成若在 3.0 之內的 nor_uni 都當成基本 unicode , 因此沒有 "組字式" 及 "big5通用字" 的查詢了.
#                 本版修正此 bug . 並且若某字有通用字及通用unicode , 皆列入檢索範圍, 就算某些通用字沒機會呈現(因為其通用unicode是 1.0), 也會被檢索到.
#                 因此最多一個字有四種檢索 : 組字, 通用, unicode, 通用unicode . 但不可能同時出現 unicode 及通用unicode.
#                 2. 本版是搭配 CBReader V5.2
####################################################

use strict;

#---------------------------------------------------
# 參數
#---------------------------------------------------

my $debug = 0;
my $buildlist = "buildlist.txt";

#my $headndexfile = "headindex.ndx";	# 放大索引檔的位置, 它的結構是 "檔案編號_中文(或英文)"
my $preindexfile = "preindex.ndx";		# 放大索引檔的位置, 它的結構是 "檔案編號_中文(或英文)"
my $tmpindexfile = "tmpindex.ndx";		# 暫存性的大索引檔的名字
my $lastindexfile = "main.ndx";			# 大索引檔的名字
my $wordindexfile = "wordindex.ndx";	# word index 的檔名

#---------------------------------------------------
# 變數
#---------------------------------------------------

my $total_word_count = 0;	# 全部的字數
my $total_word_use = 0;		# 全部使用的字數

my @files;				# 檔名

my @head_index;			# 存放 preindex 中每一個檔案的開頭位置
my %preindex;			# 放大索引檔的位置, 它的結構是 "檔案編號_中文(或英文)"
my %one_file_index;		# 單一檔案的索引檔
my %word_index;			# 存放每一個取到的字, 剛開始是判斷是否有此字, 後來是在 last index 的位置

my %word_index_onefile;	# 用來判斷單一檔案中, 出現哪一些字, 以提供 %how_many_file_has 使用
my %how_many_file_has;	# 記錄此字有多少檔案用到. 利用 %word_index_onefile 來處理


my @file_list;
my @file_list_bit;		# 由 @file_list 壓縮而成的
my @word_count;
my @word_pos;
my @sort_word;

# 缺字用的

my %uni;		# 參數是組字式, 傳回 unicode		
my %nor;		# 參數是組字式, 傳回通用字	
my %nor_uni;	# 參數是組字式, 傳回通用 unicode
my %uni_flag; 	# 參數是組字式, 傳回 unicode 是不是在 unicode 1.1 版之內? 1 表示是.	
my %zu;			# 參數是組字式, 傳回 1 表示此字是在 gaiji-m 中的標準組字式 V1.1

# 新式標記的判斷 ．、，：；。？！—…「」『』〈〉《》“” （）【】〔〕
# "║",'　','＊' 這些也加入
my %newsign = (
	"．",1,
	"、",1,
	"，",1,
	"：",1,
	"；",1,
	"。",1,
	"？",1,
	"！",1,
	"—",1,
	"…",1,
	"「",1,
	"」",1,
	"『",1,
	"』",1,
	"〈",1,
	"〉",1,
	"《",1,
	"》",1,
	"“",1,
	"”",1,
	"（",1,
	"）",1,
	"【",1,
	"】",1,
	"〔",1,
	"〕",1,
	'║',1,
	'　',1,
	'＊',1);

local *PREINDEX;
local *TMPINDEX;
local *LASTINDEX;

#---------------------------------------------------
# 常數(patten)
#---------------------------------------------------

my $DEBUG = 1;

my $big5 = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
my $a_word = '(?:\[${big5}+?\])';
my $chinese = '(?:[\x80-\xff][\x00-\xff])';
my $fullspace = '(?:　)';
my $allspace = '(?:(?:　)|\s)';

#---------------------------------------------------
# 通用詞要手動處理
#---------------------------------------------------
# V2.0 P5 沒有通用詞了

#my @CI_Word;
#my @CI_Code;
#my %CI_des;
#my %CI_nor;
#my %CI_uni;

# 底下這一段程式可以由 "產生通用字build.pl" 來產生 "通用字_build.pl" , 未來應該可以整合進來.
#$CI_Word[0] = '礔[石*歷]';
#$CI_Code[0] = '&CI0001-1;&CI0001-2;';
#$CI_des{"&CI0001-1;"} = '礔';
#$CI_nor{"&CI0001-1;"} = '霹';
#$CI_des{"&CI0001-2;"} = '[石*歷]';
#$CI_nor{"&CI0001-2;"} = '靂';
#$CI_uni{"&CI0001-2;"} = '&#X7930;';
#$CI_Word[1] = '[立*令]竮';
#$CI_Code[1] = '&CI0002-1;&CI0002-2;';
#$CI_des{"&CI0002-1;"} = '[立*令]';
#$CI_nor{"&CI0002-1;"} = '伶';
#$CI_uni{"&CI0002-1;"} = '&#X7ADB;';
#$CI_des{"&CI0002-2;"} = '竮';
#$CI_nor{"&CI0002-2;"} = '俜';
#$CI_Word[2] = '髣[髟/弗]';
#$CI_Code[2] = '&CI0003-1;&CI0003-2;';
#$CI_des{"&CI0003-1;"} = '髣';
#$CI_nor{"&CI0003-1;"} = '彷';
#$CI_des{"&CI0003-2;"} = '[髟/弗]';
#$CI_nor{"&CI0003-2;"} = '彿';
#$CI_uni{"&CI0003-2;"} = '&#X9AF4;';
#$CI_Word[3] = '[跍*月]跪';
#$CI_Code[3] = '&CI0004-1;&CI0004-2;';
#$CI_des{"&CI0004-1;"} = '[跍*月]';
#$CI_nor{"&CI0004-1;"} = '胡';
#$CI_uni{"&CI0004-1;"} = '&#X4812;';
#$CI_des{"&CI0004-2;"} = '跪';
#$CI_Word[4] = '搪[打-丁+突]';
#$CI_Code[4] = '&CI0005-1;&CI0005-2;';
#$CI_des{"&CI0005-1;"} = '搪';
#$CI_nor{"&CI0005-1;"} = '唐';
#$CI_des{"&CI0005-2;"} = '[打-丁+突]';
#$CI_nor{"&CI0005-2;"} = '突';
#$CI_uni{"&CI0005-2;"} = '&#X63EC;';
#$CI_Word[5] = '[髟/弗]髣';
#$CI_Code[5] = '&CI0006-1;&CI0006-2;';
#$CI_des{"&CI0006-1;"} = '[髟/弗]';
#$CI_nor{"&CI0006-1;"} = '彿';
#$CI_uni{"&CI0006-1;"} = '&#X9AF4;';
#$CI_des{"&CI0006-2;"} = '髣';
#$CI_nor{"&CI0006-2;"} = '彷';
#$CI_Word[6] = '鴶[亢*鳥]';
#$CI_Code[6] = '&CI0007-1;&CI0007-2;';
#$CI_des{"&CI0007-1;"} = '鴶';
#$CI_nor{"&CI0007-1;"} = '頡';
#$CI_des{"&CI0007-2;"} = '[亢*鳥]';
#$CI_nor{"&CI0007-2;"} = '頏';
#$CI_uni{"&CI0007-2;"} = '&#X4CB3;';
#$CI_Word[7] = '嬰[女*亥]';
#$CI_Code[7] = '&CI0008-1;&CI0008-2;';
#$CI_des{"&CI0008-1;"} = '嬰';
#$CI_des{"&CI0008-2;"} = '[女*亥]';
#$CI_nor{"&CI0008-2;"} = '孩';
#$CI_uni{"&CI0008-2;"} = '&#X59DF;';
#$CI_Word[8] = '[辟/石][石*歷]';
#$CI_Code[8] = '&CI0009-1;&CI0009-2;';
#$CI_des{"&CI0009-1;"} = '[辟/石]';
#$CI_nor{"&CI0009-1;"} = '霹';
#$CI_uni{"&CI0009-1;"} = '&#X7915;';
#$CI_des{"&CI0009-2;"} = '[石*歷]';
#$CI_nor{"&CI0009-2;"} = '靂';
#$CI_uni{"&CI0009-2;"} = '&#X7930;';
#$CI_Word[10] = '[王*頗][王*梨]';
#$CI_Code[10] = '&CI0011-1;&CI0011-2;';
#$CI_des{"&CI0011-1;"} = '[王*頗]';
#$CI_nor{"&CI0011-1;"} = '頗';
#$CI_des{"&CI0011-2;"} = '[王*梨]';
#$CI_nor{"&CI0011-2;"} = '梨';
#$CI_Word[11] = '[仁-二+唐][仁-二+突]';
#$CI_Code[11] = '&CI0012-1;&CI0012-2;';
#$CI_des{"&CI0012-1;"} = '[仁-二+唐]';
#$CI_nor{"&CI0012-1;"} = '唐';
#$CI_uni{"&CI0012-1;"} = '&#X508F;';
#$CI_des{"&CI0012-2;"} = '[仁-二+突]';
#$CI_nor{"&CI0012-2;"} = '突';
#$CI_uni{"&CI0012-2;"} = '&#X202B2;';
#$CI_Word[12] = '髣髣[髟/弗][髟/弗]';
#$CI_Code[12] = '&CI0013-1;&CI0013-2;&CI0013-3;&CI0013-4;';
#$CI_des{"&CI0013-1;"} = '髣';
#$CI_nor{"&CI0013-1;"} = '彷';
#$CI_des{"&CI0013-2;"} = '髣';
#$CI_nor{"&CI0013-2;"} = '彷';
#$CI_des{"&CI0013-3;"} = '[髟/弗]';
#$CI_nor{"&CI0013-3;"} = '彿';
#$CI_uni{"&CI0013-3;"} = '&#X9AF4;';
#$CI_des{"&CI0013-4;"} = '[髟/弗]';
#$CI_nor{"&CI0013-4;"} = '彿';
#$CI_uni{"&CI0013-4;"} = '&#X9AF4;';
#$CI_Word[13] = '[商*鳥][羊*鳥]';
#$CI_Code[13] = '&CI0014-1;&CI0014-2;';
#$CI_des{"&CI0014-1;"} = '[商*鳥]';
#$CI_nor{"&CI0014-1;"} = '商';
#$CI_uni{"&CI0014-1;"} = '&#X2A132;';
#$CI_des{"&CI0014-2;"} = '[羊*鳥]';
#$CI_nor{"&CI0014-2;"} = '羊';
#$CI_uni{"&CI0014-2;"} = '&#X9D39;';

#------------------------------------------------------------------------------
# 主程式
#------------------------------------------------------------------------------

readGaiji();
open_build_list();

open TMPINDEX, ">$tmpindexfile" || die "open $tmpindexfile error!";
binmode TMPINDEX;
open PREINDEX, ">$preindexfile" || die "open $preindexfile error!";

my $time1 = time;
for(my $i=0; $i<=$#files; $i++)
{
	undef %one_file_index;		# 清空
	undef %preindex;
	undef %word_index_onefile;
	
	print "build $files[$i] ... ";
	build_one_file($i);
	count_files_by_word();
	save_one_index($i);
	save_one_preindex($i);
	print "ok\n";
}
close TMPINDEX;
close PREINDEX;

my $time2 = time;
$time2-=$time1;
###########################################

#save_head_index();				# 不用了, 留在記憶體中即可
print "build last index ... ";
my $time3 = time;
build_last_index();
my $time4 = time;
print "ok\n";
$time4-=$time3;

###########################################

print "save word index ... ";
my $time5 = time;
save_word_index();
my $time6 = time;
unlink $preindexfile;		# 刪除暫存檔
unlink $tmpindexfile;		# 刪除暫存檔
print "ok\n\n";
$time6-=$time5;
print "經文總字數 : $total_word_count , 經文使用字數 : $total_word_use 字\n";
print "analysis files time : $time2\n";
print "build index time : $time4\n";
print "save index time : $time6\n";

print "... 任意鍵結束 (any key to exit) ...\n";
<>;

#------------------------------------------------------------------------------

#---------------------------------------------------
# 取出檔名
#---------------------------------------------------

sub open_build_list
{
	local *IN;
	
	open IN, $buildlist || die "open $buildlist error";
	<IN>;
	while(<IN>)
	{
		next if /^#/;
		last if /^<eof>/;
		chomp;
		push(@files, $_);
	}
	close IN;
}

#---------------------------------------------------
# 處理一個檔案
#---------------------------------------------------

sub build_one_file
{
	local $_;
	
	my $filenum = shift;
	my $file = $files[$filenum];
	my $openerr = 0;
	my $indexnum = 0;	# 記錄此字出現的位置
	
	local *IN;
	
	open IN, $file or $openerr = 1;
	if($openerr)
	{
		print " error : $!\n";
		close IN;
		return;
	}
	my @lines = <IN>;
	close IN;
	
	foreach my $line (@lines)
	{
		# V2.0 不處理通用詞了
		# # V1.0 先處理通用詞
		# # 先把通用詞的字逐一變成 &CIxxxx-x;
		# # 再獨立處理它們
		#
		#for(my $i=0; $i<=$#CI_Word; $i++)
		#{
		#	next if ($i==9);
		#	$line =~ s/\Q$CI_Word[$i]\E/$CI_Code[$i]/g;
		#}
		
		# 忽略 【圖】
		
		$line =~ s/【圖】//g;
		
		while($line)
		{
			my $get_word;
			# if($line =~ /^(\[${big5}+?\])/ && $1 =~ /[+\-*\/\@\?]/)		# 組字式
			if($line =~ /^(\[${big5}+?\])/ && $zu{$1} == 1)		# 組字式 V1.1 新的判斷法
			{
				$line =~ s/^(\[${big5}+?\])//;
				$get_word = $1;
			}
			elsif ($line =~ /^(&.*?;)/)		# & 碼, ex. &SD-xxxx;
			{
				$line =~ s/^(&.*?;)//;
				$get_word = $1;
			}
			else
			{
				$line =~ s/^($big5)//;
				$get_word = $1;
			}
			
			if (no_need($get_word)==0)		# 不要處理的字, 例如換行, 句點, 逗點.....
			{
				$indexnum++;
				$total_word_count++;		# 總字數+1
				
				# V2.0 P5 沒有通用詞了
				#
				# # V1.0 處理通用詞, 通用詞的每一個字都變成 &CI...　了
				#
				if($get_word =~ /^&CI/)
				{
					# 因為沒有通用詞了, 所以底下是不會執行了
					
					my $tmp;
					my $ID;
					# CI0003 "<gaiji cb='CBx00662' des='髣[髟/弗]' nor='彷彿' uni="&#X9AE3;&#X9AF4;"

					# #$CI_des{"&CI0003-1;"} = "髣";
					# #$CI_nor{"&CI0003-1;"} = "彷";
					# #$CI_des{"&CI0003-2;"} = "[髟/弗]";
					# #$CI_nor{"&CI0003-2;"} = "彿";
					# #$CI_uni{"&CI0003-2;"} = "&#X9AF4;";
					# 
					# if($CI_des{$get_word})
					# {
					# 	$tmp = $CI_des{$get_word};
					# 	$ID = "${filenum}_$tmp";
					# 	$one_file_index{$ID} .= "$indexnum,";
					# 	$word_index{$tmp} = 1;				# 記錄此字用過;
					# 	$word_index_onefile{$tmp} = 1;		# 記錄此字用過;
					# }
					# if($CI_nor{$get_word})
					# {
					# 	$tmp = $CI_nor{$get_word};
					# 	$ID = "${filenum}_$tmp";
					# 	$one_file_index{$ID} .= "$indexnum,";
					# 	$word_index{$tmp} = 1;				# 記錄此字用過;
					# 	$word_index_onefile{$tmp} = 1;		# 記錄此字用過;
					# }
					# if($CI_uni{$get_word})
					# {
					# 	$tmp = $CI_uni{$get_word};
					# 	$ID = "${filenum}_$tmp";
					# 	$one_file_index{$ID} .= "$indexnum,";
					# 	$word_index{$tmp} = 1;				# 記錄此字用過;
					# 	$word_index_onefile{$tmp} = 1;		# 記錄此字用過;
					# }
				}
				else
				{
					# 若這是組字式且是 unicode 1.1 , 就不用記錄組字式, 等一下會直接記錄其 unicode
					
					if($uni_flag{$get_word} != 1 or $uni{$get_word} eq "")	# uniflag 不是 1 或 沒有 unicode 的 (表示有 nor_uni)
					{
						my $ID = "${filenum}_$get_word";
						$one_file_index{$ID} .= "$indexnum,";
				
						$word_index{$get_word} = 1;				# 記錄此字用過;
						$word_index_onefile{$get_word} = 1;		# 記錄此字用過;
					}
				}
				
				# V0.7 處理缺字
				# V2.0 P5 因為以 unicode 1.1 為基本字集, 因此 unicode 1.1 之內的只記錄 unicode , 沒有通用字, 也沒有組字式
				# 因為 CBReader 只會呈現 unicode, 記錄了也檢索不到.
				
				if($get_word =~ /^\[${big5}+?\]/)
				{
					my $uni = $uni{$get_word};				# 取出 unicode
					my $nor_uni = $nor_uni{$get_word};		# 取出 unicode 通用字
					my $nor = $nor{$get_word};				# 取出通用字
					my $uni_flag = $uni_flag{$get_word};	# 用來判斷此字是不是 unicode 1.1 以內的組字式, 若 1 則表示是
					
					# 有 unicode 
					if($uni)
					{
						$uni = uc("&#x$uni;");			# 變成 &#X.....; 這種 16 進位的格式
						my $ID = "${filenum}_$uni";
						$one_file_index{$ID} .= "$indexnum,";
						
						$word_index{$uni} = 1;				# 記錄此字用過;
						$word_index_onefile{$uni} = 1;		# 記錄此字用過;
					}
					
					# 有通用 unicode
					if($nor_uni)
					{
						$nor_uni = uc("&#x$nor_uni;");			# 變成 &#X.....; 這種 16 進位的格式
						my $ID = "${filenum}_$nor_uni";
						$one_file_index{$ID} .= "$indexnum,";
						
						$word_index{$nor_uni} = 1;				# 記錄此字用過;
						$word_index_onefile{$nor_uni} = 1;		# 記錄此字用過;
					}
					
					# 有通用字就記錄, 除非是標準 unicode V1.1 的範圍內
					if($nor && ($uni_flag != 1 or $uni eq ""))
					{
						my $ID = "${filenum}_$nor";
						$one_file_index{$ID} .= "$indexnum,";
						
						$word_index{$nor} = 1;				# 記錄此字用過;
						$word_index_onefile{$nor} = 1;		# 記錄此字用過;
					}
				}
			}
		}
	}
}

#-----------------------------------------------------------------
# 用來計算某一個字有多少檔案擁有, 例如 "中" 可能有 1000 檔案有此字
#-----------------------------------------------------------------

sub count_files_by_word
{
	local $_;
	
	foreach (keys(%word_index_onefile))
	{
		if($how_many_file_has{$_})
		{
			$how_many_file_has{$_}++;
		}
		else
		{
			$how_many_file_has{$_} = 1;
		}
	}
}

#---------------------------------------------------
# 檢查某個字要不要處理, 不處理就傳回 1 , 否則傳回 0
#---------------------------------------------------

sub no_need
{
	my $word = shift;
	
	return 0 if ($word =~ /&.*?;/);
	
	return 0 if ($zu{$word} == 1);			# 標準組字式
	
	return 1 if ($word !~ /$chinese/);		# 非中文先不處理
	
	#return 1 if (($word eq "。") or ($word eq "．") or ($word eq "║") or 
	#             ($word eq '　') or ($word eq '，') or ($word eq '＊'));
	             
	# 新標
	return 1 if ($newsign{$word} == 1);		# V1.1
	             
	return 0;
}

#---------------------------------------------------
# 將某一檔的 Index 存起來
#---------------------------------------------------

sub save_one_index
{
	foreach my $key (sort(keys(%one_file_index)))
	{
		$preindex{$key} = tell(TMPINDEX);
		#print TMPINDEX "$key : $one_file_index{$key}\n";
		print TMPINDEX "$one_file_index{$key}\n";
	}
}

#---------------------------------------------------
# 將主索引檔的目錄 (pre index) 存起來
#---------------------------------------------------

sub save_one_preindex
{
	my $filenum = shift;

	$head_index[$filenum] = tell(PREINDEX);
	foreach my $key (sort(keys(%preindex)))
	{
		#my $tmp = pack "L" , $preindex{$key};
		print PREINDEX "$key:$preindex{$key}\n";
	}
}

#---------------------------------------------------
# 將所發現的字 (word bank) 存起來
#---------------------------------------------------

sub save_word_index
{
	local *WORD;
	local $_;

	open WORD, ">$wordindexfile" || die "open $wordindexfile error : $!";
	
	my $size = $#sort_word+1;
	print WORD "$size\n";
	for (@sort_word)
	{
		print WORD "$_=$word_index{$_}\n";
	}
	close WORD;
}

#---------------------------------------------------
# 儲存每一個檔案在 preindex 中一開始的位置
#---------------------------------------------------

=begin
sub save_head_index
{
	local *HEAD;
	local $_;
	
	print "save head index ... ";
	open HEAD, ">$headndexfile" || die "open $headndexfile error : $!";
	for my $i (0 .. $#head_index)
	{
		print HEAD "$i : $head_index[$i]\n";
	}
	close HEAD;
	print "ok\n";
}
=end
=cut

#---------------------------------------------------
# 處理最後的 index
#---------------------------------------------------

sub build_last_index
{
	my $line;
	my $offset;
	my $offset2;
	my $ID;
	my $filenum;
	my $word;
	
	# 先開啟大檔
	
	open PREINDEX, "$preindexfile" || die "open $preindexfile error!";
	open TMPINDEX, "$tmpindexfile" || die "open $tmpindexfile error!";
	open LASTINDEX, ">$lastindexfile" || die "open $lastindexfile error!";
	binmode LASTINDEX;
	
	my $file_count_bit;
	$file_count_bit = int (($#head_index + 1) / 32);
	$file_count_bit++ if(($#head_index + 1) % 32);

	@sort_word = sort(keys(%word_index));
	$total_word_use = $#sort_word + 1;
	print "\n經文總字數 : $total_word_count , 經文使用字數 : $total_word_use 字\n";
	print "(底下每行代表處理了 1000 個字)\n";
	
	my $count = 0;
	for $word (@sort_word)		# 每一個字都處理
	{
		$count++;

		if($count % 1000 == 0)
		{
			print "+\n";
		}
		elsif($count % 200 == 0)
		{
			print "+";
		}
		elsif($count % 20 == 0)
		{
			print ".";
		}
		
		$word_index{$word} = tell(LASTINDEX);	# 找到某字在 last index 第一次出現的地方

		@file_list = ();
		@file_list_bit = ();		# 由 @file_list 壓縮而成的
		@word_count = ();
		@word_pos = ();

		#### 先將前面的空間預留下來 #######################################
		
		my $last_index_head = tell(LASTINDEX);
		# 因為一個 int 佔 4 個 byte
		my $tmp_file_list_bit = " " x (4 * ($file_count_bit + $how_many_file_has{$word}));
		print LASTINDEX $tmp_file_list_bit;
		
		###################################################################

		for $filenum (0 .. $#head_index)		# 每一個檔案都去找這一個字
		{
			$offset = $head_index[$filenum];
			seek PREINDEX, $offset, 0;			# 找到某檔
			
			# 這裡可以考慮先將取出來的資料放到某一個變數中, 以增加速度 ????
			
			$line = <PREINDEX>;
			chomp($line);
			# $line 內容類似 1_佛:1000
			($ID, $offset2) = split(/:/, $line);
			$ID =~ /(\d*)_(.*)/;
			my $filenumtmp = $1;
			my $wordtmp = $2;
			if($filenumtmp == $filenum and $wordtmp eq $word)	# 找對了
			{
				$head_index[$filenum] = tell(PREINDEX);		# 取得下一個字的位置
				
				seek TMPINDEX, $offset2, 0;
				$line = <TMPINDEX>;
				#$line =~ s/^.*? : //;

				# print LASTINDEX "$line";
				chomp $line;
				chop $line;
				
				my @tmp_word_pos = split(/,/,$line);
				push(@file_list,1);
				push(@word_count,$#tmp_word_pos+1);
				
				#@word_pos = (@word_pos , @tmp_word_pos);

				# 舊版的 V0.5 ########################################
				#for(0..$#tmp_word_pos)
				#{
				#	my $tmp = pack "L" , $tmp_word_pos[$_];
				#	print LASTINDEX $tmp;
				#}
				# 新版的 V0.6 ########################################
				
				zipint(\@tmp_word_pos);
				
				######################################################
			}
			else
			{
				# 此檔無此字
				push(@file_list,0);
			}
		}
		
		# 印出來
		zip_file_list();
		
		my $last_index_end = tell(LASTINDEX);
		seek LASTINDEX, $last_index_head, 0;
		
		for(0..$#file_list_bit)
		{
			my $tmp = pack "L" , $file_list_bit[$_];
			print LASTINDEX $tmp;
		}

		for(0..$#word_count)
		{
			my $tmp = pack "L" , $word_count[$_];
			print LASTINDEX $tmp;
		}
		
		seek LASTINDEX, $last_index_end, 0;
	}
	
	close TMPINDEX;
	close PREINDEX;
	close LASTINDEX;
}

#---------------------------------------------------
# 壓縮 主要資料
#---------------------------------------------------
sub zipint()
{
	my $oldint = shift;
	my @newint;
	my $result = "";

	push(@newint,$oldint->[0]);
	for(my $i=1; $i<=$#$oldint; $i++)
	{
		push(@newint,$oldint->[$i]-$oldint->[$i-1]);
	}

	for(my $i=0; $i<=$#$oldint; $i++)
	{
		# 1 byte , < 64
		# 2 byte , < 16384
		# 3 byte , < 4194304
	
		my $tmp = $newint[$i];

		if($newint[$i] < 64)
		{
			$tmp += 64;	# 01000000
			$tmp = pack "C" , $tmp;
			$result .= $tmp;
		}
		elsif($newint[$i] < 16384)
		{
			$tmp += 32768;	# 10000000 00000000
			$tmp = pack "L" , $tmp;
			$tmp =~ /(.)(.)../s;
			$result .= "$2$1";
		}
		elsif($newint[$i] < 4194304)
		{
			$tmp += 12582912;	# 11000000 00000000 00000000
			$tmp = pack "L" , $tmp;
			$tmp =~ /(.)(.)(.)./s;
			$result .= "$3$2$1";
		}
		else
		{
			$result .= pack ("C", 0);
			$tmp = pack "L" , $tmp;
			$tmp =~ /(.)(.)(.)(.)/s;
			$result .= "$4$3$2$1";
		}	
	}
	
	print LASTINDEX $result;
}

#---------------------------------------------------
# 壓縮 file list
#---------------------------------------------------

sub zip_file_list()
{
	for(my $i=0; $i<=$#file_list; $i+=32)	# 每次 32 位元
	{
		my $tmp = 0;

		for(my $j=0; $j<32; $j++)
		{
			my $k = $i + $j;
			
			last if ($k > $#file_list);	# 超出範圍了
			if($file_list[$k])
			{
				my $mask = 2 ** $j;
				$tmp = $tmp | $mask;
			}
		}
		push(@file_list_bit, $tmp);
	}
}

#---------------------------------------------------
# 讀取缺字資料
#---------------------------------------------------

sub readGaiji 
{
	use Win32::ODBC;
	my $cb;
	my $zu;
	my $nor;
	my $nor_uni;
	my $uni;
	my $flag;
	my %row;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = $row{"cb"};       # cbeta code

		next if ($cb !~ /^\d+$/);

		$zu    = $row{"des"};		# 組字式
		$nor   = $row{"nor"};		# 通用字
		$uni   = $row{"unicode"};	# unicode
		$nor_uni = "";				# 要先預設為空字串
		if($row{"nor_uni"})
		{
			$nor_uni = $row{"uni"};		# nor_uni
		}
		$flag  = $row{"uni_flag"};	# uni_flag , 1 表示是 unicode 3.0 以內的字 (不含 3.0)

		$uni{$zu} = $uni;
		$nor_uni{$zu} = $nor_uni;
		$nor{$zu} = $nor;
	  	$uni_flag{$zu} = $flag;
	  	$zu{$zu} = 1;
	}
	$db->Close();
	print STDERR "ok\n";
}
#---------------------------------------------------
# The End.
#---------------------------------------------------