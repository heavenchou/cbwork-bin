@call \cbwork\bin\perl516.bat run
rem ===============================================================================================
rem �H�W���]�w perl 5.16 ����������
rem �{�������G�N���w�ؿ������ɮצX���@�Ӥj��
rem �ϥΤ�k�G
rem       perl connect.pl -s �ӷ��ؿ����ɮ׺��� -o ��X���G���ɮ� [-c -v -d]
rem �Ѽƻ����G
rem       -s �ӷ��ؿ��A�n�]�t�ɮת������Ҧ��A�Ҧp -s c:\temp\*.txt
rem       -o ���G�ɮסA�Ҧp -o c:\out.txt
rem       -c �����歺�A�p�G�歺�O T01n0001_p0001a01�� �o�ث���A�Ҥ@�߲���
rem       -v �ɮ׫e�Q��Y�� V1.0 �o�ت����榡�A�@�ߴ��� Vv.v�A�H��K���
rem       -d �ɮ׫e�Q��Y�� 2013/06/11 �o�ؤ���榡�A�@�ߴ��� yyyy/mm/dd�A�H��K���
rem �d�ҡG
rem       perl connect.pl -s c:\release\bm\normal\T01\*.txt -o c:\temp\T01.txt -c -v -d
rem ===============================================================================================
echo on

perl connect.pl -s c:\release\bm\normal\T01\*.txt -o c:\temp\T01.txt -c -v -d