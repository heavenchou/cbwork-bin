
�� readme.txt ��������

�o�ӥؿ��O�B�z CBReader 2X ����������ƪ��{��

��ƷǳƬy�{

	1. P5a �� P5b�A���ʧ@�n�����A�]�����U���Ǹ�ƬO�� P5b ���ͪ��C
    2. �ǳư򥻸�� sutralist , bulei (sutralist �ĥ� p5b ������, �g�W�~���|�� unicode ext-b)
    3. P5b ����
    4. ���ͤG���D�n������� bulei_nav.xhtml , book_nav.xhtml -----> �n�B�z <g> �ʦr , ��ʧ� �j���ϮѶ��� ..�]�W�^����
    5. ���ͦU�g�媺�ؿ� toc -----> �n�B�z <g> �ʦr
    6. ���͸g��ؿ� catalog  ----> ��ʳB�z�j��Y�g, ���O, <g> �ʦr
    7. ���͸g��y������ spine
    8. �O�ѤF�n���s�W�g�媺 epub �ʭ�����

�䤤 sutralist , catalog ����Ƴ��n�P�ɥ]�t��U���O��, �Ҧp

A,120,1565,18,1,0175b01,����v�a�׸q�t(��1��-��32��),�� �M���D��b�z
A,121,1565,5,33,0001b01,����v�a�׸q�t(��33��-��40��),�� �M���D��b�z

���b���� bulei_nav , book_nav �u�n�B�z�Ĥ@��

toc �h�n�N��U��ƦX�֦b�P�@�ӥؿ���

catalog ���M���h��, �����s����P�@����? �� �I A121n1565 �g, �n�� 33 ����?

�� P5a �� P5b

	�o�ӭn����

�� sutralist

	�i���� sutralist.bat�j
	
	�o�̬O����G�Ӱʧ@
	
	1. ���� perl create_sutralist.pl

	���� sutralist.txt�A�o�O�Ҧ��g�媺�U�B�g���B�g�W�B���ơB�Ĥ@���B�_�l������

	�O���n����¦�ؿ�
	
	2. ���� perl create_sutralist_by_bm.pl
	
	�� BM ���� sutralist_by_bm.txt�A�z�פW�n�M sutralist.txt �@�ˡA�i�C���ˬd���ءC
	
	�P�ɷ|����ª��P�s���A�ݬݦ��S�����P�C

�� �����{�� cutxml

	�i���� cutxml.bat �i�ݰѼơj
	���� cutxml.bat -a �B�z CBETA �������
	���� cutxml.bat -see �B�z�转�������
	
�� bulie

	�������
	
	�Y���s�����y�[�J�A�n�ק� bulei.xlsx , �öK���¤�r�� bulei.txt

�� ���;����ؿ� nav

	�Y���s�����y�[�J�A�n�B�z simple_nav.xlsx, advance_nav.xlsx , �öK���������¤�r��

	�i���� nav.bat , �转������ nav_slreader.bat�j
	
	���ͦp�U�T���ɮ�
	
	1. bulei_nav.xhtml

	�H�������D���g�ؾ𪬦C��

	�� bulei_nav.pl ����, �ݭnŪ�� sutralist.txt �M������� bulei.txt

	2. advance_nav.xhtml
	3. simple_nav.xhtml

	�H��ѵ��c���D���g�ؾ𪬦C��
	
	�o�O���g�L�ʦr�B�z������

�� ���ͦU�g���ؿ� toc

	���n : �]�� mac �b parser XML ��, �аO�����Ĥ@�Ӧr����O unicode ext-b ���r, 
	�]���̦n�����Ť@��. �ثe�o�O�b gaiji2word �B�J�J�ʦr�~�B�z, �������Ӧb���ͮɥ����Τ@�B�z.

	�i���� toc.bat �i�ݰѼơj
	toc.bat -a ��������
	toc.bat -g -a ��������, �ӥB�۰ʳB�z�ʦr������
	
	����ڦ��G�ӳ����G

	1. ���� perl create_toc.pl �b toc_gaiji �ؿ����ͥئ���

	2. �[�W -g �Ѽƫh�� ../gaiji2word ����

	perl gaiji2word_toc.pl 
	
	�|�b toc ���ؿ��U���� toc , �o�O���B�z�L�ʦr�����G

�� ���͸g�ئC�� catalog

	�i���� catalog.bat (�٨S�Ӥ� CBETA �M�转��)�j
	
	�� �o�@�����G���ɲz�Q, �٭n�Ҽ{��g�h�������D, �H�� T0220x , �n�O�o�M�W�@�ӥ��������C

�� ���ʹ`�ǦU�����W�C���ɮ� Spine

	�i���� spine.bat�j

	spine.txt �O���ѥ����˯��Ϊ��ɮצC��

	����ڦ��G�ӳ����G
	
	1. ���� perl create_spine.pl
	
	�� XML P5b ���� spine.txt

	2. ���� perl create_spine_by_bm.pl
	
	�� BM ���� spine_by_bm.txt�A�z�פW�n�M spine.txt �@�ˡA�i�C���ˬd���ءC
	
	�̫�|�۰ʤ��W���G�̡A�H���ª������e�C

�� ��ʦr g �аO���� unicode �βզr��


================================================================================================
�H�U�O�Ĥ@�N CBReader ���͸�ƪ������A�d�۰Ѧҥ�
================================================================================================

�� ���ͳ�����ƪ��{�� , �Ԩ� bulei/readme.txt

bulei1.txt
bulei2.txt
bulei3.txt
bulei4.txt
buleinewsign.txt
.....

�H�W�o���ɮ׬O���� TOC �ݭn��.

�A�� buleilist_make.pl �� bulei1_orig.txt ���� buleilist.txt , �� cbreader �ϥ�.

�� ���� TOC ���{�� , �Ԩ� toc/readme.txt

make_toc.cfg
make_toc.pl             (�Y�g�妳�W�[, �n�� c:/cbwork/work/bin/cbetasub.pl)
make_toc_all.bat
readme.txt		�D�n������

�� cbreader ���� normal ���{��

cbr2t.pl		�D�{��
cbr2t_all.bat	����������妸��
cbr2t_one.bat	�����U���妸��
cbr/readme.txt	������

�� �N xml �����@���@�ɪ��{��

cutxml-all.bat	���������妸��
cutxml.pl		�����{��
cutxml_cfg.pl	�]�w��

�� ���� cbreader �����˯��� perl �{��

build.pl			�D�{��
build/readme.txt	�������

build.pl �̭��B�z�q�ε��O�n�W�߳B�z, 
���@�q�{���i�H�� "���ͳq�Φrbuild.pl" �Ӳ��� "�q�Φr_build.pl" , �������ӥi�H��X�i��.

�� ���ͥ����˯��i��g��ܪ��C�� bulei_sutra_sch.lst �� sutra_sch.lst

�Ԩ� search_list/readme.txt

�� �N�C�@���Ĥ@���Ʃ�b c:/release/juanline �ؿ���

getjuan1line.pl
getjuan1line_all.bat

������������������������������������������������
�� �S����
������������������������������������������������

�� ���� epub �ݭn���ؿ� 

bulei1.txt
bulei2.txt
bulei3.txt
bulei4.txt
buleinewsign.txt
.....
make_epub.cfg
make_epub.pl             (�Y�g�妳�W�[, �n�� c:/cbwork/work/bin/cbetasub.pl)
make_epub_all.bat

c:\cbwork\work\epub\readme.txt		�D�n������

�̭����� buleilist_make.pl ���� buleilist.txt , �� cbreader �ϥ�