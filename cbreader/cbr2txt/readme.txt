��� CBReader ��������:

1.�ϥ� CBReader (�H�U²�� CBR) ���Ϳ�X��, ���O�n�`�N�榡���]�w�p�U:

  a.�̤j���î榡����
  b.�[�W�歺
  c.�ϥβզr�� (�ĤG����O�q�Φr, �o�˲��ͪ��ڧQ��~�ॿ�T���)
  d.�ɻ~�G�̬ҭn (�Υu�Υ��T��, �ݫ�����K�N���)
  e.�ϥαx��r��
  
  �ð��]��X�� c:\release\cbr_out

  �ϥ� cbr2html_all.bat �i�H�γv�U���� html

2.��ʫإߥؿ� c:\cbcheck\cbr_comp, ���ؿ��U��

  cbr2t.pl , �o�O�D�n���{��
  cbr2t_one.bat �O�B�z�@�U���妸��, �Ҧp cbr2t_one.bat T01
  cbr2t_all.bat �O�B�z�������妸��
  
  �p�G cbr ���w�]�ؿ����O c:\release\cbr_out\
  �h cbr2t.pl �n��o�@��:
  
  $source_path = "c:/release/cbr_out/";
  
  �����|���� T01_cbr.txt , T02_cbr.txt ..... 

3.�ϥ� diff_one.bat  Txx (�� diff_all �B�z����) �N Txx_crt.txt �P
  xml->normal ���ͥX�Ӫ� normal �����X�֤j�ɤ��

4.�ϥ� fcsplit_one.bat Txx (�� fcsplit_all �B�z����) �ӱN�t���ɤ���.
  �o�ɷ|���� Txx ���ؿ�, �̭��O fcsplit1.txt �� fcsplit2.txt
  �ڭ��٭n�A copy wfgfc.exe �i�h, �N�i�H��� fcsplit1.txt �� fcsplit2.txt �F.