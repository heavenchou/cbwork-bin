
�i�u�@�y�{�j

a.�� CBReader ���X������ HTML ��, �榡�Ь� 2.cbrhtm2epub.pl �̫e�������Ѥ��e, ��b c:\release\cbr_out_epub
b.�� make_cover �ؿ������{�����ͦU�g�ʭ�����, ��b c:\release\epub_cover

1.�� 1.make_epub_all.bat ���ͦU�g�� toc.ncx , TableOfContents.xhtml , content.opf , CoverPage.xhtml �� c:\release\epub_unzip_toc
2.�� 2.cbrhtm2epub.pl	�N cbr �� html �ഫ�� epub �һݭn���榡, ��� c:\release\epub_unzip . ���{���|�P�ɽƻs����, �]�����ɽЩ�m�b���w��m.
3.�N c:\release\epub_unzip_toc ����� copoy �� c:\release\epub_unzip , �A�� 3.mv_same_tag �N c:\release\epub_unzip ���Ъ��s�����@�ǳB�z.
  (�]���� 1 �B�J���� c:\release\epub_unzip_toc ����C, �Y�� 3 �B���ѤF, �����A�� copy �� 1 �B�J, �M�᭫���� 2 �B�J, ����ٮɶ�)
4.�� 4.zip_epub_all.bat �N�Ҧ�������Y�� epub �� c:\release\epub_zip
5.�� 5.check_all.bat �ˬd���S�����~

-------------------------------------------------------------------------------
�iePub �W��j

�o�䦳 ePub �䴩�� Tag �M��
http://www.idpf.org/2007/ops/OPS_2.0_0.984_draft.html#Section2.2
http://idpf.org/epub/20/spec/OPS_2.0.1_draft.htm#Section2.2
-------------------------------------------------------------------------------

�i�ؿ��榡�j

[CBR �ؿ�]

<name>JB267 �����M�|���N�O�� (14��)</name><book>J</book><vol>31</vol><sutra>B267</sutra>
<UL>
  <name>�ؿ�</name>
  <UL>
    <name>��</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0529a01</pageline>
    <name>��</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0529a21</pageline>
    <UL><!-- Level 1 -->
      <name>��</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0538a05</pageline>
      <UL><!-- Level 2 -->
        <name>�[�W�J�D��</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0538a06</pageline>
      </UL><!-- 1267 end of Level 2 -->
    </UL><!-- 1284 end of Level 1 -->
  </UL><!-- end of Mulu -->
  <name>��</name><value>1</value>
  <UL>
    <name>�Ĥ@</name><book>J</book><vol>31</vol><juan>1</juan><pageline>0538a01</pageline>
    <name>�ĤG</name><book>J</book><vol>31</vol><juan>2</juan><pageline>0545c01</pageline>
  </UL><!-- end of Juan -->
</UL><!-- end of Jing -->

[epub �ؿ�]

	 <navMap>
			<navPoint id="navPoint-1" playOrder="1">
				<navLabel>
					 <text>�ؿ�</text>
				</navLabel>
				<content src="TableOfContents.xhtml" />
			</navPoint>
			
			<navPoint id="navPoint-2" playOrder="2">                 ============>   <UL>
				<navLabel>                                           ============>        <name>
					 <text>���`</text>
				</navLabel>                                          ============>        </name>
				<content src="TableOfContents.xhtml#chapter" />      ============>           <pageline>......</pageline>
				
					 <navPoint id="navPoint-3" playOrder="3">        ============>        <UL>
					 <navLabel>                                      ============>          <name>
								<text>���~�Ĥ@</text>
					 </navLabel>                                     ============>          </name>
					 <content src="T14n0475-001.xhtml#p0537a06" />   ============>          <pageline>......</pageline>
					 </navPoint>                                     ============>        </UL>
					 
					 <navPoint id="navPoint-4" playOrder="4">
					 <navLabel>
								<text>��K�~�ĤG</text>
					 </navLabel>
					 <content src="T14n0475-001.xhtml#p0539a07" />
					 </navPoint>
					 
			</navPoint>
			<navPoint id="navPoint-17" playOrder="17">
				<navLabel>
					 <text>����</text>
				</navLabel>
				<content src="TableOfContents.xhtml#juan" />
					 <navPoint id="navPoint-18" playOrder="18">
					 <navLabel>
								<text>���W</text>
					 </navLabel>
					 <content src="T14n0475-001.xhtml" />
					 </navPoint>
					 <navPoint id="navPoint-19" playOrder="19">
					 <navLabel>
								<text>����</text>
					 </navLabel>
					 <content src="T14n0475-002.xhtml" />
					 </navPoint>
					 <navPoint id="navPoint-20" playOrder="20">
					 <navLabel>
								<text>���U</text>
					 </navLabel>
					 <content src="T14n0475-003.xhtml" />
					 </navPoint>
			</navPoint>
			<navPoint id="navPoint-21" playOrder="21">
				<navLabel>
					 <text>�٧U</text>
				</navLabel>
				<content src="donate.xhtml" />
			</navPoint>
	 </navMap>

-------------------------------------------------------------------------------

�iePub �ˬd�j

�o�̦���ӵ{���i�H�ˬdePub�ɮפ��e:

1. http://code.google.com/p/epubcheck/ (�@��python�{��)
2. http://www.threepress.org/document/epub-validate/ (�u�W����ePub �ˬd)

-------------------------------------------------------------------------------

�i�ʭ����ɦ��o�Ǧr�n�Φۤv�B�z���r�j

T,16,0710,1,�O����ĩһ��j���t�ͽ_[��/�F]��g,�i�� ����Ķ�j
T,18,0913,1,��[�X*��]�Ѿi���y,�i�j
T,20,1115,1,�[�ۦb���Ī���[��*��]�k,�i�j
T,20,1159A,1,[΢-�j+(��-��)]���j�D���X���k,�i�j
T,21,1238,1,���\�C[��*�y]�����j�N�W���ù���g,�i��Ķ�j
T,21,1240,1,���\��[��*�y]�I��G,�i�j
-------------------------------------------------------------------------------

�i�ؿ����N�Φr�j

[��*�_] => ��
[��-�S] => �I
[��/(�g*�g)] => ? �]�̤���Φr�^
[��-�g+��] => ? �]�̤���Φr�^
[��*��] => �p �]�̤���Φr�^
[��*��] = �� �]�̤���Φr�^
[��*�_] => ? �]�ѦҨ�L�U���Φr�^
[��-��+�C] �]�զr���~�^ => [��-�I+�C] => ?
[�i-��+(�I@(��-�g))] �]�զr�׭q�^=>	[�i-��+(��-�g)] => ?
== �H�U�� unicode ext-b �r�� ==
[��/�F] =>�iUnicode: 26F2E ??�j
[�X*��] =>�iUnicode: 24656 ??�j
[��*��] =>�iUnicode: 2A628 ??�j
[��*�y] =>�iUnicode: 2463D ??�j
== �H�U�S����������r�� ==
[΢-�j+(��-��)]
-------------------------------------------------------------------------------

�i�ݿ�ƶ��j

V 1. html �\�h </a> �ݸɤW, �D�n�O�~�W�@�}�l.
V 2. ���W�� <p> �S�� </p> ����
V 2. ePub �Ĥ@���ɮפ������Y, �ӥB���w�O�n�o���ɮ� mimetype
V 3. html �h�l javascript �X�n����.
V 4. <a name �n�令 <a id="pxxxx">
5. �զr�������� unicode (�ؿ�����)
6. <span class="w"><div>....�|�����D, �j�� div ����b span �̭� (p �n���]����b span �̭�)

-------------------------------------------------------------------------------

ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(143): element "br" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(144): element "a" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(144): element "br" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(145): element "a" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context

Check finished with warnings or errors!

ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(143): element "br" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(144): element "a" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(144): element "br" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context
ERROR: C:\release\epub_ziped\A112\A112n1502.epub/OPS/A112n1502_014.xhtml(145): element "a" from namespace "http://www.w3.org/1999/xhtml" not allowed in this context

Check finished with warnings or errors!

