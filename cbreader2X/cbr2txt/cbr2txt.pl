#############################################
# 將 cbr 產生的 html 檔轉成文字檔
# CBETA校勘, 有行首, 依原書, 悉曇及蘭札用 unicode
# 缺字順序: 組字
# 執行方式
# perl cb2txt.pl T01		T01 冊
# perl cb2txt.pl T			T 全部
# perl cb2txt.pl			全部
#############################################

use utf8;
use File::Find;
use strict;

# 來源目錄, 也就是 cbreader 產生的 html 檔目錄
my $source_path = "c:/Users/Heaven/AppData/Local/Temp/CBReader/Debug/";
my $outpath_base = "c:/temp/cbr_out_txt/";

my $vol = shift;	# T01
my $ed = $vol;
$ed =~ s/\d//g;	# T

my $file_patten;
if ($vol eq "")
{
	# 無參數, 跑全部
	$file_patten = "${source_path}XML_*.htm";
}
elsif($vol eq $ed)
{
	# 傳入 T , 跑一藏
	$file_patten = "${source_path}XML_${ed}_*.htm";
}
else
{
	# 傳入 T01, 跑一冊
	$file_patten = "${source_path}XML_${ed}_${vol}*.htm";
}

my @files = <${file_patten}>;
mkdir($outpath_base);

foreach my $file (sort(@files))
{
	my $outfile = $file;
	# filename : XML_T_T01_T01n0001_001.xml.htm
	$outfile =~ s/.*_((\D+)\d+)n(.*?_\d\d\d)\.xml\.htm/$2$3.txt/;

	$ed = $2;
	$vol = $1;

	my $outpath = $outpath_base . $ed . "/";
	mkdir($outpath);
	$outpath = $outpath . $vol . "/";
	mkdir($outpath);
		
	$outfile = $outpath . $outfile;
	print $outfile . "\n";
	
	open IN, "<:utf8", $file;
	open OUT, ">:utf8", $outfile;
	h2t();
	close IN;
	close OUT;
}

###########################

sub h2t()
{
	local $_;
	my $end = 0;
	
	while(<IN>)
	{
		next unless (/^name="p/);
		if(/<div[^>]*id=.CollationList./)
		{
			$end = 1;
		}

		#s/彞/彝/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		#s/〹/卄/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理

		# 一般內容
		# name="p0843a24"></a><span class="linehead">T02n0129_p0843a24║</span><span class="line_space"></span><span class="line_space">　　</span><p class="juannum" data-tagname='p'>No. 129 [Nos. 125(30.3), 128, 130]</p><br class="lb_br" data-tagname='br'/><a 
		
		s/^name=.*?>//;
		s/<a \n//;
		s/^<\/a>//;
		s/<br [^>]*?para_br[^>]*>//g;
		s/<br\/?>/\n/g;
		s/<br [^>]*>/\n/g;

		# 移除 CBETA 校勘
		#<a id="note_mod_0001003" class="note_mod" href="" onclick="return false;">[3]</a>

		s/<a [^>]*class=['"]note_mod['"][^>]*>\[.*?\]<\/a>//g;

		# 移除已移除的 [＊]
		s/<a\s[^>]*?class=["']note_star_removed["'][^>]*>\[＊\]<\/a>//g;

		# 移除沒有內容的 [＊]
		#s/<span class=["']note_star["']>\[＊\]<\/span>//g;


		# 段首資訊
		# <span class="parahead">[0001a10] </span>
		s/<span class=['"]parahead['"]>\[.{7}\] <\/span>//g;



		#s/＆lac；//g;
		#s/<p>　<span class="lg">/\n\n　/g;
		#s/<p><span class="lg">/\n\n/g;
		#s/<p.*?>/\n\n　　/g;
		
		#s#<span class="corr">(.*?)</span>#$1#g;		# 因為標記有巢狀, 所以要先處理
		s/<img src=['"][^>]*\\([^>]*gif)['"]>/【圖】/g; 	# <img src="C:\cbeta\CBReader\Figures\T\T18014601.gif">
		
		# <font face="siddam">扣</font>(<span class="nonhan">hā</span>)
		# 悉曇字只留下羅馬轉寫字
		s/<font face=['"]siddam['"]>[^<]*?<\/font>\(<span class=['"]nonhan['"]>([^<]*?)<\/span>\) ?/$1/g;
		s/<font face=['"]Ranjana['"]>[^<]*?<\/font>\(<span class=['"]nonhan['"]>([^<]*?)<\/span>\) ?/$1/g;

		s/<[^<]*?>//g;		# 去標記
		#s/<[^<]*?>//g;		# 去標記
		#s/<[^<]*?>//g;		# 去標記
		
		#s/:1:fig/<fig/g;
		#s/"\/:2:/"\/>/g;
		#s/&#X(.*?);/chr(hex($1))/ge;
		#s/　//g;						 # 忽略全部全型空白
		#s/◇{2,}/【◇】/g;	# 國圖
		#s/║ */║/;
		if($ed eq "N")
		{
			#s/\[(\d+)\-\d\]/[$1]/g;	# 南傳校勘
			s/\[P.(\d+)\]/$1/;	# 南傳校勘
		}
		if($ed eq "X")
		{
			#s/\[(\d[a-z])\]/[0$1]/ig;	# 卍續藏校勘
			#s/\[(((科)|(標)|(解))\d\d)\]/【$1】/g;	# 卍續藏校勘
		}
		s/\[(\d[A-Z]?)\]/[0$1]/g;	# 校勘
		s/\[([科標解])(\d)\]/[${1}0${2}]/g;	# 校勘
		print OUT;

		last if($end);
	}
}