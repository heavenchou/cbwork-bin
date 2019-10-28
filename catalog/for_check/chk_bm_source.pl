##################################################################
# �ˬd�{���� tripitaka.txt �O�_�M BM �����e�ۦP
##################################################################

use File::Copy;
use Win32::ODBC;

##################################################################
# �`��
##################################################################

my $bm_path = "c:/cbwork/simple";		# xml �g�媺�ؿ�

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
#readCbetaEnt();		# Ū�� ent ��
read_vols();	# ���o�Ҧ����U��
read_catalog();	# Ū�J catalog

open OUT, ">chk_bm_source.txt" or die "open chk_bm_source.txt error";

# �B�z�U�U
foreach $vol (sort(@vols))
{
	$vol =~ /^(\D+)(.*)/;
	$book = $1;
	$volnum = $2;
	dodir($vol);
}

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
# �� vols_list.txt �N�U�U���J @vols ���|
##################################################################

sub read_vols
{
	open IN, "../vols_list.txt" or die "open vols_list.txt error. $!";
	while(<IN>)
	{
		chomp;
		my @d = split(/\s*,\s*/,$_);
		my $vol = $d[0] . $d[1];		# "T01"
		push(@vols,$vol);
	}
	close IN;
}

##################################################################
# �B�z�U�U
##################################################################

sub dodir
{
	$vol = shift;
	my $dir = "$bm_path/$vol/";
	if (not -e $dir) { return; }
	print STDERR "Run $dir ...\n";
	
	do1file($dir . "source.txt");
}

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
		#CR        L1651-157-p0815       V1.0   2010/10/08    1  ����ù�~�L��                     �i�� ���D������j
		if (/([TXJHWIABCFGKLMNPQSU])(\S{5})(\d+)[\-_].*?\s+.*?\s+.*?\s+(\d+?)\s+(\S*?)\s+�i(.*)�j/)
		{
			if($book ne $1)	{ print OUT "error $book ne $1"; }
			my $number = $2;
			if($volnum != $3) { print OUT "error $volnum ne $3"; }
			
			$juan = $4;
			$name = $5;
			$author = $6;
			
			$number =~ s/[\-\_]$//;

			if ($name =~ /\)$/)
			{
			#	$name = cut_note($name);	#�h���������A��
			}
			
			my $id = $vol . "n" . $number;
			
			if(($juan{$id} ne $juan) || ($name{$id} ne $name) || ($author{$id} ne $author))
			{
				print OUT "$id" . "," . $juan{$id} . "," . $name{$id} . "," . $author{$id} . "\n";
				print OUT "$id" . "," . $juan . "," . $name . "," . $author . "\n";
				print OUT "===================================================================\n";
			}
			
			$ok{$id} = 1;
			
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
			my $des = $gj_cb2des{$cb};
			s/&CB${cb};/$des/g;
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

		$table{$des} = $nor;
	}
	$db->Close();
	#print STDERR "ok\n";
}

#############################################################
# �h���r��������A��
# �� xxxx(yy) -> xxxx
# �p�� xxxx(yy[(zz)]) -> xxxx
#############################################################

sub cut_note()
{
	local $_ = $_[0];
	
	while (/\)$/)
	{
		while(not /\([^\)]*?\)$/)
		{
			s/\(([^\(]*?)\)/#1#$1#2#/g;
		}
	
		if (/\([^\)]*\)$/)
		{
			s/\([^\(]*\)$//;
		
		}
	
		s/#1#/\(/g;
		s/#2#/\)/g;
	}
	return $_;
}

##################################################################
# The END
##################################################################