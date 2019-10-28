##################################################################
# �ˬd juanline �ؿ��P cbreader �� juanline �O�_�ۦP
##################################################################

use File::Copy;
use Win32::ODBC;

##################################################################
# �`��
##################################################################


##################################################################
# �ܼ�
##################################################################

my @vols;	# �������U�ƦC��
my $id;			# T01n0001
my $book;		# T
my $vol;		# T01
my $volnum;		# 01
my $number;		# 0001

##################################################################
# �D�{��
##################################################################


open OUT, ">chk_juanline.txt" or die "open chk_juanline.txt error";

open IN, "../vols_list.txt" or die "open vols_list.txt error";
while(<IN>)
{
	chomp;
	$_ =~ s/,//;
	
	my $file = $_ . ".txt";
	
	print "$file ... \n";
	
	checkfile($file);
}
close IN;

close OUT;


##################################################################
# �B�z�U�ɮ�
##################################################################

sub checkfile
{
	local $_;
	my $file = shift;
	
	open IN1, "../juandata/$file" or die "open ../juandata/$file error";
	open IN2, "c:/cbeta/cbreader/juanline/$file" or die "open c:/cbeta/cbreader/juanline/$file error";

	my @line1 = <IN1>;
	my @line2 = <IN2>;
	
	if($#line1 != $#line2)
	{
		# �ɮת��פ��P
		print OUT "$file line diff:" . $#line1 . " vs " . $#line2 . "\n";
		return;
	}
	
	for($i=0; $i<=$#line1; $i++)
	{
		#A098n1276,A,098,1276,1,5,0001b01
		chomp($line1[$i]);
		my @a = split(/,/,$line1[$i]);
		$a[3] =~ s/0220./0220/;		# �j��Y�g
		
		#0001b01, 1276 , 005
		chomp($line2[$i]);
		$line2[$i] =~ s/\s//g;
		my @b = split(/,/,$line2[$i]);
		#$b[2] =~ s/^0*//;
		
		if(($a[6] ne $b[0]) || ($a[3] ne $b[1]) || ($a[5] != $b[2]))
		{
			print OUT "$file : " . $line1[$i] . " vs " . $line2[$i] . "\n";
		}
	}
	
	close IN1;
	close IN2;
}

##################################################################
# The END
##################################################################