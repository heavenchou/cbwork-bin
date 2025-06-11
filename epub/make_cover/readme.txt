這是要產生 epub 封面的 perl 程式

其中 font01.ttf 是用 ttc2ttf 把 mingliu.ttc 分解出來的 "新細明體" , 
不過這是 python 才需要如此分離, perl 可以直接用 mingliu.ttc

database 版本 :

最初的版本是有副經名.
後來拿掉了.
再後來採用 unicode 1.1 以內字.
2014 年經名多了一個欄位, 用來放一些副經名的東西, 如 "(卷第四)" 這種文字.
2023 年重新産生全套，取消卷數

0.

執行

ruby get_database_by_catalog.rb

會産生 database_2023Q4.txt

執行

ruby check_database.rb

會比較這二個檔案 
database_2023Q4.txt 
database_old.txt

産生 checkdatabase.txt

這是新舊版比較檔，有些舊檔名要寫入底下第 4 步的 database_2023Q4_newname.txt


1. 

第一次産生全套，使用類似底下檔名的資料庫，字型使用隸書 li.ttc

my $db_file = "database_2023Q4.txt";	# 經名資料庫

執行後會産生 database_2023Q4_check.txt 檔案，以供檢查

裡面有三種資料：

1. 折行的資料，有待進一步檢查，需要時可加入 // 符號強迫中斷。
2. 有非 big5 的資料
3. 總高度太高的資料

第三種的處理方法是經名超過 33 字，字型大小就會由原來的 55 變成 40，理論上不會再出現第三種太高的問題。

處理完之後，將資料複製至某目錄中。

2. 

第2次産生指定折行的多行，使用類似底下檔名的資料庫，字型使用隸書 li.ttc，裡面沒有特殊文字

$db_file = "database_2023Q4_twoline.txt";	# 經名資料庫，這是有指定折行的版本

處理完之後，將新的資料複製至第一步驟的目錄中。


3. 

第3次産生指定修訂過的經名，使用類似底下檔名的資料庫，字型使用隸書 li.ttc，裡面沒有特殊文字

$db_file = "database_2023Q4_newname.txt";	# 經名資料庫，這是特定經名

處理完之後，將新的資料複製至第一步驟的目錄中。

4.

第4次産生非 big5 文字，使用類似底下檔名的資料庫，字型使用楷書 kaiu.ttf

$db_file = "database_2023Q4_nonebig5.txt";	# 經名資料庫，這是非 big5 的版本

這個版本的文字可以用楷書呈現。

處理完之後，將新的資料複製至第一步驟的目錄中。

5.

第5次産生指定修訂過的經名，使用類似底下檔名的資料庫，字型使用天衍字庫 TH-Tshyn-P0.ttf，

$db_file = "database_2023Q4_nonebig5.txt";	# 經名資料庫，這是特定經名

這些要手動處理，可在小畫家用天衍字庫畫上文字，大字約 34 ，小字為 18 size.

處理完之後，將新的資料複製至第一步驟的目錄中。
