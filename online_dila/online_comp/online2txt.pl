#############################################
# 將 Dila CBETA Online 產生的 html 檔轉成文字檔
# 執行方式
# perl online2txt.pl T T0123	由 T0123 開始
# perl online2txt.pl T			T 全部
# perl online2txt.pl			全部
#############################################

use utf8;
use File::Find;
use strict;

# 來源目錄, 也就是 cbreader 產生的 html 檔目錄
my $source_path = "c:/temp/online_html/";
my $outpath_base = "c:/temp/online_out_txt/";
mkdir($outpath_base);

my $ed = shift;		# T 藏
my $start_sutra = shift;	# T0123 由此經開始

my $vol = "";	# T01 冊數
my $pre_vol = "";	# 前一冊
my $sutranum = "";	# T0001	經號
my $juannum = "";	# 001 卷數
my $text = "";		# 經文內容

if($ed)
{
	$source_path .= $ed . "/";
}
# print $source_path . "\n";
find(\&findfile, $source_path);

sub findfile
{
	return if(-d $_);
	local $_ = $_;
	# print $_ . "\n";				# 檔名
	# print $File::Find::dir . "\n";	# 目錄
	# print $File::Find::name . "\n";	# 完整檔名

	# c:\temp\online_html\T\T0001\001.html
	$File::Find::name =~ /.*[\\\/](\D+\d+.)[\\\/](\d\d\d)\.html/;

	$sutranum = $1;	# T0001
	$juannum = $2;	# 001

	return if($sutranum lt $start_sutra);

	# 處理來源檔
	open IN, "<:utf8", $File::Find::name;
	h2t();
	close IN;

	output();
}

###########################

sub h2t()
{
	local $_;
	my $end = 0;
	while(<IN>)
	{
		last if(/<body>/);
	}
	while(<IN>)
	{
		chomp;
		if(/<div id='back'>/)
		{
			last;
		}
		# 頁碼
		# <pb>0001a</pb>
		s/<pb>.*?<\/pb>//g;

		# 行首
		# <span class="lb" id="T01n0001_p0001a01">T01n0001_p0001a01</span>
		# <span class="lb honorific" id="A098n1276_p0144b08">A098n1276_p0144b08</span>
		s/<span[^>]*class=['"]lb(?: honorific)?['"][^>]*>((.*?)n.*?)<\/span>/\n${1}║/g;
		my $thisvol = $2;
		if($vol eq "" && $thisvol ne "")
		{
			$vol = $thisvol;
		}
		# 校勘數字
		# <a class='noteAnchor' href='#n0001001'></a>
		# <a class='noteAnchor' href='#n0004002-n01'>
		# <a class='noteAnchor' href='#n0272003A'></a>
		s/<a class=['"]noteAnchor['"] href=['"]#n....0?(\d{2,3}[A-Z]?)['"\-].*?><\/a>/[$1]/g;
		
		# 卍續 <a class='noteAnchor' href='#n0600b01' data-label='標01'></a>
		# 卍續 <a class='noteAnchor' href='#n0524k01' data-label='科01'></a>
		# 卍續 <a class='noteAnchor' href='#n0001k03' data-label='科03'></a>

		s/<a class=['"]noteAnchor['"] href=['"]#n....k(\d\d)['"].*?><\/a>/[科$1]/g;
		s/<a class=['"]noteAnchor['"] href=['"]#n....b(\d\d)['"].*?><\/a>/[標$1]/g;
		s/<a class=['"]noteAnchor['"] href=['"]#n....j(\d\d)['"].*?><\/a>/[解$1]/g;
		s/<a class=['"]noteAnchor['"][^>]*data\-label=['"]([科標解]\d+)['"]><\/a>/[$1]/g;
		s/<a class=['"]noteAnchor['"][^>]*data\-label=['"]&#x79D1;(\d+)['"]><\/a>/[科$1]/g;
		
		# 星號
		# <a class='noteAnchor star' href='#n0001004'></a>
		s/<a class=['"]noteAnchor star['"][^>]*><\/a>/[＊]/g;
		
		# 新增校註
		# <a class='noteAnchor add' href='#cb_note_1'></a>
		s/<a class=['"]noteAnchor add['"][^>]*><\/a>/[A]/g;

		# 雙行小註
		# <span class='doube-line-note'>闍尼沙秦言勝結使</span>
		# <span class='interlinear-note'>
		s/<span[^>]*class=['"]doube\-line\-note['"][^>]*>(.*?)<\/span>/($1)/g;
		s/<span[^>]*class=['"]interlinear\-note['"][^>]*>(.*?)<\/span>/($1)/g;
		s/<span[^>]*class=['"]doube\-line\-note['"][^>]*>/(/g;
		s/<span[^>]*class=['"]interlinear\-note['"][^>]*>/(/g;
		# 圖
		# <p class='figure'>
		s/<p class=['"]figure['"]>/【圖】/g;

		# 悉曇
		# <span class='siddam' roman='na' code='SD-A5A9' char=''/>
		# <span class='ranja' roman='oṃ' code='RJ-CCBA' char=''/>
		s/<span[^>]*class=['"]siddam['"][^>]*roman=['"]([^'"]+?)['"][^>]*>/$1/g;
		s/<span[^>]*class=['"]ranja['"][^>]*roman=['"]([^'"]+?)['"][^>]*>/$1/g;
		# 沒有 roman 的要秀出 char 
		# <span class='siddam' roman='' code='SD-D957' char='揨'/>
		s/<span[^>]*class=['"]siddam['"][^>]*char=['"](.+?)['"][^>]*>/$1/g;
		s/<span[^>]*class=['"]ranja['"][^>]*char=['"](.+?)['"][^>]*>/$1/g;

		# 南傳頁碼
		# <span class="hint" data-label="P.1" data-text="PTS.Vin.3.1"></span>
		s/<span class=['"]hint['"] data\-label=['"]P.(\d+)['"][^>]*><\/span>/ $1 /g;

		s/&#x12B;/ī/g;
		s/&#x1E25;/ḥ/g;
		s/&#x1E6D;/ṭ/g;
		s/&#x101;/ā/g;
		s/&#x1E43;/ṃ/g;
		s/&#x16B;/ū/g;
		s/&#x15B;/ś/g;
		s/&#x1E63;/ṣ/g;

		s/<.*?>//g;
		$text .= $_;
	}
}

sub output
{
	local $_;
	my $ed = $vol;	# T01
	$ed =~ s/\d//g;	# T
	
	if($pre_vol ne $vol)
	{
		print "Running " . $vol . "\n";
		$pre_vol = $vol;
	}

	my $outfile = $outpath_base . $ed . "/";	# xxx/T/
	mkdir($outfile);
	$outfile = $outfile . $vol . "/";	# xxx/T/T01/
	mkdir($outfile);
	
	$outfile = $outfile . $sutranum . "_" . $juannum . ".txt";

	$text =~ s/^\n//;
	open OUT, ">:utf8", $outfile;
	print OUT $text;
	close OUT;

	$text = "";
	$vol = "";
}