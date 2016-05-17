#------------------------------------------------------------
# add_id.bat
# 幫 <p>, <lg>, <item> 加上 id 屬性
# 規則:
# 以下標記內不算字數
#   <foreign place="foot">
#   <note place="foot">
#   <note resp="CBETA...">
#   <note type="orig">
#   <note type="mod">
#   <rdg>
#   <t place="foot">
#   <figure> 算1個字
# &CI... 算2個字
# 不算字數: &lac; 新式標點 換行符號 點
#
# by Ray 2002/8/19 12:03PM
#------------------------------------------------------------

use utf8;

$vol = shift;
$inputFile = shift;

$dir = "/release/add-id/";  # 輸出目錄

$chm;
$nid=0; 
$debug = 0;
$vol = uc($vol);
$vol = substr($vol,0,3);

mkdir($dir . $vol, MODE);

opendir (INDIR, ".");
@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '&[^;]*;|\<[^\>]*\>|.';
#	$big5 = '[\x00-\x7f]|[\x80-\xff][\x00-\xff]';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require "utf8b5o.plx";
require "sub.pl";
#$utf8out{"\xe2\x97\x8e"} = '';

use XML::Parser;

my %Entities = ();        
%wits = ();

my $parser = new XML::Parser(NoExpand => True);
$parser->setHandlers(
	Start => \&start_handler,
	Init => \&init_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Comment => \&comment,
	Doctype => \&doctype,
	Default => \&default
);

my $parser1 = new XML::Parser(NoExpand => True);
$parser1->setHandlers(
	Start => \&start_handler1,
	Init => \&init_handler1,
	End => \&end_handler1
);

if ($debug) {
	open LOG, ">:utf8", "add_id.txt";
}

if ($inputFile eq "") {
	for $file (sort(@allfiles)) { process1file($file); }
} else {
	$file = $inputFile;
	process1file($file);
}       
        
print STDERR "Ok!!\n"; 
        
sub process1file {
	$file = shift;
	$file =~ s/^t/T/;
	print STDERR "$file\n";
	$parser1->parsefile($file);
	open O, ">:utf8", "${dir}$vol/$file";
	select O;
	$parser->parsefile($file);
	close O;
}


sub default {
	my $p = shift;
	my $string = shift;
	$string =~ s/^&(.+);$/$1/;
	if ($string eq 'amp' or $string eq 'lt') {
		print "&$string;"; 
	}
	if ($pass) { 
		if ($string ne 'lac') {
			$char_count++;
		}
	}
}       
        
sub init_handler
{       
	print "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
	$lb="";
	$ent_declare = '';
	$para_ent = "";
	%ids = ();
	$pass = 1;	# $pass 為 0 就表示這個範圍不計算字數
	@appstack = ();
	$note_type = '';
}
        
sub doctype {
	my $s = $file;
	print "\n<?xml-stylesheet type=\"text/xsl\" href=\"../dtd/cbeta.xsl\" ?>\n";
	print "<!DOCTYPE TEI.2 SYSTEM \"../dtd/cbetaxml.dtd\"\n";
	print "[$ent_declare";
	print "$para_ent]>\n";
}
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	push @savepass, $pass;
	my $parent = lc($p->current_element);

	if ($el eq 'app') {
		$app_count += 1;
		$app_id = sprintf("%s%2.2d", $lb, $app_count);
		push @appstack, $app_id 
	}
	
	if ($el eq "figure") {
		$char_count ++;
	}
	
	if ($el eq "foreign") {
		if ($att{"place"} eq "foot") { $pass = 0; }
	}
	
	if ($el eq "item") {
		if ($lb ne '') {
			if (not exists $att{"xml:id"}) {
				$id = "item${vol}p$lb" . sprintf("%2.2d",$char_count);
				if (exists $ids{$id}) {
					$id = "item${vol}p$lb" . sprintf("%2.2d",$char_count+1);
				} else {
					$ids{$id} = 0;
				}
				$att{"xml:id"} = $id;
			}
		}
	}

	if ($el eq "lb") {
		$lb = $att{"n"};
		$char_count = 1;
		$app_count = 0;
		if (not exists$att{"ed"}) { $att{"ed"}="T"; }
	}
	
	# <lem>
	if ($el eq "lem") {
		if ($note_type ne 'mod' and not exists $att{'wit'}) {
			$i = scalar @appstack;
			
			$app_id = $appstack[$i-1];
			$wit = $wits{$app_id}; 
			print LOG "\n201 $app_id $wit\n";
			if ($wit =~ /【大】/) {
				$w =  "【CBETA】";
				if (exists $att{'cf1'}) {
					$w = wit($w, $att{'cf1'});
				}
				if (exists $att{'cf2'}) {
					$w = wit($w, $att{'cf2'});
				}
				$att{"wit"} =  $w;
			}  else {
				$att{'wit'} = "【大】";
			}
		}
	}
	
	if ($el eq "lg") {
		if ($lb ne '') {
			if (not exists $att{"xml:id"}) {
				$att{"xml:id"} = "lg${vol}p$lb" . sprintf("%2.2d",$char_count);
			}
		}
	}

	if ($el eq "note") {
		if ($att{"type"} eq "orig" or $att{"type"} eq "mod" or $att{"place"} eq "foot" or $att{"resp"}=~/^CBETA/) { $pass = 0; }
		$note_type = $att{'type'};
	}
	
	if ($el eq "p") {
		if ($lb ne '') {
			if (not exists $att{"xml:id"}) {
				$att{"xml:id"} = "p${vol}p$lb" . sprintf("%2.2d",$char_count);
			}
		}
	}

	if ($el eq "rdg") {
		$pass=0;
	}
		
	if ($el eq "t") {
		if ($att{"place"} eq "foot") { $pass = 0; }
	}
	print "<$el";
	while (($key,$value) = each %att) {
		#$value = myDecode($value);	# P5 不用了
		print " $key=\"$value\"";
	}
	if ($el =~ /^(anchor)|(figure)|(lb)|(milestone)|(pb)|(todo)$/) { print "/"; }
	print ">";
}
        
        
        
sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);
	if ($el !~ /^(anchor)|(figure)|(lb)|(milestone)|(mulu)|(pb)|(todo)$/) { print "</$el>"; }
	if ($el eq 'app') {
		pop @appstack;
	}  elsif ($el eq 'note') {
		$note_type = '';
	}
	$pass = pop @savepass;
}       
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	if ($pass) {
		$char_count += myLength($char)
	}
	#$char =~ s/($pattern)/&rep($1)/eg;
	print $char;
}

sub rep{
	local $x = shift;
	
	if ($x eq "&") {
		return "&amp;";
	} elsif ($x eq "<") {
		return "&lt;";
	}
	return $x;
}
       
sub comment {       
	my $expat = shift;
	my $data = shift;
	#$data =~ s/($pattern)/$utf8out{$1}/g;
	print "<!--$data-->";
}


sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $sysid = shift;
	my $pubid = shift;
	my $ndata = shift;
	if ($ent =~ /^%(.*)$/) {
		$para_ent .= "$ent;\n";
		$ent = "% $1";
	}
	$ent_declare .= "<!ENTITY $ent SYSTEM \"$sysid\"";
	if ($ndata ne "") {
		$ent_declare .= " NDATA $ndata";
	}
	$ent_declare .= ">\n";
	&openent($sysid);
	return 1;
}       
        
        
#sub myDecode {
#	my $s = shift;
#	$s =~ s/($pattern)/$utf8out{$1}/g;
#	return $s;
#}

# 算字數
sub myLength {
	my $str=shift;
	#if ($debug) { print STDERR "myLength $str "; }
	my $n=0;
	if ($str=~/<figure/) {
		$n=1;
	}
	$str =~ s/<rdg[^>]*?>.*?<\/rdg>//g; # 去掉 <rdg> 不算
	$str =~ s/<[^>]*?>//g; # 去掉標記不算
	# 不算字數的符號
	$str =~ s/(◎|。|，|、|；|：|「|」|『|』|（|）|？|！|—|…|《|》|〈|〉|．|“|”|　|〔|〕|【|】|\(|\))//g;
	$str =~ s/\n//g;

	#my $pattern = '(?:&.*?;|[\x80-\xff][\x00-\xff]|[\x00-\x7F])';
	#utf8 pattern
	# P4
	#$utf8 = '(?:&[^;]*?;|[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f])';
	# P5
	$utf8 = '(?:&[^;]*?;|.)';
	my @a=();
	#push(@a, $str =~ /$pattern/g);
	push(@a, $str =~ /$utf8/g);
	foreach $s (@a) {
 
		$n++;
		if ($s =~ /^&CI/) {
			$n++;
		}
	}
	#if ($debug) { print STDERR $n,"\n"; }
	return $n;
}

sub init_handler1
{       
	%wits = ();
	@appstack = ();
}

sub start_handler1
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	my $parent = lc($p->current_element);
	if ($el eq 'app') {
		$app_count += 1;
		$app_id = sprintf("%s%2.2d", $lb, $app_count);
		print LOG "379 $app_id\n";
		push @appstack, $app_id;
		$wits{$app_id} = '';
		print LOG "382 " . $wits{$app_id} . "\n";
	} elsif ($el eq 'lb') {
		$lb = $att{'n'};
		$app_count = 0;
	} elsif ($el eq 'rdg') {
		$i = scalar @appstack;
		$app_id = $appstack[$i-1]; 
		if (exists  $wits{$app_id} ) {
			print LOG "388 $app_id " .  $wits{$app_id} . "\n"; 
		}
		print LOG "389 $app_id " .  $att{'wit'} . "\n"; 
		$wits{$app_id} .= $att{'wit'};
		print LOG "391 " .  $wits{$app_id} . "\n"; 
	}
}

sub end_handler1
{       
	my $p = shift;
	my $el = shift;
	my $parent = lc($p->current_element);
	if ($el eq 'app') {
		pop @appstack;
	}
}       

sub wit {
	my $ret = shift;
	my $a = shift;
	if ($a=~/^J/ and $ret !~ /【嘉興】/) {
		$ret .= '【嘉興】';
	} 
	if ($a=~/^K/ and $ret !~ /【麗】/) {
		$ret .= '【麗】';
	} 
	if ($a=~/^L/ and $ret !~ /【龍】/) {
		$ret .= '【龍】';
	}
	if ($a=~/^Q/ and $ret !~ /【磧砂】/) {
		$ret .= '【磧砂】';
	}
	return $ret;
}
        
__END__ 
:endofperl
