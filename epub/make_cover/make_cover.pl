
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
use Encode;

my $input = shift;

# 參數

my $db_file = "database_2023Q4.txt";	# 經名資料庫
$db_file = "database_2023Q4_twoline.txt";	# 經名資料庫，這是多行版本
$db_file = "database_2023Q4_newname.txt";	# 經名資料庫，這是特定經名
$db_file = "database_2023Q4_nonebig5_kai.txt";	# 經名資料庫，這是非 big5 的版本，楷書可用
$db_file = "database_2023Q4_nonebig5.txt";	# 經名資料庫，這是非 big5 的版本

$db_file = "database_2024R1_update.txt";	# 經名資料庫
$db_file = "database_2024R2.txt";	# 經名資料庫
$db_file = "database_2024R3.txt";	# 經名資料庫
$db_file = "database_2025R1.txt";	# 經名資料庫

my $db_check_file = "database_2025R1_check.txt";	# 要檢查的資料
#my $cover_page_path = "c:/release/epub_cover_ud3/";	# 輸出圖檔的目錄
my $cover_page_path = "./cover_update_2025R1/";	# 輸出圖檔的目錄
#my $cover_page_path2 = "./cover/";	# 檢查結果用的
my $cover_page_path2 = "./cover_update_2025R1/";	# 檢查結果用的


#$db_file = "database_update.txt";	# 經名資料庫
#$cover_page_path = "./cover_update/";	# 輸出圖檔的目錄
#$cover_page_path2 = "./cover_update/";	# 檢查結果用的

my $font_size_title = 55;			# 經名字體大小, 預設 55，太長就 40 (python 的大小好像是 px, 這裡好像是 pt)
my $ok_font_size_title = 55;
my $font_size_small = 30;				# 譯者字體大小 (python 的大小好像是 px, 這裡好像是 pt)
my $font_size_byline = 30;				# 譯者字體大小 (python 的大小好像是 px, 這裡好像是 pt)
my $byline_space = 0;				# 經名與譯者的距離
my $int_y = 220; 					# 經名的最初高度 (python 是以字的上方為參考, perl 是以文字下方為參考座標)

my $two_line = 0;					# 如果有切成二行，則設為 1
my $has_none_big5 = 0;			# 有 unicode 太高的文字

my @two_line = ();			# 二行以上的資料
my @too_height = ();		# 高度超過 700 的資料
my @none_big5 = ();		# unicode 超過 ext A 的資料
my $orig_line;				# 原始資料

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
		next if($_ !~ /^$input/);
		$orig_line = $_;
		$two_line = 0;
		$has_none_big5 = 0;
		# N01,N01n0001,N0001,經分別(第1卷-第4卷),(4卷),通妙譯
		# N01,N01n0001,N0001,經分別(第1卷-第4卷),(4卷),通妙譯, A097-098n1276		(有跨冊的 id 就放在最後)
		my ($vol, $sutra_id, $sutra_num, $sutra_name, $sub_name, $juan, $byline, $sutra_id2) = split(/,/,$_);

		my $ed = $vol;
		$ed =~ s/\d+//g;	# $ed = "T"
		
		# 經名太長就要縮小字型大小
		$ok_font_size_title = $font_size_title;
		if(length($sutra_name) > 33) {
			$ok_font_size_title = 40;
		}

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

	# 有問題的檔案列在這裡

	open OUT_CHECK, ">:utf8", $db_check_file or die "open $db_file error";
	# 有折行的資料
	print OUT_CHECK "# 有折行的資料\n";
	foreach my $line (@two_line) {
		print OUT_CHECK $line;
	}
	# 有非 Big5 文字
	print OUT_CHECK "# 有非 Big5 文字\n";
	foreach my $line (@none_big5) {
		print OUT_CHECK $line;
	}
	# 高度太高的文字
	print OUT_CHECK "# 高度太高的文字\n";
	foreach my $line (@too_height) {
		print OUT_CHECK $line;
	}

	close OUT_CHECK;
}


# 畫一張圖
sub draw_picture
{
	local $_;
	my ($sutra_id, $sutra_name, $sub_name, $juan, $byline, $cover, $cover2) = @_;
	
	my $image = GD::Image->newFromJpeg("default.jpg", 1);	# 1 表示為 TrueColor

	my $font = "./li.ttc";	# 指定字型
	#$font = "./kaiu.ttf";	# 楷體
	#$font = "./TH-Tshyn-P0.ttf";	# 天衍字庫

	#my $font = "./NotoSansSiddham-Regular.ttf";	# 指定字型


	# 將各字串畫出來, 傳回的 $y 是下一行的建議值
	my $y = $int_y;
	$y = draw_chinese ($image, $y, $sutra_id, $font_size_small, $font);	# 印出經號
	$y += 10;
	$y = draw_chinese ($image, $y, $sutra_name, $ok_font_size_title, $font);	# 印出經名, $ok_font_size_title 會自行調整
	if($sub_name)
	{
		$y = draw_chinese ($image, $y, $sub_name, $font_size_small, $font);	# 印出副經名
	}
	$y += 20;
	$y = draw_chinese ($image, $y, $juan, $font_size_small, $font);	# 印出卷數
	$y += $byline_space;
	$y = draw_chinese ($image, $y, $byline, $font_size_byline, $font);	# 印出譯者
	
	my $height = $y - $font_size_byline * 0.5;
	# 高度超過了
	if($height > 705) {
		#print "Y: $height is too much!";
		push(@too_height, $orig_line);
	}

	# 有切成二行才要檢查
	if($two_line == 1) {	
		push(@two_line, $orig_line);
	}

	# 判斷是不是有非 big5 文字
	$has_none_big5 = find_none_big5($orig_line);
	if($has_none_big5 == 1) {
		push(@none_big5, $orig_line);
	}

	# 將圖檔輸出
	
	print "output $cover \n";
	open OUT, ">$cover";
	binmode OUT;
	print OUT $image->jpeg(75);
	close OUT;
	#if(($two_line == 1) || ($height > 705) || ($has_none_big5 == 1)) {
		open OUT, ">$cover2";
		binmode OUT;
		print OUT $image->jpeg(75);
		close OUT;
	#}
}

sub find_none_big5
{
	local $_ = shift;

	# 這些字要扣除
	
	s/峯//g;
	s/呪//g;
	s/湼//g;
	s/冲//g;
	s/儁//g;
	s/暎//g;
	s/瀞//g;
	s/鉢//g;
	s/畺//g;
	s/迹//g;
	s/韈//g;
	s/攞//g;
	s/瑠//g;
	s/隣//g;
	s/鬪//g;
	s/欝//g;
	s/叶//g;
	s/勅//g;
	s/却//g;
	s/慤//g;
	s/脉//g;
	s/槩//g;
	s/覩//g;
	s/亘//g;
	s/梶//g;
	s/彝//g;
	

	# 嘗試將字串從 UTF-8 轉換到 Big5
	# 判斷是否有非 big5 的字
    eval {
        Encode::encode("big5", $_, Encode::FB_CROAK);
    };

    # 如果有錯誤發生，則表示字串包含非 Big5 的字符
    if ($@) {
		return 1;
    } else {
		return 0;
	}
}

# 畫中文字, 傳入 y 座標, 字串, 字體大小, 字型
sub draw_chinese
{
	my ($image, $y, $str, $font_size, $font) = @_;
	
	my $black = $image->colorAllocate(50,50,50);				# 黑色
	my $str1 = $str;										# str1 全部要畫的字	
	my $max_word = int((600 - 140) / $font_size );			# 每行最多的字數 , 圖檔寛度為 600 , 預計左右各留 70 

	if($str =~ /^[A-Za-z0-9\-]+$/) {
		$max_word = $max_word * 3;	# 經號有 2 倍數字，3 比較安全
	}

	while ($str1)
	{
		# 如果傳入的字串有 // 符號, 就以它來分隔, 否則就計算長度
		if (length($str1) > $max_word)
		{	
			if($str1 =~ /^(.*?)\/\/(.*)/)
			{
				$str2 = $1;
				$str1 = $2;
				if($str1 ne "") {
					$two_line = 1;	# 有切成二行
				}
			}
			else
			{
				$str2 = substr($str1,0,$max_word);		# str2 目前這行要畫的字
				$str1 = substr($str1,$max_word);

				# 第二行只有一個字，就接起來吧
				if(length($str1) == 1) {
					$str2 .= $str1;
					$str1 = "";
				# 如果有二個空格或全型空格，會出現在譯者，也要隔開
				} elsif($str2 =~ /^(.*)(?:(?:  )|(?:　))(.*)/) {
					$str2 = $1;
					$str1 = $2 . $str1;
					$two_line = 1;	# 有切成二行
				} else {
					# 底下是切斷處
					# (嗣法)淨伏、(門人)行佑．德
					# 珍．瓊林 等編
					# 若切斷處都是漢字，而最後一、二字之前有．或)等符號，則由該處切斷，變成
					# (嗣法)淨伏、(門人)行佑．
					# 德珍．瓊林 等編

					if(($str2 =~ /[^． \)]$/) && ($str1 =~ /^[^． \)]/)) {
						if($str2 =~ /.*[．](.{1,2})$/) {
							#print "$str2\n$str1";
							$str2 =~ s/(.*[．])(.{1,2})$/\1/;
							$str1 = $2 . $str1;
							#print "$str2\n$str1";
						}
					}
					$two_line = 1;	# 有切成二行
				}
			}
		}
		else
		{
			if($str1 =~ /^(.*?)\/\/(.*)/)
			{
				$str2 = $1;
				$str1 = $2;
				if($str1 ne "") {
					$two_line = 1;	# 有切成二行
				}
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
