# 產生 sutralist.txt , 這是主要的經名資料

use utf8;
use File::Copy;
#use Win32::ODBC;

#readGaiji();
#readCbetaEnt();
open OUT, ">utf8", "sutralist.txt" or die "open error";

for ($i=1; $i<=85; $i++) {
	$i = 85 if($i == 56);
	$vol = "T" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=1; $i<=88; $i++) {
	$i = 7 if($i == 6);
	$i = 53 if($i == 52);
	$vol = "X" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=1; $i<=40; $i++) {
	$i = 7 if($i == 2);
	$i = 10 if($i == 8);
	$i = 15 if($i == 11);
	$i = 19 if($i == 16);
	$vol = "J" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=1; $i<=1; $i++) {
	$vol = "H" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=1; $i<=9; $i++) {
	$vol = "W" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=1; $i<=1; $i++) {
	$vol = "I" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=91; $i<=120; $i++) {
	$vol = "A" . sprintf("%03d",$i);
	dodir($vol);
}
for ($i=1; $i<=36; $i++) {
	$vol = "B" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=56; $i<=106; $i++) {
	$vol = "C" . sprintf("%03d",$i);
	dodir($vol);
}
for ($i=1; $i<=64; $i++) {
	$vol = "D" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=1; $i<=29; $i++) {
	$vol = "F" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=52; $i<=84; $i++) {
	$vol = "G" . sprintf("%03d",$i);
	dodir($vol);
}
for ($i=9; $i<=90; $i++) {
	$vol = "GA" . sprintf("%03d",$i);
	dodir($vol);
}
for ($i=78; $i<=78; $i++) {
	$vol = "GB" . sprintf("%03d",$i);
	dodir($vol);
}
for ($i=5; $i<=41; $i++) {
	$vol = "K" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=115; $i<=164; $i++) {
	$vol = "L" . sprintf("%03d",$i);
	dodir($vol);
}
for ($i=59; $i<=59; $i++) {
	$vol = "M" . sprintf("%03d",$i);
	dodir($vol);
}
for ($i=1; $i<=70; $i++) {
	$vol = "N" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=154; $i<=189; $i++) {
	$vol = "P" . sprintf("%03d",$i);
	dodir($vol);
}
for ($i=6; $i<=6; $i++) {
	$vol = "S" . sprintf("%02d",$i);
	dodir($vol);
}
for ($i=205; $i<=223; $i++) {
	$vol = "U" . sprintf("%03d",$i);
	dodir($vol);
}

# 西蓮淨苑資料
for ($i=1; $i<=44; $i++) {
	$vol = "ZY" . sprintf("%02d",$i);
	dodir($vol);
}

for ($i=1; $i<=18; $i++) {
	$vol = "DA" . sprintf("%02d",$i);
	dodir($vol);
}
close OUT;

##################################################################

sub dodir
{
	local $vol = shift;
	local $ed = $vol;
	$ed =~ s/\d+//;
	
	$dir = "c:/cbwork/xml-p5/$ed/$vol";
	if (not -e $dir) { return; }
	print STDERR "$dir\n";
	opendir INDIR, $dir or die "opendir $dir error: $dir";
	my @allfiles = grep(/^${ed}\d+n.{4,5}\.xml$/i, readdir(INDIR));
	closedir INDIR;
  
	foreach $file (sort @allfiles)
	{
		do1file($file);
	}
}

# 處理單一檔案

sub do1file 
{
	my $file = shift;
	my $findbody = 0;	# 找到 <body> 才設為 1, 才開始檢查 <lb> , 以免查到註解中的 <lb>
	my $name = "";
	
	print STDERR "$file\n";
	open I, "<:utf8", "$dir/$file" or die "open error";
	$juan = 0;
	while (<I>) 
	{
		if (/title.*No. ([AB]?)(\d+)([A-Za-z])? (.*)<\/title/) 
		{
			my $j = $1;
			my $number  = $2;
			my $other = $3;
			$name = $4;
			
			if($j)	#嘉興藏的經號
			{
				$num = $j . sprintf("%03d",$number) . $other;
			}
			else
			{
				$num = sprintf("%04d",$number) . $other;
			}
		}
		
		if (m#<extent>(\d+?)卷</extent>#) 
		{
			$juan = $1;
		}
		if (/<body>/) 
		{
			$findbody = 1;
		}
		if($findbody == 1)
		{
			if (/(<lb\s[^>]*ed="${ed}"[^>]*>)/) 
			{
				my $tag = $1;
				if ($tag =~ /n="(.{7})"/) 
				{
					$lb = $1;
					last;
				}
			}
		}
	}
	
	if ($juan == 0) 
	{
		#$juan = 1;
		print stderr "error : no juan\n";
		exit;
		while (<I>) {
			if (/<cb:juan fun=\"open\" n=\"(.*?)\">/) 
			{
				$n = int($1);
				if ($n > $juan) { $juan = $n; }
			}
		}
	}
	close I;
	
	if ($name eq "") 
	{
		print stderr "error : no sutra name\n";
		exit;
	}
	
	#while ($name=~ /&(.*?);/) 
	#{
	#	if (exists($nor{$1})) 
	#	{
	#		my $n = $nor{$1};
	#		$name =~ s/&.*?;/$n/;
	#	}
	#	else 
	#	{
	#		die "$1";
	#	}
	#}
	
	print OUT "$vol##$num##$name##$juan##$lb\n";
}

# 以下用不到了 ####################################

=BEGIN
sub readGaiji {
	my $cb,$zu,$ent,$mojikyo,$ty;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = 'CB' . $row{"cb"};       # cbeta code
		$mojikyo = $row{"mojikyo"};  # mojikyo code
		$zu      = $row{"des"};      # 組字式
		$ty      = $row{"nor"};

		next if ($cb =~ /^#/);

		$ty = "" if ($ty =~ /none/i);
		$ty = "" if ($ty =~ /\x3f/);
		die "ty=[$ty]" if ($ty =~ /\?/);

		if ($ty ne '') {
			$nor{$cb} = $ty;
		} else {
			$nor{$cb} = $zu;
		}
	}
	$db->Close();
	print STDERR "ok\n";
}

sub readCbetaEnt {
	open I, "c:/cbwork/xml/dtd/cbeta.ent" or die "open error";
	while (<I>) {
		if (/<!ENTITY (\S*) +"(.*)"  >/) {
			$nor{$1} = $2;
			print STDERR "$1 => ",$nor{$1},"\n";
		}
	}
	close I;
}
=END
=cut

