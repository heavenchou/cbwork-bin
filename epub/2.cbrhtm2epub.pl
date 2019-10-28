#####################################################################
# CBR HTML to ePub 
# 將 CBReader 產生的 HTML 經文檔轉換成 ePub 使用的格式
#
# CBR 輸出時的選項：不依原書, 無行首, 無校勘, 有標點, 
#                   缺字順利 : 通用字, 組字式 (不使用 unicode 1.1 以上的 unicode)
#                   悉曇, 蘭札用 unicode
#                   呈現修訂用字
#                   
# 執行方式：
#           cbrhtm2epub.pl T01
#####################################################################
use utf8;
use File::Copy;

my $vol = shift;

# require "c:/cbwork/work/bin/b52utf8_h.plx";

#################################################
# 基本參數
#################################################

my $indir = "c:/release/cbr_out_epub";			# 來源目錄
my $outdir = "c:/release/epub_unzip";		# 輸出目錄

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
	
	my $all_text = "";		# 放處理好的檔案
	
	# 處理輸出的目錄及檔名
	
	mkdir("${outdir}/${vol}/${vol}n${sutranum}");	
	my $outfile = "${outdir}/${vol}/${vol}n${sutranum}/${vol}n${filename}";	# 輸出檔名
	$outfile =~ s/htm$/xhtml/;	

	#open IN, $file or die "open $file error$!";
	#open OUT, ">$outfile" or die "open $outfile error";
	open IN, "<:encoding(big5)", $file or die "open $file error$!";
	open OUT, ">:utf8", $outfile or die "open $outfile error";
		
	# 先印出開頭, 除了 <title> 
print OUT << "HTML_HEAD";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xml="http://www.w3.org/XML/1998/namespace" xml:lang="zh-TW">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="stylesheet.css" type="text/css" rel="stylesheet"/>
HTML_HEAD

	# 印出 title
	while(<IN>)
	{
		s/彞/彝/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		s/〹/卄/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		s/<!--.*?-->//g;	# 移除註解
		s/&#x(.{4});/chr(hex($1))/gei;	# 將這類 &#x9262; 直接換成 unicode 鉢
		
		if(/<title>/)
		{
			#$_ = b52utf8($_);	# big5 轉成 utf8 (不用了, 已直接由 perl 的功能讀取 utf8)
			#print OUT $_;
			$all_text .= $_;
		}
		if(/<div class="root"/)			# 找到 <div> 之後就到下一階段
		{
			#print OUT "</head>\n<body>\n<div>\n";
			$all_text .= "</head>\n<body>\n<div>\n";
			last;
		}
	}
	
	# 處理其他資料
	
	while(<IN>)
	{
		s/彞/彝/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		s/〹/卄/g;	# perl 在處理 big5 轉 u8 會錯誤的地方, 一開始就要先處理
		s/<!--.*?-->//g;	# 移除註解
		s/&#x(.{4});/chr(hex($1))/gei;	# 將這類 &#x9262; 直接換成 unicode 鉢
		
		#$_ = b52utf8($_);	# big5 轉成 utf8 (不用了, 已直接由 perl 的功能讀取 utf8)
		
		# 把經文每一行行首 name="0537a05" id="0537a05"> 變成 id="p0537a05">
		s/^name=".*?" id="(.*?)">/id="p$1">/;
		
		# 把品名的標記 <a pin_name="1 佛國品"></a> 去除
		s/<a pin_name=".*?"><\/a>//g;
		
		# 要用小寫的 x 才行
		s/&#X(.*?);/&#x$1;/g;
		
		# 不需要字型
		s/<font.*?>//g;
		s/<\/font>//g;
		
		# 這段不處理, 由 CBReader 本身來解決
		# <span><p>....</p></span> 要換成 <p><span>....</span></p>
		#s/(<span.*?>)<p>/<p>$1/g;
		#s#</p></span>#</span></p>#g;

		# 把 <p> 換成 <div
		#s/<p /<div /g;
		#s/<p>/<div>/g;
		#s/<\/p>/<\/div>/g;	

		# ===========把所有的 <p <div 換成 <span style="display: block;
		#s/<p>/<br \/><span style="display: block;">/g;
		#s/<div>/<br \/><span style="display: block;">/g;
		
		#s/(<p .*?>)/&chg2span($1)/ge;
		#s/(<div .*?>)/&chg2span($1)/ge;
		
		#s/<\/p>/<\/span>/g;	
		#s/<\/div>/<\/span>/g;
		# ===========把所有的 <p <div 換成 <span style="display: block;
		
		
		# ===========換個方式, div 不動, p 換成 <br>
		s/<p\s*[^>]*?>/<br \/><br \/>/g;
		#s/<div>/<br \/><span style="display: block;">/g;
		
		#s/(<p .*?>)/&chg2span($1)/ge;
		#s/(<div .*?>)/&chg2span($1)/ge;
		
		s/<\/p>//g;	
		#s/<\/div>/<\/span>/g;
		# ===========換個方式, div 不動, p 換成 <br>	
		
		s/<br>/<br \/>/g;
		s/<hr>/<hr \/>/g;
		
		# <img src="C:\CBETA\CBReader\Figures\T\T16084701.gif">
		# 改成 
		# <img src="T16084701.gif" />
		
		# 移除 target="_blank" , 有些驗證不能用這個屬性
		s/(<a .*?)\s*target=".*?"/$1/sg;
		
		while(/<img /)
		{
			s/<img src="([^>]*\\(.*?))">/<imgimg src="$2" alt="$2"\/>/;	# alt 是必須的
			my $fullpic = $1;	# C:\CBETA\CBReader\Figures\T\T16084701.gif
			my $pic = $2;		# T16084701.gif
			copy("$fullpic", "${outdir}/${vol}/${vol}n${sutranum}/${pic}");	#將圖檔copy 到相關位置
		}
		s/<imgimg /<img /g;
		
		# 到這裡就算結束了
		if(/<hr \/>【經文資訊】/)
		{
			s/<input .*?>//g;
			#print OUT $_;
			$all_text .= $_;
			#print OUT "</div></body></html>\n";
			$all_text .= "</div></body></html>\n";
			last;
		}
		#print OUT $_;
		$all_text .= $_;
	}
	
	# 如下, <a> 是不能在 <li> 之間, 要移到 <li> 之後 
	# id="p0848c17"></a><ul><li>罽賓國三藏賜紫沙門般若宣梵文</li><a 
	# id="p0848c18"></a><li>東都天宮寺沙門廣濟譯語</li><a 
	# id="p0848c19"></a><li>西明寺賜紫沙門圓照筆受</li><a 
	# id="p0848c20"></a><li>保壽寺沙門智柔迴綴</li><a 
	
	$all_text =~ s/<\/li>((<a\s*[^>]*?><\/a>)+)<li>/<\/li><li>$1/g;	# 遇過 <a..></a> 連續二個 T18n0850_003
	$all_text =~ s/<ul>((<a\s*[^>]*?><\/a>)+)<li>/<ul><li>$1/g;
	$all_text =~ s/<\/li>((<a\s*[^>]*?><\/a>)+)<\/ul>/<\/li><\/ul>$1/g;
	
	
	# 特例, 在 T50n2054_001 , <ul> 不能在 span 中
	# <span class="note">(<ul>........ 換成   <div class="note">(<ul>....
	# </ul>)</span>........ 換成   </ul>)</div>....
	if($vol eq "T50")
	{
		if($outfile =~ /T50n2054_001/)
		{
			$all_text =~ s/<span class="note">\(<ul>/<div class="note">\(<ul>/;
			$all_text =~ s#</ul>\)</span>#</ul>\)</div>#;
		}
	}
	
	# 特例 T12n0377_002 有一個 <span > 包 <div> 的例子, 所以 span 換成 div
	# id="p0912a16"></a><span class="corr" title='[&gt;時迦毘羅等...'><div class="w"><div style="margin-left: 1em"><br /><br />....舍利事已。</div></div></span>\n<hr
	if($vol eq "T12")
	{
		if($outfile =~ /T12n0377_002/)
		{
			$all_text =~ s#id="p0912a16"></a><span#id="p0912a16"></a><div#;
			$all_text =~ s#</div></div></span>(\s*<hr)#</div></div></div>$1#;
		}
	}	
	
	# 特例, I01 有很多重複的行, 等於有重複的 id , 所以要過濾掉重複的
	# <a 
	# id="p0003a00"></a>..........<a 
	# id="p0003a00"></a>..........<a 
	# id="p0003a00"></a>..........<a 
	# id="p0003a00"></a>..........<a 
	
	if($vol eq "I01")
	{
		my $new_all_text = "";
		my %ids = ();
		
		while($all_text)
		{
			# 先取出一般文字
			$all_text =~ s/^([^<]*)//;
			$new_all_text .= $1;
			
			# 取出標記
			$all_text =~ s/^(<[^>]*?>)//;
			my $tag = $1;
			
			# 如果是 a 標記, 就處理重覆的 id 屬性
			if($tag =~ /<a\s.*?id="(.*?)".*?>/s)
			{
				my $id = $1;
				if($ids{$id})
				{
					# 此 id 已存在, 則移除 id="xx"
					$tag =~ s/id="$id"//;
				}
				else
				{
					$ids{$id} = 1;
				}	
			}
			
			$new_all_text .= $tag;
		}
		$all_text = $new_all_text
	}
		
	# 如下, <a> 是不能在 <tr> 之間, 要移到 <td> 之後 
	# id="p0158c23"></a><tr><td colspan = "1" rowspan = "1">新道行<span class="note">(支讖)</span>&nbsp;</td></tr><a 
	# id="p0158c24"></a><tr><td colspan = "1" rowspan = "1">大明度&nbsp;</td></tr><a 
	
	$all_text =~ s/<\/tr>(<a\s*[^>]*?><\/a>)(<tr><td\s*[^>]*?>)/<\/tr>$2$1/g;
	$all_text =~ s/(<table\s*[^>]*?>)(<a\s*[^>]*?><\/a>)(<tr><td\s*[^>]*?>)/$1$3$2/g;
	
	# 在西蓮淨苑資料中, 有一種是引文格式, 在 HTML 是
	
	# <span class="quote_link" link="http://www.cbeta.org/cgi-bin/goto.pl?linehead=T12n0360_p0268a26" onClick="go_quote_link(this);">「設我得佛，十方眾生，至心信樂，欲生我國，乃至十念，若不<a 
	# name="0021a09" id="0021a09"></a>生者，不取正覺。」</span>
	
	# 這一種要把 <span> 換成 <a> 的連結, 而且其中的 <a>..</a> 要移除, 變成
	
	# <a href="http://www.cbeta.org/cgi-bin/goto.pl?linehead=T12n0360_p0268a26">「設我得佛，十方眾生，至心信樂，欲生我國，乃至十念，若不
	# 生者，不取正覺。」</a>
	
	$all_text_head = "";
	
	while($all_text =~ /^(.*?)(<span class="quote_link" link=".*?".*?<\/span>)(.*)/s)
	{
		$all_text_head .= $1;
		$_ = $2;
		$all_text = $3;
		
		s/\&lineheadto/&amp;lineheadto/g;	# 在 ePub 驗證中, 網址的 & 要改成 &amp;
		
		if($_ =~ /^<span.*?<span/)
		{
			# 有問題, 二套 <span
			my $span_head_count = count_span_head($_);
			my $span_end_count = count_span_end($_);
			
			# 如果 <span 與 </span> 數量不同, 就要再加入一段..... </span>
			while($span_head_count != $span_end_count)
			{
				if($all_text =~ /^(.*?<\/span>)(.*)/s)
				{
					$all_text = $2;
					$_ .= $1;
					
					$span_head_count = count_span_head($_);
					$span_end_count = count_span_end($_);
				}
				else
				{
					print "error : span error\n";
					#print substr($_,1,300) . "\n";
					print $_ . "\n";
					<>;
					exit;
				}
			}
		}

		# 移除 <span> 裡面的 <a></a> 標記
		
		s/<a\s*id=".*?"><\/a>//sg;
		s/^<span class="quote_link" link=(".*?").*?>/<a href=$1>/;
		s/<\/span>$/<\/a>/;
		$all_text_head .= $_;
		$_ = "";
	}
	
	$all_text = $all_text_head . $all_text;		# 最後二者接在一起
	
	print OUT $all_text;
	
}

# 計算傳入字串的 <span 有幾個
sub count_span_head
{
	local $_ = shift;
	my $count = 0;
	while(/<span/)
	{
		s/<span//;
		$count++;
	}
	return $count;
}

# 計算傳入字串的 </span> 有幾個
sub count_span_end
{
	local $_ = shift;
	my $count = 0;
	while(/<\/span>/)
	{
		s/<\/span>//;
		$count++;
	}
	return $count;
}

####################################################
# 把所有的 <p <div 換成 <span style="display: block;
####################################################

sub chg2span
{
	local $_ = shift;

	/<(\S+) (.*?)>/;
	my $tag = $1;
	$_ = $2;
	
	if(/style="/)
	{
		s/style="/style="display: block; /;
	}
	else
	{
		$_ = "style=\"display: block;\" " . $_;
	}
	
	return "<br /><span $_>";
}

#################################################
# big5 2 utf8
#################################################

sub b52utf8
{
	my $in = shift;
	my $big5 = "[\x00-\x7f]|[\x80-\xff][\x00-\xff]";
	my @a;
	my $temp='';
	push(@a, $in =~ /$big5/gs);
	my $s='', $c;
	foreach $c (@a)
	{ 
		if ($b52utf8{$c} ne "")
		{ 
			$temp .= $c;
			$c =  $b52utf8{$c}; 
		}
		else
		{ 
			print STDERR "83 $in\n";
			print STDERR "84 $temp\n";
			die "sub b52utf8 85 Error: not in big52utf8 table. char:[$c] hex:" . unpack("H4",$c) ;
			<>;
		}
		$s.=$c;
	}
	return $s;
}

#################################################
# END
#################################################