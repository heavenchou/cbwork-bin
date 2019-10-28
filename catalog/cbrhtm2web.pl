#####################################################################
# CBR HTML to Web 
# 將 CBReader 產生的 HTML 經文檔轉換成 CBETA Tipitaka 網站使用的格式
#
# CBR 輸出時的選項：不依原書(依傳入參數決定), 有頁欄行, 無校勘, 有標點
#                   缺字順利 : 通用字, 組字式, UnicodeEXT (此項等於沒作用)
#                   修訂 : 修訂用字
#                   梵巴悉曇皆用 Unicode
#                   
# 執行方式：
#           cbrhtm2web.pl T01
#####################################################################

use utf8;

my $vol = shift;
my $book_format = shift;	# 若傳入 1 , 則表示原書格式, 沒傳入應該表示一般格式

exit if($vol eq "");

#################################################
# 基本參數
#################################################

my $indir = "c:/release/cbr_out_web";			# 來源目錄
my $outdir = "c:/release/cb_tripitaka_web";		# 輸出目錄

# 這一行表示處理依原書格式的版本
if($book_format)
{
	$indir .= "_line";
	$outdir .= "_line";
}

#################################################
# 主程式
#################################################

my @files = <${indir}/${vol}/*.htm>;

# 產生輸出的目錄

mkdir("$outdir");
mkdir("${outdir}/${vol}");	

for $file (sort(@files))
{
	#next if($file !~ /0475/);	# 只處理這一經
	
	print "Run $file ...\n";
	run_file($file);
}

#################################################
# 處理單一檔案
#################################################

sub run_file
{
	my $file = shift;
	$file =~ /.*[\\\/]((.*?)(\d{3}).htm)/;
	local $_;
	
	my $filename = $1;		# 0001_001.htm
	my $sutranum_ = $2;		# 0001_
	my $sutranum = $2;		# 0001
	my $juannum = $3;		# 001
	$sutranum =~ s/_$//;	# 移除經號後面的 _ 
	
	my $all_text = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><title></title></head>\n";		# 放處理好的檔案
	
	# 處理輸出的目錄及檔名
		
	my $outfile = "${outdir}/${vol}/${vol}n${filename}";	# 輸出檔名

	open IN, "<:encoding(big5)", $file or die "open $file error$!";
	open OUT, ">:utf8", $outfile or die "open $outfile error";
	
	# 先找到 <body> , 
	while(<IN>)
	{
		if(/<body.*?>/)
		{
			$all_text .= $_;
			last;
		}
	}
	
	# 處理其他資料
	
	while(<IN>)
	{
		s/彞/彝/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		s/〹/卄/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		
		# 要用小寫的 x 才行
		s/&#X(.*?);/&#x$1;/g;
		
		# 處理圖檔
		while(/<img /)
		{
			# <img src="C:\CBETA\CBReader\Figures\T\T16p0845_01.gif">
			s/<img src="([^>]*\\figures\\(.*?)\\(.*?))">/<imgimg src=".\/cb_tripitaka_web\/figures\/$2\/$3" alt="$3"\/>/i;	# alt 是必須的
			
			# <img src="C:\CBETA\CBReader\sd-gif\D9\SD-D957.gif">
			s/<img src="([^>]*\\sd\-gif\\(.*?)\\(.*?))">/<imgimg src=".\/cb_tripitaka_web\/sd-gif\/$2\/$3" alt="$3"\/>/i;	# alt 是必須的
			
			# <img src="C:\CBETA\CBReader\rj-gif\E0\RJ-E041.gif">
			s/<img src="([^>]*\\rj\-gif\\(.*?)\\(.*?))">/<imgimg src=".\/cb_tripitaka_web\/rj-gif\/$2\/$3" alt="$3"\/>/i;	# alt 是必須的
		}
		s/<imgimg /<img /g;
		
		s/<input .*//;
		s/<textarea .*?<\/textarea>//;
		s/\(Big5\)/(UTF8)/;
		
		$all_text .= $_;
	}
	
	print OUT $all_text;
	
}

#################################################
# END
#################################################