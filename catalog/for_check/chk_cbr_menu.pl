##################################################################
# �ˬd�{���� tripitaka.txt �O�_�M BM �����e�ۦP
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

readGaiji();		# Ū���ʦr��
read_catalog();	# Ū�J catalog

open OUT, ">chk_cbr_menu.txt" or die "open chk_menu.txt error";


do1file("cbr_menu.txt");

# �ݦ��S���S�B�z�쪺���

foreach $key (sort(keys(%juan)))
{
	if($ok{$key} != 1)
	{
		print OUT "\n$key �S���B�z��";
	}
}
close OUT;

print "\nok\n";


##################################################################
# �B�z�U�ɮ�
##################################################################

sub do1file
{
	my $file = shift;
	
	my $juan;	# ����
	my $name;	# �g�W
	my $author;	# �@Ķ��
	my $normal_juan = 1;	# �P�_�O�_�O���`���s����
	my @lbs;	# �U���� ����� ��T
	
	print STDERR "$file\n";
	open IN, $file or die "open $file error. $!";
	
	$juan = 0;
	while (<IN>)
	{
		chomp;
		#I,01,  ,0001, 1 ,�X�����u�֦x�O                  ,�i�C�S�^�D�s�j
		($book, $vol, $part, $number, $juan, $name, $author) = split(/\s*,\s*/,$_);
		$author =~ s/�i(.*)�j/$1/;
	
	
			my $id = $book . $vol . "n" . $number;
			
			if(($juan{$id} ne $juan) || ($name{$id} ne $name) || ($author{$id} ne $author))
			{
				print OUT "$id" . "," . $juan{$id} . "," . $name{$id} . "," . $author{$id} . "\n";
				print OUT "$id" . "," . $juan . "," . $name . "," . $author . "\n";
				print OUT "===================================================================\n";
			}
			
			$ok{$id} = 1;
	}
}

##################################################################
# Ū�J catalog
##################################################################

sub read_catalog
{
	open IN, "../catalog.txt";
	while(<IN>)
	{
		#A091n1066,A,091,1066,2,1,�sĶ�j��s����Y�g���q,�� �z�`�z
		chomp;
		
		# �������զr��
		while(/&CB(\d{5});/)
		{
			my $cb = $1;
			if($gj_cb2nor{$cb})
			{
				$word = $gj_cb2nor{$cb};
			}
			else
			{
				$word = $gj_cb2des{$cb};
			}
			s/&CB${cb};/$word/g;
		}
		
		my @d = split(/,/,$_);
		my $id = $d[0];
		$juan{$id} = $d[4];
		$name{$id} = $d[6];
		$author{$id} = $d[7];
	}
}

##################################################################
# Ū�J gaiji
##################################################################

sub readGaiji 
{
	my $cb,$des,$ent,$mojikyo,$nor;
	#print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		
		$cb      = $row{"cb"};		# cbeta code
		$des     = $row{"des"};		# �զr��
		$nor     = $row{"nor"};		# �q�Φr

		if($cb =~ /^x/)		# �q�ε�
		{
			push (@key, $des);
			#push (@table2, $nor);
			$table2{$des} = $nor;
			next;
		}

		next if ($cb !~ /^\d/);
		$gj_cb2des{$cb} = $des;
		
		next if ($nor eq "");

		$gj_cb2nor{$cb} = $nor;
		$gj_des2nor{$des} = $nor;
	}
	$db->Close();
	#print STDERR "ok\n";
}

##################################################################
# The END
##################################################################