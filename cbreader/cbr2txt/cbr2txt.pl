#############################################
# 將 cbr 產生的 html 檔轉成文字檔
# 沒有校勘, 有行首, 依原書, 悉曇及蘭札用 &SD-XXXX; 碼
# 缺字順序: 通用, 組字
# 只用修訂的字
#############################################

use utf8;

my $vol = shift;	# T01
my $ed = $vol;
$ed =~ s/\d//g;	# T

exit if $vol eq "";

# 來源目錄, 也就是 cbreader 產生的 html 檔目錄
$source_path = "c:/release/cbr_out_201405/";
$outpath = "c:/release/cbr_out_txt_201405/";

mkdir($outpath);
$outpath = $outpath . $ed . "/";
mkdir($outpath);
$outpath = $outpath . $vol . "/";
mkdir($outpath);

$filename = "$source_path${vol}/*.htm";
@files = <${filename}>;

foreach $file (sort(@files))
{
	my $outfile = $file;
	$outfile =~ s/.*[\/\\](.*?)\.htm/$1.txt/;
	
	if($outfile !~ /_/)
	{
		$outfile =~ s/(\d\d\d.txt)/_$1/;	# 檔名 T0128a001.txt 改成 T0128a_001.txt
	}
	
	$outfile = $outpath . $ed . $outfile;
	print $outfile . "\n";
	
	open(IN, "<:encoding(big5)", $file);
	open(OUT, ">:utf8", $outfile);
	h2t();
	close IN;
	close OUT;
}

###########################

sub h2t()
{
	local $_;
	
	while(<IN>)
	{
		next unless (/^name="\d{4}.\d\d"/);

		# name="0016b19" id="0016b19"><span class="linehead">T01n0001_p0016b19║</span>
		# 去頭去尾
		
		s/彞/彝/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		s/〹/卄/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		
		s/^name=.*?>//;
		s/<a \n//;
		s/＆lac；//g;
		s/<p>　<span class="lg">/\n\n　/g;
		s/<p><span class="lg">/\n\n/g;
		s/<p.*?>/\n\n　　/g;
		
		s#<span class="corr">(.*?)</span>#$1#g;		# 因為標記有巢狀, 所以要先處理
		#s/<img src="[^>]*\\([^>]*gif)">/:1:figure entity="$1"\/:2:/g; 	# <img src="C:\cbeta\CBReader\Figures\T\T18014601.gif">
		s/<img src="[^>]*\\([^>]*gif)">/【圖】/g; 	# <img src="C:\cbeta\CBReader\Figures\T\T18014601.gif">
		s/<br>/\n/g;
		s/<[^<]*?>//g;		# 去標記
		s/<[^<]*?>//g;		# 去標記
		s/<[^<]*?>//g;		# 去標記
		
		s/:1:fig/<fig/g;
		s/"\/:2:/"\/>/g;
		s/&#X(.*?);/chr(hex($1))/ge;
		s/　//g;						 # 忽略全部全型空白
		s/◇{2,}/【◇】/g;	# 國圖
		s/^ZW/W/;			# 藏外
		s/^ZS/H/;			# 正史
		#s/◎//g;			# 不要忽略, 非大正藏有很多這類符號
		s/║ */║/;
		if($ed eq "N")
		{
			s/\[(\d+)\-\d\]/[$1]/g;	# 南傳校勘
			s/\[P.(\d+)\]/ $1/;	# 南傳校勘
		}
		if($ed eq "X")
		{
			s/\[(\d[a-z])\]/[0$1]/ig;	# 卍續藏校勘
			s/\[(((科)|(標)|(解))\d\d)\]/【$1】/g;	# 卍續藏校勘
		}
		s/\[(\d)\]/[0$1]/g;	# 校勘
		print OUT;
	}
}