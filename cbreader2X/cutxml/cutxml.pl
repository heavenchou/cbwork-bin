# cutxml.pl  		                                    ~by heaven 
#
# 程式說明：XML P5 版切卷程式
#
# 執行參數：cutxml.pl [-b] Vol [file]
# 例1：cutxml.pl T01
# 例2：cutxml.pl T01n0001.xml
# 例3：cutxml.pl -b T01
#
# 設定檔：輸出目錄由 ../cbwork_bin.ini 取得 , 在 [cutxml]區中的 output_dir = /temp/cutxml
#
# ★★★ 請注意, 若有 "不連續卷", 底下有程式要先處理
#
#############################################################################

=BEGIN

【程式處理方式】

先切出 head , body , back (利用 ...<body> ... </body>.... 來區隔)

XML 要切成數個部份

1. 一開始至缺字之前的內容
2. 缺字內容
3. 缺字之後至 <body> 之前的內容
4. 各卷內容
5. 校勘區

【變數規劃】

$xml_all					=> 0. 全部的 XML 內容
$xml_head					=> 1. <?xml> 至 <body> 之前的內容
	$xml_head1				=> 1-1. 一開始至缺字之前的內容
	$xml_gaiji				=> 1-2. 全部缺字
		$xml_gaiji{"xxxx"}	=> 1-2-1. 某一筆缺字的內容
		@xml_gaiji			=> 1-2-2. 某一卷缺字的內容
	$xml_head2				=> 1-3. 缺字之後至 <body> 之前的內容
$xml_body					=> 2. 全部內容
	@xml_juan				=> 2-1. 各卷內容
	@xml_juan_id			=> 2-1. 各卷 id , $xml_juan_id[1]->{"beg0001002"} = 1 , 表示第一卷有 "beg0001002" 這個 id
	@xml_juan_num			=> 2-1. 各卷的卷數, 由 milestone 取得
$xml_back					=> 3. 校勘區 (僅 </body> 那一行, 最後也會推入 @xml_back_line 的最前面)
@xml_back_line				=> 4. 校勘區 (</body> 之後都放在此陣列)
	@xml_back				=> 4-1. 各卷校勘區


【程式規劃】

1. 先把各卷的位置切出來
2. parser xml , 把各卷要補齊的 tag 及 mulu 記錄起來, 南傳也要把最後的 PTS 頁碼記下來
3. 組合出各卷的內容

=END
=cut

###############################################################################
# 主程式
###############################################################################

use utf8;
use autodie;
use Config::IniFiles;
use Cwd;
use XML::DOM;

###############################################################################
# 取得參數
###############################################################################
my $vol;
my $P5b_Format = shift;

if($P5b_Format eq "-b")
{
	$P5b_Format = 1;	# P5b 格式
	$vol = shift;
}
else
{
	$vol = $P5b_Format;
	$P5b_Format = 0;	# 不是 p5b 格式
}
my $inputFile = shift;

###############################################################################
# 讀取來自 ../../cbwork_bin.ini 的設定
###############################################################################

my $cfg = Config::IniFiles->new( -file => "../../cbwork_bin.ini" );
my $cbwork_dir = $cfg->val('default', 'cbwork', '/cbwork');			# 讀取 cbwork 目錄
my $output_dir = $cfg->val('cutxml', 'output_dir', '/temp/cutxml');	# 讀取輸出目錄

###############################################################################
# 分析傳入的參數
###############################################################################

if($inputFile eq "" and $vol =~ /^(\D+\d+)n.*?\.xml$/)
{
	$inputFile = $vol;
	$vol = $1;
}

$vol = uc($vol);	# T01
my $edit = $vol;
$edit =~ s/\d+//;	# T

unless($vol)
{
	print "perl cut_xml.pl [-b] T01 [T01n0001.xml]\n";
	exit;
}

###############################################################################
# 處理參數
###############################################################################

my $errlog = "cutxml_${vol}_err.txt";

my $sourcePath;
if($P5b_Format)
{
	$sourcePath = $cbwork_dir . "/xml-p5b/$edit/$vol";	# xml-p5b 經文的位置
}
else
{
	$sourcePath = $cbwork_dir . "/xml-p5/$edit/$vol";	# xml-p5 經文的位置
}
#$sourcePath = "C:/Temp/cbetap5-ok" . "/$edit/$vol";
$output_dir = $output_dir . "/$edit";					# 輸出的目錄
mkdir($output_dir) if(not -d $output_dir);
$output_dir = $output_dir . "/$vol";					# 輸出的目錄
mkdir($output_dir) if(not -d $output_dir);

my $myPath = cwd();										# 目前目錄

###############################################################################
# 取得所有 xml 的檔案名稱
###############################################################################

opendir (INDIR, $sourcePath);
my @allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

my $parser = new XML::DOM::Parser;

if ($inputFile eq "") 
{
	# 處理全部檔案
	
	my $killfile = "$output_dir/*.*";
	$killfile =~ s/\//\\/g;
	my $rmfile = unlink <${killfile}>;
	print "remove $killfile ($rmfile files removed)\n";

	open ERRLOG, ">$errlog" || die "open error log $errlog error!";
	close ERRLOG;
	for my $file (sort(@allfiles)) 
	{
		print "\n$file   ";
		#$file =~ /(?:[TXJHWIABCDFGKLMNPSU])(\d*)n(.{4,5})/;
		#print STDERR "$1$2 ";
		do1file($file);
	}
	unlink $errlog;
} 
else
{
	# 處理指定的檔案
	
	my $killfile = "$output_dir/$inputFile";
	$killfile =~ s/\//\\/g;
	$killfile =~ s/\.xml$/*.*/;
	my $rmfile = unlink <${killfile}>;
	print "remove $killfile ($rmfile files removed)\n";

	$file = $inputFile;
	print "\n$file   ";
	#$file =~ /(?:[TXJHWIABCDFGKLMNPSU])(\d*)n(.{4,5})/;
	#print STDERR "$1$2 ";
	
	$errlog = "cutxml_${file}_err.txt";
	open ERRLOG, ">$errlog" || die "open error log $errlog error!";
	close ERRLOG;
	do1file($file);
	unlink $errlog;
}

#################################################
# 處理單一檔案
#################################################

sub do1file 
{
	local $_;
	my $file = shift;
	my $infile = "$sourcePath/$file";	# 來源檔
	my $outfile;
	
	local $xml_all = "";	# 本檔所有的內容
	
	local $xml_head = "";	# XML 檔頭
	local $xml_head1 = "";	# XML 檔頭 , gaiji 之前的部份
	local $xml_head2 = "";	# XML 檔頭 , gaiji 之後的部份
	local $xml_gaiji = "";	# XML 缺字 , gaiji 的部份
	local %xml_gaiji = {};	# XML 缺字 , 每一個缺字的資料
	local @xml_gaiji = ();	# XML 缺字 , 每一卷缺字的資料
	
	local $xml_body = "";	# body 內容
	local @xml_juan = ();	# 各卷的內容
	local @xml_juan_id = ();	# 各卷裡面的標記 : $xml_juan_id[1]->{"beg0001002"} = 1 , 表示第一卷有 "beg0001002" 這個 id
	local @xml_juan_num = ();	# 各卷的卷數, 由 milestone 取得

	local $xml_back = "";	# 校勘區
	local @xml_back = ();	# 各卷的校勘區
	local @xml_back_line = ();	# 校勘逐行放入此陣列中
	
	local $total_juannum = 1;	# 全部的卷數
	
	local @lbn = ();			# 各卷開頭的 <lb> 之中 n 的內容
	local @start_tag = ();		# 記錄各卷開頭應該要補上的標記
	local @end_tag = ();		# 記錄各卷結尾應該要補上的標記
	
	# 各卷目錄開頭的處理法:
	# 每一卷一遇到 <mulu level="n"> 就記錄在 $this_juan_mulu[n] , 並把 n 記錄在 $mulu_n 變數中
	# 該卷結束時, 就把 1~n 的標記都記錄在 $mulu_tag[n] 之中
	# 例如某一卷結束時, @this_juan_mulu 內容是 ("<mulu level=1 label=第一個/>", "<mulu level=2 label=第二個/>")
	# 則 $mulu_tag[x] = "<mulu level=1 label=第一個/><mulu level=2 label=第二個/>"
	
	local @mulu_tag = ();			# 記錄各卷開頭要補上的記錄 , 陣列是由 1 開始處理, 0 不管它.
	local @this_juan_mulu = ();		# 記錄某一卷的所有 mulu 標記 , 陣列是由 1 開始處理, 0 不管它.
	local $mulu_n = 0;
	
	# 各卷 PTS 開頭的處理法:
	# 每一卷最後一個 PTS 都要記錄下來, 例如 N01n0001.xml 第一卷最後的 PTS 頁碼是 <ref target="#PTS.Vin.3.109"></ref>
	# 將此記錄在 $this_juan_last_pts[1] = '<ref target="#PTS.Vin.3.109"></ref>';
	# 因此在下一卷一開始要加上 <ref target="#PTS.Vin.3.109" type="PTS_hide"></ref> , 其中加上 type="PTS_hide" 是為了區別一般要呈現的標記.
	
	local @this_juan_last_pts = ();	# 記錄某一卷最後遇到的 PTS 頁碼, 這要加在下一卷的開頭, 僅限南傳
	
	##########################################
	
	# 讀入 XML 全部資料, 並移除註解 <!-- .... --> 的內容
	read_xml_file($infile);
	
	# 找出 head, body, back 三個範圍, 校勘主要在 @xml_back_line 陣列中
	get_head_body_back();
	
	# 把 head 區切成三塊 , head1 , giaji, head2
	cut_head_to_3blocks();
	
	# 切出各卷 , 存放在 @xml_juan
	get_juans();

	# 取出各卷 <lb> 中的 n 屬性
	get_lbn();
	
	# paser xml 了, 找出各卷卷首及卷尾需要補上的標記
	ParserXML($file);
	
	# 在各卷前後補上標記
	add_tag_2_juan();
		
	# 取出各卷有什麼 id , 這是要判斷哪些校勘是在哪一卷用的
	# 例如 $xml_juan_id[1]->{"nkr_note_orig_0001001"} = 1 , 表示卷一有 "nkr_note_orig_0001001" 這個 xml:id
	get_xml_id();
	
	# 整理校勘區
	# 1. 把 $xml_back 推入校勘區
	# 2. 把 <tt>....</tt> 分散在多行的, 合併在一筆陣列資料中.
	make_xml_back();
	
	# 將校勘區切出各卷的校勘區
	get_backs();
	
	# 做出各卷缺字的內容
	make_gaiji();

	# 輸出結果
	output_all($file);
}

##########################################
# 讀入 XML 全部資料
##########################################

sub read_xml_file
{
	my $file = shift;
	$xml_all = "";
	
	open IN, "<:utf8", $file;
	while(<IN>)
	{
		$xml_all .= $_;
		last if(/<\/body>/);	# 只取到 </body> 就好了
	}
	# 剩下的放入 @xml_back_line 陣列中
	while(<IN>)
	{
		push (@xml_back_line, $_);
	}	
	close IN;
	
	$xml_all =~ s/<!\-\-.*?\-\->//gs;
}

##########################################
# 找出 head, body, back 三個範圍
##########################################

sub get_head_body_back
{	
	# 切出主要三個區塊
	if($xml_all =~ /^(.*?<body>)\n?(.*?)\n?(<\/body>.*)/s)
	{
		$xml_head = $1 . "\n";
		$xml_body = $2 . "\n";
		$xml_back = $3;
	}
	else
	{
		print "cannot find ...<body>...</body>...\n";
	}		
}

##############################################
# 把 head 區切成三塊 , head1 , giaji, head2
##############################################

sub cut_head_to_3blocks
{
	if(index($xml_head, "<charDecl>" , 0) >= 0)
	{
		# 有缺字 , 先不放 <charDecl> , 以免該卷沒有缺字時, 還要再刪除.
		$xml_head =~ /^(.*?)<charDecl>\n?(.*?)<\/charDecl>\n?(.*)/s;
		$xml_head1 = $1;
		$xml_gaiji = $2;
		$xml_head2 = $3;
		
		# 把缺字逐一取出, 放到 %xml_gaiji 裡面
		get_gaijis();
	}
	else
	{
		# 沒有缺字
		$xml_head1 = $xml_head;
	}
}

##############################################
# 把缺字逐一取出, 放到 %xml_gaiji 裡面
##############################################

sub get_gaijis
{
	local $_ = $xml_gaiji;
	while(/(<char .*?<\/char>\n?)(.*)/s)
	{
		my $char = $1;
		$_ = $2;
		
		# <char xml:id="CB00006">
		if($char =~ /<char xml:id="(.*?)">/)
		{
			my $key = $1;
			$xml_gaiji{$key} = $char;
		}
		else
		{
			print "error : gaiji format error!\n";
		}
	}
}

##############################################
# 切出各卷, 存放在 @xml_juan
##############################################

sub get_juans
{
	local $_ = $xml_body;
	$total_juannum = 1;	# 總卷數
	
	while(/^(.*?<milestone .*?)(<milestone .*)/s)
	{
		$xml_juan[$total_juannum] = $1;
		$_ = $2;
		$total_juannum++;
	}
	$xml_juan[$total_juannum] = $_;		# 最後一卷了
	
	############################################################
	# 調整各卷的內容, 把前一卷卷尾的 <lb> 及 <pb> 移到下一卷卷首
	############################################################
	
	for(my $i=1; $i<$total_juannum; $i++)
	{
		# 卷尾的 <lb...> 要移到下一卷開頭
		
		if($xml_juan[$i] =~ s/^(.*)(<lb[^>]*ed="$edit".*)$/\1/s)	# 卍續藏有二組 lb, 所以要儘量移到下一卷
		{
			$xml_juan[$i+1] = $2 . $xml_juan[$i+1];
		}
		else
		{
			print "$total_juannum no <lb> in the end.\n";
		}
		
		# 如果前一卷最後是 <pb> 也併到下一卷
		
		if($xml_juan[$i] =~ s/^(.*)(<pb [^>]*>\n?)$/\1/s)
		{
			$xml_juan[$i+1] = $2 . $xml_juan[$i+1];
		}
	}
}

############################################
# 取出各卷 <lb> 中的 n 屬性
############################################

sub get_lbn
{	
	for(my $i=1; $i<=$total_juannum; $i++)
	{
		$xml_juan[$i] =~ /<lb.*?n="(.\d\d\d.\d\d)"/;
		$lbn[$i] = $1;
	}
}

###################################################
# XML Parser
# paser xml 了, 找出各卷卷首及卷尾需要補上的標記
###################################################

sub ParserXML()
{
	my $file = shift;
	
	$newdir = "$sourcePath/";
	chdir "$newdir";
	print "parse ...\n";
	my $doc = $parser->parsefile($file);
	chdir "$myPath";
	
	my $root = $doc->getDocumentElement();
	
	local $milestoneNum = 0;
	
	parseNode($root);	# 進行分析
	$root->dispose;
}

sub parseNode
{
	my $node = shift;
	my $nodeTypeName = $node->getNodeTypeName;
	if ($nodeTypeName eq "ELEMENT_NODE") {
		start_handler($node);
		for my $kid ($node->getChildNodes) {
			parseNode($kid);
		}
		#end_handler($node);
	}
	# elsif ($nodeTypeName eq "TEXT_NODE") {text_handler($node);}	# 我不做這個
}

sub start_handler 
{       
	my $node = shift;
	my $parentnode;
	
	local $el = $node->getTagName;
	
	# 處理<milestone n="1" unit="juan"/> 標記
	if ($el eq "milestone")
	{
		my $n = $node->getAttributeNode("n")->getValue;	# 取得 n 屬性
		push(@xml_juan_num, $n);
	}

	# 處理 <lb> 標記
	if ($el eq "lb")
	{
		my $att_ed = $node->getAttributeNode("ed")->getValue;	# 取得 ed 屬性
		my $att_n = $node->getAttributeNode("n")->getValue;		# 取得 n 屬性
		
		#n = 某卷第一行及 ed = 大藏經, 表示找到卷首了. (卍續藏有二個 <lb> 所以要檢查 ed 屬性)
     	return if($att_n ne $lbn[$milestoneNum+1] || $att_ed ne $edit);	
     			
		# 至此, 表示找到另一卷的開頭處, 所以要記錄上卷未結束的各種標記, 才符合 XML 的原則.

		$milestoneNum++;	# 第 N 個
		#print "mile : $milestoneNum \n";
		#print "lb_n : $att_n \n";
		$parentnode = $node->getParentNode();
		while(($pnName = $parentnode->getTagName()) ne "body")
		{
			my $map = $parentnode->getAttributes;
			my $attrs = "<$pnName";
			for my $attr ($map->getValues) 
			{
				my $attrName = $attr->getName;
				my $attrValue = $attr->getValue;
				#$attrValue =~ s/($pattern)/$utf8out{$1}/g;
				$attrs .= " $attrName=\"$attrValue\"";
			}
			
			$attrs .= ">";
						
			#print "attr : $attrs \n";
						
			# 百品第一卷前面都會有 <cb:div>, 這是在 <milestone> 之前 , 但會直接放入卷裡面.
			# 不過在分析每一卷前面有多少標記時, 它會被分析到, 因此要移除, 以免出現連續二個 <cb:div>
			if($edit eq "I" && $milestoneNum == 1 && $attrs eq "<cb:div>")
			{
				$attrs = "";
			}
			$start_tag[$milestoneNum] = $attrs . $start_tag[$milestoneNum];
			$end_tag[$milestoneNum-1] .= "</${pnName}>";
			$parentnode = $parentnode->getParentNode();
		}
		# 記錄此卷的 mulu 標記
		$mulu_tag[$milestoneNum] = "";
		for($i = 1; $i<=$mulu_n; $i++)
		{
			$mulu_tag[$milestoneNum] = $mulu_tag[$milestoneNum] . $this_juan_mulu[$i];
		}
		#$mulu_n = 0;			# 不可以歸零, 因為某一卷可能完全沒有 mulu , 但都要一直繼承上去
		#$this_juan_mulu = ();	# 不可以歸零, 因為某一卷可能完全沒有 mulu , 但都要一直繼承上去
	}
	
	# 處理 <mulu> 標記 <mulu level="1" label="序" type="序"/>
	
	# 各卷目錄開頭的處理法:
	# 每一卷一遇到 <mulu level="n"> 就記錄在 $this_juan_mulu[n] , 並把 n 記錄在 $mulu_n 變數中
	# 該卷結束時, 就把 1~n 的標記都記錄在 $mulu_tag[n] 之中
	# 例如某一卷結束時, @this_juan_mulu 內容是 ("<mulu level=1 label=第一個/>", "<mulu level=2 label=第二個/>")
	# 則 $mulu_tag[x] = "<mulu level=1 label=第一個/><mulu level=2 label=第二個/>"
	
	if ($el eq "cb:mulu")
	{
		my $map = $node->getAttributes;

		my $mulu_n_tmp = -1;			# 記錄 level 的數字
		for my $attr ($map->getValues) 
		{
			my $attrName = $attr->getName;
			my $attrValue = $attr->getValue;
			if($attrName eq "level")
			{
				$mulu_n_tmp = $attrValue;
				
				# 沒有 level 的不處理 <cb:mulu n="001" type="卷"></cb:mulu>
				$mulu_n = $mulu_n_tmp;
				$this_juan_mulu[$mulu_n] = $node->toString();
			}
		}
	}
	
	# 各卷 PTS 開頭的處理法:
	# 每一卷最後一個 PTS 都要記錄下來, 例如 N01n0001.xml 第一卷最後的 PTS 頁碼是 <ref target="#PTS.Vin.3.109"></ref>
	# 將此記錄在 $this_juan_last_pts[1] = '<ref target="#PTS.Vin.3.109"></ref>';
	# 因此在下一卷一開始要加上 <ref target="#PTS.Vin.3.109" type="PTS_hide"></ref> , 其中加上 type="PTS_hide" 是為了區別一般要呈現的標記.
	
	if ($el eq "ref")
	{
		my $map = $node->getAttributes;

		for my $attr ($map->getValues) 
		{
			if($attr->getName eq "target" && substr($attr->getValue, 0,5) eq "#PTS.")
			{
				$this_juan_last_pts[$milestoneNum] = $node->toString();
			}
		}
	}	
}

##########################################################
# 在各卷前後補上標記
##########################################################
	
sub add_tag_2_juan()
{
	for(my $i=1; $i<= $total_juannum; $i++)
	{
		# 把 <ref target="#PTS.Vin.3.109"></ref> 換成 <ref target="#PTS.Vin.3.109" type="PTS_hide"></ref>
		$this_juan_last_pts[$i-1] =~ s/><\/ref>/ type="PTS_hide"><\/ref>/;	
		# 把 <ref target="#PTS.Vin.3.109"/> 換成 <ref target="#PTS.Vin.3.109" type="PTS_hide"></ref>
		$this_juan_last_pts[$i-1] =~ s/\/>/ type="PTS_hide"><\/ref>/;	# 

		if($mulu_tag[$i] or $start_tag[$i] or $this_juan_last_pts[$i-1])
		{
			$xml_juan[$i] = $mulu_tag[$i] . $this_juan_last_pts[$i-1] . $start_tag[$i] . "\n" . $xml_juan[$i];
		}
		$xml_juan[$i] = $xml_juan[$i] . $end_tag[$i];
	}
}

######################################################################################################
# 取出各卷有什麼 id , 這是要判斷哪些校勘是在哪一卷用的
# 例如 $xml_juan_id[1]->{"nkr_note_orig_0001001"} = 1 , 表示卷一有 "nkr_note_orig_0001001" 這個 xml:id
######################################################################################################

sub get_xml_id
{
	local $_;
	for(my $i=1; $i<=$total_juannum; $i++)
	{
		$_ = $xml_juan[$i];
		$hash = {};
		while(/xml:id="(((beg)|(nkr)).*?)"/g)
		{
			$hash->{$1} = 1;
		}
		$xml_juan_id[$i] = $hash;
	}
}

##############################################################################################
# 整理校勘區
# 1. 把 $xml_back 推入校勘區
# 2. 把 <tt>....</tt> 分散在多行的, 合併在一筆陣列資料中.
##############################################################################################
	
sub make_xml_back()
{
	local $_;
	# 1. 把 $xml_back 推入校勘區
	unshift @xml_back_line , $xml_back;
	
	# 2. 把 <tt>....</tt> 分散在多行的, 合併在一筆陣列資料中.
	for(my $i=0; $i<=$#xml_back_line; $i++)
	{
		if($xml_back_line[$i] =~ /^<cb:tt[ >]/)
		{
			if($xml_back_line[$i] !~ /<\/cb:tt>/)
			{
				# 有 <cb:tt 開頭, 沒有 </cb:tt> 結尾
				for($j=$i+1; $j<=$#xml_back_line; $j++)
				{
					$xml_back_line[$i] .= $xml_back_line[$j];
					if($xml_back_line[$j] =~ /<\/cb:tt>/)
					{
						$xml_back_line[$j] = "";
						last;
					}
					else
					{
						$xml_back_line[$j] = "";
					}
				}
			}
		}
	}
		
	# 3. 把 <app>....</app> 分散在多行的, 合併在一筆陣列資料中.
	for(my $i=0; $i<=$#xml_back_line; $i++)
	{
		if($xml_back_line[$i] =~ /^<app[ >]/)
		{
			$_ = $xml_back_line[$i];
			my $app_head_num = app_head_num($_);	# <app 的數量
			my $app_tail_num = app_tail_num($_);	# </app> 的數量
			if($app_head_num != $app_tail_num)
			{
				# 有 <app 開頭, 沒有 </app> 結尾
				for($j=$i+1; $j<=$#xml_back_line; $j++)
				{
					$xml_back_line[$i] .= $xml_back_line[$j];
					$_ = $xml_back_line[$i];
					$app_head_num = app_head_num($_);	# <app 的數量
					$app_tail_num = app_tail_num($_);	# </app> 的數量					
					if($app_head_num == $app_tail_num)
					{
						$xml_back_line[$j] = "";
						last;
					}
					else
					{
						$xml_back_line[$j] = "";
					}
				}
			}
		}
	}
}

# 傳回某一行 <app> 及 <app 的數量
sub app_head_num
{
	local $_ = shift;
	my $num = 0;
	while(/<app>/g)
	{
		$num++;
	}
	while(/<app\s/g)
	{
		$num++;
	}
	return $num;
}
# 傳回某一行 </app> 的數量
sub app_tail_num
{
	local $_ = shift;
	my $num = 0;
	while(/<\/app>/g)
	{
		$num++;
	}
	return $num;
}
	
##############################################################################################
# 將校勘區切出各卷的校勘區
# 第一版 :                       校勘區是一個大檔案, 逐一取出校勘, 比對該卷是否有此校勘, 極慢.
# 第二版 : 先取出各卷有哪些 id , 校勘區是一個大檔案, 逐一取出校勘, 比對該卷是否有此校勘, 極慢.
# 第三版 : 先取出各卷有哪些 id , 先把校勘區切成陣列,               比對該卷是否有此校勘, 尚可.
# 第四版 : 校勘區在讀入時直接放入陣列, 先取出各卷有哪些 id ,       比對該卷是否有此校勘, 速度不錯.
##############################################################################################

sub get_backs
{
	local $_;
	
	for(my $i=0; $i<=$total_juannum; $i++)
	{
		my $back = "";	# 本卷的校勘內容
		my $id = "";
		
		for(my $j = 0; $j<=$#xml_back_line; $j++)
		{
			# 依據不同的內容來處理
			
			$_ = $xml_back_line[$j];
			
			# 校勘內容
			# <app from="#beg0001007" to="#end0001007"><lem wit="#wit1">析</lem><rdg resp="#resp1" wit="#wit2">斤</rdg></app>
			# <app from="#beg_1" to="#end_1" corresp="#0001004"><lem wit="#wit1">辨</lem><rdg resp="#resp1" wit="#wit2">辯</rdg></app>
			if(/^(<app .*?from="#(beg.*?)".*<\/app>\n)$/s)
			{
				if($xml_juan_id[$i]->{$2} == 1)
				{
					$back .= $1;
				}
			}
			# 校勘, CBETA 修訂校勘, 巴利書名, 其他
			# <note n="0001002" resp="#resp1" type="orig" place="foot text" target="#nkr_note_orig_0001002">〔長安〕－【宋】</note>
			# <note n="0001012" resp="#resp2" type="mod" target="#nkr_note_mod_0001012">後秦弘始年＝姚秦三藏法師【宋】【元】【明】</note>
			# <note n="0011004" place="foot" type="equivalent" target="#nkr_note_equivalent_0011004">遊行經～D. 10. Mahāparinibbānasuttanta.</note>
			# <note n="0030012" place="foot" type="cf." target="#nkr_note_cf._0030012">[No. 8]</note>
			# <note resp="#resp7" target="#nkr_3f0">查永樂北藏 P055_p0650b10 調=掉</note> -- T01n0026.xml
			# 因為 target 可能有好幾個, 所以要切開來處理
			# <note n="0014001" resp="#resp2" place="foot text" type="orig" target="#nkr_note_orig_0014001 #note_star_3">
			elsif(/^(<note .*?target="(.*?)".*<\/note>\n)$/)
			{
				my $thisline = $1;
				my $targets = $2;
								
				my @targets = split(/\s+/, $targets);
				
				foreach $key (@targets)
				{
					$key =~ s/^#//;
					if($xml_juan_id[$i]->{$key} == 1)
					{
						$back .= $thisline;
						last;
					}
				}
			}
			# 修訂
			# <choice cb:from="#beg_2" cb:to="#end_2"><corr>念</corr><sic>忘</sic></choice>
			elsif(/^(<choice .*?from="#(beg.*?)".*<\/choice>\n)$/)
			{
				if($xml_juan_id[$i]->{$2} == 1)
				{
					$back .= $1;
				}
			}
			# 多語詞條對照
			# <cb:tt type="app" from="#beg0001011" to="#end0001011">
			# <cb:t resp="#resp1" xml:lang="zh">長阿含經</cb:t>
			# <cb:t resp="#resp1" xml:lang="sa" place="foot">Dīrgha-āgama</cb:t>
			# <cb:t resp="#resp1" xml:lang="pi" place="foot">Dīgha-nikāya</cb:t>
			# </cb:tt>
			elsif(/^(<cb:tt .*?from="#(beg.*?)".*<\/cb:tt>\n)$/s)
			{
				if($xml_juan_id[$i]->{$2} == 1)
				{
					$back .= $1;
				}
			}
			elsif($_ eq "")
			{
				# pass;
			}
			# </body>
			# <back>
			# <cb:div type="apparatus">
			# <p>
			elsif(/^(<((\/body)|(back)|(\/?cb:div[^>]*)|(\/?p))>\n)/)
			{
				# 處理一般標記
				$back .= $1;
			}
			# <head>校勘記</head>
			elsif(/^(<head>.*?<\/head>\n)/)
			{
				$back .= $1;
			}
			# </back></text></TEI>
			elsif(/^(<\/back><\/text><\/TEI>\n?)/)
			{
				$back .= $1;
			}
			# </body></text></TEI>
			# 沒有 back 的版本 P5b
			elsif(/^(<\/body><\/text><\/TEI>\n?)/)
			{
				$back .= $1;
			}
			# </back></text>
			elsif(/^(<\/back><\/text>\n?)/)
			{
				$back .= $1;
			}
			# </body>
			elsif(/^(<\/body>\n?)/)
			{
				$back .= $1;
			}
			# </text>
			elsif(/^(<\/text>\n?)/)
			{
				$back .= $1;
			}
			# </TEI>
			elsif(/^(<\/TEI>\n?)/)
			{
				$back .= $1;
			}
			# <note target="#beg0434012"><foreign n="0434012" cb:resp="#resp1" xml:lang="pi" cb:place="foot">Nigaṇṭhasāvaka.</foreign></note>
			elsif(/^(<note .*?target="#(beg.*?)".*<\/note>\n)$/)
			{
				if($xml_juan_id[$i]->{$2} == 1)
				{
					$back .= $1;
				}
			}
			# 空白行
			elsif(/^(\s*)$/)
			{
				# pass
			}
			else
			{
				print "error : find unknow back data\n";
				print substr($_,0,80);
				<>;
			}
		}
		$xml_back[$i] = $back;
	}
}

################################################
# 做出各卷缺字的內容
################################################

sub make_gaiji
{
	if($xml_gaiji)
	{
		for(my $i=1; $i<=$total_juannum; $i++)
		{
			foreach $key (sort(keys(%xml_gaiji)))
			{
				# 該卷有此缺字才要輸出
				if(index($xml_juan[$i], $key) >= 0 or index($xml_back[$i], $key) >= 0)
				{
					$xml_gaiji[$i] .= $xml_gaiji{$key};
				}
			}
			# 若該卷有缺字, 則要加上 <charDecl> 標記
			if($xml_gaiji[$i])
			{
				$xml_gaiji[$i] = "<charDecl>\n". $xml_gaiji[$i] . "</charDecl>\n";
			}
		}
	}
}
	
################################################
# 輸出結果
################################################

sub output_all
{
	my $file = shift;
	
	print "total juans : $total_juannum\n";
	for(my $i=1; $i<= $total_juannum; $i++)
	{
		# my $ii = get_real_juan_num($file , $i);	# 取得真實卷數
		# 上面是舊方法, 新版直接用 @xml_juan_num 的數字
		my $ii = sprintf("%03d",$xml_juan_num[$i-1]);

		# 處理特殊檔名 ###########################################
		$outfile = "$output_dir/$file";	# 輸出檔
		$outfile =~ s/\.xml$/_$ii.xml/;	# 檔名變成 T01n0001_001.xml
		$outfile =~ s/(T0[5-7]n0220)[a-z]/$1/;		# 專門為大般若經寫的

		################################
		# 輸出結果
		################################
		
		print "> $outfile\n";
		open OUT, ">:utf8" , $outfile;
		
		print OUT $xml_head1;
		print OUT $xml_gaiji[$i];
		print OUT $xml_head2;
		print OUT $xml_juan[$i];
		print OUT $xml_back[$i];
		
		close OUT;
	}
}

####################################################################