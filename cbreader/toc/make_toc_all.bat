@echo off
call \cbwork\bin\perl518.bat run
rem ===============================================================================================
rem 以上先設定 perl 的執行環境
rem 以下才開始執行各冊
rem 程式說明：產生 CBReader 的 TOC 目錄
rem 參數說明：
rem 　　bm2nor.pl 執行冊數 [NoHead] [No_Normal] [JK_Num] [ Normal | Normal1 | App | App1 ]
rem 　　nohead 表示沒有卷首資訊
rem 　　no_normal 是不要換通用字
rem 　　jk_num 是要呈現校勘數字及星號
rem 　　normal 一卷一檔(預設值) / normal1 一經一檔 / app 一卷一檔 App 格式 / app1 一經一檔 app 格式
rem 設定檔：相關設定由 ../cbwork_bin.ini 取得
rem 範例：perl bm2nor.pl N01
rem ===============================================================================================



rem #######################  先刪除記錄檔 ###############

del make_toc-err.txt

goto start



rem ==== 部類 ========
perl make_toc.pl BL 1
perl make_toc.pl BL 2
perl make_toc.pl BL 3
perl make_toc.pl BL 4
perl make_toc.pl BL 5
perl make_toc.pl BL 6
perl make_toc.pl BL 7
perl make_toc.pl BL 8
perl make_toc.pl BL 9
perl make_toc.pl BL 10
perl make_toc.pl BL 11
perl make_toc.pl BL 12
perl make_toc.pl BL 13
perl make_toc.pl BL 14
perl make_toc.pl BL 15
perl make_toc.pl BL 16
perl make_toc.pl BL 17
perl make_toc.pl BL 18
perl make_toc.pl BL 19
perl make_toc.pl BL 20
perl make_toc.pl BL 21


rem ==== 大正冊 ========
perl make_toc.pl T 1
perl make_toc.pl T 2
perl make_toc.pl T 3
perl make_toc.pl T 4
perl make_toc.pl T 5
perl make_toc.pl T 6
perl make_toc.pl T 7
perl make_toc.pl T 8
perl make_toc.pl T 9a
perl make_toc.pl T 9b
perl make_toc.pl T 10
perl make_toc.pl T 11
perl make_toc.pl T 12a
perl make_toc.pl T 12b
perl make_toc.pl T 13
perl make_toc.pl T 14
perl make_toc.pl T 15
perl make_toc.pl T 16
perl make_toc.pl T 17
perl make_toc.pl T 18
perl make_toc.pl T 19
perl make_toc.pl T 20
perl make_toc.pl T 21
perl make_toc.pl T 22
perl make_toc.pl T 23
perl make_toc.pl T 24
perl make_toc.pl T 25
perl make_toc.pl T 26a
perl make_toc.pl T 26b
perl make_toc.pl T 27
perl make_toc.pl T 28
perl make_toc.pl T 29
perl make_toc.pl T 30a
perl make_toc.pl T 30b
perl make_toc.pl T 31
perl make_toc.pl T 32
perl make_toc.pl T 33
perl make_toc.pl T 34
perl make_toc.pl T 35
perl make_toc.pl T 36
perl make_toc.pl T 37
perl make_toc.pl T 38
perl make_toc.pl T 39
perl make_toc.pl T 40a
perl make_toc.pl T 40b
perl make_toc.pl T 41
perl make_toc.pl T 42
perl make_toc.pl T 43
perl make_toc.pl T 44a
perl make_toc.pl T 44b
perl make_toc.pl T 45
perl make_toc.pl T 46
perl make_toc.pl T 47
perl make_toc.pl T 48
perl make_toc.pl T 49
perl make_toc.pl T 50
perl make_toc.pl T 51
perl make_toc.pl T 52
perl make_toc.pl T 53
perl make_toc.pl T 54a
perl make_toc.pl T 54b
perl make_toc.pl T 55
perl make_toc.pl T 85a
perl make_toc.pl T 85b

rem ==== 卍續冊 ========
perl make_toc.pl X 1
perl make_toc.pl X 2
perl make_toc.pl X 3
perl make_toc.pl X 4
perl make_toc.pl X 5
perl make_toc.pl X 6
perl make_toc.pl X 7
perl make_toc.pl X 8
perl make_toc.pl X 9
perl make_toc.pl X 10
perl make_toc.pl X 11
perl make_toc.pl X 12
perl make_toc.pl X 13
perl make_toc.pl X 14
perl make_toc.pl X 15
perl make_toc.pl X 16
perl make_toc.pl X 17
perl make_toc.pl X 18
perl make_toc.pl X 19
perl make_toc.pl X 20
perl make_toc.pl X 21
perl make_toc.pl X 22
perl make_toc.pl X 23
perl make_toc.pl X 24
perl make_toc.pl X 25
perl make_toc.pl X 26
perl make_toc.pl X 27
perl make_toc.pl X 28
perl make_toc.pl X 29
perl make_toc.pl X 30
perl make_toc.pl X 31
perl make_toc.pl X 32
perl make_toc.pl X 33
perl make_toc.pl X 34
perl make_toc.pl X 35
perl make_toc.pl X 36
perl make_toc.pl X 37
perl make_toc.pl X 38
perl make_toc.pl X 39
perl make_toc.pl X 40
perl make_toc.pl X 41
perl make_toc.pl X 42
perl make_toc.pl X 43
perl make_toc.pl X 44
perl make_toc.pl X 45
perl make_toc.pl X 46
perl make_toc.pl X 47
perl make_toc.pl X 48
perl make_toc.pl X 49
perl make_toc.pl X 50
perl make_toc.pl X 51
perl make_toc.pl X 52
perl make_toc.pl X 53
perl make_toc.pl X 54
perl make_toc.pl X 55
perl make_toc.pl X 56
perl make_toc.pl X 57
perl make_toc.pl X 58
perl make_toc.pl X 59
perl make_toc.pl X 60
perl make_toc.pl X 61
perl make_toc.pl X 62
perl make_toc.pl X 63
perl make_toc.pl X 64
perl make_toc.pl X 65
perl make_toc.pl X 66
perl make_toc.pl X 67
perl make_toc.pl X 68
perl make_toc.pl X 69
perl make_toc.pl X 70
perl make_toc.pl X 71
perl make_toc.pl X 72
perl make_toc.pl X 73
perl make_toc.pl X 74
perl make_toc.pl X 75
perl make_toc.pl X 76
perl make_toc.pl X 77
perl make_toc.pl X 78
perl make_toc.pl X 79
perl make_toc.pl X 80
perl make_toc.pl X 81
perl make_toc.pl X 82
perl make_toc.pl X 83
perl make_toc.pl X 84
perl make_toc.pl X 85
perl make_toc.pl X 86
perl make_toc.pl X 87
perl make_toc.pl X 88

rem ==== 卍續部 ========
perl make_toc.pl XB 1
perl make_toc.pl XB 2
perl make_toc.pl XB 3
perl make_toc.pl XB 4
perl make_toc.pl XB 5
perl make_toc.pl XB 6
perl make_toc.pl XB 7

rem ==== 金藏冊 ========
perl make_toc.pl A 091
perl make_toc.pl A 097
perl make_toc.pl A 098
perl make_toc.pl A 110
perl make_toc.pl A 111
perl make_toc.pl A 112
perl make_toc.pl A 114
perl make_toc.pl A 119
perl make_toc.pl A 120
perl make_toc.pl A 121



rem ==== 中華藏冊 ========
perl make_toc.pl C 056
perl make_toc.pl C 057
perl make_toc.pl C 059
perl make_toc.pl C 071
perl make_toc.pl C 073
perl make_toc.pl C 077
perl make_toc.pl C 078
perl make_toc.pl C 097
perl make_toc.pl C 106

rem ==== 國圖 冊 ========  
perl make_toc.pl D 1
perl make_toc.pl D 2
perl make_toc.pl D 3
perl make_toc.pl D 4
perl make_toc.pl D 5
perl make_toc.pl D 6
perl make_toc.pl D 7
perl make_toc.pl D 8
perl make_toc.pl D 9
perl make_toc.pl D 10
perl make_toc.pl D 11
perl make_toc.pl D 12
perl make_toc.pl D 13
perl make_toc.pl D 14
perl make_toc.pl D 15
perl make_toc.pl D 16
perl make_toc.pl D 17
perl make_toc.pl D 18
perl make_toc.pl D 19
perl make_toc.pl D 20
perl make_toc.pl D 21
perl make_toc.pl D 22
perl make_toc.pl D 23
perl make_toc.pl D 24
perl make_toc.pl D 25
perl make_toc.pl D 26
perl make_toc.pl D 27
perl make_toc.pl D 28
perl make_toc.pl D 29
perl make_toc.pl D 30
perl make_toc.pl D 31
perl make_toc.pl D 32
perl make_toc.pl D 33
perl make_toc.pl D 34
perl make_toc.pl D 35
perl make_toc.pl D 36
perl make_toc.pl D 37
perl make_toc.pl D 38
perl make_toc.pl D 39
perl make_toc.pl D 40
perl make_toc.pl D 41
perl make_toc.pl D 42
perl make_toc.pl D 43
perl make_toc.pl D 44
perl make_toc.pl D 45
perl make_toc.pl D 46
perl make_toc.pl D 47
perl make_toc.pl D 48
perl make_toc.pl D 49
perl make_toc.pl D 50
perl make_toc.pl D 51
perl make_toc.pl D 52
perl make_toc.pl D 53
perl make_toc.pl D 54
perl make_toc.pl D 55
perl make_toc.pl D 56
perl make_toc.pl D 57
perl make_toc.pl D 58
perl make_toc.pl D 59
perl make_toc.pl D 60
perl make_toc.pl D 61
perl make_toc.pl D 62
perl make_toc.pl D 63
perl make_toc.pl D 64

rem ==== 房山石經冊 ========      
perl make_toc.pl F 01
perl make_toc.pl F 02
perl make_toc.pl F 03
perl make_toc.pl F 12
perl make_toc.pl F 24
perl make_toc.pl F 27
perl make_toc.pl F 28
perl make_toc.pl F 29

rem ==== 佛教大藏經冊 ========  
perl make_toc.pl G 052
perl make_toc.pl G 069
perl make_toc.pl G 083
perl make_toc.pl G 084


rem ==== 嘉興冊 ========
perl make_toc.pl J 1
perl make_toc.pl J 2
perl make_toc.pl J 3
perl make_toc.pl J 4
perl make_toc.pl J 5
perl make_toc.pl J 6
perl make_toc.pl J 7
perl make_toc.pl J 8
perl make_toc.pl J 9
perl make_toc.pl J 10
perl make_toc.pl J 11
perl make_toc.pl J 12
perl make_toc.pl J 13
perl make_toc.pl J 14
perl make_toc.pl J 15
perl make_toc.pl J 16
perl make_toc.pl J 17
perl make_toc.pl J 18
perl make_toc.pl J 19
perl make_toc.pl J 20
perl make_toc.pl J 21
perl make_toc.pl J 22
perl make_toc.pl J 23
perl make_toc.pl J 24
perl make_toc.pl J 25
perl make_toc.pl J 26
perl make_toc.pl J 27
perl make_toc.pl J 28
perl make_toc.pl J 29
perl make_toc.pl J 30
perl make_toc.pl J 31
perl make_toc.pl J 32
perl make_toc.pl J 33
perl make_toc.pl J 34
perl make_toc.pl J 35
perl make_toc.pl J 36
perl make_toc.pl J 37
perl make_toc.pl J 38
perl make_toc.pl J 39
perl make_toc.pl J 40



rem ==== 高麗藏冊 ========  
perl make_toc.pl K 05
perl make_toc.pl K 32
perl make_toc.pl K 34
perl make_toc.pl K 35
perl make_toc.pl K 38
perl make_toc.pl K 41

rem ==== 乾隆藏冊 ========  
perl make_toc.pl L 115
perl make_toc.pl L 116
perl make_toc.pl L 130
perl make_toc.pl L 131
perl make_toc.pl L 132
perl make_toc.pl L 133
perl make_toc.pl L 135
perl make_toc.pl L 141
perl make_toc.pl L 143
perl make_toc.pl L 149
perl make_toc.pl L 153
perl make_toc.pl L 154
perl make_toc.pl L 155
perl make_toc.pl L 157
perl make_toc.pl L 158
perl make_toc.pl L 162
perl make_toc.pl L 164

rem ==== 卍正藏冊 ========
perl make_toc.pl M 059


rem ==== 南傳大藏經冊 ========  
perl make_toc.pl N 1
perl make_toc.pl N 2
perl make_toc.pl N 3
perl make_toc.pl N 4
perl make_toc.pl N 5
perl make_toc.pl N 6
perl make_toc.pl N 7
perl make_toc.pl N 8
perl make_toc.pl N 9
perl make_toc.pl N 10
perl make_toc.pl N 11
perl make_toc.pl N 12
perl make_toc.pl N 13
perl make_toc.pl N 14
perl make_toc.pl N 15
perl make_toc.pl N 16
perl make_toc.pl N 17
perl make_toc.pl N 18
perl make_toc.pl N 19
perl make_toc.pl N 20
perl make_toc.pl N 21
perl make_toc.pl N 22
perl make_toc.pl N 23
perl make_toc.pl N 24
perl make_toc.pl N 25
perl make_toc.pl N 26
perl make_toc.pl N 27
perl make_toc.pl N 28
perl make_toc.pl N 29
perl make_toc.pl N 30
perl make_toc.pl N 31
perl make_toc.pl N 32
perl make_toc.pl N 33
perl make_toc.pl N 34
perl make_toc.pl N 35
perl make_toc.pl N 36
perl make_toc.pl N 37
perl make_toc.pl N 38
perl make_toc.pl N 39
perl make_toc.pl N 40
perl make_toc.pl N 41
perl make_toc.pl N 42
perl make_toc.pl N 43
perl make_toc.pl N 44
perl make_toc.pl N 45
perl make_toc.pl N 46
perl make_toc.pl N 47
perl make_toc.pl N 48
perl make_toc.pl N 49
perl make_toc.pl N 50
perl make_toc.pl N 51
perl make_toc.pl N 52
perl make_toc.pl N 53
perl make_toc.pl N 54
perl make_toc.pl N 55
perl make_toc.pl N 56
perl make_toc.pl N 57
perl make_toc.pl N 58
perl make_toc.pl N 59
perl make_toc.pl N 60
perl make_toc.pl N 61
perl make_toc.pl N 62
perl make_toc.pl N 63
perl make_toc.pl N 64
perl make_toc.pl N 65
perl make_toc.pl N 66
perl make_toc.pl N 67
perl make_toc.pl N 68
perl make_toc.pl N 69
perl make_toc.pl N 70

rem ==== 南傳大藏經 部 ========  
perl make_toc.pl NB 1
perl make_toc.pl NB 2
perl make_toc.pl NB 3
perl make_toc.pl NB 4

rem ==== 永樂北藏冊 ========
perl make_toc.pl P 154
perl make_toc.pl P 155
perl make_toc.pl P 167
perl make_toc.pl P 168
perl make_toc.pl P 174
perl make_toc.pl P 178
perl make_toc.pl P 179
perl make_toc.pl P 180
perl make_toc.pl P 181
perl make_toc.pl P 182
perl make_toc.pl P 183
perl make_toc.pl P 184
perl make_toc.pl P 185
perl make_toc.pl P 187
perl make_toc.pl P 189

rem ==== 宋藏遺珍冊 ========
perl make_toc.pl S 06

rem ==== 洪武南藏冊 ========
perl make_toc.pl U 205
perl make_toc.pl U 222
perl make_toc.pl U 223

rem ==== 藏外冊 ========
perl make_toc.pl W 1
perl make_toc.pl W 2
perl make_toc.pl W 3
perl make_toc.pl W 4
perl make_toc.pl W 5
perl make_toc.pl W 6
perl make_toc.pl W 7
perl make_toc.pl W 8
perl make_toc.pl W 9

rem ==== 正史冊 ========
perl make_toc.pl H 1

rem ==== 百品冊 ========
perl make_toc.pl I 1

rem ==== 大藏經補編 ========
perl make_toc.pl B 1
perl make_toc.pl B 2
perl make_toc.pl B 3
perl make_toc.pl B 4
perl make_toc.pl B 5
perl make_toc.pl B 6
perl make_toc.pl B 7
perl make_toc.pl B 8
perl make_toc.pl B 9
perl make_toc.pl B 10
perl make_toc.pl B 11
perl make_toc.pl B 12
perl make_toc.pl B 13
perl make_toc.pl B 14
perl make_toc.pl B 15
perl make_toc.pl B 16
perl make_toc.pl B 17
perl make_toc.pl B 18
perl make_toc.pl B 19
perl make_toc.pl B 20
perl make_toc.pl B 21
perl make_toc.pl B 22
perl make_toc.pl B 23
perl make_toc.pl B 24
perl make_toc.pl B 25
perl make_toc.pl B 26
perl make_toc.pl B 27
perl make_toc.pl B 28
perl make_toc.pl B 29
perl make_toc.pl B 30
perl make_toc.pl B 31
perl make_toc.pl B 32
perl make_toc.pl B 33
perl make_toc.pl B 34
perl make_toc.pl B 35
perl make_toc.pl B 36

rem ==== 中國佛寺史志彙刊 ========
perl make_toc.pl GA 009
perl make_toc.pl GA 010
perl make_toc.pl GA 011
perl make_toc.pl GA 012
perl make_toc.pl GA 020
perl make_toc.pl GA 031
perl make_toc.pl GA 032
perl make_toc.pl GA 043
perl make_toc.pl GA 045
perl make_toc.pl GA 058
perl make_toc.pl GA 072
perl make_toc.pl GA 079
perl make_toc.pl GA 081
perl make_toc.pl GA 082
perl make_toc.pl GA 084
perl make_toc.pl GA 088
perl make_toc.pl GA 089
perl make_toc.pl GA 090


rem ==== 中國佛寺志叢刊 ========
perl make_toc.pl GB 078
:start

rem ==== 中國佛寺志 GA GB 二套 ========
perl make_toc.pl GAB 1
perl make_toc.pl GAB 2
goto end

rem ==== 西蓮淨苑 ========
perl make_toc.pl ZY 1
perl make_toc.pl ZY 2
perl make_toc.pl ZY 3
perl make_toc.pl ZY 4
perl make_toc.pl ZY 5
perl make_toc.pl ZY 6
perl make_toc.pl ZY 7
perl make_toc.pl ZY 8
perl make_toc.pl ZY 9
perl make_toc.pl ZY 10
perl make_toc.pl ZY 11
perl make_toc.pl ZY 12
perl make_toc.pl ZY 13
perl make_toc.pl ZY 14
perl make_toc.pl ZY 15
perl make_toc.pl ZY 16
perl make_toc.pl ZY 17
perl make_toc.pl ZY 18
perl make_toc.pl ZY 19
perl make_toc.pl ZY 20
perl make_toc.pl ZY 21
perl make_toc.pl ZY 22
perl make_toc.pl ZY 23
perl make_toc.pl ZY 24
perl make_toc.pl ZY 25
perl make_toc.pl ZY 26
perl make_toc.pl ZY 27
perl make_toc.pl ZY 28
perl make_toc.pl ZY 29
perl make_toc.pl ZY 30
perl make_toc.pl ZY 31
perl make_toc.pl ZY 32
perl make_toc.pl ZY 33
perl make_toc.pl ZY 34
perl make_toc.pl ZY 35
perl make_toc.pl ZY 36
perl make_toc.pl ZY 37
perl make_toc.pl ZY 38
perl make_toc.pl ZY 39
perl make_toc.pl ZY 40
perl make_toc.pl ZY 41
perl make_toc.pl ZY 42
perl make_toc.pl ZY 43
perl make_toc.pl ZY 44

rem ==== 西蓮淨苑 智諭老和尚 部類 ========
perl make_toc.pl ZYB 1
perl make_toc.pl ZYB 2
perl make_toc.pl ZYB 3
perl make_toc.pl ZYB 4
perl make_toc.pl ZYB 5
perl make_toc.pl ZYB 6

rem ==== 西蓮淨苑 道安長老 部類 ========
perl make_toc.pl DAB 1
perl make_toc.pl DAB 2
perl make_toc.pl DAB 3
perl make_toc.pl DAB 4

rem ==== 新標 ========
perl make_toc.pl newsign 1

rem ==== 福嚴讀經 ========
rem perl make_toc.pl fuyan 1

rem ==== 禮懺 ========
rem perl make_toc.pl lichan 1

:end