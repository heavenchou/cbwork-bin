# 檢查 buleiX_orig.txt 有沒有重覆的卍續藏經文

open IN, "buleiX_orig.txt";		# 改這一行也可以檢查 buleiX_orig.txt , buleiXB_orig.txt
while(<IN>)
{
	if(/^\s*(X\d{4}[a-z]?)/i)
	{
		$tmp = $1;
		$hash{$tmp} = $hash{$tmp} + 1;
	}
}
$found = 0;
for $key (keys(%hash))
{
	if($hash{$key} > 1)
	{
		$found++;
		print "$key\n";
	}
}
if($found == 0)
{
	print "OK\n" ;
}
else
{
	print "Oh! NO Good , please check ....\n" ;
}

print "press any key exit...";
<>;
