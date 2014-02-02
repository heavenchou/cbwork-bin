# cutxml.pl  		                                    ~by heaven 
#
# 程式說明：XML P5 版切卷程式
#
# 執行參數：cutxml.pl Vol [file]
# 例1：cutxml.pl T01
# 例2：cutxml.pl T01n0001.xml
#
# 設定檔：輸出目錄由 ../cbwork_bin.ini 取得 , 在 [cutxml]區中的 output_dir = /release/cutxml
#
# ★★★ 請注意, 若有不連續卷, 要先處理不連續卷資料
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
$xml_back					=> 3. 校勘區 (僅 </body> 那一行, 最後也會推入 @xml_back_line 的最前面)
@xml_back_line				=> 4. 校勘區 (</body> 之後都放在此陣列)
	@xml_back				=> 4-1. 各卷校勘區


【程式規劃】

1. 先把各卷的位置切出來
2. parser xml , 把各卷要補齊的 tag 及 mulu 記錄起來
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

###############################################################################
# 取得參數
###############################################################################

local $vol = shift;
my $inputFile = shift;

###############################################################################
# 讀取來自 ../../cbwork_bin.ini 的設定
###############################################################################

my $cfg = Config::IniFiles->new( -file => "../../cbwork_bin.ini" );
my $cbwork_dir = $cfg->val('default', 'cbwork', '/cbwork');			# 讀取 cbwork 目錄
my $output_dir = $cfg->val('cutxml', 'output_dir', '/release/cutxml');	# 讀取輸出目錄

###############################################################################
# 分析傳入的參數
###############################################################################

if($inputFile eq "" and $vol =~ /^(([TXJHWIABCFGKLMNPQSU]|(ZS)|(ZW))\d*)n.*?\.xml$/)
{
	$inputFile = $vol;
	$vol = $1;
}

$vol = uc($vol);	# T01
my $edit = $vol;
$edit =~ s/[AB]?\d+//;	# T

unless($vol)
{
	print "perl cut_xml.pl T01 [T01n0001.xml]\n";
	exit;
}

###############################################################################
# 處理參數
###############################################################################

my $errlog = "cutxml_${vol}_err.txt";

my $sourcePath = $cbwork_dir . "/xml-p5/$edit/$vol";	# xml-p5 經文的位置
$output_dir = $output_dir . "/$vol";					# 輸出的目錄

my $myPath = cwd();										# 目前目錄

###############################################################################
# 取得所有 xml 的檔案名稱
###############################################################################

opendir (INDIR, $sourcePath);
@allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

mkdir($output_dir) if(not -d $output_dir);

use XML::DOM;
my $parser = new XML::DOM::Parser;

if ($inputFile eq "") 
{
	# 處理全部檔案
	
	my $killfile = "$output_dir/*.*";
	$killfile =~ s/\//\\/g;
	$rmfile = unlink <${killfile}>;
	print "remove $killfile ($rmfile files removed)\n";

	open ERRLOG, ">$errlog" || die "open error log $errlog error!";
	close ERRLOG;
	for $file (sort(@allfiles)) 
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
	$rmfile = unlink <${killfile}>;
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
	
	local $xml_back = "";	# 校勘區
	local @xml_back = ();	# 各卷的校勘區
	local @xml_back_line = ();	# 校勘逐行放入此陣列中
	
	local $total_juannum = 1;	# 全部的卷數
	
	local @lbn = ();			# 各卷開頭的 <lb> 之中 n 的內容
	local @start_tag = ();		# 記錄各卷開頭應該要補上的標記
	local @end_tag = ();		# 記錄各卷結尾應該要補上的標記
	
	# 各卷目錄開頭的處理法:
	# 每一卷一遇到 <mulu level="n"> 就記錄在 $this_juan_mulu[n] , 並把 n 記錄k在 $mulu_n 變數中
	# 該卷結束時, 就把 1~n 的標記都記錄在 $mulu_tag[n] 之中
	# 例如某一卷結束時, @this_juan_mulu 內容是 ("<mulu level=1 label=第一個/>", "<mulu level=2 label=第二個/>")
	# 則 $mulu_tag[x] = "<mulu level=1 label=第一個/><mulu level=2 label=第二個/>"
	
	local @mulu_tag = ();			# 記錄各卷開頭要補上的記錄 , 陣列是由 1 開始處理, 0 不管它.
	local @this_juan_mulu = ();		# 記錄某一卷的所有 mulu 標記 , 陣列是由 1 開始處理, 0 不管它.
	local $mulu_n = 0;
	
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
		# 有缺字
		$xml_head =~ /^(.*<charDecl>\n)(.*)(<\/charDecl>.*)/s;
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
		
		if($xml_juan[$i] =~ s/^(.*)(<lb .*)$/\1/s)
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
		$xml_juan[$i] =~ /<lb.*?n="(\d\d\d\d.\d\d)"/;
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
	
	# 處理 <lb> 標記
	if ($el eq "lb")
	{
		my $lb_attmap = $node->getAttributes;
		my $bingo = 0;
		
		for my $lb_attr ($lb_attmap->getValues) 
		{
			my $attrName = $lb_attr->getName;
			my $attrValue = $lb_attr->getValue;
			
			if ($attrName eq "n" and $attrValue eq $lbn[$milestoneNum+1])
			{
				# 至此, 表示這一個 <lb> 是某一卷的開始.
				$bingo = 1;
				last;
			}
		}
		
		return if($bingo == 0);

		# 至此, 表示找到另一卷的開頭處, 所以要記錄上卷未結束的各種標記, 才符合 XML 的原則.

		$milestoneNum++;	# 第 N 個
		
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
	
			$start_tag[$milestoneNum] = "${attrs}>" . $start_tag[$milestoneNum];
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
	# 每一卷一遇到 <mulu level="n"> 就記錄在 $this_juan_mulu[n] , 並把 n 記錄k在 $mulu_n 變數中
	# 該卷結束時, 就把 1~n 的標記都記錄在 $mulu_tag[n] 之中
	# 例如某一卷結束時, @this_juan_mulu 內容是 ("<mulu level=1 label=第一個/>", "<mulu level=2 label=第二個/>")
	# 則 $mulu_tag[x] = "<mulu level=1 label=第一個/><mulu level=2 label=第二個/>"
	
	if ($el eq "mulu")
	{
		my $map = $node->getAttributes;
		my $attrs = "<mulu";
		my $mulu_n_tmp = 0;
		for my $attr ($map->getValues) 
		{
			my $attrName = $attr->getName;
			my $attrValue = $attr->getValue;
			#$attrValue =~ s/($pattern)/$utf8out{$1}/g;
			$attrs .= " $attrName=\"$attrValue\"";
			if($attrName eq "level")
			{
				$mulu_n_tmp = $attrValue;
			}
		}
		if($attrs =~ / level=/)		# 沒有 level 的不處理 <mulu n="002" type="卷"/>
		{
			$mulu_n = $mulu_n_tmp;
			$this_juan_mulu[$mulu_n] = "${attrs}/>";
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
		if($mulu_tag[$i] or $start_tag[$i])
		{
			$xml_juan[$i] = $mulu_tag[$i] . $start_tag[$i] . "\n" . $xml_juan[$i];
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
			if($xml_back_line[$i] !~ /<\/app>/)
			{
				# 有 <app 開頭, 沒有 </app> 結尾
				for($j=$i+1; $j<=$#xml_back_line; $j++)
				{
					$xml_back_line[$i] .= $xml_back_line[$j];
					if($xml_back_line[$j] =~ /<\/app>/)
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
			if(/^(<app .*?from="#(beg.*?)".*?<\/app>\n)/s)
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
			elsif(/^(<note .*?target="#(nkr_.*?)".*?<\/note>\n)/)
			{
				if($xml_juan_id[$i]->{$2} == 1)
				{
					$back .= $1;
				}
			}
			# 修訂
			# <choice cb:from="#beg_2" cb:to="#end_2"><corr>念</corr><sic>忘</sic></choice>
			elsif(/^(<choice .*?from="#(beg.*?)".*?<\/choice>\n)/)
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
			elsif(/^(<cb:tt .*?from="#(beg.*?)".*?<\/cb:tt>\n)/s)
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
			# <note target="#beg0434012"><foreign n="0434012" cb:resp="#resp1" xml:lang="pi" cb:place="foot">Nigaṇṭhasāvaka.</foreign></note>
			elsif(/^(<note .*?target="#(beg.*?)".*?<\/note>\n)/)
			{
				if($xml_juan_id[$i]->{$2} == 1)
				{
					$back .= $1;
				}
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
		my $ii = get_real_juan_num($file , $i);	# 取得真實卷數
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

###################################################
# 取得真正的卷數
###################################################

sub get_real_juan_num()
{
	my $file = shift;
	my $i = shift;

	my $ii = sprintf("%03d",$i);
	
	#處理特殊檔名 ###########################################
	
	if($file eq "T06n0220b.xml")
	{
		$ii = sprintf("%03d",$i+200);
	}
	if($file eq "T07n0220c.xml")
	{
		$ii = sprintf("%03d",$i+400);
	}
	if($file eq "T07n0220d.xml")
	{
		$ii = sprintf("%03d",$i+537);
	}
	if($file eq "T07n0220e.xml")
	{
		$ii = sprintf("%03d",$i+565);
	}
	if($file eq "T07n0220f.xml")
	{
		$ii = sprintf("%03d",$i+573);
	}
	if($file eq "T07n0220g.xml")
	{
		$ii = sprintf("%03d",$i+575);
	}
	if($file eq "T07n0220h.xml")
	{
		$ii = sprintf("%03d",$i+576);
	}
	if($file eq "T07n0220i.xml")
	{
		$ii = sprintf("%03d",$i+577);
	}
	if($file eq "T07n0220j.xml")
	{
		$ii = sprintf("%03d",$i+578);
	}
	if($file eq "T07n0220k.xml")
	{
		$ii = sprintf("%03d",$i+583);
	}
	if($file eq "T07n0220l.xml")
	{
		$ii = sprintf("%03d",$i+588);
	}
	if($file eq "T07n0220m.xml")
	{
		$ii = sprintf("%03d",$i+589);
	}
	if($file eq "T07n0220n.xml")
	{
		$ii = sprintf("%03d",$i+590);
	}
	if($file eq "T07n0220o.xml")
	{
		$ii = sprintf("%03d",$i+592);
	}
	#T19n0946.xml 沒有第三卷, 只有 1, 2, 4, 5 卷
	if($file eq "T19n0946.xml")
	{
		$ii = sprintf("%03d",$i+1) if($i>2);
	}
	# T54
	if($file eq "T54n2139.xml")
	{
		$ii = "010" if($i==2);
	}
	# T85
	if($file eq "T85n2742.xml")
	{
		$ii = "002" if($i==1);
	}
	if($file eq "T85n2744.xml")
	{
		$ii = "002" if($i==1);
	}
	if($file eq "T85n2748.xml")
	{
		$ii = "003" if($i==1);
	}
	if($file eq "T85n2754.xml")
	{
		$ii = "003" if($i==1);
	}
	if($file eq "T85n2757.xml")
	{
		$ii = "003" if($i==1);
	}
	if($file eq "T85n2764B.xml")
	{
		$ii = "004" if($i==1);
	}
	if($file eq "T85n2769.xml")
	{
		$ii = "004" if($i==1);
	}
	if($file eq "T85n2772.xml")
	{
		$ii = "003" if($i==1);
	}
	if($file eq "T85n2772.xml")
	{
		$ii = "006" if($i==2);
	}
	if($file eq "T85n2799.xml")
	{
		$ii = "003" if($i==2);
	}
	if($file eq "T85n2803.xml")
	{
		$ii = "004" if($i==1);
	}
	if($file eq "T85n2805.xml")
	{
		$ii = "005" if($i==1);
	}
	if($file eq "T85n2805.xml")
	{
		$ii = "007" if($i==2);
	}
	if($file eq "T85n2809.xml")
	{
		$ii = "004" if($i==1);
	}
	if($file eq "T85n2814.xml")
	{
		$ii = sprintf("%03d",$i+2);
	}
	if($file eq "T85n2820.xml")
	{
		$ii = "012" if($i==1);
	}
	if($file eq "T85n2825.xml")
	{
		$ii = "003" if($i==2);
	}
	if($file eq "T85n2827.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	if($file eq "T85n2880.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	########################################
	#處理特殊的卷
	
	# X03n0208.xml 只有卷10
	if($file eq "X03n0208.xml")
	{
		$ii = "010" if($i==1);
	}
	# X03n0211.xml 只有卷6
	if($file eq "X03n0211.xml")
	{
		$ii = "006" if($i==1);
	}
	# X03n0221.xml 由卷 1~5,8~15, 不是 6~13 (沒有 6,7)
	if($file eq "X03n0221.xml")
	{
		$ii = sprintf("%03d",$i+2) if($i>5);
	}
	#X07n0234.xml 華嚴經疏注,(百二十卷但欠卷21~70、91~100及111~112)
	#01~20,71~90,101~110,113~120 (實際卷數)
	#01~20,21~40, 41~ 50, 51~ 58 (流水卷數)
	if($file eq "X07n0234.xml")
	{
		$ii = sprintf("%03d",$i+50) if($i>20);
		$ii = sprintf("%03d",$i+60) if($i>40);
		$ii = sprintf("%03d",$i+62) if($i>50);
	}
	# X08n0235.xml 華嚴經談玄抉擇,(六卷但初卷不傳),
	if($file eq "X08n0235.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	# X09n0240 由卷 45 開始
	if($file eq "X09n0240.xml")
	{
		$ii = sprintf("%03d",$i+44);
	}
	# X09n0244 由是 2,3 , 沒有卷1
	if($file eq "X09n0244.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	# X17n0321.xml 由卷 1,2,5 不是 1~3 (沒有 3,4)
	if($file eq "X17n0321.xml")
	{
		$ii = "005" if($i == 3);
	}
	# X19n0345.xml 由卷 4,5 不是 1~2 (沒有 1~3)
	if($file eq "X19n0345.xml")
	{
		$ii = sprintf("%03d",$i+3);
	}
	# X21n0367.xml 由卷 4~8 不是 1~5 (沒有 1~3)
	if($file eq "X21n0367.xml")
	{
		$ii = sprintf("%03d",$i+3);
	}
	# X21n0368.xml 由卷 2~4 不是 1~3 (沒有 1)
	if($file eq "X21n0368.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	# X24n0451.xml 由卷 1,3~10, 不是 1~9 (沒有 2)
	if($file eq "X24n0451.xml")
	{
		$ii = sprintf("%03d",$i+1) if($i > 1);
	}
	# X26n0560.xml 只有卷 2 不是 1 (沒有 1)
	if($file eq "X26n0560.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	# X34n0638.xml 由卷 1~21,24~29,31,33~35 , 不是 1~31 (沒有 22,23,30.32)
	if($file eq "X34n0638.xml")
	{
		$ii = sprintf("%03d",$i+2) if($i > 21);
		$ii = sprintf("%03d",$i+3) if($i > 27);
		$ii = sprintf("%03d",$i+4) if($i > 28);
	}
	# X37n0662.xml 由卷 1~14,16~20, 不是 1~19 (沒有 15)
	if($file eq "X37n0662.xml")
	{
		$ii = sprintf("%03d",$i+1) if($i > 14);
	}
	# X38n0687.xml 由卷 2,4 , 不是 1,2 (沒有 1,3)
	if($file eq "X38n0687.xml")
	{
		$ii = "002" if($i == 1);
		$ii = "004" if($i == 2);
	}
	# X39n0704.xml 由卷 3~5, 不是 1~3 (沒有 1,2)
	if($file eq "X39n0704.xml")
	{
		$ii = sprintf("%03d",$i+2);
	}
	# X39n0705.xml 由卷 2 不是 1 (沒有 1)
	if($file eq "X39n0705.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	# X39n0712.xml 由卷 3 不是 1 (沒有 1,2)
	if($file eq "X39n0712.xml")
	{
		$ii = sprintf("%03d",$i+2);
	}
	# X40n0714.xml 由卷 3,4 不是 1,2 (沒有 1,2)
	if($file eq "X40n0714.xml")
	{
		$ii = sprintf("%03d",$i+2);
	}
	# X42n0733.xml 由卷 2~8,10 不是 1~8 (沒有 1,9)
	if($file eq "X42n0733.xml")
	{
		$ii = sprintf("%03d",$i+1);
		$ii = "010" if($i == 8);
	}
	# X42n0734.xml 由卷 9 不是 1 (沒有 1~8)
	if($file eq "X42n0734.xml")
	{
		$ii = "009";
	}
	# X46n0784.xml 由卷 2,5~10 不是 1~7 (沒有 1,3,4)
	if($file eq "X46n0784.xml")
	{
		$ii = "002" if($i == 1);
		$ii = sprintf("%03d",$i+3) if($i > 1);
	}
	# X46n0791.xml 由卷 1,6,14,15,17,21,24 不是 1~7 (沒有 ...)
	if($file eq "X46n0791.xml")
	{
		$ii = "006" if($i == 2);
		$ii = "014" if($i == 3);
		$ii = "015" if($i == 4);
		$ii = "017" if($i == 5);
		$ii = "021" if($i == 6);
		$ii = "024" if($i == 7);
	}
	# X48n0797.xml 由卷 3 不是 1 (沒有 1,2)
	if($file eq "X48n0797.xml")
	{
		$ii = "003";
	}
	# X48n0799.xml 由卷 1,2,7 不是 1~3 (沒有 3~6)
	if($file eq "X48n0799.xml")
	{
		$ii = "007" if($i == 3);
	}
	# X48n0808.xml 由卷 1,5,9,10 不是 1~4 (沒有 2,3,4,6,7,8)
	if($file eq "X48n0808.xml")
	{
		$ii = "005" if($i == 2);
		$ii = "009" if($i == 3);
		$ii = "010" if($i == 4);
	}
	# X49n0812.xml 由卷 2 不是 1 (沒有 1)
	if($file eq "X49n0812.xml")
	{
		$ii = "002";
	}
	# X49n0815.xml 由卷 1~8,10~13 不是 1~12 (沒有 9)
	if($file eq "X49n0815.xml")
	{
		$ii = sprintf("%03d",$i+1) if($i > 8);
	}
	# X50n0817.xml 由卷 17 不是 1 (沒有 1~16)
	if($file eq "X50n0817.xml")
	{
		$ii = "017";
	}
	# X50n0819.xml 由卷 1~14,16,18 不是 1~16 (沒有 15,17)
	if($file eq "X50n0819.xml")
	{
		$ii = "016" if($i == 15);
		$ii = "018" if($i == 16);
	}
	# X51n0822.xml 由卷 4~10 不是 1~7 (沒有 1~3)
	if($file eq "X51n0822.xml")
	{
		$ii = sprintf("%03d",$i+3);
	}
	# X53n0836.xml 由卷 1,2,4~7,17 不是 1~7 (沒有 3,8~16)
	if($file eq "X53n0836.xml")
	{
		$ii = sprintf("%03d",$i+1) if($i > 2);
		$ii = "017" if($i == 7);
	}
	# X53n0842.xml 由卷 29,30 不是 1,2 (沒有 1~28)
	if($file eq "X53n0842.xml")
	{
		$ii = "029" if($i == 1);
		$ii = "030" if($i == 2);
	}
	# X53n0843.xml 由卷 9,18 不是 1,2 (沒有 1~8,10~17)
	if($file eq "X53n0843.xml")
	{
		$ii = "009" if($i == 1);
		$ii = "018" if($i == 2);
	} 
	# X55n0882.xml 有三卷, 分別為 4,7,8
	if($file eq "X55n0882.xml")
	{
		$ii = "004" if($i == 1);
		$ii = "007" if($i == 2);
		$ii = "008" if($i == 3);
	} 
	# X57n0952.xml 只有卷 10
	if($file eq "X57n0952.xml")
	{
		$ii = "010" if($i == 1);
	} 
	# X57n0966.xml 由卷 2 開始 (2,3,4,5)
	if($file eq "X57n0966.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	# X57n0967.xml 由卷 3 開始 (3,4)
	if($file eq "X57n0967.xml")
	{
		$ii = sprintf("%03d",$i+2);
	}
	# X58n1015.xml 只有二卷, 分別為 14,22
	if($file eq "X58n1015.xml")
	{
		$ii = "014" if($i == 1);
		$ii = "022" if($i == 2);
	}
	# X72n1435.xml 由卷13 接著卷 16
	if($file eq "X72n1435.xml" and $i > 13)
	{
		$ii = sprintf("%03d",$i+2);
	}
	# X73n1456.xml 由卷44~55, 不是 41~52 (沒有 41,42,43)
	if($file eq "X73n1456.xml" and $i > 40)
	{
		$ii = sprintf("%03d",$i+3);
	}
	# X81n1568.xml 由卷10~卷25, 不是1~16
	if($file eq "X81n1568.xml")
	{
		$ii = sprintf("%03d",$i+9);
	}
	# X82n1571.xml 由卷 34~120 不是 1~ 87
	if($file eq "X82n1571.xml")
	{
		$ii = sprintf("%03d",$i+33);
	}
	# X85n1587.xml 由卷 2~16 不是 1~ 15
	if($file eq "X85n1587.xml")
	{
		$ii = sprintf("%03d",$i+1);
	}
	# J25nB165.xml 共 1 卷, 只有卷 6
	if($file eq "J25nB165.xml")
	{
		$ii = "006" if($i==1);
	}
	# J25nB166.xml 共 1 卷, 只有卷 7
	if($file eq "J25nB166.xml")
	{
		$ii = "007" if($i==1);
	}
	# J25nB167.xml 共 1 卷, 只有卷 8
	if($file eq "J25nB167.xml")
	{
		$ii = "008" if($i==1);
	}
	# J32nB271.xml 由卷 6~44 不是 1~39
	if($file eq "J32nB271.xml")
	{
		$ii = sprintf("%03d",$i+5);
	}
	# J33nB277.xml 由卷 12~25 不是 1~14
	if($file eq "J33nB277.xml")
	{
		$ii = sprintf("%03d",$i+11);
	}
	# W01n0007.xml 共 1 卷, 只有卷 3
	if($file eq "W01n0007.xml")
	{
		$ii = "003" if($i==1);
	}
	# W03n0025.xml 共 1 卷, 只有卷 2
	if($file eq "W03n0025.xml")
	{
		$ii = "002" if($i==1);
	}
	# W03n0030.xml 共 1 卷, 只有卷 14
	if($file eq "W03n0030.xml")
	{
		$ii = "014" if($i==1);
	}
	# A097n1276      大唐開元釋教廣品歷章(第3卷-第4卷)
	if($file eq "A097n1276.xml")
	{
		$ii = sprintf("%03d",$i+2);
	}
	# A098n1276      大唐開元釋教廣品歷章(第5-10,12-20卷)
	if($file eq "A098n1276.xml")
	{
		if($i<=6) {	$ii = sprintf("%03d",$i+4); }
		else { $ii = sprintf("%03d",$i+5); }
	}
	# A111n1501      大中祥符法寶錄 (3-8,10-12)
	if($file eq "A111n1501.xml")
	{
		if($i<=6) {	$ii = sprintf("%03d",$i+2); }
		else { $ii = sprintf("%03d",$i+3); }
	}
	# A112n1501      大中祥符法寶錄 (13-18,20)
	if($file eq "A112n1501.xml")
	{
		if($i<=6) {	$ii = sprintf("%03d",$i+12); }
		else { $ii = sprintf("%03d",$i+13); }
	}
	# A114n1510      佛說大乘僧伽吒法義經 (2,6,7卷)
	if($file eq "A114n1510.xml")
	{
		$ii = "002" if($i==1);
		$ii = "006" if($i==2);
		$ii = "007" if($i==3);
	}
	# A120n1565      瑜伽師地論義演(第1,4,6-8,11-12,15,17,19-20,22,26,28-32卷)
	if($file eq "A120n1565.xml")
	{
		$ii = "001" if($i==1);
		$ii = "004" if($i==2);
		$ii = "006" if($i==3);
		$ii = "007" if($i==4);
		$ii = "008" if($i==5);
		$ii = "011" if($i==6);
		$ii = "012" if($i==7);
		$ii = "015" if($i==8);
		$ii = "017" if($i==9);
		$ii = "019" if($i==10);
		$ii = "020" if($i==11);
		$ii = "022" if($i==12);
		$ii = "026" if($i==13);
		$ii = sprintf("%03d",$i+14) if($i > 13);
	}
	# A121n1565      瑜伽師地論義演(第33-35,38,40卷)
	if($file eq "A121n1565.xml")
	{
		$ii = "033" if($i==1);
		$ii = "034" if($i==2);
		$ii = "035" if($i==3);
		$ii = "038" if($i==4);
		$ii = "040" if($i==5);
	}
	# C056n1163      一切經音義(第1卷-第15卷)
	# C057n1163      一切經音義(第16卷-第25卷)
	if($file eq "C057n1163.xml")
	{
		$ii = sprintf("%03d",$i+15);
	}
	# K34n1257       新集藏經音義隨函錄(第1卷-第12)
	# K35n1257       新集藏經音義隨函錄(第13卷-第30)
	if($file eq "K35n1257.xml")
	{
		$ii = sprintf("%03d",$i+12);
	}
	# K41n1482       大乘中觀釋論(第10卷-第18卷)
	if($file eq "K41n1482.xml")
	{
		$ii = sprintf("%03d",$i+9);
	}
	# L115n1490      妙法蓮華經玄義釋籤(第1卷-第3卷)
	# L116n1490      妙法蓮華經玄義釋籤(第4卷-第40卷)
	if($file eq "L116n1490.xml")
	{
		$ii = sprintf("%03d",$i+3);
	}
	# L130n1557      大方廣佛華嚴經疏鈔會本(第1卷-第17卷)
	# L131n1557      大方廣佛華嚴經疏鈔會本(第17卷-第34卷)
	if($file eq "L131n1557.xml")
	{
		$ii = sprintf("%03d",$i+16);
	}
	# L132n1557      大方廣佛華嚴經疏鈔會本(第34卷-第51卷)
	if($file eq "L132n1557.xml")
	{
		$ii = sprintf("%03d",$i+33);
	}
	# L133n1557      大方廣佛華嚴經疏鈔會本(第51卷-第80卷)
	if($file eq "L133n1557.xml")
	{
		$ii = sprintf("%03d",$i+50);
	}
	# L153n1638      雪嶠信禪師語錄(第1卷-第6卷)
	# L154n1638      雪嶠信禪師語錄(第7卷-第10卷)
	if($file eq "L154n1638.xml")
	{
		$ii = sprintf("%03d",$i+6);
	}
	# P154n1519      宗門統要正續集(第1卷-第12卷)
	# P155n1519      宗門統要正續集(第13卷-第20卷)
	if($file eq "P155n1519.xml")
	{
		$ii = sprintf("%03d",$i+12);
	}
	# P178n1611      諸佛世尊如來菩薩尊者神僧名經(第1卷-第29卷)
	# P179n1611      諸佛世尊如來菩薩尊者神僧名經(第30卷-第40卷)
	if($file eq "P179n1611.xml")
	{
		$ii = sprintf("%03d",$i+29);
	}
	# P179n1612      諸佛世尊如來菩薩尊者名稱歌曲(第1卷-第18卷)
	# P180n1612      諸佛世尊如來菩薩尊者名稱歌曲(第19卷-第50卷)
	if($file eq "P180n1612.xml")
	{
		$ii = sprintf("%03d",$i+18);
	}
	# P181n1612      諸佛世尊如來菩薩尊者名稱歌曲(第51卷)
	if($file eq "P181n1612.xml")
	{
		$ii = "051" if($i==1);
	}
	# P181n1615      大明三藏法數(第1卷-第13卷)
	# P182n1615      大明三藏法數(第14卷-第35卷)
	if($file eq "P182n1615.xml")
	{
		$ii = sprintf("%03d",$i+13);
	}
	# P183n1615      大明三藏法數(第36卷-第38卷)
	if($file eq "P183n1615.xml")
	{
		$ii = sprintf("%03d",$i+35);
	}
	# P184n1617      妙法蓮華經要解(第1卷-第12卷)
	# P185n1617      妙法蓮華經要解(第13卷-第19卷)
	if($file eq "P185n1617.xml")
	{
		$ii = sprintf("%03d",$i+12);
	}
	# S06n0046       上生經會古通今新抄(第2,4卷)
	if($file eq "S06n0046.xml")
	{
		$ii = "002" if($i==1);
		$ii = "004" if($i==2);
	}
	# U222n1418      華嚴經疏科(第1卷-第3卷)
	# U223n1418      華嚴經疏科(第4-5,7-20卷)
	if($file eq "U223n1418.xml")
	{
		$ii = "004" if($i==1);
		$ii = "005" if($i==2);
		$ii = sprintf("%03d",$i+4) if($i > 2);
	}
	
	return $ii;
}

####################################################################