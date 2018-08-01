#############################################
# 將 cbr 產生的 html 檔轉成文字檔給大陸
# 沒有校勘, 沒有行首, 不依原書, 悉曇及蘭札用 unicode 
# 缺字順序: unicode(含 3.1), 組字
# 只用修訂的字
# 執行方式
# perl cb2txt_china.pl T01		T01 冊
# perl cb2txt_china.pl T			T 全部
# perl cb2txt_china.pl			全部
#############################################

use utf8;
use File::Find;
use strict;

# 來源目錄, 也就是 cbreader 產生的 html 檔目錄
my $source_path = "c:/Users/Heaven/AppData/Local/Temp/CBReader/Debug/";
my $outpath_base = "c:/temp/cbr_out_txt_china/";

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
	my $text = "";
	my $title = "";
	
	while(<IN>)
	{
		if(/【經文資訊】(.*?)<br>/)
		{
			$title = $1 . "\n";
			last;
		}
		next unless (/^name=['"]p/);

		# name="0016b19" id="0016b19"><span class="linehead">T01n0001_p0016b19║</span>
		# 去頭去尾
		
		#s/彞/彝/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		#s/〹/卄/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理

		s/^name=.*?>//;
		s/<a \n//;
		s/^<\/a>//;

		s/<p ?[^>]*>　<span class='lg'>/\n\n　/g;
		s/<p ?[^>]*><span class='lg'>/\n\n/g;
		s/<p ?[^>]*>/\n\n　　/g;
		
		s/<span class='juanname'>/\n\n/g;

		#<br class='para_br' data-tagname='br'/>
		s/<br ?[^>]*>/\n/g;

		# 移除校勘
		#<a id="note_mod_0001003" class="note_mod" href="" onclick="return false;">[3]</a>
		s/<a [^>]*display:none[^>]*>\[.*?\]<\/a>//g;

		#<span class='linehead' style='display:none'>T01n0001_p0001c02║</span>
		s/<span [^>]*display:none[^>]*>[^>]*<\/span>//g;

		# <font face="siddam">扣</font>(<span class="nonhan">hā</span>)
		# 悉曇字只留下羅馬轉寫字
		s/<font face=['"]siddam['"]>[^<]*?<\/font>\(<span class=['"]nonhan['"]>([^<]*?)<\/span>\) ?/$1/g;
		s/<font face=['"]Ranjana['"]>[^<]*?<\/font>\(<span class=['"]nonhan['"]>([^<]*?)<\/span>\) ?/$1/g;

	
		# <img src="C:\cbeta\CBReader\Figures\T\T18014601.gif">
		s/<img src=['"][^>]*\\([^>]*gif)['"]>/:1:figure entity="$1"\/:2:/g; 

		s/<[^<]*?>//g;		# 去標記
		s/<[^<]*?>//g;		# 去標記
		s/<[^<]*?>//g;		# 去標記
		
		s/:1:fig/<fig/g;
		s/"\/:2:/"\/>/g;
		s/◇{2,}/【◇】/g;	# 國圖
		s/\[＊\]//g;
		s/\[\d+\]//g;
		
		$text .= $_;
	}
	print OUT $title;
	print OUT $text;
}

