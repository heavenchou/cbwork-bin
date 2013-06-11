######################################################################################
# �{�������G�N���w�ؿ������ɮצX���@�Ӥj��                        by heaven 2013/06/12
# �ϥΤ�k�G
#       perl connect.pl -s �ӷ��ؿ����ɮ׺��� -o ��X���G���ɮ� [-c -v -d]
# �Ѽƻ����G
#       -s �ӷ��ؿ��A�n�]�t�ɮת������Ҧ��A�Ҧp -s c:\temp\*.txt
#       -o ���G�ɮסA�Ҧp -o c:\out.txt
#       -c �����歺�A�p�G�歺�O T01n0001_a01�� �o�ث���A�Ҥ@�߲���
#       -v �ɮ׫e�Q��Y�� V1.0 �o�ت����榡�A�@�ߴ��� Vv.v�A�H��K���
#       -d �ɮ׫e�Q��Y�� 2013/06/11 �o�ؤ���榡�A�@�ߴ��� yyyy/mm/dd�A�H��K���
# �d�ҡG
#       perl connect.pl -s c:\release\bm\normal\T01\*.txt -o c:\temp\T01.txt -c -v -d
######################################################################################

#use utf8;	# ���n�ϥ� utf8 �ӳB�z, �ܤ֤���T����K�e�{
use Encode;
use strict;
use autodie;
use Getopt::Std;
use vars qw($opt_s $opt_o $opt_c $opt_v $opt_d);		# �p�G���ϥ� use strict; , ����N�n�[�W�h

############################################################
# �ܼ�
############################################################

my $code = "";	# �P�_�s�X�O utf8 �� big5
my $endline = encode("utf8",decode("big5", "��"));	# ���Ÿ��� utf8 �s�X

############################################################
# �ˬd�Ѽ�
############################################################

getopts('s:o:cvd');

print "�i�ɮצX�ֵ{���j\n";

if($opt_s eq "")
{
	print "���~�G�S���ϥ� -s �Ѽ�\n";
	exit;
}
if($opt_o eq "")
{
	print "���~�G�S���ϥ� -o �Ѽ�\n";
	exit;
}

print "�ӷ���m : $opt_s\n";
print "��X�ɮ� : $opt_o\n";

############################################################
# �D�{��
############################################################

my @file = <${opt_s}>;
open OUT, ">$opt_o";
foreach my $filename (sort (@file))
{
	print STDERR "�B�z�� ... => $filename\n";
	open IN, "$filename";
	my $linenum = 0;
	while (<IN>)
	{
		$linenum++;
		chomp ;
		if($code eq "")		# �٨S�P�_�s�X
		{
			$code = check_encoding($_);
		}
		
		# �O�_�n�����歺
		if($opt_c) 
		{
			$_ = cut_head($_);
		}
		
		if($linenum <= 10)
		{
			# �B�z�����O��������P����
			#�i�����O���jCBETA �q�l��� V1.0 (Big5) ���Ϊ��A��������G2003/08/29
			#�i�����O���jCBETA �q�l��� Vv.v (Big5) ���Ϊ��A��������Gyyyy/mm/dd
			# CBETA Chinese Electronic Tripitaka V1.0 (Big5) Normalized Version, Release Date: 2003/08/29
			# CBETA Chinese Electronic Tripitaka Vv.v (Big5) Normalized Version, Release Date: yyyy/mm/dd
			
			# �O�_�ק睊���榡
			if($opt_v)
			{
				s/V\d+\.\d+/Vv.v/g;
			}
			# �O�_�ק����榡
			if($opt_d)
			{
				s/\d{4}\/\d+\/\d+/yyyy\/mm\/dd/g;
			}
		}
		
		print OUT "$_\n";
	}
	close IN;
}
close OUT;

print "�B�z����.\n\n";
############################################################
# �P�_�s�X
############################################################

sub check_encoding
{
	local $_ = shift;
	return "" if($_ !~ /[\x81-\xFD]/);	# �P�_���X big5 �� utf8
	
	my $tmp = encode("big5",decode("big5",$_));
	return "big5" if($tmp eq $_);
		
	$tmp = encode("utf8",decode("utf8",$_));
	return "utf8" if($tmp eq $_);
	
	return "";	# �P�_���X big5 �� utf8
}

############################################################
# �����歺
############################################################

sub cut_head
{
	local $_ = shift;
	
	if($code eq "big5")
	{
		s/^\D*\d\dn.{5}p\d{4}.\d\d.*?��//;
	}
	
	if($code eq "utf8")
	{
		s/^\D*\d\dn.{5}p\d{4}.\d\d.*?${endline}//;
	}
	
	return $_;
}

############################################################
# End
############################################################