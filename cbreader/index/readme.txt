build_index.pl 使用方法

utf8 normal 產生的方法:

   1. 用 p5totxt.py 產生 utf8 的 normal 版, 不要檔頭, 不要校勘, 不要通用, 一卷一檔, 悉曇字用 &SD-xxxx;
      例 : p5totxt.py -a -u -x 1 -z -v T01
   2. 再用 u8-b5.py 轉成 big5 normal , 不要使用通用字, 非 big5 的字會轉成組字式. 
       要記得用特別處理過日文的 u8-b5 版本, 日文就會轉成 &#Xxxxx; , 而不是【A】這種無法檢索的拼音.
      例 : u8-b5_japan.py -s c:/temp/u8 -o c:/temp/u8_to_b5


建一個子目錄, 裡面放二個檔案, 一個是 build_index.pl , 一個是 buildlist.txt
 
其中 buildlist.txt 如下:
 
10
C:\cbeta\Normal\T01\T0001_001.txt
C:\cbeta\Normal\T01\T0001_002.txt
C:\cbeta\Normal\T01\T0001_003.txt
C:\cbeta\Normal\T01\T0001_004.txt
C:\cbeta\Normal\T01\T0001_005.txt
C:\cbeta\Normal\T01\T0001_006.txt
C:\cbeta\Normal\T01\T0001_007.txt
C:\cbeta\Normal\T01\T0001_008.txt
C:\cbeta\Normal\T01\T0001_009.txt
C:\cbeta\Normal\T01\T0001_010.txt
 
它就是每一卷普及版的位置, 第一行只是告訴程式, 底下有幾卷, 本例是 10 卷
然後執行 build_index.pl 就行了. 
 
執行後會再產生二個檔, 將那二個檔及 buildlist.txt 放在
cbreader 目錄下的 Index 子目錄就 ok 了.
