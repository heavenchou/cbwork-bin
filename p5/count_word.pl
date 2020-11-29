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
#   例：
#   count_word.pl -c T
#   count_word.pl -v T01
#   count_word.pl -n T01n0001.xml
#   count_word.pl -v T01 -xn
#   count_word.pl -c T -o count_word.csv
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

my %bookCount = ();  # 各書的字數統計, 不含校勘、校註
my %volCount = ();  # 各冊的字數統計, 不含校勘、校註
my %sutraCount = ();  # 各經的字數統計, 不含校勘、校註

my %bookCount_note = ();  # 各書的校註字數統計
my %volCount_note = ();  # 各冊的校註字數統計
my %sutraCount_note = ();  # 各經的校註字數統計

my %bookCount_mod = ();  # 各書的 mod 校註字數統計
my %volCount_mod = ();  # 各冊的 mod 校註字數統計
my %sutraCount_mod = ();  # 各經的 mod 校註字數統計

my %bookCount_orig = ();  # 各書的 orig 字數統計, 可能在 lem 或 rdg 中
my %volCount_orig = ();  # 各冊的 orig 字數統計, 可能在 lem 或 rdg 中
my %sutraCount_orig = ();  # 各經的 orig 字數統計, 可能在 lem 或 rdg 中

my %bookCount_lem = ();  # 各書的 lem 字數統計
my %volCount_lem = ();  # 各冊的 lem 字數統計
my %sutraCount_lem = ();  # 各經的 lem 字數統計

my %bookCount_rdg = ();  # 各書的 rdg 字數統計
my %volCount_rdg = ();  # 各冊的 rdg 字數統計
my %sutraCount_rdg = ();  # 各經的 rdg 字數統計

my $book = "";  # 目前書本
my $vol = "";   # 目前冊數
my $sutra = ""; # 目前經名
my $thisVer = "";  # 本經版本, 例如大正藏為【大】

my $condition = "text"; # 目前標記, 有這些 : text, note, mod, orig, lem, rdg

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
GetOptions(\%opt, "c=s","v=s","n=s","o=s","xn!");

#######################################
# 主程式
#######################################

if($opt{"c"}) {           # -c T 
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

    # 把缺字 <g > 換成一個字
    s/<g [^>]*\/\s*>/一/;
    s/<g [^>]*>.*?<\/g>/一/;

    while($_) {
        if(/^</) {
            # 有標記
            if(/^(<\/.*?>)/) {              # 找到結束標記
                s/^(<\/.*?>)//;
                endTag($1);
            } elsif(/^(<[^>]*\/\s*>)/) {    # 找到單一封閉標記
                s/^(<[^>]*\/\s*>)//;        # pass
            } elsif(/^(<!.*?>)/) {          # 註解
                s/^(<!.*?>)//;              # pass
            } elsif(/^(<.*?>)/) {           # 找到起始標記
                s/^(<.*?>)//;
                startTag($1);
            } else {
                return $_;                  # 有標記卻沒有結尾, 傳回去與下一行接起來
            }
        } else {
            # 非標記
            s/^(.)//;   # 取出一個字
            my $word = $1;
            if(countThisWord($word)) {
                if($condition eq "text") {
                    $bookCount{$book} += 1;
                    $volCount{$vol} += 1;
                    $sutraCount{$sutra} += 1;
                } elsif($condition eq "note") {
                    $bookCount_note{$book} += 1;
                    $volCount_note{$vol} += 1;
                    $sutraCount_note{$sutra} += 1;
                } elsif($condition eq "mod") {
                    $bookCount_mod{$book} += 1;
                    $volCount_mod{$vol} += 1;
                    $sutraCount_mod{$sutra} += 1;
                } elsif($condition eq "lem") {
                    $bookCount_lem{$book} += 1;
                    $volCount_lem{$vol} += 1;
                    $sutraCount_lem{$sutra} += 1;
                    if($inOrig) {
                        $bookCount_orig{$book} += 1;
                        $volCount_orig{$vol} += 1;
                        $sutraCount_orig{$sutra} += 1;
                    }
                } elsif($condition eq "rdg") {
                    $bookCount_rdg{$book} += 1;
                    $volCount_rdg{$vol} += 1;
                    $sutraCount_rdg{$sutra} += 1;
                    if($inOrig) {
                        $bookCount_orig{$book} += 1;
                        $volCount_orig{$vol} += 1;
                        $sutraCount_orig{$sutra} += 1;
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
sub countThisWord
{
    local $_ = shift;

    if(/[。，、；：「」『』（）？！—…《》〈〉．【】＝［］～＋－＊　\s]/) {
        return 0;
    }
    return 1;
}

sub outputReport
{
    my $outputFile = "count_word.csv";
    if($opt{"o"}) {
        $outputFile = $opt{"o"};
    }
    open OUT, ">:utf8", $outputFile;
    
    print OUT "ID,Text,Note,Mod,Orig,Lem,Rdg,T+O,T+O+N,All\n";
    for my $key (sort(keys(%bookCount))) {
        print OUT "$key,$bookCount{$key},$bookCount_note{$key},$bookCount_mod{$key},$bookCount_orig{$key},$bookCount_lem{$key},$bookCount_rdg{$key}," . 
        ($bookCount{$key} + $bookCount_orig{$key}) . "," .
        ($bookCount{$key} + $bookCount_orig{$key} + $bookCount_note{$key}) . "," .
        ($bookCount{$key} + $bookCount_note{$key} + $bookCount_mod{$key} + $bookCount_lem{$key} + $bookCount_rdg{$key}) . "\n";
    }
    for my $key (sort(keys(%volCount))) {
        print OUT "$key,$volCount{$key},$volCount_note{$key},$volCount_mod{$key},$volCount_orig{$key},$volCount_lem{$key},$volCount_rdg{$key}," . 
        ($volCount{$key} + $volCount_orig{$key}) . "," .
        ($volCount{$key} + $volCount_orig{$key} + $volCount_note{$key}) . "," .
        ($volCount{$key} + $volCount_note{$key} + $volCount_mod{$key} + $volCount_lem{$key} + $volCount_rdg{$key}) . "\n";
    }
    if($opt{"xn"} != 1) {
        for my $key (sort(keys(%sutraCount))) {
            print OUT "$key,$sutraCount{$key},$sutraCount_note{$key},$sutraCount_mod{$key},$sutraCount_orig{$key},$sutraCount_lem{$key},$sutraCount_rdg{$key}," . 
            ($sutraCount{$key} + $sutraCount_orig{$key}) . "," .
            ($sutraCount{$key} + $sutraCount_orig{$key} + $sutraCount_note{$key}) . "," .
            ($sutraCount{$key} + $sutraCount_note{$key} + $sutraCount_mod{$key} + $sutraCount_lem{$key} + $sutraCount_rdg{$key}) . "\n";
        }
    }
    close OUT;
}