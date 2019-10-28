注意: 最底下有一段要手動修改記錄:

■ 首先在 bulei 目錄下要先產生部類的資料

buleiBL.txt 產生全部部類目錄的來源檔, 這是由惠敏法師的部類列表產生的.
buleiT.txt 產生大正藏各冊的目錄列表.
buleiX.txt 產生卍續藏各冊的目錄列表.
buleiXB.txt 產生卍續藏各部的目錄列表.
....
....
buleinewsign.txt 產生新式標點的目錄列表.
buleifuyan.txt 產生福嚴三年讀經的目錄列表.
buleilichan.txt 產生杜老師做的禮懺部目錄列表.

以上來源請參考 bulei/readme.txt

至於大正藏的部則是由各冊來組合的, 所以就不需要產生.

■ 產生 TOC

執行前要更新 C:/cbwork/bin/sutralst/sutralst.txt , 這是由 C:/cbwork/bin/sutralst/sutralst.pl 來產生的.

make_toc.pl 產生 TOC 的主要程式, 但參數有一點複雜, 等一下會解釋.
            ■ (若經文有增加, 要改 c:/cbwork/work/bin/cbetasub.pl)

make_toc.cfg 主要參數檔, 只有二行, 這是你們要改的, 改了之後就不用再 update .
             除非又加了新參數.

make_toc_all.bat 產生全部目錄的批次檔. (大正部類, 大正冊數, 卍續冊數, ...)

研究一下 make_toc_all.bat 就知道有哪些參數.

1. 產生部類, 共有 21 個部類.

方式: make_toc.pl 3 1

說明: 第一個參數是部類編號, 1 是阿含部類... 20 是敦煌寫本部類
      第二個參數一定是 1 , 表示這是產生部類目錄.

2.產生大正藏的冊, 共有 1-55 , 85 冊, 但其中有幾冊要分成 ab , 因為那是不同部的關係.

方式: make_toc.pl 5 2

說明: 第一個參數是冊數, 1 是第一冊... 55 是第 55 冊, 85 是第 85 冊
      第二個參數一定是 2 , 表示這是產生大正藏冊數.

方式: make_toc.pl 9a 2

說明: 9a 表示是第九冊上半冊(法華部), 而 9b 則是第九冊下半冊(華嚴部).
這一類的計有:

perl make_toc.pl 9a 2
perl make_toc.pl 9b 2
perl make_toc.pl 12a 2
perl make_toc.pl 12b 2
perl make_toc.pl 26a 2
perl make_toc.pl 26b 2
perl make_toc.pl 30a 2
perl make_toc.pl 30b 2
perl make_toc.pl 40a 2
perl make_toc.pl 40b 2
perl make_toc.pl 44a 2
perl make_toc.pl 44b 2
perl make_toc.pl 54a 2
perl make_toc.pl 54b 2
perl make_toc.pl 85a 2
perl make_toc.pl 85b 2

3.產生卍續藏的冊, 共有 1-88 冊.

方式: make_toc.pl 78 3

說明: 第一個參數是冊數, 78 是第78冊... 87 是第 87 冊
      第二個參數一定是 3 , 表示這是產生卍續藏冊數.
      
4.產生卍續藏的部, 共有 7 部.

方式: make_toc.pl 1 4

說明: 第一個參數是部, 1 是第1個部 (印度撰述)
      第二個參數一定是 4 , 表示這是產生卍續藏部.

5.產生嘉興藏的冊, 共有 40 冊. (目前是 1,7,10,15,19~40)

方式: make_toc.pl 1 5

6.產生正史的冊, 共有 1 冊.

方式: make_toc.pl 1 6

7.產生藏外的冊, 共有 9 冊.

方式: make_toc.pl 1 7

8.產生百品的冊, 共有 1 冊.

方式: make_toc.pl 1 8

############################################

a.產生新標目錄, 共有 1 部.

方式: make_toc.pl 1 a

b.產生印順導師福嚴讀經目錄

方式: make_toc.pl 1 b

c.產生杜老師做的禮懺部目錄

方式: make_toc.pl 1 c

--------------------------
手動修改：
--------------------------

1. 跨冊經要手動處理.

2.般若經部類

    <name>T0220d 大般若波羅蜜多經 (28卷)</name><book>T</book><vol>07</vol><sutra>0220</sutra>
    <UL>
      <name>目錄</name>
      <UL>
        <name>4 會</name><book>T</book><vol>07</vol><juan>401</juan><pageline>0763a02</pageline>
        <UL><!-- Level 1 -->
          <name>序</name><book>T</book><vol>07</vol><juan>401</juan><pageline>0763a02</pageline>
          <name>1 妙行品</name><book>T</book><vol>07</vol><juan>538</juan><pageline>0763b06</pageline>
          <name>2 帝釋品</name><book>T</book><vol>07</vol><juan>539</juan><pageline>0769c01</pageline>

改成如下, 以免無法直接連到正確位置

    <name>T0220d 大般若波羅蜜多經 (28卷)</name><book>T</book><vol>07</vol><sutra>0220</sutra><pageline>0763a02</pageline>
