rem ==========================================================
rem 程式說明：XML P5 版轉出純文字 Normal 版
rem 參數說明：p5totxt.py 參數
rem 　-a：不要檔頭資訊
rem 　-v：指定要轉換哪一冊
rem 　-k：顯示校勘符號
rem 　-u：一卷一檔, 預設是一經一檔
rem 　-x：悉曇字呈現方法: 0=轉寫(預設), 1=entity &SD-xxxx, 2=◇【◇】
rem 　-z：不使用通用字
rem 設定檔：相關設定由 ../cbwork_bin.ini 取得
rem 範例：p5totxt.py -v N01 -z -k -x 1
rem ==========================================================

p5totxt.py -v N01 -z -k -x 1