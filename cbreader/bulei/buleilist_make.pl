
open IN, "buleiBL_orig.txt" or die "open error";
@lines = <IN>;
close IN;

open OUT, ">BuleiList.txt";

my $nowpart;

for($i =0; $i<=$#lines; $i++)
{
	
#01 阿含部類 T01-02,25,33
#	T0001-25 長阿含經類 T01
#		T0001 長阿含經22卷
#		T0002-25 長阿含經單本
#			T0002 七佛經1卷

	$lines[$i] =~ /^(\s*)(\S+)\s/;
	$head[$i] = $1;
	$body[$i] = $2;
}

for($i =0; $i<$#lines; $i++)
{
	if($head[$i] eq "")
	{
		$nowpart = $body[$i];
	}
	elsif(length($head[$i])>=length($head[$i+1]))
	{
		$body[$i] = "T0220" if($body[$i] eq "T0220a");	# 處理大般若經
		next if($body[$i] =~ /T0220[b-o]/);
		print OUT "#" if($body[$i] eq "T0310(5)");		# 印出 #16,T0310(5)
		
		$body[$i] = "X0240" if($body[$i] eq "X0240a");	# 跨冊要處理的資料
		next if($body[$i] eq "X0240b");					# 跨冊要處理的資料
		$body[$i] = "X0367" if($body[$i] eq "X0367a");	# 跨冊要處理的資料
		next if($body[$i] eq "X0367b");					# 跨冊要處理的資料
		$body[$i] = "X0714" if($body[$i] eq "X0714a");	# 跨冊要處理的資料
		next if($body[$i] eq "X0714b");					# 跨冊要處理的資料
		$body[$i] = "X0822" if($body[$i] eq "X0822a");	# 跨冊要處理的資料
		next if($body[$i] eq "X0822b");					# 跨冊要處理的資料
		$body[$i] = "X1568" if($body[$i] eq "X1568a");	# 跨冊要處理的資料
		next if($body[$i] eq "X1568b");					# 跨冊要處理的資料
		$body[$i] = "X1571" if($body[$i] eq "X1571a");	# 跨冊要處理的資料
		next if($body[$i] eq "X1571b");					# 跨冊要處理的資料
		
		$body[$i] = "JB271" if($body[$i] eq "JB271a");	# 跨冊要處理的資料
		next if($body[$i] eq "JB271b");					# 跨冊要處理的資料
		$body[$i] = "JB277" if($body[$i] eq "JB277a");	# 跨冊要處理的資料
		next if($body[$i] eq "JB277b");					# 跨冊要處理的資料

		$body[$i] = "A1276" if($body[$i] eq "A1276a");	# 跨冊要處理的資料
		next if($body[$i] eq "A1276b");					# 跨冊要處理的資料
		$body[$i] = "A1501" if($body[$i] eq "A1501a");	# 跨冊要處理的資料
		next if($body[$i] eq "A1501b");					# 跨冊要處理的資料
		$body[$i] = "A1565" if($body[$i] eq "A1565a");	# 跨冊要處理的資料
		next if($body[$i] eq "A1565b");					# 跨冊要處理的資料

		$body[$i] = "B0001" if($body[$i] eq "B0001a");	# 跨冊要處理的資料
		next if($body[$i] eq "B0001b");					# 跨冊要處理的資料
		$body[$i] = "B0002" if($body[$i] eq "B0002a");	# 跨冊要處理的資料
		next if($body[$i] eq "B0002b");					# 跨冊要處理的資料
		next if($body[$i] eq "B0002c");					# 跨冊要處理的資料
		$body[$i] = "B0088" if($body[$i] eq "B0088a");	# 跨冊要處理的資料
		next if($body[$i] eq "B0088b");					# 跨冊要處理的資料
		
		$body[$i] = "C1163" if($body[$i] eq "C1163a");	# 跨冊要處理的資料
		next if($body[$i] eq "C1163b");					# 跨冊要處理的資料
		
		$body[$i] = "GA0010" if($body[$i] eq "GA0010a");	# 跨冊要處理的資料
		next if($body[$i] eq "GA0010b");					# 跨冊要處理的資料
		$body[$i] = "GA0032" if($body[$i] eq "GA0032a");	# 跨冊要處理的資料
		next if($body[$i] eq "GA0032b");					# 跨冊要處理的資料
		$body[$i] = "GA0084" if($body[$i] eq "GA0084a");	# 跨冊要處理的資料
		next if($body[$i] eq "GA0084b");					# 跨冊要處理的資料
		$body[$i] = "GA0089" if($body[$i] eq "GA0089a");	# 跨冊要處理的資料
		next if($body[$i] eq "GA0089b");					# 跨冊要處理的資料
		next if($body[$i] eq "GA0089c");					# 跨冊要處理的資料
		
		$body[$i] = "K1257" if($body[$i] eq "K1257a");	# 跨冊要處理的資料
		next if($body[$i] eq "K1257b");					# 跨冊要處理的資料
		
		$body[$i] = "L1490" if($body[$i] eq "L1490a");	# 跨冊要處理的資料
		next if($body[$i] eq "L1490b");					# 跨冊要處理的資料
		$body[$i] = "L1557" if($body[$i] eq "L1557a");	# 跨冊要處理的資料
		next if($body[$i] =~ /L1557[bcd]/);				# 跨冊要處理的資料
		$body[$i] = "L1638" if($body[$i] eq "L1638a");	# 跨冊要處理的資料
		next if($body[$i] eq "L1638b");					# 跨冊要處理的資料

		$body[$i] = "P1519" if($body[$i] eq "P1519a");	# 跨冊要處理的資料
		next if($body[$i] eq "P1519b");					# 跨冊要處理的資料
		$body[$i] = "P1611" if($body[$i] eq "P1611a");	# 跨冊要處理的資料
		next if($body[$i] eq "P1611b");					# 跨冊要處理的資料
		$body[$i] = "P1612" if($body[$i] eq "P1612a");	# 跨冊要處理的資料
		next if($body[$i] eq "P1612b");					# 跨冊要處理的資料
		next if($body[$i] eq "P1612c");					# 跨冊要處理的資料
		$body[$i] = "P1615" if($body[$i] eq "P1615a");	# 跨冊要處理的資料
		next if($body[$i] eq "P1615b");					# 跨冊要處理的資料
		next if($body[$i] eq "P1615c");					# 跨冊要處理的資料
		$body[$i] = "P1617" if($body[$i] eq "P1617a");	# 跨冊要處理的資料
		next if($body[$i] eq "P1617b");					# 跨冊要處理的資料

		$body[$i] = "U1418" if($body[$i] eq "U1418a");	# 跨冊要處理的資料
		next if($body[$i] eq "U1418b");					# 跨冊要處理的資料

		$body[$i] = "DA0004" if($body[$i] eq "DA0004a");	# 跨冊要處理的資料
		next if($body[$i] eq "DA0004b");					# 跨冊要處理的資料
		$body[$i] = "DA0005" if($body[$i] eq "DA0005a");	# 跨冊要處理的資料
		next if($body[$i] =~ /DA0005[b-h]/);				# 跨冊要處理的資料


		print OUT "$nowpart,$body[$i]\n";
	}
}

print OUT "$nowpart,$body[$#lines]\n";

close OUT;