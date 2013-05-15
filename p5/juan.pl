#######################################################
# 程式名稱：juan.pl
# 程式位置：c:\cbwork\bin\p5
# 程式用途：檢查XML檔中的卷首資訊。
# 程式步驟：c:\cbwork\bin\p5\perl juan.pl T01
# 結果會在 DOS 視窗上呈現
#######################################################

use utf8;
use autodie;
use Encode;
use XML::Parser;

my $vol = shift;				# $vol = T01 , 冊數
my $ed = substr($vol,0,1);		# $ed = T
my $xml_path = "c:/cbwork/xml-p5a/$ed/$vol/";

#require "head.pl";
#open (CFG, "../../work/bin/CBETA.CFG") || die "can't open cbeta.cfg\n";
#xml_root=c:/cbwork/xml
#hh_out_root=u:/release/hh-jk-work
#hh_out_root=d:/MyDocs/cbeta/cd/cd10/hh-work
#xml_txt_root=d:/temp
#outdir=c:/release
#while(<CFG>){
#	next if (/^#/); #comments
#	chop;
#	($key, $val) = split(/=/, $_);
#	$key = uc($key);
#	$cfg{$key}=$val; #store cfg values
#	#print "$key\t$cfg{$key}\n";
#}

my %Entities = ();

my $juanNum = 0;	# 卷的數字, 若卷是 1a , 則此字串為 1a
my $juanNum_1 = 0;	# 卷的數字, 若卷是 1a , 則此數為 1
my $juanNum_2 = 0;	# 卷的英文字, 若卷是 1a , 則此數為 a
my $lineNum = "";	# 行首訊息
my $error = "\n\n錯誤訊息：\n";		# 錯誤訊息

my $div1Type = "";			# Div1 的 type 屬性內容
my $juanOpen = 0;			# 判斷 juan 是否是 open
#my $inDiv1 = 0;				# 是否在 Div1 當中
my $juan_open_count = 0;	# juan open 的數量
my $inExtent = 0;			# 判斷是否在 extent 標記中 <extent>3卷</extent>
my $total_juan = 0;			# 本經的卷數

# 開啟目錄, 找出所有檔案

opendir (INDIR, $xml_path);
@files = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @files;

# 逐檔 parse

my $parser = new XML::Parser(NoExpand => True);
$parser->setHandlers (
	Init => \&init_handler,
	Final => \&final_handler,
	Start => \&start_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default);

for $file (sort(@files)){
	if ($vol eq "T06") { $juanNum_1 = 200; }
	elsif ($vol eq "T07") { $juanNum_1 = 400; }
	else { $juanNum_1 = 0; }
	
	my $filename = $xml_path . $file;
	print "\n" . $file . " :" ;
	$parser->parsefile($filename);
}

print Encode::encode("big5", $error);	# 印出錯誤訊息

#######################################
# XML Parser
#######################################

#use XML::Parser;
#my $parser = new XML::Parser(NoExpand => True);
my $ent;
my $val;

sub init_handler
{
	$div1Type = "";			# Div1 的 type 屬性內容
	$juanOpen = 0;			# 判斷 juan 是否是 open
	#$inDiv1 = 0;			# 是否在 Div1 當中
	$juan_open_count = 0;	# juan open 的數量
	$inExtent = 0;			# 判斷是否在 extent 標記中 <extent>3卷</extent>
	$total_juan = 0;		# 本經的卷數
}

sub final_handler 
{	
	if ($juan_open_count == 0) 
	{
		$error .= "$file : 無卷首資訊\n";
	}
	if ($total_juan == 0)		# 本經的卷數
	{
		$error .= "$file : <extent> 標記中的卷數有問題\n";
	}
	if ($total_juan != $juan_open_count)		# 本經的卷數
	{
		$error .= "$file : <extent> 記錄有 $total_juan 卷, 實際卻有 $juan_open_count 卷\n";
	}
}

sub start_handler 
{
	my $p = shift;
	$tag = shift;
	my (%att) = @_;

	### <div1> ###
	#if ($tag eq "div1"){
	#	if (lc($att{"type"}) ne "") { $div1Type = lc($att{"type"}); }
	#	$inDiv1=1;
	#}
	
	### <lb> ###
	if ($tag eq "lb") { $lineNum = $att{"n"}; }		# 記錄行號
	
	### <extent> ###
	if ($tag eq "extent") { $inExtent = 1; }		# 判斷是否在 extent 標記中 <extent>3卷</extent>
	
	### <juan> ###
	if ($tag eq "cb:juan")
	{
		my $fun = lc($att{"fun"});
		my $n = $att{"n"};
		
		# 印出各檔的卷數情況
		if ($fun eq "open")
		{
			print " [ $n ,";
		}
		elsif ($fun eq "close")
		{
			print " $n ] ,";
		}
		else
		{
			print " ?? $fun $n ,";
			$error .= "$file : 奇怪的 fun 屬性 <juan fun=\"$fun\"> , 行號：$lineNum\n";
		}
		
		# 與上一卷比較, 看看是否合理
		if ($fun eq "open") 
		{
			#if ($div1Type ne "w") 
			#{
				#卷數n值可能包含1a、lb、lc...
				
				if ($n =~ /([0-9]+)([a-z]?)/)
				{
					$n1 = $1;
					$n2 = hex($2);  #作法將字母(a,b,c,...)轉成(10,11,12...)十六進位去比較	
					
					my $pass = 0;
					# 合理的卷數變化
					# 1. 2 -> 3
					# 2. 2 -> 3a
					# 3. 2b -> 3
					# 4. 2b -> 3a
					# 5. 2a -> 2b
					
					# 1. 2 -> 3
					# 2. 2 -> 3a
					# 3. 2b -> 3
					# 4. 2b -> 3a
					if(($n1 == $juanNum_1 + 1) and ($n2 == 0 or $n2 == 10))
					{
						$pass = 1;
					}
					# 5. 2a -> 2b
					elsif(($n1 == $juanNum_1) and ($n2 == $juanNum_2 + 1))
					{
						$pass = 1;
					}
					else
					{
						#exit;  #edith modify 2005/5/30 不中斷程式, 給提示訊息, 例如跑 X55n0882卷不連續卷數
						$error .= "$file : 卷數不連續, 上一卷 [$juanNum] -> 本卷 [$n] , 行號：$lineNum\n";
            		}
				}
				else
				{
					$error .= "$file : 卷數格式錯誤 上一卷 [$juanNum] -> 本卷 [$n] , 行號：$lineNum\n";
				}
				
            	$juanNum_1 = $n1;
            	$juanNum_2 = $n2;
			#}
            $juanNum = $n;
			$juanOpen = 1;
			$juan_open_count++;
			
		}
		elsif ($fun eq "close")
		{
			if (not $juanOpen)
			{
				#edith modify 2005/5/27 <J> 表示切卷，xml 只會轉出 milestone 及 mulu ，並不會轉出 juan open
				$error .= "$file 卷未 Open 行號, 可能是切卷, 行號：$lineNum\n";
			}
			$juanOpen = 0;
		}
	}
}

sub end_handler {
	my $p = shift;
	my $tag = shift;
	#if ($tag eq "div1") { $inDiv1 = 0; }	
	### <extent> ###
	if ($tag eq "extent") { $inExtent = 0; }		# 判斷是否在 extent 標記中 <extent>3卷</extent>
}

sub char_handler {
	my $p = shift;
	my $char = shift;
	if($inExtent)		# 判斷是否在 extent 標記中 <extent>3卷</extent>
	{
		$char =~ /(\d+)卷/;
		$total_juan = $1;	# 本經的卷數
	}
	$char =~ s/^\&(.+);$/&rep($1)/eg;
}

# 遇到這二行
# [<!ENTITY % ENTY  SYSTEM "X01n0001.ent" >
# <!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
# $ent 分別是 ENTY 及 CBENT
# $entval 皆為空白
# next 分別是 X01n0001.ent 及 ../dtd/cbeta.ent
sub entity {
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	openent($next);
	return 1;
}

# 我看到的 default 是註解, 以及這些
# <?xml version="1.0" encoding="UTF-8" ?>
# <?xml-stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
# <!DOCTYPE TEI.2 SYSTEM
# [
# ]>
sub default {
    my $p = shift;
    my $string = shift;
    $string =~ s/^\&(.+);$/&rep($1)/eg;
}

##################################################


sub rep{
	local($x) = $_[0];
	return $Entities{$x} if defined($Entities{$x});
	die "Unknkown entity $x!!\n";
	return $x;
}

sub openent{
	local($file) = $_[0];
	#local($k) = "." . $cfg{"CHAR"};
 	#$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
 	$file =~ s#/#\\#g;
 	#$file =~ s/\.\./$cfg{"DIR"}/;
 	if ($file =~ /gif$/) {
 		return;
 	}
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chop;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		s/\s+>$//;
		($ent, $val) = split(/\s+/);
		$val =~ s/"//g;
		$Entities{$ent} = $val;
	}
}
