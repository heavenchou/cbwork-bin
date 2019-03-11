###################
# 移除新標中的標點
###################

use utf8;

my $infile = shift;
my $outfile = shift;

open IN, "<:utf8", $infile;
open OUT, ">:utf8", $outfile;

while(<IN>)
{
	print OUT $_;
	if(/<body>/)
	{
		last;
	}
}

while(<IN>)
{
	$_ = dothisline($_);
	print OUT $_;
}

close IN;
close OUT;

###################
# 處理本行
###################
sub dothisline
{
	local $_ = shift;
	my $result = "";
	
	while(1)
	{
		# 註解中的標點不要動
		if(/^<note[^>]*?type="((orig)|(mod))".*?>.*?<\/note>/)
		{
			s/^(<note[^>]*?type="((orig)|(mod))".*?>.*?<\/note>)//;
			$result .= $1;
			next;
		}
		
		# 處理標記
		if(/^<.*?>/)
		{
			s/^(<.*?>)//;
			$result .= $1;
			next;
		}
		
		# 處理純文字
		if(/^[^<]+/)
		{
			s/^([^<]+)//;
			my $tmp = $1;
			# 移除新標
			$tmp =~ s/(。)|(、)|(，)|(．)|(；)|(：)|(「)|(」)|(『)|(』)|(（)|(）)|(？)|(！)|(—)|(…)|(《)|(》)|(〈)|(〉)|(“)|(”)//g;
			$result .= $tmp;
			next;
		}
		
		if($_ eq "\n")
		{
			$result .= "\n";
			$_ = "";
			next;
		}
		
		if($_ eq "")
		{
			last;
		}
	}
	
	return $result;
}