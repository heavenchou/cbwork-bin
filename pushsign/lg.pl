##################################################################################
# 將 <lg...><l>「  改成  <lg ... style="margin-left:1em;text-indent:-1em"><l>「 
# 將 <lg...><l>「『  改成  <lg ... style="margin-left:2em;text-indent:-2em"><l>「『 
# 將 <lg...><l>　「  改成  <lg ... style="margin-left:2em;text-indent:-1em"><l>「 
# 將 <lg...><l>　「『  改成  <lg ... style="margin-left:3em;text-indent:-2em"><l>「『  
##################################################################################
use utf8;

my $in = shift;		# 輸入檔名, 若是批次檔的參數, 可用 $in = shift; 即可
my $out = shift;			# 輸出檔名, 若是批次檔的參數, 可用 $out = shift; 即可

open IN, "<:utf8", $in;
open OUT, ">:utf8", $out;
my $space = '　';

while(<IN>)
{
	if(/(<lg\s*[^>]*?>)(<l[^>]*?>)?($space)?「(.?)/)
	{
		my $lg = $1;
		my $l = $2;
		my $sp = $3;
		my $second = $4;
		
		my $indent1 = "1em";
		my $indent2 = "1em";
		if($sp eq '　')
		{
			$indent1 = "2em";
		}
		if($second eq "『")
		{
			$indent1 = "2em";
			$indent2 = "2em";
			if($sp eq '　')
			{
				$indent1 = "3em";
			}
		}
		
		if($lg =~ /style/)	# 有 style 了, 加上 xxx , 讓它 parse 不過請手動處理
		{
			$lg =~ s/<lg /<lg todo="請手動改style" /;
		}
		else
		{
			$lg =~ s/>/ style="margin-left:${indent1};text-indent:-${indent2}">/;
		}

		s/(<lg\s*[^>]*?>)(<l[^>]*?>)?($space)?(「.?)/$lg$2$4/;
	}
	print OUT;
}
close IN;
close OUT;