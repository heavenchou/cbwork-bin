catalog ���ؿ��n���ͪ��O�j�øg�ؿ����������

�D�n��ƪ�

�� �j�øg�򥻸��  (T, X, J, A .....)
�� �U�j�øg�U�ƦC�� (T01, T02 , ....)

�� �j�ö���
�� �U�j�øg�ؿ���Ʈw (�D�n���U�g��Ʈw)

�� �U�g�����Ƹ�� (�]�A���s�����ƤΦU�����_�l��m)
�� �U�g�������g��


ps. �ˬd���䪺�ؿ����

xml �g��
cbwork/normal/xx/source.txt
cbeta/cbreader/xxx_menu.txt .......
cbwork/cbreader/xxxMenu_b5.txt .......
cbepubtool/tripitaka.txt
data/python/���ɥ[�J�~�r/database.txt

D:/cbeta.src/budalist/*
cbwork/bin/website/taisho.txt .....
cbeta/cbreader/juanline

===============================================================================

�� �j�øg�򥻸��  (T, X, J, A .....)

�v�� 1 (�U�j�øg�X�{������, �j���ó̭��n)
������ 1 (1 ��ܥ�����, 0 ��ܿ��, ���ɸg�W�|�ݭn�g���)
tid T
������W �j���s��j�øg
����²�� �j����
�^����W Taisho Tripitaka
* �^��²�� Taisho
�`�U�� 85
�ȥ��ӷ� �j���s�פj�øg�Z��| �s / �F�ʡG�j�åX���覡�|��, Popular Edition in 1988.

CREATE TABLE `tripitaka` (
`number` INT NOT NULL COMMENT '�v������',
`full` INT NOT NULL COMMENT '��������',
`tid` VARCHAR( 3 ) NOT NULL COMMENT 'tid',
`name_c` VARCHAR( 15 ) NOT NULL COMMENT '������W',
`short_name_c` VARCHAR( 10 ) NOT NULL COMMENT '����²��',
`name_e` VARCHAR( 80 ) NOT NULL COMMENT '�^����W',
`total_vol` INT NOT NULL COMMENT '�`�U��',
`paper_source` VARCHAR( 80 ) NOT NULL COMMENT '�ȥ��ӷ�',
PRIMARY KEY ( `tid` ) 
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = '�j�øg���';


�� �U�j�øg�U�ƦC��

T01,T,01
T02,T,02
....
T55,T,55
T85,T,85
X01,X,01
X02,X,02
....

CREATE TABLE `voldata` (
`tvol` VARCHAR( 6 ) NOT NULL COMMENT '�U�N�X',
`tid` VARCHAR( 3 ) NOT NULL COMMENT '�øg�N�X',
`vol` VARCHAR( 3 ) NOT NULL COMMENT '�U��',
PRIMARY KEY ( `tvol` ) 
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = 'CBETA���U��';


�� �U�j�øg�ؿ���Ʈw

��ƪ��c�G

id (T01n0001 , ZH001n0001a)
�øg�N�X (T,X,J,ZH,ZW,....)
�U
�g��
*���� (CBETA ������)
*���O
����
�O�_�O�s���?
�g�W
�@Ķ��


T01n0001,T,01,0001,22,1,�����t�g,�᯳ ����C�٦@�Ǧ��Ķ
T01n0002,T,01,0002,1,1,�C��g,�� �k��Ķ
T01n0003,T,01,0003,2,1,�i�C�r��g,�� �k��Ķ

CREATE TABLE `catalog` (
`id` VARCHAR( 15 ) NOT NULL COMMENT 'id',
`tid` VARCHAR( 3 ) NOT NULL COMMENT '�øg�N�X',
`vol` VARCHAR( 3 ) NOT NULL COMMENT '�U��',
`sid` VARCHAR( 5 ) NOT NULL COMMENT '�g��',
`juan` INT NOT NULL COMMENT '����',
`juantype` INT NOT NULL COMMENT '�s���',
`sutra_name` VARCHAR( 250 ) NOT NULL COMMENT '�g�W',
`byline` VARCHAR( 250 ) NOT NULL COMMENT '�@Ķ��',
PRIMARY KEY ( `id` ) 
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = 'CBETA���ؿ�';

�� �U�g�����Ƹ��

id T01n0001
tid T
vol 01
sid 0001
���y���� 1
����ڨ��� 1
����������� 0001a01

T01n0001,T,01,0001,1,1,0001a01
T01n0001,T,01,0001,2,2,0011a02
T01n0001,T,01,0001,3,3,0016b12

CREATE TABLE `juandata` (
`id` VARCHAR( 15 ) NOT NULL COMMENT 'id',
`tid` VARCHAR( 3 ) NOT NULL COMMENT '�øg�N�X',
`vol` VARCHAR( 3 ) NOT NULL COMMENT '�U',
`sid` VARCHAR( 5 ) NOT NULL COMMENT '�g��',
`juan_count` INT NOT NULL COMMENT '���Ƭy����',
`juan_num` INT NOT NULL COMMENT '��ڨ���',
`pageline` VARCHAR( 7 ) NOT NULL COMMENT '�����'
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = 'CBETA���U�����';

===============================================================================

�� �@�~�y�{

1. ��catalog.pl , 
   ���� catalog.txt , �o�O�U�g���D�n��Ʈw, �]�|���� juandata �ؿ�, �o�O�U�������.
   �� ����e�n���ǳƦn���ɮ� : vol_list.txt , �o�O�Ҧ��U�ƪ��C��
   �� �����j��Y�g�n��ʳB�z���T�U�p�U�G
	T05n0220,T,05,0220,200,1,�j��Y�iù�e�h�g(��1��-��200��),�� �ȮNĶ
	T06n0220,T,06,0220,200,0,�j��Y�iù�e�h�g(��201��-��400��),�� �ȮNĶ
	T07n0220,T,07,0220,200,0,�j��Y�iù�e�h�g(��401��-��600��),�� �ȮNĶ
   �� juandata �ؿ����� T07 �]�n�B�z�� 1-200 ��
   
2. juandata �ؿ������e�n�X�֦��@�� all.txt , �]�N�O�U�R�O copy *.txt all.txt .
   �o�O�n�W�Ǩ� juandata ��Ʈw, �]�O���U�|�Ψ쪺���.
   
3. �� catalog2mysql.pl ���ͭn�W�Ǩ� mysql cbetaorg_tripitaka ��Ʈw���ؿ� mysql_catalog.txt

4. �� create_drupal_import_cvs.pl ���� drupal_import_sutra.csv, drupal_import_juan.csv , �o�O�n�פJ drupal �U�g�P�U�����.

   Drupal Import ���L�{
   1. �� "�g�孶��"
   2. �W���ɮ�
   3. �� "Comma Separated Values", �� , �� " �Ÿ�
   4. ��w�]��
   5. ���L
   6. �y�� : �y������
      ��� : �D���
      ��J�榡 : PHP Code
      �@�� : cbeta
      ��� : �ť�
      ��x�T�� : (�M��)
      �w�o�� : yes
      �������� : no
      �m�� : no
      �^�� : �i�^��

   ps. 2015/06/29 �J��o�ӿ��~ 
   
   Fatal error: Cannot unset string offsets in /home1/cbetaorg/public_html/sites/all/modules/image/contrib/image_attach/image_attach.module on line 457
   
   �N�� image �Ҳճ�����, �u�d�̥D�n��, ���~�N�����F.

5. ���ͭn�e�{���g�� (�D��Ѯ榡)

   a. ���� CBReader �Ӳ���, ���G��b c:\release\cbr_out_web
      �榡 : ���̭��, �������, �L�հ�, �����I
      �ʦr : �q�Φr, �զr��, UnicodeEXT (��������S�@��)
      �׭q : �׭q�Φr
      ��ڱx��ҥ� Unicode
   
   b. �ϥ� cbrhtm2web_all.bat (cbrhtm2web.pl) �N cbr_out_web �����e�ഫ�� cb_tripitaka_web �ؿ�

6. ���ͭn�e�{���g�� (��Ѯ榡)

   a. ���� CBReader �Ӳ���, ���G��b c:\release\cbr_out_web_line
      �榡 : �̭��, �������, �L�հ�, �����I
      �ʦr : �q�Φr, �զr��, UnicodeEXT (��������S�@��)
      �׭q : �׭q�Φr
      ��ڱx��ҥ� Unicode
   
   b. �ϥ� cbrhtm2web_all.bat (�̭��n�]�w�̭�Ѥ��� set line=1)  (cbrhtm2web.pl) �N cbr_out_web_line �����e�ഫ�� cb_tripitaka_web_line �ؿ�

7. ���ɭn�ɻ�, ���O��b������ ./cb_tripitaka_web/figures , ./cb_tripitaka_web/sd-gif , ./cb_tripitaka_web/rj-gif

�ݰ��ƶ� :

1. �B�J 3 ���ͪ���ƭn�P 2014 �~�����, �H�K��ʰ��X�n�W�Ǫ�����.
1. �B�J 4 ���ͪ���ƭn�P 2014 �~�����, �H�K��ʭקﳡ���g�W.