#####################################################################
# 在製作 ePub 電子書的過程中, 因為 toc.ncx 會有重複的經文位置, 也就是不同的目錄指到同一行, 
# 如下的 p0480a16
#
#                <navPoint id="navPoint-5" playOrder="5">
#                    <navLabel>
#                    <text>一切佛語心品</text>
#                    </navLabel>
#                    <content src="T16n0670_001.xhtml#p0480a16" />       <===========
#                    <navPoint id="navPoint-6" playOrder="6">
#                        <navLabel>
#                        <text>之一</text>
#                        </navLabel>
#                        <content src="T16n0670_001.xhtml#p0480a16" />    <=========
#                    </navPoint>
#
#  xhtml 經文中也會有 <a id="p0480a16"></a> 這樣的錨點
#
#  所以若有重複的, toc.ncx 第二個之後要換成 <content src="T16n0670_001.xhtml#p0480a16_2" />
#                                 ..........<content src="T16n0670_001.xhtml#p0480a16_3" /> ......
#  經文則要增加標記, 變成 <a id="p0480a16"></a><a id="p0480a16_2"></a><a id="p0480a16_3"></a> ......
#
#####################################################################
#
# 執行方式：
#           mv_same_tag.pl T01
#
#  程式流程
#
#  1.先讀取 toc.ncx , 若讀到重複的 tag , 記錄在 $same_tag_count{"T16n0670_001.xhtml#p0480a16"} ++
#  2.同時記錄 $new_tag{"T16n0670_001.xhtml#p0480a16"} .= <a id="p0480a16_2"></a>
#  3.逐一讀取各 xhtml 檔, 逐行讀取, 判斷該行的 tag 是否要加上 $new_tag{"xxxx"} (其實一律都加入也行)
#
#####################################################################

use utf8;

my $vol = shift;

#################################################
# 基本參數
#################################################

my $indir = "c:/release/epub_unzip";		# 輸出目錄
my %same_tag_count = ();	# $same_tag_count{"T16n0670_001.xhtml#p0480a16"} = 2
my %new_tag = ();			# $new_tag{"T16n0670_001.xhtml#p0480a16"} = <a id="p0480a16_2"></a><a id="p0480a16_3"></a>
my %change_file = ();		# 有需要改變的 xhtml 檔 , 例如 $change_file{"T16n0670_001.xhtml"} = 1

#################################################
# 主程式
#################################################

$indir = $indir . "/" . $vol;

# 讀取指定目錄中的各經子目錄名
opendir(DIR, $indir ) || die "Error in opening dir $indir\n";
while(($dirname = readdir(DIR)))
{
	next if($dirname =~ /^\./);
	print("\nSutra $dirname\n");
	
	# 處理各經目錄
	run_dir("${indir}/${dirname}");
}
closedir(DIR);

#################################################
# 處理目錄中的各經
# 1.讀 toc.ncx
# 2.讀 xhtml
#################################################

sub run_dir
{
	my $indir = shift;
	my $tocncx = $indir . "/toc.ncx";
	
	# 1.先讀取 toc.ncx , 若讀到重複的 tag , 記錄在 $same_tag_count{"T16n0670_001.xhtml#p0480a16"} ++
	# 2.同時記錄 $new_tag{"T16n0670_001.xhtml#p0480a16"} .= <a id="p0480a16_2"></a>
	
	my $changed = do_tocncx($tocncx);
	
	return if($changed == 0);	# 沒有修改任何檔案
	
	# 3.逐一讀取各 xhtml 檔, 逐行讀取, 判斷該行的 tag 是否要加上 $new_tag{"xxxx"} (其實一律都加入也行)
	
	my $patten = $indir . "/*.xhtml";
	@files = <${patten}>;
	foreach $file (sort(@files))
	{
		$file =~ /^.*[\/\\](.*)/;
		my $short_file = $1;		# = T16n0670_001.xhtml
		next if($file =~ /(CoverPage.xhtml)|(TableOfContents.xhtml)/);
		next if($change_file{$short_file} != 1);
		
		# 至此, 才是要修改 xhtml 的檔案
		print "$short_file\n";
		do_xhtml($file, $short_file);
	}
}

#################################################
# 先讀取 toc.ncx
#
# 1.先讀取 toc.ncx , 若讀到重複的 tag , 記錄在 $same_tag_count{"T16n0670_001.xhtml#p0480a16"} ++
# 2.同時記錄 $new_tag{"T16n0670_001.xhtml#p0480a16"} .= <a id="p0480a16_2"></a>
#################################################

sub do_tocncx
{
	local $_;
	my $file = shift;
	my $changed = 0;	# 判斷有沒有改變資料, 來決定要不要改 toc.ncx 及相關的 xhtml 檔
	
	# 讀取 toc.ncx 檔
	open IN, "<:utf8", $file || die "open $file error!";
	my @lines = <IN>;
	
	# 逐行處理
	for($i=0; $i<=$#lines; $i++)
	{
		$_ = $lines[$i];
		
		# 標記為 <content src="T16n0670_002.xhtml#p0489a24" />
		
		if(/<content src="((.*?)#(p.*?))"/)
		{
			my $src = $1;
			my $f = $2;
			my $t = $3;
			
			$same_tag_count{$src}++;	# 某標記出現次數 + 1;
			
			if($same_tag_count{$src} > 1)	# 重點來了, 此標記重複了 ------------------------------
			{
				my $new_tag = $t . "_" . $same_tag_count{$src};
				$new_tag{$src} .= "<a id=\"${new_tag}\"></a>";			# 記錄未來要在 xhtml 改的標記
				s/<content src=".*?"/<content src="${f}#${new_tag}"/;	# 修改 toc.ncx 內容
				
				$changed = 1;				# 表示 toc.ncx 有修改
				$change_file{$f} = 1;		# 例 : $change_file{"T16n0670_001.xhtml"} = 1
			}
		}
		
		$lines[$i] = $_;
	}
	
	# 若有改變, 則寫回 toc.ncx 檔
	if($changed == 1)
	{
		open OUT, ">:utf8", $file || die "write $file error!";
		for($i=0; $i<=$#lines; $i++)
		{
			print OUT $lines[$i];
		}
		close OUT;
	}
	
	return $changed;	# 傳回有沒有修
}

#################################################
# 逐一讀取各 xhtml 檔
#
# 3.逐一讀取各 xhtml 檔, 逐行讀取, 判斷該行的 tag 是否要加上 $new_tag{"xxxx"} (其實一律都加入也行)
#################################################

sub do_xhtml
{
	local $_;
	my $file = shift;		# 檔案全名, 含路徑 = c:/xxx/xxx/T16n0670_001.xhtml
	my $short_file = shift;	# 檔名, 不含路徑 = T16n0670_001.xhtml
	
	# 讀取資料
	open IN, "<:utf8", $file || die "open $file error!$!";
	my @lines = <IN>;
	close IN;
	
	# 逐行檢查資料, 若有重覆的標記, 則要加入新標記
	for($i=0; $i<=$#lines; $i++)
	{
		$lines[$i] =~ /^id="(.*?)"><\/a>/;
		my $id = $1;	# $id = "p0479a10"
		
		if($id eq "p0725c22")
		{
			my $debug = 1;
		}
		
		my $newtag = $new_tag{"${short_file}#${id}"};
		if($newtag)
		{
			$lines[$i] =~ s/(id=".*?"><\/a>)/$1$newtag/;
		}
	}
	
	# 寫回檔案
	open OUT , ">:utf8", $file || die "open $file error!$!";
	for($i=0; $i<=$#lines; $i++)
	{
		print OUT $lines[$i];
	}
	close OUT;
}

#################################################
# END
#################################################