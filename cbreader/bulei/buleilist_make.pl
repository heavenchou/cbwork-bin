
open IN, "buleiBL_orig.txt" or die "open error";
@lines = <IN>;
close IN;

open OUT, ">BuleiList.txt";

my $nowpart;

for($i =0; $i<=$#lines; $i++)
{
	
#01 ���t���� T01-02,25,33
#	T0001-25 �����t�g�� T01
#		T0001 �����t�g22��
#		T0002-25 �����t�g�楻
#			T0002 �C��g1��

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
		$body[$i] = "T0220" if($body[$i] eq "T0220a");	# �B�z�j��Y�g
		next if($body[$i] =~ /T0220[b-o]/);
		print OUT "#" if($body[$i] eq "T0310(5)");		# �L�X #16,T0310(5)
		
		$body[$i] = "X0240" if($body[$i] eq "X0240a");	# ��U�n�B�z�����
		next if($body[$i] eq "X0240b");					# ��U�n�B�z�����
		$body[$i] = "X0367" if($body[$i] eq "X0367a");	# ��U�n�B�z�����
		next if($body[$i] eq "X0367b");					# ��U�n�B�z�����
		$body[$i] = "X0714" if($body[$i] eq "X0714a");	# ��U�n�B�z�����
		next if($body[$i] eq "X0714b");					# ��U�n�B�z�����
		$body[$i] = "X0822" if($body[$i] eq "X0822a");	# ��U�n�B�z�����
		next if($body[$i] eq "X0822b");					# ��U�n�B�z�����
		$body[$i] = "X1568" if($body[$i] eq "X1568a");	# ��U�n�B�z�����
		next if($body[$i] eq "X1568b");					# ��U�n�B�z�����
		$body[$i] = "X1571" if($body[$i] eq "X1571a");	# ��U�n�B�z�����
		next if($body[$i] eq "X1571b");					# ��U�n�B�z�����
		
		$body[$i] = "JB271" if($body[$i] eq "JB271a");	# ��U�n�B�z�����
		next if($body[$i] eq "JB271b");					# ��U�n�B�z�����
		$body[$i] = "JB277" if($body[$i] eq "JB277a");	# ��U�n�B�z�����
		next if($body[$i] eq "JB277b");					# ��U�n�B�z�����

		$body[$i] = "A1276" if($body[$i] eq "A1276a");	# ��U�n�B�z�����
		next if($body[$i] eq "A1276b");					# ��U�n�B�z�����
		$body[$i] = "A1501" if($body[$i] eq "A1501a");	# ��U�n�B�z�����
		next if($body[$i] eq "A1501b");					# ��U�n�B�z�����
		$body[$i] = "A1565" if($body[$i] eq "A1565a");	# ��U�n�B�z�����
		next if($body[$i] eq "A1565b");					# ��U�n�B�z�����

		$body[$i] = "B0001" if($body[$i] eq "B0001a");	# ��U�n�B�z�����
		next if($body[$i] eq "B0001b");					# ��U�n�B�z�����
		$body[$i] = "B0002" if($body[$i] eq "B0002a");	# ��U�n�B�z�����
		next if($body[$i] eq "B0002b");					# ��U�n�B�z�����
		next if($body[$i] eq "B0002c");					# ��U�n�B�z�����
		$body[$i] = "B0088" if($body[$i] eq "B0088a");	# ��U�n�B�z�����
		next if($body[$i] eq "B0088b");					# ��U�n�B�z�����
		
		$body[$i] = "C1163" if($body[$i] eq "C1163a");	# ��U�n�B�z�����
		next if($body[$i] eq "C1163b");					# ��U�n�B�z�����
		
		$body[$i] = "GA0010" if($body[$i] eq "GA0010a");	# ��U�n�B�z�����
		next if($body[$i] eq "GA0010b");					# ��U�n�B�z�����
		$body[$i] = "GA0032" if($body[$i] eq "GA0032a");	# ��U�n�B�z�����
		next if($body[$i] eq "GA0032b");					# ��U�n�B�z�����
		$body[$i] = "GA0084" if($body[$i] eq "GA0084a");	# ��U�n�B�z�����
		next if($body[$i] eq "GA0084b");					# ��U�n�B�z�����
		$body[$i] = "GA0089" if($body[$i] eq "GA0089a");	# ��U�n�B�z�����
		next if($body[$i] eq "GA0089b");					# ��U�n�B�z�����
		next if($body[$i] eq "GA0089c");					# ��U�n�B�z�����
		
		$body[$i] = "K1257" if($body[$i] eq "K1257a");	# ��U�n�B�z�����
		next if($body[$i] eq "K1257b");					# ��U�n�B�z�����
		
		$body[$i] = "L1490" if($body[$i] eq "L1490a");	# ��U�n�B�z�����
		next if($body[$i] eq "L1490b");					# ��U�n�B�z�����
		$body[$i] = "L1557" if($body[$i] eq "L1557a");	# ��U�n�B�z�����
		next if($body[$i] =~ /L1557[bcd]/);				# ��U�n�B�z�����
		$body[$i] = "L1638" if($body[$i] eq "L1638a");	# ��U�n�B�z�����
		next if($body[$i] eq "L1638b");					# ��U�n�B�z�����

		$body[$i] = "P1519" if($body[$i] eq "P1519a");	# ��U�n�B�z�����
		next if($body[$i] eq "P1519b");					# ��U�n�B�z�����
		$body[$i] = "P1611" if($body[$i] eq "P1611a");	# ��U�n�B�z�����
		next if($body[$i] eq "P1611b");					# ��U�n�B�z�����
		$body[$i] = "P1612" if($body[$i] eq "P1612a");	# ��U�n�B�z�����
		next if($body[$i] eq "P1612b");					# ��U�n�B�z�����
		next if($body[$i] eq "P1612c");					# ��U�n�B�z�����
		$body[$i] = "P1615" if($body[$i] eq "P1615a");	# ��U�n�B�z�����
		next if($body[$i] eq "P1615b");					# ��U�n�B�z�����
		next if($body[$i] eq "P1615c");					# ��U�n�B�z�����
		$body[$i] = "P1617" if($body[$i] eq "P1617a");	# ��U�n�B�z�����
		next if($body[$i] eq "P1617b");					# ��U�n�B�z�����

		$body[$i] = "U1418" if($body[$i] eq "U1418a");	# ��U�n�B�z�����
		next if($body[$i] eq "U1418b");					# ��U�n�B�z�����

		$body[$i] = "DA0004" if($body[$i] eq "DA0004a");	# ��U�n�B�z�����
		next if($body[$i] eq "DA0004b");					# ��U�n�B�z�����
		$body[$i] = "DA0005" if($body[$i] eq "DA0005a");	# ��U�n�B�z�����
		next if($body[$i] =~ /DA0005[b-h]/);				# ��U�n�B�z�����


		print OUT "$nowpart,$body[$i]\n";
	}
}

print OUT "$nowpart,$body[$#lines]\n";

close OUT;