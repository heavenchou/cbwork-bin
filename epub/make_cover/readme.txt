這是要產生 epub 封面的 perl 程式

其中 font01.ttf 是用 ttc2ttf 把 mingliu.ttc 分解出來的 "新細明體" , 
不過這是 python 才需要如此分離, perl 可以直接用 mingliu.ttc

database 版本 :

最初的版本是有副經名.
後來拿掉了.
再後來採用 unicode 1.1 以內字.
2014 年經名多了一個欄位, 用來放一些副經名的東西, 如 "(卷第四)" 這種文字.