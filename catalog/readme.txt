catalog 此目錄要產生的是大藏經目錄相關的資料

主要資料表有

■ 大藏經基本資料  (T, X, J, A .....)
■ 各大藏經冊數列表 (T01, T02 , ....)

■ 大藏集成
■ 各大藏經目錄資料庫 (主要的各經資料庫)

■ 各經的卷數資料 (包括不連續卷資料及各卷的起始位置)
■ 各經的相關經文


ps. 檢查手邊的目錄資料

xml 經文
cbwork/normal/xx/source.txt
cbeta/cbreader/xxx_menu.txt .......
cbwork/cbreader/xxxMenu_b5.txt .......
cbepubtool/tripitaka.txt
data/python/圖檔加入漢字/database.txt

D:/cbeta.src/budalist/*
cbwork/bin/website/taisho.txt .....
cbeta/cbreader/juanline

===============================================================================

■ 大藏經基本資料  (T, X, J, A .....)

權重 1 (各大藏經出現的順序, 大正藏最重要)
全收錄 1 (1 表示全收錄, 0 表示選錄, 有時經名會需要寫選錄)
tid T
中文全名 大正新脩大藏經
中文簡稱 大正藏
英文全名 Taisho Tripitaka
* 英文簡稱 Taisho
總冊數 85
紙本來源 大正新修大藏經刊行會 編 / 東京：大藏出版株式會社, Popular Edition in 1988.

CREATE TABLE `tripitaka` (
`number` INT NOT NULL COMMENT '權重順序',
`full` INT NOT NULL COMMENT '全部收錄',
`tid` VARCHAR( 3 ) NOT NULL COMMENT 'tid',
`name_c` VARCHAR( 15 ) NOT NULL COMMENT '中文全名',
`short_name_c` VARCHAR( 10 ) NOT NULL COMMENT '中文簡稱',
`name_e` VARCHAR( 80 ) NOT NULL COMMENT '英文全名',
`total_vol` INT NOT NULL COMMENT '總冊數',
`paper_source` VARCHAR( 80 ) NOT NULL COMMENT '紙本來源',
PRIMARY KEY ( `tid` ) 
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = '大藏經資料';


■ 各大藏經冊數列表

T01,T,01
T02,T,02
....
T55,T,55
T85,T,85
X01,X,01
X02,X,02
....

CREATE TABLE `voldata` (
`tvol` VARCHAR( 6 ) NOT NULL COMMENT '冊代碼',
`tid` VARCHAR( 3 ) NOT NULL COMMENT '藏經代碼',
`vol` VARCHAR( 3 ) NOT NULL COMMENT '冊數',
PRIMARY KEY ( `tvol` ) 
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = 'CBETA佛典冊數';


■ 各大藏經目錄資料庫

資料表結構：

id (T01n0001 , ZH001n0001a)
藏經代碼 (T,X,J,ZH,ZW,....)
冊
經號
*部類 (CBETA 的部類)
*部別
卷數
是否是連續卷?
經名
作譯者


T01n0001,T,01,0001,22,1,長阿含經,後秦 佛陀耶舍共竺佛念譯
T01n0002,T,01,0002,1,1,七佛經,宋 法天譯
T01n0003,T,01,0003,2,1,毘婆尸佛經,宋 法天譯

CREATE TABLE `catalog` (
`id` VARCHAR( 15 ) NOT NULL COMMENT 'id',
`tid` VARCHAR( 3 ) NOT NULL COMMENT '藏經代碼',
`vol` VARCHAR( 3 ) NOT NULL COMMENT '冊數',
`sid` VARCHAR( 5 ) NOT NULL COMMENT '經號',
`juan` INT NOT NULL COMMENT '卷數',
`juantype` INT NOT NULL COMMENT '連續卷',
`sutra_name` VARCHAR( 250 ) NOT NULL COMMENT '經名',
`byline` VARCHAR( 250 ) NOT NULL COMMENT '作譯者',
PRIMARY KEY ( `id` ) 
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = 'CBETA佛典目錄';

■ 各經的卷數資料

id T01n0001
tid T
vol 01
sid 0001
卷流水號 1
卷實際卷數 1
此卷的頁欄行 0001a01

T01n0001,T,01,0001,1,1,0001a01
T01n0001,T,01,0001,2,2,0011a02
T01n0001,T,01,0001,3,3,0016b12

CREATE TABLE `juandata` (
`id` VARCHAR( 15 ) NOT NULL COMMENT 'id',
`tid` VARCHAR( 3 ) NOT NULL COMMENT '藏經代碼',
`vol` VARCHAR( 3 ) NOT NULL COMMENT '冊',
`sid` VARCHAR( 5 ) NOT NULL COMMENT '經號',
`juan_count` INT NOT NULL COMMENT '卷數流水號',
`juan_num` INT NOT NULL COMMENT '實際卷數',
`pageline` VARCHAR( 7 ) NOT NULL COMMENT '頁欄行'
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT = 'CBETA佛典各卷資料';

===============================================================================

■ 作業流程

1. 用catalog.pl , 
   產生 catalog.txt , 這是各經的主要資料庫, 也會產生 juandata 目錄, 這是各卷的資料.
   ★ 執行前要先準備好的檔案 : vol_list.txt , 這是所有冊數的列表
   ★ 執行後大般若經要手動處理成三冊如下：
	T05n0220,T,05,0220,200,1,大般若波羅蜜多經(第1卷-第200卷),唐 玄奘譯
	T06n0220,T,06,0220,200,0,大般若波羅蜜多經(第201卷-第400卷),唐 玄奘譯
	T07n0220,T,07,0220,200,0,大般若波羅蜜多經(第401卷-第600卷),唐 玄奘譯
   ★ juandata 目錄中的 T07 也要處理成 1-200 卷
   
2. juandata 目錄的內容要合併成一個 all.txt , 也就是下命令 copy *.txt all.txt .
   這是要上傳到 juandata 資料庫, 也是底下會用到的資料.
   
3. 用 catalog2mysql.pl 產生要上傳到 mysql cbetaorg_tripitaka 資料庫的目錄 mysql_catalog.txt

4. 用 create_drupal_import_cvs.pl 產生 drupal_import_sutra.csv, drupal_import_juan.csv , 這是要匯入 drupal 各經與各卷資料.

   Drupal Import 的過程
   1. 選 "經文頁面"
   2. 上傳檔案
   3. 選 "Comma Separated Values", 用 , 及 " 符號
   4. 選預設值
   5. 跳過
   6. 語言 : 語言中性
      選單 : 主選單
      輸入格式 : PHP Code
      作者 : cbeta
      日期 : 空白
      日誌訊息 : (清空)
      已發表 : yes
      首頁推薦 : no
      置頂 : no
      回應 : 可回應

   ps. 2015/06/29 遇到這個錯誤 
   
   Fatal error: Cannot unset string offsets in /home1/cbetaorg/public_html/sites/all/modules/image/contrib/image_attach/image_attach.module on line 457
   
   就把 image 模組都關掉, 只留最主要的, 錯誤就不見了.

5. 產生要呈現的經文 (非原書格式)

   a. 先用 CBReader 來產生, 結果放在 c:\release\cbr_out_web
      格式 : 不依原書, 有頁欄行, 無校勘, 有標點
      缺字 : 通用字, 組字式, UnicodeEXT (此項等於沒作用)
      修訂 : 修訂用字
      梵巴悉曇皆用 Unicode
   
   b. 使用 cbrhtm2web_all.bat (cbrhtm2web.pl) 將 cbr_out_web 的內容轉換成 cb_tripitaka_web 目錄

6. 產生要呈現的經文 (原書格式)

   a. 先用 CBReader 來產生, 結果放在 c:\release\cbr_out_web_line
      格式 : 依原書, 有頁欄行, 無校勘, 有標點
      缺字 : 通用字, 組字式, UnicodeEXT (此項等於沒作用)
      修訂 : 修訂用字
      梵巴悉曇皆用 Unicode
   
   b. 使用 cbrhtm2web_all.bat (裡面要設定依原書切行 set line=1)  (cbrhtm2web.pl) 將 cbr_out_web_line 的內容轉換成 cb_tripitaka_web_line 目錄

7. 圖檔要補齊, 分別放在網站的 ./cb_tripitaka_web/figures , ./cb_tripitaka_web/sd-gif , ./cb_tripitaka_web/rj-gif

待做事項 :

1. 步驟 3 產生的資料要與 2014 年版比對, 以便手動做出要上傳的部份.
1. 步驟 4 產生的資料要與 2014 年版比對, 以便手動修改部份經名.