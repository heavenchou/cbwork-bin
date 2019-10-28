##################################################################
# �ˬd�{���� tripitaka.txt �O�_�M BM �����e�ۦP
##################################################################

use File::Copy;
use Win32::ODBC;

require "c:/cbwork/work/bin/b52utf8.plx";

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

open OUT, ">chk_taisho.txt" or die "open chk_taisho.txt error";


do1file("../taisho.txt");

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
		next if /^#/;
		
		#  ���t����                        ���t���W      T0001-01-p0001 K0647-17  22  �����t�g(22��)     �i�᯳ ����C�٦@�Ǧ��Ķ�j
		
		if(/\s+(.*?)\s+(.*?)\s+T(.{5})(\d\d)\-.*\s+(.*?)\s+(\d+?)\s+(.*?)\s+(.*)/)
		{
			$book = "T";
			$number = $3;
			$vol = $4;
			$juan = $6;
			$name = $7;
			$author = $8;
			
			$number =~ s/\-//;
			#$name =~ s/\(${juan}��\)//;
			$author =~ s/�i(.*)�j/$1/;
			#$name =~ s/\(.*?\)$//;
	
			my $id = $book . $vol . "n" . $number;
			
			if(($juan{$id} ne $juan) || ($name{$id} ne $name) || ($author{$id} ne $author))
			{
				print OUT "$id" . "," . $juan{$id} . "," . $name{$id} . "," . $author{$id} . "\n";
				print OUT "$id" . "," . $juan . "," . $name . "," . $author . "\n";
				print OUT "===================================================================\n";
			}
			
			$ok{$id} = 1;
		}
		else
		{
			print OUT "format error : $_\n";
		}
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
			$word = $gj_cb2des{$cb};
			s/&CB${cb};/$word/g;
		}
		
		my @d = split(/,/,$_);
		next if $d[1] ne "T";	# �u�n�j����
		
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
		$flag    = $row{"uni_flag"};
		$uni     = $row{"uni"};

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