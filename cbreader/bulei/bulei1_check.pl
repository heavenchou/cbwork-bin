# �ˬd bulei1_orig.txt �O�_�����Щίʤ�.
# �ѦҨӷ��O TaishoMenu_b5.txt �� XuzangjingMenu_b5.txt , JiaXingZangMenu_b5.txt , ZhengShiMenu_b5.txt , ZangWaiMenu_b5.txt

#�{����z��²��, ��Ū�J�W�z�ѦҨӷ��� big5 ��, �CŪ�@��, �U�g�O���[ 1 .
#�AŪ bulie1_orig.txt , �CŪ��@�g�����, �U�g�O���[ 10.
#�ҥH�Y�Y�@�g�O���O 11 , ��ܥ��O�зǪ�.
#�Y�u�� 1, ��ܦ��g�S���X�{�b bule1_orig.txt ��.
#�p�G�S�� 1 , �u�� 10, 20 .... , ��ܥ��u�X�{�b bule1_orig.txt
#�p�G�j�� 11 , ��ܦ��g���ФF.

# �n�ק諸�Ѽ�

my $bulei1 = "BuLei1_orig.txt";	# bulei4.txt ����m
my $taisho = "../TaishoMenu_b5.txt";		# �n big5 ���榡
my $xuzangjing = "../XuzangjingMenu_b5.txt";		# �n big5 ���榡
my $jiaxingzang = "../JiaXingZangMenu_b5.txt";		# �n big5 ���榡
my $zhengshi = "../ZhengShiMenu_b5.txt";		# �n big5 ���榡
my $zangwai = "../ZangWaiMenu_b5.txt";		# �n big5 ���榡
my $baipin = "../BaiPinMenu_b5.txt";		# �n big5 ���榡
my $out = "bulei1_chk_out.txt"; # ��X��

# �D�{��

my %jing;		# �H�U�g�����޼�, �b taisho �� xuzangjing �X�{���g��, �[ 1 , �b bulei4.txt �X�{�� �[ 10
my %vol;		# �U�g���U��

###############################
# Ū�J�U�åؿ�
###############################

#�j����
open IN, $taisho or die "open $taisho error.$!";
while(<IN>)
{
	#54,�ѩv�ۭz��,0866 ,  2,�F�ײ�                                   ,�i�� �f�F���j
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"T$2"} = $jing{"T$2"} + 1;
		$vol{"T$2"} = "T$1";
	}
}
close IN;
#������
open IN, $xuzangjing or die "open $xuzangjing error.$!";
while(<IN>)
{
	#54,�ѩv�ۭz��,0866 ,  2,�F�ײ�                                   ,�i�� �f�F���j
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"X$2"} = $jing{"X$2"} + 1;
		$vol{"X$2"} = "X$1";
	}
}
close IN;
#�ſ���
open IN, $jiaxingzang or die "open $jiaxingzang error.$!";
while(<IN>)
{
	#54,�ѩv�ۭz��,0866 ,  2,�F�ײ�                                   ,�i�� �f�F���j
	if(/^([AB]?\d+),.*?,(.*?)\s*,/)
	{
		$jing{"J$2"} = $jing{"J$2"} + 1;
		$vol{"J$2"} = "J$1";
	}
}
close IN;
# ���v
open IN, $zhengshi or die "open $zhengshi error.$!";
while(<IN>)
{
	#54,�ѩv�ۭz��,0866 ,  2,�F�ײ�                                   ,�i�� �f�F���j
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"H$2"} = $jing{"H$2"} + 1;
		$vol{"H$2"} = "H$1";
	}
}
close IN;
#�å~
open IN, $zangwai or die "open $zangwai error.$!";
while(<IN>)
{
	#54,�ѩv�ۭz��,0866 ,  2,�F�ײ�                                   ,�i�� �f�F���j
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"W$2"} = $jing{"W$2"} + 1;
		$vol{"W$2"} = "W$1";
	}
}
close IN;
#�ʫ~
open IN, $baipin or die "open $baipin error.$!";
while(<IN>)
{
	#54,�ѩv�ۭz��,0866 ,  2,�F�ײ�                                   ,�i�� �f�F���j
	if(/^(\d+),.*?,(.*?)\s*,/)
	{
		$jing{"I$2"} = $jing{"I$2"} + 1;
		$vol{"I$2"} = "I$1";
	}
}
close IN;

####################
# Ū�J����
####################

open IN, $bulei1 or die "open $bulei1 error.$!";
while(<IN>)
{
	#54,�ѩv�ۭz��,0866 ,  2,�F�ײ�                                   ,�i�� �f�F���j
	if(/^\s*([TXJWHI][AB]?\d{3,4}[A-Za-z]?)\s/)
	{
		$jing{"$1"} = $jing{"$1"} + 10;
	}
	if(/^\s*(((ZW)|(ZS))\d{3,4}[A-Za-z]?)\s/)	# ���v�P�å~���i��� Hxxxx , Wxxxx �� ZSxxxx , ZWxxxx (�٨S�Τ@)
	{
		# ���� ZS, ZW , �u�� HW
		#$jing{"$1"} = $jing{"$1"} + 10;
	}
}
close IN;

open OUT, ">$out" or die "open $out error $!";

	print OUT "======= ���b bulie4.txt ===========\n";
foreach $key (sort(keys(%jing)))
{
	print OUT "$vol{$key} , $key = $jing{$key}\n" if($jing{$key} < 10);
}
	print OUT "======= ������B�Ӫ��g��? ===========\n";
foreach $key (sort(keys(%jing)))
{
	print OUT "$key = $jing{$key}\n" if($jing{$key} =~ /0$/);	# �Ӧ�Ƥ��O 1
}
	print OUT "======= ���ХX�{.txt ===========\n";
foreach $key (sort(keys(%jing)))
{
	print OUT "$vol{$key} , $key = $jing{$key}\n" if($jing{$key}) > 11;
}

close OUT;