
# 將中文字加入至圖檔中, 做出 ePub 電子書的封面
# 若希望強迫斷行的文字, 請加入 //
# 例如經名是 "特賜興禪大燈國師參詳語要" , 結果斷為
#     特賜興禪大燈國師參
#           詳語要
# 希望它整齊, 因此經名設為 "特賜興禪大燈國師//參詳語要", 斷行就變成
#     特賜興禪大燈國師
#         參詳語要
# 或是剛好有一個字折到第二行, 卻不希望它折行, 就在最後加上 // 即可.

use utf8;
use GD;

# 參數

my $db_file = "database_update8.txt";	# 經名資料庫
#my $cover_page_path = "c:/release/epub_cover_ud3/";	# 輸出圖檔的目錄
my $cover_page_path = "./cover_update8/";	# 輸出圖檔的目錄
#my $cover_page_path2 = "./cover/";	# 檢查結果用的
my $cover_page_path2 = "./cover_update8/";	# 檢查結果用的

my $font_size_title = 55;				# 經名字體大小 (python 的大小好像是 px, 這裡好像是 pt)
my $font_size_small = 30;				# 譯者字體大小 (python 的大小好像是 px, 這裡好像是 pt)
my $font_size_byline = 30;				# 譯者字體大小 (python 的大小好像是 px, 這裡好像是 pt)
my $byline_space = 0;				# 經名與譯者的距離
my $int_y = 220; 					# 經名的最初高度 (python 是以字的上方為參考, perl 是以文字下方為參考座標)

#################
# 主程式
#################

mkdir($cover_page_path);
mkdir($cover_page_path2);

read_tripitaka_db();	# 讀入各經資料

#################

# 讀入資料庫
sub read_tripitaka_db
{
	open IN, "<:utf8", $db_file or die "open $db_file error";
	while(<IN>)
	{
		next if(/^[;#]/);	# 若用 ; 或 # 開頭的表示為註解, 不理它
		
		# N01,N01n0001,N0001,經分別(第1卷-第4卷),(4卷),通妙譯
		# N01,N01n0001,N0001,經分別(第1卷-第4卷),(4卷),通妙譯, A097-098n1276		(有跨冊的 id 就放在最後)
		my ($vol, $sutra_id, $sutra_num, $sutra_name, $sub_name, $juan, $byline, $sutra_id2) = split(/,/,$_);
		
		my $ed = $vol;
		$ed =~ s/\d+//g;	# $ed = "T"
		
		# 主要圖檔的檔名
		
		# 這裡產生的檔名是 cover_path/T01/T01n0001/cover.jpg
		#my $cover = $cover_page_path . $vol . "/";
		#mkdir($cover);
		#$cover = $cover . $sutra_id . "/";
		#mkdir($cover);
		#$cover = $cover . "cover.jpg";
		
		# 這裡產生的檔名是 cover_path/T/T0001.jpg
		my $cover = $cover_page_path . $ed . "/";
		mkdir($cover);
		$cover = $cover . "$sutra_num.jpg";		
		
		# 檢查用的圖檔, 主要是輸出在同一目錄, 方便檢查
		
		my $cover2 = $cover_page_path2 . $sutra_num . ".jpg";
		
		# 卷數前加空白比較好看
		$juan =~ s/^\((.*)\)$/( $1 )/;
		
		if($sutra_id2) {$sutra_id = $sutra_id2;}
		draw_picture($sutra_id, $sutra_name, $sub_name, $juan, $byline, $cover, $cover2);
	}
	close IN;
}


# 畫一張圖
sub draw_picture
{
	local $_;
	my ($sutra_id, $sutra_name, $sub_name, $juan, $byline, $cover, $cover2) = @_;
	
	my $image = GD::Image->newFromJpeg("default.jpg", 1);	# 1 表示為 TrueColor

	my $font = "./li.ttc";	# 指定字型


	# 將各字串畫出來, 傳回的 $y 是下一行的建議值
	my $y = $int_y;
	$y = draw_chinese ($image, $y, $sutra_id, $font_size_small, $font);	# 印出經號
	$y += 10;
	$y = draw_chinese ($image, $y, $sutra_name, $font_size_title, $font);	# 印出經名
	if($sub_name)
	{
		$y = draw_chinese ($image, $y, $sub_name, $font_size_small, $font);	# 印出副經名
	}
	$y += 20;
	$y = draw_chinese ($image, $y, $juan, $font_size_small, $font);	# 印出卷數
	$y += $byline_space;
	draw_chinese ($image, $y, $byline, $font_size_byline, $font);	# 印出譯者
	
	# 將圖檔輸出
	
	print "output $cover \n";
	open OUT, ">$cover";
	binmode OUT;
	print OUT $image->jpeg(75);
	close OUT;
	
	open OUT, ">$cover2";
	binmode OUT;
	print OUT $image->jpeg(75);
	close OUT;
}

# 畫中文字, 傳入 y 座標, 字串, 字體大小, 字型
sub draw_chinese
{
	my ($image, $y, $str, $font_size, $font) = @_;
	
	my $black = $image->colorAllocate(0,0,0);				# 黑色
	my $str1 = $str;										# str1 全部要畫的字	
	my $max_word = int((600 - 140) / $font_size );			# 每行最多的字數 , 圖檔寛度為 600 , 預計左右各留 70 

	while ($str1)
	{
		# 如果傳入的字串有 // 符號, 就以它來分隔, 否則就計算長度
		if (length($str1) > $max_word)
		{	
			if($str1 =~ /^(.*?)\/\/(.*)/)
			{
				$str2 = $1;
				$str1 = $2;
			}
			else
			{
				$str2 = substr($str1,0,$max_word);		# str2 目前這行要畫的字
				$str1 = substr($str1,$max_word);
			}
		}
		else
		{
			if($str1 =~ /^(.*?)\/\/(.*)/)
			{
				$str2 = $1;
				$str1 = $2;
			}
			else
			{
				$str2 = $str1;
				$str1 = "";
			}
		}
		
		my $real_font_size = $font_size * 3/4;
		
		# @bounds[0,1]  Lower left corner (x,y)
		# @bounds[2,3]  Lower right corner (x,y)
 		# @bounds[4,5]  Upper right corner (x,y)
		# @bounds[6,7]  Upper left corner (x,y)
		
		@bounds = GD::Image->stringFT($black, $font, $real_font_size, 0, 0, $y, $str2);

		$width = $bounds[2] - $bounds[0];		# 實際文字的寬度
		$x = int ( (600 - $width) / 2 );	# 算出實際要印字的 X 座標

		$image->stringFT($black, $font, $real_font_size, 0, $x, $y + $real_font_size, $str2);
		$image->stringFT($black, $font, $real_font_size, 0, $x + 1, $y + $real_font_size, $str2);
		
		$y += $font_size * 1.5;
	}
	return $y;
}
