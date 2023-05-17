# 檢查校注檔及 BM 經文檔，看二者是否有搭配與不合理的問題  ~by Heaven
#
#校注類型： [01]、[01A]、[A01]、【科01】、【標01】、【解01】。  
#以「頁」為單位，比對「校注檔注標」及「內文檔注標」 
#「校注檔注標」與「內文檔注標」的順序可以不一樣，只要各類型有連續且能夠"吻合"即可。
#如底下這樣是可以比對過關的： 
#「校注檔注標」順序作：[01]→[02]→[03A]→[03B]→[04]→[A01]→【科01】→【科02】
#「內文檔注標」順序作：[01]→【科01】→[02]→[A01]→[03A]→[04]→[03B]→【科02】  
#除以上狀況外，兩有不一致的地方(包括頁碼錯誤、條目增減等等)，則提出警告。

###################################################
use utf8;

my $vol = "HM20";                # 要處理的冊數 , 若是要變成傳入的參數, 就改成 $vol = shift;
my $infile1 = "${vol}-notes.txt";     # 校注來源檔
my $infile2 = "${vol}-new.txt";  # 經文來源檔
# my $infile1 = "D:/cbwork/bm/Y/${vol}/notes.txt";        # 校注來源檔
# my $infile1 = "D:/cbwork/cbeta_project/HM/bm/${vol}/notes.txt;        # 校注來源檔
# my $infile2 = "new.txt";      # 經文來源檔
# my $infile2 = "D:/cbwork/Y/${vol}/new.txt";  # 經文來源檔
# my $infile2 = "D:/cbwork/cbeta_project/HM/bm/${vol}/new.txt";  # 經文來源檔
my $outfile = "${vol}-out.txt"; # 輸出結果檔

my $newpage0 = 1;       # 校勘數字是否跨頁就歸 0 ? 0 表示要歸 0 , 1 表示不歸 0

###################################################

my $lastpage = "";      # 上一個頁碼 : p0001

my $lastid = "";        # 上一個 id : p0001-01
my $lastida = "";       # 上一個 ida : p0001-A01
my $lastidk = "";       # 上一個 idk : p0001-科01
my $lastidb = "";       # 上一個 idb : p0001-標01
my $lastidj = "";       # 上一個 idj : p0001-解01

my $lastidn = 0;        # 本頁上一個 id 數字
my $lastidan = 0;       # 本頁上一個 ida 數字
my $lastidkn = 0;       # 本頁上一個 idk 數字
my $lastidbn = 0;       # 本頁上一個 idb 數字
my $lastidjn = 0;       # 本頁上一個 idj 數字

my $lastidc = "";       # 本頁上一個 id 數字後面的英文字母
my $lastidac = "";      # 本頁上一個 ida 數字後面的英文字母
my $lastidkc = "";      # 本頁上一個 idk 數字後面的英文字母
my $lastidbc = "";      # 本頁上一個 idb 數字後面的英文字母
my $lastidjc = "";      # 本頁上一個 idj 數字後面的英文字母

###################################################

open IN, "<:utf8", $infile1 or die "open $infile1 error\n";
open OUT, ">:utf8", $outfile or die "open $outfile error\n";

print OUT "=== 檢查 $vol 校注檔 ===\n";
while(<IN>)
{
        #X01
        #p0077
        #  01 省略觀無量壽佛經文
        #p0078
        #  01 省略阿彌陀經文
        
        chomp;
        if(($_ =~ /^$vol/) || ($_ =~ /^#/) || ($_ =~ /^\s*$/))
        {
                # 沒事
        }
        #p0077 (or pa001)
        elsif(/^(p.\d{3})$/)
        {
                $page = $1;
                if($lastpage ne "" and $page le $lastpage)
                {
                        # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                        if(($lastpage !~ /^p[a-z]/i) || ($page !~ /^p\d/))
                        {
                                print OUT "頁碼小於前一頁 : $_\n";     # 頁碼比之前的還要小
                        }
                }
                # 歸零
                if($newpage0 == 0)
                {
                        $lastidn = 0;   # 本頁上一個 id 數字
                        $lastidc = "";  # 本頁上一個 id 數字後面的英文字母
                }

                $lastidan = 0;  # 本頁上一個 ida 數字 , 
                $lastidkn = 0;  # 本頁上一個 idk 數字
                $lastidbn = 0;  # 本頁上一個 idb 數字
                $lastidjn = 0;  # 本頁上一個 idj 數字
                
                $lastidac = ""; # 本頁上一個 ida 數字後面的英文字母
                $lastidkc = ""; # 本頁上一個 idk 數字後面的英文字母
                $lastidbc = ""; # 本頁上一個 idb 數字後面的英文字母
                $lastidjc = ""; # 本頁上一個 idj 數字後面的英文字母

                $lastpage = $page;
        }
        #  【科01】 省略觀無量壽佛經文
        elsif(/^\s*【(科(\d\d)([a-z]?))】\s*/i)
        {
                $idk = $page . $1;
                $idkn = $2;
                $idkc = $3;
                
                if($idkn != $lastidkn and $idkn != $lastidkn+1 )
                {
                        print OUT "校注號碼不連續 : $_\n";
                }
                if($idkn == $lastidkn)  # 數字相同, 比較後面的文字
                {
                        my $tmp1 = ord($lastidkc);
                        my $tmp2 = ord($idkc);
                        if($tmp2 != $tmp1 + 1)
                        {
                                print OUT "校注號碼不連續 : $_\n";
                        }
                }
                if($idkn != $lastidkn)  # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
                {
                        if(($lastidkc eq "A") or ($lastidkc eq "a"))
                        {
                                print OUT "前一個校注不應該是 【科${lastidkn}${lastidkc}】 : $_\n";
                        }
                        if(($idkc ne "") and ($idkc ne "A") and ($idkc ne "a"))
                        {
                                print OUT "校注不應該是 【科${idkn}${idkc}】 : $_\n";
                        }
                }
                if($idk le $lastidk)
                {
                        # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                        if(($lastidk !~ /^p[a-z]/i) || ($idk !~ /^p\d/))
                        {
                                print OUT "頁碼+校注號碼小於前一個 : $_\n";
                        }
                }
                
                $hash{$idk} = 1;
                
                $lastidk= $idk;
                $lastidkn = $idkn;
                $lastidkc = $idkc;
        }
        #  【標01】 省略觀無量壽佛經文
        elsif(/^\s*【(標(\d\d)([a-z]?))】\s*/i)
        {
                $idb = $page . $1;
                $idbn = $2;
                $idbc = $3;
                
                if($idbn != $lastidbn and $idbn != $lastidbn+1 )
                {
                        print OUT "校注號碼不連續 : $_\n";
                }
                if($idbn == $lastidbn)  # 數字相同, 比較後面的文字
                {
                        my $tmp1 = ord($lastidbc);
                        my $tmp2 = ord($idbc);
                        if($tmp2 != $tmp1 + 1)
                        {
                                print OUT "校注號碼不連續 : $_\n";
                        }
                }
                if($idbn != $lastidbn)  # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
                {
                        if(($lastidbc eq "A") or ($lastidbc eq "a"))
                        {
                                print OUT "前一個校注不應該是 【標${lastidbn}${lastidbc}】 : $_\n";
                        }
                        if(($idbc ne "") and ($idbc ne "A") and ($idbc ne "a"))
                        {
                                print OUT "校注不應該是 【標${idbn}${idbc}】 : $_\n";
                        }
                }
                if($idb le $lastidb)
                {
                        # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                        if(($lastidb !~ /^p[a-z]/i) || ($idb !~ /^p\d/))
                        {
                                print OUT "頁碼+校注號碼小於前一個 : $_\n";
                        }
                }
                
                $hash{$idb} = 1;
                
                $lastidb = $idb;
                $lastidbn = $idbn;
                $lastidbc = $idbc;
        }
        #  【解01】 省略觀無量壽佛經文
        elsif(/^\s*【(解(\d\d)([a-z]?))】\s*/i)
        {
                $idj = $page . $1;
                $idjn = $2;
                $idjc = $3;
                
                if($idjn != $lastidjn and $idjn != $lastidjn+1 )
                {
                        print OUT "校注號碼不連續 : $_\n";
                }
                if($idjn == $lastidjn)  # 數字相同, 比較後面的文字
                {
                        my $tmp1 = ord($lastidjc);
                        my $tmp2 = ord($idjc);
                        if($tmp2 != $tmp1 + 1)
                        {
                                print OUT "校注號碼不連續 : $_\n";
                        }
                }
                if($idjn != $lastidjn)  # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
                {
                        if(($lastidjc eq "A") or ($lastidjc eq "a"))
                        {
                                print OUT "前一個校注不應該是 【解${lastidjn}${lastidjc}】 : $_\n";
                        }
                        if(($idjc ne "") and ($idjc ne "A") and ($idjc ne "a"))
                        {
                                print OUT "校注不應該是 【解${idjn}${idjc}】 : $_\n";
                        }
                }
                if($idj le $lastidj)
                {
                        # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                        if(($lastidj !~ /^p[a-z]/i) || ($idj !~ /^p\d/))
                        {
                                print OUT "頁碼+校注號碼小於前一個 : $_\n";
                        }
                }
                
                $hash{$idj} = 1;
                
                $lastidj = $idj;
                $lastidjn = $idjn;
                $lastidjc = $idjc;
        }
        #  A01 省略觀無量壽佛經文
        elsif(/^\s*(A(\d\d\d?)([a-z]?))\s*/i)
        {
                #$ida = $page . $1;
                $idan = $2;
                $idac = $3;
                if($idan < 100)
                {
                        $ida = $page . "A0" . $idan . $idac;
                }
                else
                {
                        $ida = $page . "A" . $idan . $idac;
                }
                
                if($idan != $lastidan and $idan != $lastidan+1 )
                {
                        print OUT "校注號碼不連續 : $_\n";
                }
                if($idan == $lastidan)  # 數字相同, 比較後面的文字
                {
                        my $tmp1 = ord($lastidac);
                        my $tmp2 = ord($idac);
                        if($tmp2 != $tmp1 + 1)
                        {
                                print OUT "校注號碼不連續 : $_\n";
                        }
                }
                if($idan != $lastidan)  # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
                {
                        if(($lastidac eq "A") or ($lastidac eq "a"))
                        {
                                print OUT "前一個校注不應該是 A${lastidan}${lastidac} : $_\n";
                        }
                        if(($idac ne "") and ($idac ne "A") and ($idac ne "a"))
                        {
                                print OUT "校注不應該是 A${idan}${idac} : $_\n";
                        }
                }
                if($ida le $lastida)
                {
                        # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                        if(($lastida !~ /^p[a-z]/i) || ($ida !~ /^p\d/))
                        {
                                print OUT "頁碼+校注號碼小於前一個 : $_\n";
                        }
                }
                
                $hash{$ida} = 1;
                
                $lastida = $ida;
                $lastidan = $idan;
                $lastidac = $idac;
        }
        #  01 省略觀無量壽佛經文
        elsif(/^\s*((\d\d\d?)([a-z]?))\s*/i)
        {
                #$id = $page . $1;
                $idn = $2;
                $idc = $3;
                  
                if($idn < 100)
                {
                        $id = $page . "0" . $idn . $idc;
                }
                else
                {
                        $id = $page . $idn . $idc;
                }
                
                if($idn != $lastidn and $idn != $lastidn+1 )
                {
                        if($newpage0 == 0 || $idn != 1)
                        {
                                print OUT "校注號碼不連續 : $_\n";
                        }
                }
                if($idn == $lastidn)    # 數字相同, 比較後面的文字
                {
                        my $tmp1 = ord($lastidc);
                        my $tmp2 = ord($idc);
                        if($tmp2 != $tmp1 + 1)
                        {
                                print OUT "校注號碼不連續 : $_\n";
                        }
                }
                if($idn != $lastidn)    # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
                {
                        if(($lastidc eq "A") or ($lastidc eq "a"))
                        {
                                print OUT "前一個校注不應該是 [${lastidn}${lastidc}] : $_\n";
                        }
                        if(($idc ne "") and ($idc ne "A") and ($idc ne "a"))
                        {
                                print OUT "校注不應該是 [${idn}${idc}] : $_\n";
                        }
                }
                if($id le $lastid)
                {
                        if($newpage0 == 0 || $idn != 1)
                        {
                                # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                                if(($lastid !~ /^p[a-z]/i) || ($id !~ /^p\d/))
                                {
                                        print OUT "頁碼+校注號碼小於前一個 : $_\n";
                                }
                        }
                }
                
                $hash{$id} = 1;
                
                $lastid = $id;
                $lastidn = $idn;
                $lastidc = $idc;
        }
        elsif(/^\s*<[Fc][\s\d,>]/)
        {
                # 沒事，有時校注內文會有<c> 或 <F> 開頭的表格
        }
        else
        {
                print OUT "有問題的格式 : $_\n";
        }
}
close IN;

################ 檢查經文裡的校注 ###################

$lastpage = ""; # 上一個頁碼 : p0001

$lastid = "";   # 上一個 id : p0001-01
$lastida = "";  # 上一個 ida : p0001-A01
$lastidk = "";  # 上一個 idk : p0001-科01
$lastidb = "";  # 上一個 idb : p0001-標01
$lastidj = "";  # 上一個 idj : p0001-解01
my @lastidabc = ();     # 上一個有 ABC 的校注, 因為 [04C] 一定要在 [04B] 之後, 但可能在 [06] 之後. 所以每一組數字要記錄最後一筆

$lastidn = 0;   # 本頁上一個 id 數字
$lastidan = 0;  # 本頁上一個 ida 數字
$lastidkn = 0;  # 本頁上一個 idk 數字
$lastidbn = 0;  # 本頁上一個 idb 數字
$lastidjn = 0;  # 本頁上一個 idj 數字

$lastidc = "";  # 本頁上一個 id 數字後面的英文字母
$lastidac = ""; # 本頁上一個 ida 數字後面的英文字母
$lastidkc = ""; # 本頁上一個 idk 數字後面的英文字母
$lastidbc = ""; # 本頁上一個 idb 數字後面的英文字母
$lastidjc = ""; # 本頁上一個 idj 數字後面的英文字母

open IN, "<:utf8", $infile2 or die "open $infile2 error\n";

print OUT "=== 檢查 $vol 經文中的校注 ===\n";

while(<IN>)
{
        chomp;
        #X01n0008_p0238a04_##云何為卑陋。何因而卑陋。云何六[01]節攝。云何一闡提。
        
        if(/^${vol}n.{5}(p.\d{3})/)
        {
                $page = $1;
                
                if(($lastpage ne "") and ($page lt $lastpage))
                {
                        # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                        if(($lastpage !~ /^p[a-z]/i) || ($page !~ /^p\d/))
                        {
                                print OUT "頁碼小於前一頁 : $_\n";     # 頁碼比之前的還要小
                        }
                }
                
                if($page ne $lastpage)
                {
                        # 歸零
                        if($newpage0 == 0)
                        {
                                $lastidn = 0;   # 本頁上一個 id 數字
                                $lastidc = "";  # 本頁上一個 id 數字後面的英文字母
                        }
                        
                        $lastidan = 0;  # 本頁上一個 ida 數字
                        $lastidkn = 0;  # 本頁上一個 idk 數字
                        $lastidbn = 0;  # 本頁上一個 idb 數字
                        $lastidjn = 0;  # 本頁上一個 idj 數字
                        
                        $lastidac = ""; # 本頁上一個 ida 數字後面的英文字母
                        $lastidkc = ""; # 本頁上一個 idk 數字後面的英文字母
                        $lastidbc = ""; # 本頁上一個 idb 數字後面的英文字母
                        $lastidjc = ""; # 本頁上一個 idj 數字後面的英文字母

                        $lastpage = $page;
                }
                
                while(/\[((\d\d\d?)([a-z]?))\]/ig)
                {
                        my $id = $page . $1;    # p000101A
                        my $idall = $1;                 # 01A
                        my $idn = $2;                   # 01
                        my $idc = $3;                   # A

                        if($idn < 100)
                        {
                                $id = $page . "0" . $idn . $idc;
                        }
                        else
                        {
                                $id = $page . $idn . $idc;
                        }

                        
                        if($idn != $lastidn and $idn != $lastidn+1 )
                        {
                                if($idc !~ /[b-z]/i)            # [XXC] 這種格式可能不連續
                                {
                                        if($newpage0 == 0 || $idn != 1)
                                        {
                                                print OUT "[${idall}]校注號碼不連續 : $_\n";
                                        }
                                }
                        }
                        if($id le $lastid)
                        {
                                if($idc !~ /[b-z]/i)            # [XXC] 這種格式可能不連續
                                {
                                        # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                                        if(($lastid !~ /^p[a-z]/i) || ($id !~ /^p\d/))
                                        {
                                                if($newpage0 == 0 || $idn != 1)
                                                {
                                                        print OUT "[${idall}]頁碼+校注號碼小於前一個 : $id : $lastid : $_\n";
                                                }
                                        }
                                }
                        }
                        
                        if($hash{$id} != 1)
                        {
                                print OUT "[${idall}]校注不在校注檔 : $_\n";
                        }
                        else
                        {
                                $hash{$id} = 0;
                        }
                        
                        if($idc !~ /[b-z]/i)            # [XXC] 這種格式可能不連續
                        {
                                $lastid = $id;
                                $lastidn = $idn;
                                $lastidc = $idc;
                        }
                        
                        if($idc =~ /[a-z]/i)    # 有 abc 的要獨自比對
                        {
                                if($id le $lastidabc[$idn])     # 小於等於前一個有 abc 的校注
                                {
                                        print OUT "[${idall}]頁碼+校注號碼小於前一個有 ABC 的校注 : $_\n";
                                }
                                $lastidabc[$idn] = $id;
                        }
                        
                }
                
                while(/\[(A(\d\d\d?)([a-z]?))\]/ig)
                {
                        my $id = $page . $1;                    # p0001A01a
                        my $idall = $1;                 # A01a
                        my $idn = $2;                   # 01      
                        my $idc = $3;                   # a       
                        
                        if($idn < 100)
                        {
                                $id = $page . "A0" . $idn . $idc;
                        }
                        else
                        {
                                $id = $page . "A" . $idn . $idc;
                        }

                        if($idn != $lastidan and $idn != $lastidan+1 )
                        {
                                print OUT "[${idall}]校注號碼不連續 : $_\n";
                        }
                        if($id le $lastida)
                        {
                                # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                                if(($lastida !~ /^p[a-z]/i) || ($id !~ /^p\d/))
                                {
                                        print OUT "[${idall}]頁碼+校注號碼小於前一個 : $_\n";
                                }
                        }
                        
                        if($hash{$id} != 1)
                        {
                                print OUT "[${idall}]校注不在校注檔 : $_\n";
                        }
                        else
                        {
                                $hash{$id} = 0;
                        }
                        
                        $lastida = $id;
                        $lastidan = $idn;
                        $lastidac = $idc;
                }

                while(/【(科(\d\d)([a-z]?))】/ig)
                {
                        my $id = $page . $1;                    # p0001科01A
                        my $idall = $1;                 # 科01A
                        my $idn = $2;                   # 01      
                        my $idc = $3;                   # A       
                        
                        if($idn != $lastidkn and $idn != $lastidkn+1 )
                        {
                                print OUT "【${idall}】校注號碼不連續 : $_\n";
                        }
                        if($id le $lastidk)
                        {
                                print OUT "【${idall}】頁碼+校注號碼小於前一個 : $_\n";
                        }
                        
                        if($hash{$id} != 1)
                        {
                                print OUT "【${idall}】校注不在校注檔 : $_\n";
                        }
                        else
                        {
                                $hash{$id} = 0;
                        }
                        
                        $lastidk = $id;
                        $lastidkn = $idn;
                        $lastidkc = $idc;
                }
                
                while(/【(標(\d\d)([a-z]?))】/ig)
                {
                        my $id = $page . $1;                    # p0001標01A
                        my $idall = $1;                 # 標01A
                        my $idn = $2;                   # 01      
                        my $idc = $3;                   # A       
                        
                        if($idn != $lastidbn and $idn != $lastidbn+1 )
                        {
                                print OUT "【${idall}】校注號碼不連續 : $_\n";
                        }
                        if($id le $lastidb)
                        {
                                print OUT "【${idall}】頁碼+校注號碼小於前一個 : $_\n";
                        }
                        
                        if($hash{$id} != 1)
                        {
                                print OUT "【${idall}】校注不在校注檔 : $_\n";
                        }
                        else
                        {
                                $hash{$id} = 0;
                        }
                        
                        $lastidb = $id;
                        $lastidbn = $idn;
                        $lastidbc = $idc;
                }
                
                while(/【(解(\d\d)([a-z]?))】/g)
                {
                        my $id = $page . $1;                    # p0001解01A
                        my $idall = $1;                 # 解01A
                        my $idn = $2;                   # 01      
                        my $idc = $3;                   # A       
                        
                        if($idn != $lastidjn and $idn != $lastidjn+1 )
                        {
                                print OUT "【${idall}】校注號碼不連續 : $_\n";
                        }
                        if($id le $lastidj)
                        {
                                print OUT "【${idall}】頁碼+校注號碼小於前一個 : $_\n";
                        }
                        
                        if($hash{$id} != 1)
                        {
                                print OUT "【${idall}】校注不在校注檔 : $_\n";
                        }
                        else
                        {
                                $hash{$id} = 0;
                        }
                        
                        $lastidj = $id;
                        $lastidjn = $idn;
                        $lastidjc = $idc;
                }
        }
        else
        {
                print OUT "經文格式有問題 : $_\n";
        }
}
close IN;

print OUT "=== 檢查校注是否出現在經文中 ===\n";

foreach $key (sort(keys(%hash)))
{
        if($hash{$key})
        {
                $key =~ /(p....)(.*)/;
                print OUT "$1 , [$2] 沒出現在經文中\n";
        }
}

close OUT;
