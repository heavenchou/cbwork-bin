########################################################################
# count_word.pl                                    ~by heaven 2020/11/29
#
# 計算 XML p5a 經文的字數
#
# 執行參數 
#   -c : 統計某一部典籍
#   -v : 統計某一冊典籍
#   -n : 統計某一經
#   -c -v -n 只能三選一
#   -xn : 統計結果不要列出各經細節
#   -o : 輸出檔案, 預設檔名為 count_word.csv
#   -d : debug 用的檔案, -d debug.txt
#   例：
#   perl count_word.pl -c T
#   perl count_word.pl -v T01
#   perl count_word.pl -n T01n0001.xml
#   perl count_word.pl -v T01 -xn
#   perl count_word.pl -c T -o count_word.csv
#
# 設定檔：相關設定由 ../cbwork_bin.ini 取得
#
# Copyright (C) 1998-2020 CBETA
# Copyright (C) 2020 Heaven Chou
################################

#use lib "../";
#use cbeta;
use utf8;
use autodie;
use Config::IniFiles;
use Getopt::Long;
use File::Find;

#######################################
# 主要變數
#######################################

#my %bookCount = ();  # 各書的字數統計, 不含校勘、校註
#my %volCount = ();  # 各冊的字數統計, 不含校勘、校註
#my %sutraCount = ();  # 各經的字數統計, 不含校勘、校註
#
#my %bookCount_note = ();  # 各書的校註字數統計
#my %volCount_note = ();  # 各冊的校註字數統計
#my %sutraCount_note = ();  # 各經的校註字數統計
#
#my %bookCount_mod = ();  # 各書的 mod 校註字數統計
#my %volCount_mod = ();  # 各冊的 mod 校註字數統計
#my %sutraCount_mod = ();  # 各經的 mod 校註字數統計
#
#my %bookCount_orig = ();  # 各書的 orig 字數統計, 可能在 lem 或 rdg 中
#my %volCount_orig = ();  # 各冊的 orig 字數統計, 可能在 lem 或 rdg 中
#my %sutraCount_orig = ();  # 各經的 orig 字數統計, 可能在 lem 或 rdg 中
#
#my %bookCount_lem = ();  # 各書的 lem 字數統計
#my %volCount_lem = ();  # 各冊的 lem 字數統計
#my %sutraCount_lem = ();  # 各經的 lem 字數統計
#
#my %bookCount_rdg = ();  # 各書的 rdg 字數統計
#my %volCount_rdg = ();  # 各冊的 rdg 字數統計
#my %sutraCount_rdg = ();  # 各經的 rdg 字數統計

# 資料結構為
# $bookCount[0] 表示中文 , [1]是英文, [2]是符號
# $bookCount[0]{text} 表示文字區, 計有 text, note, mod, orig, lem, rdg
# $bookCount[0]{text}{T} 表示大正藏文字區

# orig 可能在 lem , 也可能在 rdg
# [0]是中文, [1]是英文, [2]是符號, [3]是未知字元
my @bookCount = ();     # 各藏經
my @volCount = ();      # 各冊
my @sutraCount = ();    # 各單經

$bookCount[0] = {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};
$volCount[0] =   {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};
$sutraCount[0] = {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};

$bookCount[1] =  {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};
$volCount[1] =   {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};
$sutraCount[1] = {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};

$bookCount[2] =  {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};
$volCount[2] =   {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};
$sutraCount[2] = {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};

$bookCount[3] =  {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};
$volCount[3] =   {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};
$sutraCount[3] = {text => {}, note => {}, mod => {}, orig => {}, lem => {}, rdg => {}};

my $book = "";  # 目前書本
my $vol = "";   # 目前冊數
my $sutra = ""; # 目前經名
my $thisVer = "";  # 本經版本, 例如大正藏為【大】

my $condition = "text"; # 目前標記, 有這些 : text, note, mod, orig, lem, rdg, skip(忽略的)

# 狀態堆疊
# 例如遇到 note orig , 則把 text 推入堆疊, condition = orig => [text]
# 再遇到 lem , 則把 orig 推入堆疊, condition = lem => [text, orig]
# 再遇到一般的 note , 則把 lem 推入堆疊, condition 依然不變 = lem =>  [text, orig, lem]
# 再遇到一般的 xxx , 則把 lem 推入堆疊, condition 依然不變 = lem =>  [text, orig, lem, lem]
# xxx 結束後, 取出堆疊中的 lem , 存入 condition =>   [text, orig, lem]
# note 結束後, 取出堆疊中的 lem , 存入 condition =>   [text, orig]
# lem 結束後, 取出堆疊中的 orig , 存入 condition =>   [text]
my @conditionStack = ();    

my $inOrig = 0;     # 判斷是否是在 orig 的情況, 在 lem 或 rdg 判斷版本
my $inEng = 0;      # 判斷是不是在英數區
my $debugCount = 0;    # 除錯時, 計算字數用的

#######################################
# 讀取來自 ../cbwork_bin.ini 的設定
#######################################

my $cfg = Config::IniFiles->new( -file => "../cbwork_bin.ini" );
my $cbwork_dir = $cfg->val('default', 'cbwork', '/cbwork');	# 讀取 cbwork 目錄
my $xml_p5a_path = $cbwork_dir . "/xml-p5a/";		# xml 經文的位置

#######################################
# 取得參數
#######################################

my %opt = (); 	# 指定 hash 用來放置傳入的參數
GetOptions(\%opt, "a!","c=s","v=s","n=s","o=s","xn!","d=s");

#######################################
# 主程式
#######################################
if($opt{"d"}) {
    open DEBUG , ">:utf8", $opt{"d"};
}

if($opt{"a"} == 1) {           # -c T 
    runAll();
} elsif($opt{"c"}) {           # -c T 
    runBook($opt{"c"});
} elsif($opt{"v"}) {      # -v T01
    runVol($opt{"v"});
} elsif($opt{"n"}) {      # -n
    runSutra($opt{"n"});
} else {
    showHelp();
    exit;
}

outputReport(); # 輸出結果

#######################################

sub showHelp
{
    print "Count Word
    perl count_word.pl -c T
    perl count_word.pl -v T01
    perl count_word.pl -v T01 -xn
    perl count_word.pl -v T01 -o count_word.csv
    perl count_word.pl -n T01n0001.xml
    -xn : don't show sutra
    -o : output file\n";
}

# 計算整部資料
sub runAll
{
    my $path = $xml_p5a_path;
    countSutra($path);
}

# 計算整部資料
sub runBook
{
    my $path = $xml_p5a_path . $opt{"c"};
    countSutra($path);
}

# 計算整冊資料
sub runVol
{
    $opt{"v"} =~ /^(\D+)/;
    $book = $1;
    my $path = $xml_p5a_path . $book . "/" . $opt{"v"};
    countSutra($path);
}

# 計算單經資料
sub runSutra
{
    $opt{"n"} =~ /^(\D+)(\d+)/;
    $book = $1;
    $vol = $1 . $2;
    my $path = $xml_p5a_path . $book . "/" . $vol . "/" . $opt{"n"};
    countSutra($path);
}

sub countSutra
{
    my $path = shift;
    find(\&countFile, $path);
}

# 計算單一檔案的字數
sub countFile
{
    local $_ = $_;			# 檔名
    # print $File::Find::dir . "\n";	# 目錄
    # print $File::Find::name . "\n";	# 完整檔名
    return if($_ !~ /\.xml/);
    $sutra = $_;
    my $fullPath = $File::Find::dir;
    my $fullFilename = $File::Find::name;
    print $fullFilename . "\n";

    $sutra =~ /^(\D+)(\d+)/;
    $book = $1;
    $vol = $1 . $2;
    $thisVer = "";  # 本經版本
    $condition = "text";
    $debugCount = 0;

    open IN, "<:utf8", $fullFilename;
    while(<IN>) {
        if(/<witness [^>]*xml:id\s*=\s*"wit\.orig"[^>]*>(.*?)<\/witness>/) {
            $thisVer = $1;
        }
        last if(/<body/);
    }
    my $preLine = "";   # 前一行剩下的內容, 可能是半個標記, 需要和下一行合併
    while(<IN>) {
        chomp;
        $_ = $preLine . $_;
        $preLine = countLine($_);
    }
    close IN;
}

# 處理某一行
sub countLine
{
    local $_ = shift;
    my $tag = "";

    # 把缺字 <g > 或未知的字 <unclear/> 換成一個字
    s/<g [^>]*\/\s*>/缺/g;
    s/<g [^>]*>.*?<\/g>/缺/g;
    s/<unclear\s*\/\s*>/未/g;
    s/&amp;/&/g;

    while($_) {
        if(/^</) {
            # 有標記
            if(/^(<\/.*?>)/) {              # 找到結束標記
                s/^(<\/.*?>)//;
                endTag($1);
                $inEng = 0;
            } elsif(/^(<[^>]*\/\s*>)/) {    # 找到單一封閉標記
                s/^(<[^>]*\/\s*>)//;        # pass
            } elsif(/^(<!\-\-.*?\-\->)/) {          # 註解
                s/^(<!\-\-.*?\-\->)//;              # pass
            } elsif(/^(<.*?>)/) {           # 找到起始標記
                s/^(<.*?>)//;
                startTag($1);
                $inEng = 0;
            } else {
                return $_;                  # 有標記卻沒有結尾, 傳回去與下一行接起來
            }
        } else {
            # 非標記
            s/^(.)//;   # 取出一個字
            my $word = $1;
            my $wordType = countThisWord($word);    #0:忽略, 1:CJK等 , 2:英數, 3:符號, 4:未知字元
            if($wordType) {
                $wordType--;
                $bookCount[$wordType]{$condition}->{$book} += 1;
                $volCount[$wordType]{$condition}->{$vol} += 1;
                $sutraCount[$wordType]{$condition}->{$sutra} += 1;
                
                if($condition eq "text") {
                    if($opt{"d"} && $wordType == 0) {
                        print DEBUG $word;
                        $debugCount += 1;
                        if($debugCount == 50) {
                            print DEBUG "\n";
                            $debugCount = 0;
                        }
                    }
                } elsif($condition eq "lem") {
                    if($opt{"d"} && $wordType == 0) {
                        print DEBUG $word;
                        $debugCount += 1;
                        if($debugCount == 50) {
                            print DEBUG "\n";
                            $debugCount = 0;
                        }
                    }
                    if($inOrig) {
                        $bookCount[$wordType]{orig}->{$book} += 1;
                        $volCount[$wordType]{orig}->{$vol} += 1;
                        $sutraCount[$wordType]{orig}->{$sutra} += 1;
                    }
                } elsif($condition eq "rdg") {
                    if($inOrig) {
                        $bookCount[$wordType]{orig}->{$book} += 1;
                        $volCount[$wordType]{orig}->{$vol} += 1;
                        $sutraCount[$wordType]{orig}->{$sutra} += 1;
                    }
                } 
            }
        }
    }
    return $_;
}

# 起始標記
sub startTag
{
    local $_ = shift;
    push(@conditionStack, $condition);
    if(/<note.*?type\s*=\s*"((orig)|(equivalent)|(cf\.)|(rest))"/) {
        $condition = "note";
    }
    if(/<note.*?type\s*=\s*"((mod)|(add)|(cf\d))"/) {
        $condition = "mod";
    }
    if(/<cb:mulu/) {
        $condition = "mod";
    }
    if(/<lem[ >]/) {
        $condition = "lem";
        if(/$thisVer/) {
            $inOrig = 1;
        }
    }
    if(/<rdg[ >]/) {
        $condition = "rdg";
        if(/$thisVer/) {
            $inOrig = 1;
        }
    }
    if(/(<figDesc)|(<cb:docNumber)/) {
        $condition = "skip";
    }
    # <cb:t resp="Taisho" xml:lang="pi" place="foot">
    if(/<cb:t .*place="foot"/) {
        $condition = "skip";
    }
}

# 結束標記
sub endTag
{
    local $_ = shift;
    if(/<\s*\/\s*((lem)|(rdg))\s*>/) {
        $inOrig = 0;
    }
    $condition = pop(@conditionStack);
}

# 判斷是不是標點？或其他不用計算的文字

# 標準新標 。，、；：「」『』（）？！—…《》〈〉．

# 英數和拉丁文字(包括 ASCII 半型符號)

# 0000 - 007F : 0905100169 : ASCII (只有數字 0-9 英文大寫 A-Z 英文小寫 a-z 單引號 ' 減號 - )
# 0080 - 00FF : 0000009721 : Latin_1_Sup,,,,,,,,,,,
# 0100 - 017F : 0000110454 : Latin_Ext_A,Ā,ā,Ă,ă,Ą,ą,Ć,ć,Ĉ,ĉ,
# 0180 - 024F : 0000000008 : Latin_Ext_B,ƀ,Ɓ,Ƃ,ƃ,Ƅ,ƅ,Ɔ,Ƈ,ƈ,Ɖ,
# 0370 - 03FF : 0000000021 : Greek,Ͱ,ͱ,Ͳ,ͳ,ʹ,͵,Ͷ,ͷ,͸,͹,
# 0400 - 04FF : 0000000066 : Cyrillic,Ѐ,Ё,Ђ,Ѓ,Є,Ѕ,І,Ї,Ј,Љ,
# 1E00 - 1EFF : 0000065021 : Latin_Ext_Additional,Ḁ,ḁ,Ḃ,ḃ,Ḅ,ḅ,Ḇ,ḇ,Ḉ,ḉ,
# 2150 - 218F : 0000000400 : Number_Forms,⅐,⅑,⅒,⅓,⅔,⅕,⅖,⅗,⅘,⅙,
# 2460 - 24FF : 0000000675 : Enclosed_Alphanum,①,②,③,④,⑤,⑥,⑦,⑧,⑨,⑩,
# 2C60 - 2C7F :            : Latin_Ext_C,Ⱡ,ⱡ,Ɫ,Ᵽ,Ɽ,ⱥ,ⱦ,Ⱨ,ⱨ,Ⱪ,
# A720 - A7FF :            : Latin_Ext_D,꜠,꜡,Ꜣ,ꜣ,Ꜥ,ꜥ,Ꜧ,ꜧ,Ꜩ,ꜩ,
# AB30 - AB6F :            : Latin_Ext_E,ꬰ,ꬱ,ꬲ,ꬳ,ꬴ,ꬵ,ꬶ,ꬷ,ꬸ,ꬹ,

# 符號

# 02B0 - 02FF : 0000000080 : Modifier_Letters,ʰ,ʱ,ʲ,ʳ,ʴ,ʵ,ʶ,ʷ,ʸ,ʹ,
# 0300 - 036F : 0000000003 : Diacriticals,̀,́,̂,̃,̄,̅,̆,̇,̈,̉,
# 2000 - 206F : 0000320262 : Punctuation, , , , , , , , , , ,
# 2190 - 21FF : 0000000994 : Arrows,←,↑,→,↓,↔,↕,↖,↗,↘,↙,
# 2200 - 22FF : 0000003260 : Math_Operators,∀,∁,∂,∃,∄,∅,∆,∇,∈,∉,
# 2500 - 257F : 0000023078 : Box_Drawing,─,━,│,┃,┄,┅,┆,┇,┈,┉,
# 2580 - 259F : 0000000005 : Block_Elements,▀,▁,▂,▃,▄,▅,▆,▇,█,▉,
# 25A0 - 25FF : 0000192537 : Geometric_Shapes,■,□,▢,▣,▤,▥,▦,▧,▨,▩,
# 2600 - 26FF : 0000000001 : Misc_Symbols,☀,☁,☂,☃,☄,★,☆,☇,☈,☉,
# 3000 - 303F : 0036608362 : CJK_Symbols,　,、,。,〃,〄,々,〆,〇,〈,〉,
# FE30 - FE4F : 0000000058 : CJK_Compat_Forms,︰,︱,︲,︳,︴,︵,︶,︷,︸,︹,
# FE50 - FE6F : 0000000002 : Small_Forms,﹐,﹑,﹒,﹓,﹔,﹕,﹖,﹗,﹘,﹙,
# FF00 - FFEF : 0010413972 : Half_And_Full_Forms,＀,！,＂,＃,＄,％,＆,＇,（,）,

# CJK 文字

# 2E80 - 2EFF : 0000000008 : CJK_Radicals_Sup,⺀,⺁,⺂,⺃,⺄,⺅,⺆,⺇,⺈,⺉,
# 3040 - 309F : 0000004358 : Hiragana,぀,ぁ,あ,ぃ,い,ぅ,う,ぇ,え,ぉ,
# 30A0 - 30FF : 0000033558 : Katakana,゠,ァ,ア,ィ,イ,ゥ,ウ,ェ,エ,ォ,
# 3100 - 312F : 0000003845 : Bopomofo,㄀,㄁,㄂,㄃,㄄,ㄅ,ㄆ,ㄇ,ㄈ,ㄉ,
# 3200 - 32FF : 0000000218 : Enclosed_CJK,㈀,㈁,㈂,㈃,㈄,㈅,㈆,㈇,㈈,㈉,
# 3400 - 4DBF : 0000106531 : CJK_Ext_A,㐀,㐁,㐂,㐃,㐄,㐅,㐆,㐇,㐈,㐉,
# 4E00 - 9FFF : 0238801588 : CJK,一,丁,丂,七,丄,丅,丆,万,丈,三,
# AC00 - D7AF : 0000000004 : Hangul,가,각,갂,갃,간,갅,갆,갇,갈,갉,
# F900 - FAFF : 0000000554 : CJK_Compat_Ideographs,豈,更,車,賈,滑,串,句,龜,龜,契,
# 20000 - 2A6DF : 0000147279 : CJK_Ext_B,𠀀,𠀁,𠀂,𠀃,𠀄,𠀅,𠀆,𠀇,𠀈,𠀉,
# 2A700 - 2B73F : 0000000409 : CJK_Ext_C,𪜀,𪜁,𪜂,𪜃,𪜄,𪜅,𪜆,𪜇,𪜈,𪜉,
# 2B740 - 2B81F : 0000000003 : CJK_Ext_D,𫝀,𫝁,𫝂,𫝃,𫝄,𫝅,𫝆,𫝇,𫝈,𫝉,
# 2B820 - 2CEAF : 0000000012 : CJK_Ext_E,𫠠,𫠡,𫠢,𫠣,𫠤,𫠥,𫠦,𫠧,𫠨,𫠩,
# 2CEB0 - 2EBEF : 0000000081 : CJK_Ext_F,𬺰,𬺱,𬺲,𬺳,𬺴,𬺵,𬺶,𬺷,𬺸,𬺹,
# 2F800 - 2FA1F : 0000000043 : CJK_Compat_Ideographs_Sup,丽,丸,乁,𠄢,你,侮,侻,倂,偺,備,
# 30000 - 3134F :            : CJK_Ext_G,𰀀,𰀁,𰀂,𰀃,𰀄,𰀅,𰀆,𰀇,𰀈,𰀉,


# 符號：

#     3000  IDEOGRAPHIC SPACE
#     3001 、IDEOGRAPHIC COMMA
#     3002 。IDEOGRAPHIC FULL STOP
#     3004 〄JAPANESE INDUSTRIAL STANDARD SYMBOL
#     3008 〈LEFT ANGLE BRACKET
#     3009 〉RIGHT ANGLE BRACKET
#     300A 《LEFT DOUBLE ANGLE BRACKET
#     300B 》RIGHT DOUBLE ANGLE BRACKET
#     300C 「LEFT CORNER BRACKET
#     300D 」RIGHT CORNER BRACKET
#     300E 『LEFT WHITE CORNER BRACKET
#     300F 』RIGHT WHITE CORNER BRACKET
#     3010 【LEFT BLACK LENTICULAR BRACKET
#     3011 】RIGHT BLACK LENTICULAR BRACKET
#     3014 〔LEFT TORTOISE SHELL BRACKET
#     3015 〕RIGHT TORTOISE SHELL BRACKET
#     3016 〖LEFT WHITE LENTICULAR BRACKET
#     3017 〗RIGHT WHITE LENTICULAR BRACKET
#     3018 〘LEFT WHITE TORTOISE SHELL BRACKET
#     3019 〙RIGHT WHITE TORTOISE SHELL BRACKET
#     301A 〚LEFT WHITE SQUARE BRACKET
#     301B 〛RIGHT WHITE SQUARE BRACKET
#     301C 〜WAVE DASH
#     301D 〝REVERSED DOUBLE PRIME QUOTATION MARK
#     301E 〞DOUBLE PRIME QUOTATION MARK
#     301F 〟LOW DOUBLE PRIME QUOTATION MARK
#     3030 〰WAVY DASH
#     3037 〷IDEOGRAPHIC TELEGRAPH LINE FEED SEPARATOR SYMBOL
#     303D 〽PART ALTERNATION MARK
#         marks the start of a song part in Japanese
#         參考: https://zh.wikipedia.org/wiki/%E5%BA%B5%E9%BB%9E
#     303E  IDEOGRAPHIC VARIATION INDICATOR
#     303F 〿IDEOGRAPHIC HALF FILL SPACE

# 列入字數統計：

#     3003 〃DITTO MARK
#     3005 々IDEOGRAPHIC ITERATION MARK
#     3006 〆IDEOGRAPHIC CLOSING MARK
#         參考: https://www.letsgojp.com/archives/393819
#         看到「〆shime」時，大家都以為是簡寫的符號吧？其實這個字是和製漢字，部首為「丿部」，被收錄在日本的漢字辭典中呢！日本女聲優「〆野潤子」的名字裡就有這個字。
#     3007 〇IDEOGRAPHIC NUMBER ZERO (Ray: 因為 一二三 都算文字，二〇二〇 就該算4個字)
#     3012 〒POSTAL MARK (參考 U+3006 的那個網址裡也有說)
#     3013 〓GETA MARK (用來取代字型沒有、不能顯示的字)
#     3020 〠POSTAL MARK FACE
#     3021 〡 HANGZHOU NUMERAL ONE
#     3022 〢 HANGZHOU NUMERAL TWO
#     3023 〣 HANGZHOU NUMERAL THREE
#     3024 〤 HANGZHOU NUMERAL FOUR
#     3025 〥 HANGZHOU NUMERAL FIVE
#     3026 〦 HANGZHOU NUMERAL SIX
#     3027 〧 HANGZHOU NUMERAL SEVEN
#     3028 〨 HANGZHOU NUMERAL EIGHT
#     3029 〩 HANGZHOU NUMERAL NINE
#     3031 〱 VERTICAL KANA REPEAT MARK
#     3032 〲 VERTICAL KANA REPEAT WITH VOICED SOUND
#     MARK
#     3033 〳 VERTICAL KANA REPEAT MARK UPPER HALF
#     3034 〴 VERTICAL KANA REPEAT WITH VOICED SOUND
#     MARK UPPER HALF
#     3035 〵 VERTICAL KANA REPEAT MARK LOWER HALF
#     3036 〶CIRCLED POSTAL MARK
#     3038 〸HANGZHOU NUMERAL TEN
#     3039 〹HANGZHOU NUMERAL TWENTY
#     303A 〺HANGZHOU NUMERAL THIRTY
#     303B 〻VERTICAL IDEOGRAPHIC ITERATION MARK
#     303C 〼MASU MARK
#         informal abbreviation for Japanese -masu ending
#         這是兩個字的縮寫符號, 通常用在結尾, XXXXmasu
#         參考: https://ja.wikipedia.org/wiki/%E3%80%BC



# 傳回值, 0: 忽略字 1: CJK, 2: 英數, 3: 符號, 4: 未知字元
sub countThisWord
{
    local $_ = shift;

    # 先處理 3000-303F 之間的特例，這要當成文字的
    if(/[〃々〆〇〒〓〠〡〢〣〤〥〦〧〨〩〱〲〳〴〵〶〸〹〺〻〼]/) {
        $inEng = 0;
        return 1;
    }

    # 移除新標和全型空白
    if(/[。，、；：「」『』（）？！—…《》〈〉．　]/) {
        $inEng = 0;
        return 0;
    }
    
    # ASCII 符號, 扣除數字, 英文和單引號 ' 和減號 -
    # !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~

    if(/[\s!"#\$%\&\(\)*\+,\.\/:;<=>\?\@\[\\\]\^_`\{\|\}~]/) {
        $inEng = 0;
        return 0;
    }

    # 符號區 (3000-303F 有些是文字區, 在上方先濾掉了)

    if(/[\x{02B0}-\x{036F}\x{2000}-\x{206F}\x{2190}-\x{22FF}\x{2500}-\x{259F}\x{25A0}-\x{26FF}\x{3000}-\x{3029}\x{3030}-\x{303F}\x{FE30}-\x{FE6F}\x{FF00}-\x{FFEF}]/) {
        $inEng = 0;
        return 3;   # 傳回 3 表示符號
    }

    # 英數, 數字不可用 \d, 否則全型也會算進去。

    if(/[0-9A-Za-z\x{0080}-\x{024F}\x{0370}-\x{04FF}\x{1E00}-\x{1EFF}\x{2150}-\x{218F}\x{2460}-\x{24FF}\x{2C60}-\x{2C7F}\x{A720}-\x{A7FF}\x{AB30}-\x{AB6F}]/) {
        if($inEng == 0) {
            $inEng = 1;
            return 2;   # 傳回 2 表示英文
        } else {
            return 0;
        }
    }

    # 英數連結符號, 單引號 ' 和減號 -

    if(/['\-]/) {
        return 0;
    }

    # CJK 文字區

    if(/[\x{2E80}-\x{2EFF}\x{3040}-\x{312F}\x{3200}-\x{32FF}\x{3400}-\x{4DBF}\x{4E00}-\x{9FFF}\x{AC00}-\x{D7AF}\x{F900}-\x{FAFF}\x{20000}-\x{2A6DF}\x{2A700}-\x{2EBEF}\x{2F800}-\x{2FA1F}\x{30000}-\x{3134F}]/) {
        $inEng = 0;
        return 1;
    }

    return 4;   # 未知字元
}

sub outputReport
{
    my $outputFile = "count_word.csv";
    if($opt{"o"}) {
        $outputFile = $opt{"o"};
    }
    open OUT, ">:utf8", $outputFile;
    
    print OUT "ID,Text+Lem,Eng,Sign,Unknow,Text,Note,Mod,Orig,Lem,Rdg,All(CJK),All(Eng),All(Sing),All(Unknow)\n";
    for my $key (sort(keys(%{$bookCount[0]{text}}))) {
        print OUT $key . "," .
        ($bookCount[0]{text}->{$key} + $bookCount[0]{lem}->{$key}) . "," .
        ($bookCount[1]{text}->{$key} + $bookCount[1]{lem}->{$key}) . "," .
        ($bookCount[2]{text}->{$key} + $bookCount[2]{lem}->{$key}) . "," .
        ($bookCount[3]{text}->{$key} + $bookCount[3]{lem}->{$key}) . "," .
        $bookCount[0]{text}->{$key} . "," .
        $bookCount[0]{note}->{$key} . "," .
        $bookCount[0]{mod}->{$key} . "," .
        $bookCount[0]{orig}->{$key} . "," .
        $bookCount[0]{lem}->{$key} . "," .
        $bookCount[0]{rdg}->{$key} . "," .
        ($bookCount[0]{text}->{$key} + $bookCount[0]{note}->{$key} + $bookCount[0]{mod}->{$key} + $bookCount[0]{lem}->{$key} + $bookCount[0]{rdg}->{$key}) . "," .
        ($bookCount[1]{text}->{$key} + $bookCount[1]{note}->{$key} + $bookCount[1]{mod}->{$key} + $bookCount[1]{lem}->{$key} + $bookCount[1]{rdg}->{$key}) . "," .
        ($bookCount[2]{text}->{$key} + $bookCount[2]{note}->{$key} + $bookCount[2]{mod}->{$key} + $bookCount[2]{lem}->{$key} + $bookCount[2]{rdg}->{$key}) . "," .
        ($bookCount[3]{text}->{$key} + $bookCount[3]{note}->{$key} + $bookCount[3]{mod}->{$key} + $bookCount[3]{lem}->{$key} + $bookCount[3]{rdg}->{$key}) . "\n";
    }
    for my $key (sort(keys(%{$volCount[0]{text}}))) {
        print OUT $key . "," .
        ($volCount[0]{text}->{$key} + $volCount[0]{lem}->{$key}) . "," .
        ($volCount[1]{text}->{$key} + $volCount[1]{lem}->{$key}) . "," .
        ($volCount[2]{text}->{$key} + $volCount[2]{lem}->{$key}) . "," .
        ($volCount[3]{text}->{$key} + $volCount[3]{lem}->{$key}) . "," .
        $volCount[0]{text}->{$key} . "," .
        $volCount[0]{note}->{$key} . "," .
        $volCount[0]{mod}->{$key} . "," .
        $volCount[0]{orig}->{$key} . "," .
        $volCount[0]{lem}->{$key} . "," .
        $volCount[0]{rdg}->{$key} . "," .
        ($volCount[0]{text}->{$key} + $volCount[0]{note}->{$key} + $volCount[0]{mod}->{$key} + $volCount[0]{lem}->{$key} + $volCount[0]{rdg}->{$key}) . "," .
        ($volCount[1]{text}->{$key} + $volCount[1]{note}->{$key} + $volCount[1]{mod}->{$key} + $volCount[1]{lem}->{$key} + $volCount[1]{rdg}->{$key}) . "," .
        ($volCount[2]{text}->{$key} + $volCount[2]{note}->{$key} + $volCount[2]{mod}->{$key} + $volCount[2]{lem}->{$key} + $volCount[2]{rdg}->{$key}) . "," .
        ($volCount[3]{text}->{$key} + $volCount[3]{note}->{$key} + $volCount[3]{mod}->{$key} + $volCount[3]{lem}->{$key} + $volCount[3]{rdg}->{$key}) . "\n";
    }
    if($opt{"xn"} != 1) {
        for my $key (sort(keys(%{$sutraCount[0]{text}}))) {
            print OUT $key . "," .
            ($sutraCount[0]{text}->{$key} + $sutraCount[0]{lem}->{$key}) . "," .
            ($sutraCount[1]{text}->{$key} + $sutraCount[1]{lem}->{$key}) . "," .
            ($sutraCount[2]{text}->{$key} + $sutraCount[2]{lem}->{$key}) . "," .
            ($sutraCount[3]{text}->{$key} + $sutraCount[3]{lem}->{$key}) . "," .
            $sutraCount[0]{text}->{$key} . "," .
            $sutraCount[0]{note}->{$key} . "," .
            $sutraCount[0]{mod}->{$key} . "," .
            $sutraCount[0]{orig}->{$key} . "," .
            $sutraCount[0]{lem}->{$key} . "," .
            $sutraCount[0]{rdg}->{$key} . "," . 
            ($sutraCount[0]{text}->{$key} + $sutraCount[0]{note}->{$key} + $sutraCount[0]{mod}->{$key} + $sutraCount[0]{lem}->{$key} + $sutraCount[0]{rdg}->{$key}) . "," .
            ($sutraCount[1]{text}->{$key} + $sutraCount[1]{note}->{$key} + $sutraCount[1]{mod}->{$key} + $sutraCount[1]{lem}->{$key} + $sutraCount[1]{rdg}->{$key}) . "," .
            ($sutraCount[2]{text}->{$key} + $sutraCount[2]{note}->{$key} + $sutraCount[2]{mod}->{$key} + $sutraCount[2]{lem}->{$key} + $sutraCount[2]{rdg}->{$key}) . "," .
            ($sutraCount[3]{text}->{$key} + $sutraCount[3]{note}->{$key} + $sutraCount[3]{mod}->{$key} + $sutraCount[3]{lem}->{$key} + $sutraCount[3]{rdg}->{$key}) . "\n";
        }
    }
    close OUT;
}