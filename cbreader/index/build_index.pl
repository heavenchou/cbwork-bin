####################################################
#  �إ� Index �����˯��ɪ��{�� V2.0 by heaven
# 
# normal : ���n�q�Φr, ���n���Y, ���n�հ�
# utf8 normal ���ͪ���k:
#
#   1. �� p5totxt.py ���� utf8 �� normal ��, ���n���Y, ���n�հ�, ���n�q��, �@���@��, �x��r�� &SD-xxxx;
#      �� : p5totxt.py -a -u -x 1 -z -v T01
#   2. �A�� u8-b5.py �ন big5 normal , ���n�ϥγq�Φr, �D big5 ���r�|�ন�զr��. �n�O�o�ίS�O�B�z�L��媺 u8-b5 ����, ���N�|�ন &#Xxxxx; , �Ӥ��O�iA�j�o�صL�k�˯�������.
#      �� : u8-b5_japan.py -s c:/temp/u8 -o c:/temp/u8_to_b5
#
# 2002/09/30 V0.1 ���K��
# 2002/10/09 V0.2 �ק� index ���覡
# 2002/11/02 V0.3 �o�@���O�令�H�G�i�쪺�覡�x�s���, �H�K c �y���{��Ū��, 
#                 �o�@������N�L�k�t�X perl  �� search.pl �F
# 2002/11/03 V0.4 ��}���ͯ��ު��t��, ���|�]���j�ɦӳB�z�ӺC�F
# 2002/12/03 V0.5 �i�H�B�z�զr��, ���զr�����O���I, ��᭫�I�O &CB �X�a!
# 2003/07/23 V0.6 �N������Y, �H�٪Ŷ�
# 2003/11/08 V0.7 �J��ʦr��, �P�ɳB�z�q�Φr, �զr�� unicode , �]�N�O�@�r���T�Ӹ��
# 2003/12/14 V0.8 �p��r�Ƥήɶ�
# 2004/01/14 V0.9 �B�z�e�{�e��
# 2005/06/29 V1.0 �n���������P��, �åB�B�z�q�ε������ްO�� (�q�Φr, �զr��, unicode ���n�O��)
# 2006/01/06 V1.1 1.�ק�զr���P�_����k,�� gaiji-m �̭����зǲզr�� (�]�����Ǧr�p [�B�{�B],�S��+-*/@)
#                 2.�B�z�s����,�n�h�����@�Ǽ��I�@�D�B�A�G�F�C�H�I�X�K�u�v�y�z�q�r�m�n���� �]�^�i�j�e�f
#                 3.�����i�ϡj
# 2014/03/22 V2.0 1. P5 ��
#                 2. ���A�ϥγq�ε�
#                 3. unicode 1.1 ���򥻦r��, unicode 1.1 (uni_flag = 1) �H�����r���B�z�զr���γq�Φr.
#                 4. �����O�f�t CBReader V5.1
# 2014/05/08 V2.1 1. �W�@���� nor_uni ���F unicode , �]���y���Y�b 3.0 ������ nor_uni ������ unicode , �]���S�� "�զr��" �� "big5�q�Φr" ���d�ߤF.
#                 �����ץ��� bug . �åB�Y�Y�r���q�Φr�γq��unicode , �ҦC�J�˯��d��, �N��Y�ǳq�Φr�S���|�e�{(�]����q��unicode�O 1.0), �]�|�Q�˯���.
#                 �]���̦h�@�Ӧr���|���˯� : �զr, �q��, unicode, �q��unicode . �����i��P�ɥX�{ unicode �γq��unicode.
#                 2. �����O�f�t CBReader V5.2
####################################################

use strict;

#---------------------------------------------------
# �Ѽ�
#---------------------------------------------------

my $debug = 0;
my $buildlist = "buildlist.txt";

#my $headndexfile = "headindex.ndx";	# ��j�����ɪ���m, �������c�O "�ɮ׽s��_����(�έ^��)"
my $preindexfile = "preindex.ndx";		# ��j�����ɪ���m, �������c�O "�ɮ׽s��_����(�έ^��)"
my $tmpindexfile = "tmpindex.ndx";		# �Ȧs�ʪ��j�����ɪ��W�r
my $lastindexfile = "main.ndx";			# �j�����ɪ��W�r
my $wordindexfile = "wordindex.ndx";	# word index ���ɦW

#---------------------------------------------------
# �ܼ�
#---------------------------------------------------

my $total_word_count = 0;	# �������r��
my $total_word_use = 0;		# �����ϥΪ��r��

my @files;				# �ɦW

my @head_index;			# �s�� preindex ���C�@���ɮת��}�Y��m
my %preindex;			# ��j�����ɪ���m, �������c�O "�ɮ׽s��_����(�έ^��)"
my %one_file_index;		# ��@�ɮת�������
my %word_index;			# �s��C�@�Ө��쪺�r, ��}�l�O�P�_�O�_�����r, ��ӬO�b last index ����m

my %word_index_onefile;	# �ΨӧP�_��@�ɮפ�, �X�{���@�Ǧr, �H���� %how_many_file_has �ϥ�
my %how_many_file_has;	# �O�����r���h���ɮץΨ�. �Q�� %word_index_onefile �ӳB�z


my @file_list;
my @file_list_bit;		# �� @file_list ���Y�Ӧ���
my @word_count;
my @word_pos;
my @sort_word;

# �ʦr�Ϊ�

my %uni;		# �ѼƬO�զr��, �Ǧ^ unicode		
my %nor;		# �ѼƬO�զr��, �Ǧ^�q�Φr	
my %nor_uni;	# �ѼƬO�զr��, �Ǧ^�q�� unicode
my %uni_flag; 	# �ѼƬO�զr��, �Ǧ^ unicode �O���O�b unicode 1.1 ������? 1 ��ܬO.	
my %zu;			# �ѼƬO�զr��, �Ǧ^ 1 ��ܦ��r�O�b gaiji-m �����зǲզr�� V1.1

# �s���аO���P�_ �D�B�A�G�F�C�H�I�X�K�u�v�y�z�q�r�m�n���� �]�^�i�j�e�f
# "��",'�@','��' �o�Ǥ]�[�J
my %newsign = (
	"�D",1,
	"�B",1,
	"�A",1,
	"�G",1,
	"�F",1,
	"�C",1,
	"�H",1,
	"�I",1,
	"�X",1,
	"�K",1,
	"�u",1,
	"�v",1,
	"�y",1,
	"�z",1,
	"�q",1,
	"�r",1,
	"�m",1,
	"�n",1,
	"��",1,
	"��",1,
	"�]",1,
	"�^",1,
	"�i",1,
	"�j",1,
	"�e",1,
	"�f",1,
	'��',1,
	'�@',1,
	'��',1);

local *PREINDEX;
local *TMPINDEX;
local *LASTINDEX;

#---------------------------------------------------
# �`��(patten)
#---------------------------------------------------

my $DEBUG = 1;

my $big5 = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
my $a_word = '(?:\[${big5}+?\])';
my $chinese = '(?:[\x80-\xff][\x00-\xff])';
my $fullspace = '(?:�@)';
my $allspace = '(?:(?:�@)|\s)';

#---------------------------------------------------
# �q�ε��n��ʳB�z
#---------------------------------------------------
# V2.0 P5 �S���q�ε��F

#my @CI_Word;
#my @CI_Code;
#my %CI_des;
#my %CI_nor;
#my %CI_uni;

# ���U�o�@�q�{���i�H�� "���ͳq�Φrbuild.pl" �Ӳ��� "�q�Φr_build.pl" , �������ӥi�H��X�i��.
#$CI_Word[0] = '�Y[��*��]';
#$CI_Code[0] = '&CI0001-1;&CI0001-2;';
#$CI_des{"&CI0001-1;"} = '�Y';
#$CI_nor{"&CI0001-1;"} = '�R';
#$CI_des{"&CI0001-2;"} = '[��*��]';
#$CI_nor{"&CI0001-2;"} = '�E';
#$CI_uni{"&CI0001-2;"} = '&#X7930;';
#$CI_Word[1] = '[��*�O]�M';
#$CI_Code[1] = '&CI0002-1;&CI0002-2;';
#$CI_des{"&CI0002-1;"} = '[��*�O]';
#$CI_nor{"&CI0002-1;"} = '�D';
#$CI_uni{"&CI0002-1;"} = '&#X7ADB;';
#$CI_des{"&CI0002-2;"} = '�M';
#$CI_nor{"&CI0002-2;"} = '��';
#$CI_Word[2] = '��[�I/��]';
#$CI_Code[2] = '&CI0003-1;&CI0003-2;';
#$CI_des{"&CI0003-1;"} = '��';
#$CI_nor{"&CI0003-1;"} = '��';
#$CI_des{"&CI0003-2;"} = '[�I/��]';
#$CI_nor{"&CI0003-2;"} = '��';
#$CI_uni{"&CI0003-2;"} = '&#X9AF4;';
#$CI_Word[3] = '[��*��]��';
#$CI_Code[3] = '&CI0004-1;&CI0004-2;';
#$CI_des{"&CI0004-1;"} = '[��*��]';
#$CI_nor{"&CI0004-1;"} = '�J';
#$CI_uni{"&CI0004-1;"} = '&#X4812;';
#$CI_des{"&CI0004-2;"} = '��';
#$CI_Word[4] = '�e[��-�B+��]';
#$CI_Code[4] = '&CI0005-1;&CI0005-2;';
#$CI_des{"&CI0005-1;"} = '�e';
#$CI_nor{"&CI0005-1;"} = '��';
#$CI_des{"&CI0005-2;"} = '[��-�B+��]';
#$CI_nor{"&CI0005-2;"} = '��';
#$CI_uni{"&CI0005-2;"} = '&#X63EC;';
#$CI_Word[5] = '[�I/��]��';
#$CI_Code[5] = '&CI0006-1;&CI0006-2;';
#$CI_des{"&CI0006-1;"} = '[�I/��]';
#$CI_nor{"&CI0006-1;"} = '��';
#$CI_uni{"&CI0006-1;"} = '&#X9AF4;';
#$CI_des{"&CI0006-2;"} = '��';
#$CI_nor{"&CI0006-2;"} = '��';
#$CI_Word[6] = '�y[��*��]';
#$CI_Code[6] = '&CI0007-1;&CI0007-2;';
#$CI_des{"&CI0007-1;"} = '�y';
#$CI_nor{"&CI0007-1;"} = '�e';
#$CI_des{"&CI0007-2;"} = '[��*��]';
#$CI_nor{"&CI0007-2;"} = '��';
#$CI_uni{"&CI0007-2;"} = '&#X4CB3;';
#$CI_Word[7] = '��[�k*��]';
#$CI_Code[7] = '&CI0008-1;&CI0008-2;';
#$CI_des{"&CI0008-1;"} = '��';
#$CI_des{"&CI0008-2;"} = '[�k*��]';
#$CI_nor{"&CI0008-2;"} = '��';
#$CI_uni{"&CI0008-2;"} = '&#X59DF;';
#$CI_Word[8] = '[�@/��][��*��]';
#$CI_Code[8] = '&CI0009-1;&CI0009-2;';
#$CI_des{"&CI0009-1;"} = '[�@/��]';
#$CI_nor{"&CI0009-1;"} = '�R';
#$CI_uni{"&CI0009-1;"} = '&#X7915;';
#$CI_des{"&CI0009-2;"} = '[��*��]';
#$CI_nor{"&CI0009-2;"} = '�E';
#$CI_uni{"&CI0009-2;"} = '&#X7930;';
#$CI_Word[10] = '[��*��][��*��]';
#$CI_Code[10] = '&CI0011-1;&CI0011-2;';
#$CI_des{"&CI0011-1;"} = '[��*��]';
#$CI_nor{"&CI0011-1;"} = '��';
#$CI_des{"&CI0011-2;"} = '[��*��]';
#$CI_nor{"&CI0011-2;"} = '��';
#$CI_Word[11] = '[��-�G+��][��-�G+��]';
#$CI_Code[11] = '&CI0012-1;&CI0012-2;';
#$CI_des{"&CI0012-1;"} = '[��-�G+��]';
#$CI_nor{"&CI0012-1;"} = '��';
#$CI_uni{"&CI0012-1;"} = '&#X508F;';
#$CI_des{"&CI0012-2;"} = '[��-�G+��]';
#$CI_nor{"&CI0012-2;"} = '��';
#$CI_uni{"&CI0012-2;"} = '&#X202B2;';
#$CI_Word[12] = '����[�I/��][�I/��]';
#$CI_Code[12] = '&CI0013-1;&CI0013-2;&CI0013-3;&CI0013-4;';
#$CI_des{"&CI0013-1;"} = '��';
#$CI_nor{"&CI0013-1;"} = '��';
#$CI_des{"&CI0013-2;"} = '��';
#$CI_nor{"&CI0013-2;"} = '��';
#$CI_des{"&CI0013-3;"} = '[�I/��]';
#$CI_nor{"&CI0013-3;"} = '��';
#$CI_uni{"&CI0013-3;"} = '&#X9AF4;';
#$CI_des{"&CI0013-4;"} = '[�I/��]';
#$CI_nor{"&CI0013-4;"} = '��';
#$CI_uni{"&CI0013-4;"} = '&#X9AF4;';
#$CI_Word[13] = '[��*��][��*��]';
#$CI_Code[13] = '&CI0014-1;&CI0014-2;';
#$CI_des{"&CI0014-1;"} = '[��*��]';
#$CI_nor{"&CI0014-1;"} = '��';
#$CI_uni{"&CI0014-1;"} = '&#X2A132;';
#$CI_des{"&CI0014-2;"} = '[��*��]';
#$CI_nor{"&CI0014-2;"} = '��';
#$CI_uni{"&CI0014-2;"} = '&#X9D39;';

#------------------------------------------------------------------------------
# �D�{��
#------------------------------------------------------------------------------

readGaiji();
open_build_list();

open TMPINDEX, ">$tmpindexfile" || die "open $tmpindexfile error!";
binmode TMPINDEX;
open PREINDEX, ">$preindexfile" || die "open $preindexfile error!";

my $time1 = time;
for(my $i=0; $i<=$#files; $i++)
{
	undef %one_file_index;		# �M��
	undef %preindex;
	undef %word_index_onefile;
	
	print "build $files[$i] ... ";
	build_one_file($i);
	count_files_by_word();
	save_one_index($i);
	save_one_preindex($i);
	print "ok\n";
}
close TMPINDEX;
close PREINDEX;

my $time2 = time;
$time2-=$time1;
###########################################

#save_head_index();				# ���ΤF, �d�b�O���餤�Y�i
print "build last index ... ";
my $time3 = time;
build_last_index();
my $time4 = time;
print "ok\n";
$time4-=$time3;

###########################################

print "save word index ... ";
my $time5 = time;
save_word_index();
my $time6 = time;
unlink $preindexfile;		# �R���Ȧs��
unlink $tmpindexfile;		# �R���Ȧs��
print "ok\n\n";
$time6-=$time5;
print "�g���`�r�� : $total_word_count , �g��ϥΦr�� : $total_word_use �r\n";
print "analysis files time : $time2\n";
print "build index time : $time4\n";
print "save index time : $time6\n";

print "... ���N�䵲�� (any key to exit) ...\n";
<>;

#------------------------------------------------------------------------------

#---------------------------------------------------
# ���X�ɦW
#---------------------------------------------------

sub open_build_list
{
	local *IN;
	
	open IN, $buildlist || die "open $buildlist error";
	<IN>;
	while(<IN>)
	{
		next if /^#/;
		last if /^<eof>/;
		chomp;
		push(@files, $_);
	}
	close IN;
}

#---------------------------------------------------
# �B�z�@���ɮ�
#---------------------------------------------------

sub build_one_file
{
	local $_;
	
	my $filenum = shift;
	my $file = $files[$filenum];
	my $openerr = 0;
	my $indexnum = 0;	# �O�����r�X�{����m
	
	local *IN;
	
	open IN, $file or $openerr = 1;
	if($openerr)
	{
		print " error : $!\n";
		close IN;
		return;
	}
	my @lines = <IN>;
	close IN;
	
	foreach my $line (@lines)
	{
		# V2.0 ���B�z�q�ε��F
		# # V1.0 ���B�z�q�ε�
		# # ����q�ε����r�v�@�ܦ� &CIxxxx-x;
		# # �A�W�߳B�z����
		#
		#for(my $i=0; $i<=$#CI_Word; $i++)
		#{
		#	next if ($i==9);
		#	$line =~ s/\Q$CI_Word[$i]\E/$CI_Code[$i]/g;
		#}
		
		# ���� �i�ϡj
		
		$line =~ s/�i�ϡj//g;
		
		while($line)
		{
			my $get_word;
			# if($line =~ /^(\[${big5}+?\])/ && $1 =~ /[+\-*\/\@\?]/)		# �զr��
			if($line =~ /^(\[${big5}+?\])/ && $zu{$1} == 1)		# �զr�� V1.1 �s���P�_�k
			{
				$line =~ s/^(\[${big5}+?\])//;
				$get_word = $1;
			}
			elsif ($line =~ /^(&.*?;)/)		# & �X, ex. &SD-xxxx;
			{
				$line =~ s/^(&.*?;)//;
				$get_word = $1;
			}
			else
			{
				$line =~ s/^($big5)//;
				$get_word = $1;
			}
			
			if (no_need($get_word)==0)		# ���n�B�z���r, �Ҧp����, �y�I, �r�I.....
			{
				$indexnum++;
				$total_word_count++;		# �`�r��+1
				
				# V2.0 P5 �S���q�ε��F
				#
				# # V1.0 �B�z�q�ε�, �q�ε����C�@�Ӧr���ܦ� &CI...�@�F
				#
				if($get_word =~ /^&CI/)
				{
					# �]���S���q�ε��F, �ҥH���U�O���|����F
					
					my $tmp;
					my $ID;
					# CI0003 "<gaiji cb='CBx00662' des='��[�I/��]' nor='�ϩ�' uni="&#X9AE3;&#X9AF4;"

					# #$CI_des{"&CI0003-1;"} = "��";
					# #$CI_nor{"&CI0003-1;"} = "��";
					# #$CI_des{"&CI0003-2;"} = "[�I/��]";
					# #$CI_nor{"&CI0003-2;"} = "��";
					# #$CI_uni{"&CI0003-2;"} = "&#X9AF4;";
					# 
					# if($CI_des{$get_word})
					# {
					# 	$tmp = $CI_des{$get_word};
					# 	$ID = "${filenum}_$tmp";
					# 	$one_file_index{$ID} .= "$indexnum,";
					# 	$word_index{$tmp} = 1;				# �O�����r�ιL;
					# 	$word_index_onefile{$tmp} = 1;		# �O�����r�ιL;
					# }
					# if($CI_nor{$get_word})
					# {
					# 	$tmp = $CI_nor{$get_word};
					# 	$ID = "${filenum}_$tmp";
					# 	$one_file_index{$ID} .= "$indexnum,";
					# 	$word_index{$tmp} = 1;				# �O�����r�ιL;
					# 	$word_index_onefile{$tmp} = 1;		# �O�����r�ιL;
					# }
					# if($CI_uni{$get_word})
					# {
					# 	$tmp = $CI_uni{$get_word};
					# 	$ID = "${filenum}_$tmp";
					# 	$one_file_index{$ID} .= "$indexnum,";
					# 	$word_index{$tmp} = 1;				# �O�����r�ιL;
					# 	$word_index_onefile{$tmp} = 1;		# �O�����r�ιL;
					# }
				}
				else
				{
					# �Y�o�O�զr���B�O unicode 1.1 , �N���ΰO���զr��, ���@�U�|�����O���� unicode
					
					if($uni_flag{$get_word} != 1 or $uni{$get_word} eq "")	# uniflag ���O 1 �� �S�� unicode �� (��ܦ� nor_uni)
					{
						my $ID = "${filenum}_$get_word";
						$one_file_index{$ID} .= "$indexnum,";
				
						$word_index{$get_word} = 1;				# �O�����r�ιL;
						$word_index_onefile{$get_word} = 1;		# �O�����r�ιL;
					}
				}
				
				# V0.7 �B�z�ʦr
				# V2.0 P5 �]���H unicode 1.1 ���򥻦r��, �]�� unicode 1.1 �������u�O�� unicode , �S���q�Φr, �]�S���զr��
				# �]�� CBReader �u�|�e�{ unicode, �O���F�]�˯�����.
				
				if($get_word =~ /^\[${big5}+?\]/)
				{
					my $uni = $uni{$get_word};				# ���X unicode
					my $nor_uni = $nor_uni{$get_word};		# ���X unicode �q�Φr
					my $nor = $nor{$get_word};				# ���X�q�Φr
					my $uni_flag = $uni_flag{$get_word};	# �ΨӧP�_���r�O���O unicode 1.1 �H�����զr��, �Y 1 �h��ܬO
					
					# �� unicode 
					if($uni)
					{
						$uni = uc("&#x$uni;");			# �ܦ� &#X.....; �o�� 16 �i�쪺�榡
						my $ID = "${filenum}_$uni";
						$one_file_index{$ID} .= "$indexnum,";
						
						$word_index{$uni} = 1;				# �O�����r�ιL;
						$word_index_onefile{$uni} = 1;		# �O�����r�ιL;
					}
					
					# ���q�� unicode
					if($nor_uni)
					{
						$nor_uni = uc("&#x$nor_uni;");			# �ܦ� &#X.....; �o�� 16 �i�쪺�榡
						my $ID = "${filenum}_$nor_uni";
						$one_file_index{$ID} .= "$indexnum,";
						
						$word_index{$nor_uni} = 1;				# �O�����r�ιL;
						$word_index_onefile{$nor_uni} = 1;		# �O�����r�ιL;
					}
					
					# ���q�Φr�N�O��, ���D�O�з� unicode V1.1 ���d��
					if($nor && ($uni_flag != 1 or $uni eq ""))
					{
						my $ID = "${filenum}_$nor";
						$one_file_index{$ID} .= "$indexnum,";
						
						$word_index{$nor} = 1;				# �O�����r�ιL;
						$word_index_onefile{$nor} = 1;		# �O�����r�ιL;
					}
				}
			}
		}
	}
}

#-----------------------------------------------------------------
# �Ψӭp��Y�@�Ӧr���h���ɮ׾֦�, �Ҧp "��" �i�঳ 1000 �ɮצ����r
#-----------------------------------------------------------------

sub count_files_by_word
{
	local $_;
	
	foreach (keys(%word_index_onefile))
	{
		if($how_many_file_has{$_})
		{
			$how_many_file_has{$_}++;
		}
		else
		{
			$how_many_file_has{$_} = 1;
		}
	}
}

#---------------------------------------------------
# �ˬd�Y�Ӧr�n���n�B�z, ���B�z�N�Ǧ^ 1 , �_�h�Ǧ^ 0
#---------------------------------------------------

sub no_need
{
	my $word = shift;
	
	return 0 if ($word =~ /&.*?;/);
	
	return 0 if ($zu{$word} == 1);			# �зǲզr��
	
	return 1 if ($word !~ /$chinese/);		# �D��������B�z
	
	#return 1 if (($word eq "�C") or ($word eq "�D") or ($word eq "��") or 
	#             ($word eq '�@') or ($word eq '�A') or ($word eq '��'));
	             
	# �s��
	return 1 if ($newsign{$word} == 1);		# V1.1
	             
	return 0;
}

#---------------------------------------------------
# �N�Y�@�ɪ� Index �s�_��
#---------------------------------------------------

sub save_one_index
{
	foreach my $key (sort(keys(%one_file_index)))
	{
		$preindex{$key} = tell(TMPINDEX);
		#print TMPINDEX "$key : $one_file_index{$key}\n";
		print TMPINDEX "$one_file_index{$key}\n";
	}
}

#---------------------------------------------------
# �N�D�����ɪ��ؿ� (pre index) �s�_��
#---------------------------------------------------

sub save_one_preindex
{
	my $filenum = shift;

	$head_index[$filenum] = tell(PREINDEX);
	foreach my $key (sort(keys(%preindex)))
	{
		#my $tmp = pack "L" , $preindex{$key};
		print PREINDEX "$key:$preindex{$key}\n";
	}
}

#---------------------------------------------------
# �N�ҵo�{���r (word bank) �s�_��
#---------------------------------------------------

sub save_word_index
{
	local *WORD;
	local $_;

	open WORD, ">$wordindexfile" || die "open $wordindexfile error : $!";
	
	my $size = $#sort_word+1;
	print WORD "$size\n";
	for (@sort_word)
	{
		print WORD "$_=$word_index{$_}\n";
	}
	close WORD;
}

#---------------------------------------------------
# �x�s�C�@���ɮצb preindex ���@�}�l����m
#---------------------------------------------------

=begin
sub save_head_index
{
	local *HEAD;
	local $_;
	
	print "save head index ... ";
	open HEAD, ">$headndexfile" || die "open $headndexfile error : $!";
	for my $i (0 .. $#head_index)
	{
		print HEAD "$i : $head_index[$i]\n";
	}
	close HEAD;
	print "ok\n";
}
=end
=cut

#---------------------------------------------------
# �B�z�̫᪺ index
#---------------------------------------------------

sub build_last_index
{
	my $line;
	my $offset;
	my $offset2;
	my $ID;
	my $filenum;
	my $word;
	
	# ���}�Ҥj��
	
	open PREINDEX, "$preindexfile" || die "open $preindexfile error!";
	open TMPINDEX, "$tmpindexfile" || die "open $tmpindexfile error!";
	open LASTINDEX, ">$lastindexfile" || die "open $lastindexfile error!";
	binmode LASTINDEX;
	
	my $file_count_bit;
	$file_count_bit = int (($#head_index + 1) / 32);
	$file_count_bit++ if(($#head_index + 1) % 32);

	@sort_word = sort(keys(%word_index));
	$total_word_use = $#sort_word + 1;
	print "\n�g���`�r�� : $total_word_count , �g��ϥΦr�� : $total_word_use �r\n";
	print "(���U�C��N��B�z�F 1000 �Ӧr)\n";
	
	my $count = 0;
	for $word (@sort_word)		# �C�@�Ӧr���B�z
	{
		$count++;

		if($count % 1000 == 0)
		{
			print "+\n";
		}
		elsif($count % 200 == 0)
		{
			print "+";
		}
		elsif($count % 20 == 0)
		{
			print ".";
		}
		
		$word_index{$word} = tell(LASTINDEX);	# ���Y�r�b last index �Ĥ@���X�{���a��

		@file_list = ();
		@file_list_bit = ();		# �� @file_list ���Y�Ӧ���
		@word_count = ();
		@word_pos = ();

		#### ���N�e�����Ŷ��w�d�U�� #######################################
		
		my $last_index_head = tell(LASTINDEX);
		# �]���@�� int �� 4 �� byte
		my $tmp_file_list_bit = " " x (4 * ($file_count_bit + $how_many_file_has{$word}));
		print LASTINDEX $tmp_file_list_bit;
		
		###################################################################

		for $filenum (0 .. $#head_index)		# �C�@���ɮ׳��h��o�@�Ӧr
		{
			$offset = $head_index[$filenum];
			seek PREINDEX, $offset, 0;			# ���Y��
			
			# �o�̥i�H�Ҽ{���N���X�Ӫ���Ʃ��Y�@���ܼƤ�, �H�W�[�t�� ????
			
			$line = <PREINDEX>;
			chomp($line);
			# $line ���e���� 1_��:1000
			($ID, $offset2) = split(/:/, $line);
			$ID =~ /(\d*)_(.*)/;
			my $filenumtmp = $1;
			my $wordtmp = $2;
			if($filenumtmp == $filenum and $wordtmp eq $word)	# ���F
			{
				$head_index[$filenum] = tell(PREINDEX);		# ���o�U�@�Ӧr����m
				
				seek TMPINDEX, $offset2, 0;
				$line = <TMPINDEX>;
				#$line =~ s/^.*? : //;

				# print LASTINDEX "$line";
				chomp $line;
				chop $line;
				
				my @tmp_word_pos = split(/,/,$line);
				push(@file_list,1);
				push(@word_count,$#tmp_word_pos+1);
				
				#@word_pos = (@word_pos , @tmp_word_pos);

				# �ª��� V0.5 ########################################
				#for(0..$#tmp_word_pos)
				#{
				#	my $tmp = pack "L" , $tmp_word_pos[$_];
				#	print LASTINDEX $tmp;
				#}
				# �s���� V0.6 ########################################
				
				zipint(\@tmp_word_pos);
				
				######################################################
			}
			else
			{
				# ���ɵL���r
				push(@file_list,0);
			}
		}
		
		# �L�X��
		zip_file_list();
		
		my $last_index_end = tell(LASTINDEX);
		seek LASTINDEX, $last_index_head, 0;
		
		for(0..$#file_list_bit)
		{
			my $tmp = pack "L" , $file_list_bit[$_];
			print LASTINDEX $tmp;
		}

		for(0..$#word_count)
		{
			my $tmp = pack "L" , $word_count[$_];
			print LASTINDEX $tmp;
		}
		
		seek LASTINDEX, $last_index_end, 0;
	}
	
	close TMPINDEX;
	close PREINDEX;
	close LASTINDEX;
}

#---------------------------------------------------
# ���Y �D�n���
#---------------------------------------------------
sub zipint()
{
	my $oldint = shift;
	my @newint;
	my $result = "";

	push(@newint,$oldint->[0]);
	for(my $i=1; $i<=$#$oldint; $i++)
	{
		push(@newint,$oldint->[$i]-$oldint->[$i-1]);
	}

	for(my $i=0; $i<=$#$oldint; $i++)
	{
		# 1 byte , < 64
		# 2 byte , < 16384
		# 3 byte , < 4194304
	
		my $tmp = $newint[$i];

		if($newint[$i] < 64)
		{
			$tmp += 64;	# 01000000
			$tmp = pack "C" , $tmp;
			$result .= $tmp;
		}
		elsif($newint[$i] < 16384)
		{
			$tmp += 32768;	# 10000000 00000000
			$tmp = pack "L" , $tmp;
			$tmp =~ /(.)(.)../s;
			$result .= "$2$1";
		}
		elsif($newint[$i] < 4194304)
		{
			$tmp += 12582912;	# 11000000 00000000 00000000
			$tmp = pack "L" , $tmp;
			$tmp =~ /(.)(.)(.)./s;
			$result .= "$3$2$1";
		}
		else
		{
			$result .= pack ("C", 0);
			$tmp = pack "L" , $tmp;
			$tmp =~ /(.)(.)(.)(.)/s;
			$result .= "$4$3$2$1";
		}	
	}
	
	print LASTINDEX $result;
}

#---------------------------------------------------
# ���Y file list
#---------------------------------------------------

sub zip_file_list()
{
	for(my $i=0; $i<=$#file_list; $i+=32)	# �C�� 32 �줸
	{
		my $tmp = 0;

		for(my $j=0; $j<32; $j++)
		{
			my $k = $i + $j;
			
			last if ($k > $#file_list);	# �W�X�d��F
			if($file_list[$k])
			{
				my $mask = 2 ** $j;
				$tmp = $tmp | $mask;
			}
		}
		push(@file_list_bit, $tmp);
	}
}

#---------------------------------------------------
# Ū���ʦr���
#---------------------------------------------------

sub readGaiji 
{
	use Win32::ODBC;
	my $cb;
	my $zu;
	my $nor;
	my $nor_uni;
	my $uni;
	my $flag;
	my %row;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = $row{"cb"};       # cbeta code

		next if ($cb !~ /^\d+$/);

		$zu    = $row{"des"};		# �զr��
		$nor   = $row{"nor"};		# �q�Φr
		$uni   = $row{"unicode"};	# unicode
		$nor_uni = "";				# �n���w�]���Ŧr��
		if($row{"nor_uni"})
		{
			$nor_uni = $row{"uni"};		# nor_uni
		}
		$flag  = $row{"uni_flag"};	# uni_flag , 1 ��ܬO unicode 3.0 �H�����r (���t 3.0)

		$uni{$zu} = $uni;
		$nor_uni{$zu} = $nor_uni;
		$nor{$zu} = $nor;
	  	$uni_flag{$zu} = $flag;
	  	$zu{$zu} = 1;
	}
	$db->Close();
	print STDERR "ok\n";
}
#---------------------------------------------------
# The End.
#---------------------------------------------------