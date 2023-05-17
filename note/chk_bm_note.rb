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
$vol = "HM20"        # 要處理的冊數 , 若是要變成傳入的參數, 就改成 $vol = shift
$infile1 = "#{$vol}-notes.txt"     # 校注來源檔
$infile2 = "#{$vol}-new.txt"  # 經文來源檔
# $infile1 = "D:/cbwork/bm/Y/#{$vol}/notes.txt"    # 校注來源檔
# $infile1 = "D:/cbwork/cbeta_project/HM/bm/#{$vol}/notes.txt    # 校注來源檔
# $infile2 = "new.txt"      # 經文來源檔
# $infile2 = "D:/cbwork/Y/#{$vol}/new.txt"  # 經文來源檔
# $infile2 = "D:/cbwork/cbeta_project/HM/bm/#{$vol}/new.txt"  # 經文來源檔
$outfile = "#{$vol}-out.txt" # 輸出結果檔
$newpage0 = 1       # 校勘數字是否跨頁就歸 0 ? 0 表示要歸 0 , 1 表示不歸 0

###################################################

$lastpage = ""      # 上一個頁碼 : p0001

$lastid = ""    # 上一個 id : p0001-01
$lastida = ""       # 上一個 ida : p0001-A01
$lastidk = ""       # 上一個 idk : p0001-科01
$lastidb = ""       # 上一個 idb : p0001-標01
$lastidj = ""       # 上一個 idj : p0001-解01

$lastidn = 0    # 本頁上一個 id 數字
$lastidan = 0       # 本頁上一個 ida 數字
$lastidkn = 0       # 本頁上一個 idk 數字
$lastidbn = 0       # 本頁上一個 idb 數字
$lastidjn = 0       # 本頁上一個 idj 數字

$lastidc = ""       # 本頁上一個 id 數字後面的英文字母
$lastidac = ""      # 本頁上一個 ida 數字後面的英文字母
$lastidkc = ""      # 本頁上一個 idk 數字後面的英文字母
$lastidbc = ""      # 本頁上一個 idb 數字後面的英文字母
$lastidjc = ""      # 本頁上一個 idj 數字後面的英文字母

$hash = Hash.new

###################################################

fin = File.open($infile1, 'r')
fout = File.open($outfile, 'w')

fout.print "=== 檢查 #{$vol} 校注檔 ===\n"
fin.each_line { |line|
    #X01
    #p0077
    #  01 省略觀無量壽佛經文
    #p0078
    #  01 省略阿彌陀經文
    
    line.chomp!
    if (line =~ /^#{$vol}/) || (line =~ /^#/) || (line =~ /^\s*$/)
        # 沒事
    #p0077 (or pa001)
    elsif line =~ /^(p.\d{3})$/
        $page = $1
        if $lastpage != "" and $page <= $lastpage
            # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
            if ($lastpage !~ /^p[a-z]/i) || ($page !~ /^p\d/)
                fout.print "頁碼小於前一頁 : #{line}\n"     # 頁碼比之前的還要小
            end
        end
        # 歸零
        if $newpage0.to_i == 0
            $lastidn = 0   # 本頁上一個 id 數字
            $lastidc = ""  # 本頁上一個 id 數字後面的英文字母
        end

        $lastidan = 0  # 本頁上一個 ida 數字 , 
        $lastidkn = 0  # 本頁上一個 idk 數字
        $lastidbn = 0  # 本頁上一個 idb 數字
        $lastidjn = 0  # 本頁上一個 idj 數字
        
        $lastidac = "" # 本頁上一個 ida 數字後面的英文字母
        $lastidkc = "" # 本頁上一個 idk 數字後面的英文字母
        $lastidbc = "" # 本頁上一個 idb 數字後面的英文字母
        $lastidjc = "" # 本頁上一個 idj 數字後面的英文字母

        $lastpage = $page
    #  【科01】 省略觀無量壽佛經文
    elsif line =~ /^\s*【(科(\d\d)([a-z]?))】\s*/i
        $idk = $page + $1
        $idkn = $2
        $idkc = $3
        
        if $idkn != $lastidkn and $idkn.to_i != $lastidkn.to_i + 1
            fout.print "校注號碼不連續 : #{line}\n"
        end
        if $idkn == $lastidkn   # 數字相同, 比較後面的文字
            $tmp1 = $lastidkc.empty? ? 0 : $lastidkc.ord
            $tmp2 = $idkc.empty? ? 0 : $idkc.ord
            if $tmp2 != $tmp1 + 1
                fout.print "校注號碼不連續 : #{line}\n"
            end
        end
        if $idkn != $lastidkn   # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
            if ($lastidkc == "A") or ($lastidkc == "a")
                fout.print "前一個校注不應該是 【科#{$lastidkn}#{$lastidkc}】 : #{line}\n"
            end
            if ($idkc != "") and ($idkc != "A") and ($idkc != "a")
                fout.print "校注不應該是 【科#{$idkn}#{$idkc}】 : #{line}\n"
            end
        end
        if $idk <= $lastidk
            # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
            if ($lastidk !~ /^p[a-z]/i) || ($idk !~ /^p\d/)
                fout.print "頁碼+校注號碼小於前一個 : #{line}\n"
            end
        end
        
        $hash[$idk] = 1
        
        $lastidk = $idk
        $lastidkn = $idkn
        $lastidkc = $idkc
    #  【標01】 省略觀無量壽佛經文
    elsif line =~ /^\s*【(標(\d\d)([a-z]?))】\s*/i
        $idb = $page + $1
        $idbn = $2
        $idbc = $3
        
        if $idbn != $lastidbn and $idbn.to_i != $lastidbn.to_i + 1
            fout.print "校注號碼不連續 : #{line}\n"
        end
        if $idbn == $lastidbn   # 數字相同, 比較後面的文字
            $tmp1 = $lastidbc.empty? ? 0 : $lastidbc.ord
            $tmp2 = $idbc.empty? ? 0 : $idbc.ord
            if $tmp2 != $tmp1 + 1
                fout.print "校注號碼不連續 : #{line}\n"
            end
        end
        if $idbn != $lastidbn   # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
            if ($lastidbc == "A") or ($lastidbc == "a")
                fout.print "前一個校注不應該是 【標#{$lastidbn}#{$lastidbc}】 : #{line}\n"
            end
            if ($idbc != "") and ($idbc != "A") and ($idbc != "a")
                fout.print "校注不應該是 【標#{$idbn}#{$idbc}】 : #{line}\n"
            end
        end
        if $idb <= $lastidb
            # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
            if ($lastidb !~ /^p[a-z]/i) || ($idb !~ /^p\d/)
                fout.print "頁碼+校注號碼小於前一個 : #{line}\n"
            end
        end
        
        $hash[$idb] = 1
        
        $lastidb = $idb
        $lastidbn = $idbn
        $lastidbc = $idbc
    #  【解01】 省略觀無量壽佛經文
    elsif line =~ /^\s*【(解(\d\d)([a-z]?))】\s*/i
        $idj = $page + $1
        $idjn = $2
        $idjc = $3
        
        if $idjn != $lastidjn and $idjn.to_i != $lastidjn.to_i + 1
            fout.print "校注號碼不連續 : #{line}\n"
        end
        if $idjn == $lastidjn   # 數字相同, 比較後面的文字
            $tmp1 = $lastidjc.empty? ? 0 : $lastidjc.ord
            $tmp2 = $idjc.empty? ? 0 : $idjc.ord
            if $tmp2 != $tmp1 + 1
                fout.print "校注號碼不連續 : #{line}\n"
            end
        end
        if $idjn != $lastidjn  # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
            if ($lastidjc == "A") or ($lastidjc == "a")
                fout.print "前一個校注不應該是 【解#{$lastidjn}#{$lastidjc}】 : #{line}\n"
            end
            if ($idjc != "") and ($idjc != "A") and ($idjc != "a")
                fout.print "校注不應該是 【解#{$idjn}#{$idjc}】 : #{line}\n"
            end
        end
        if $idj <= $lastidj
            # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
            if ($lastidj !~ /^p[a-z]/i) || ($idj !~ /^p\d/)
                fout.print "頁碼+校注號碼小於前一個 : #{line}\n"
            end
        end
        
        $hash[$idj] = 1
        
        $lastidj = $idj
        $lastidjn = $idjn
        $lastidjc = $idjc
    #  A01 省略觀無量壽佛經文
    elsif line =~ /^\s*(A(\d\d\d?)([a-z]?))\s*/i
        #$ida = $page + $1
        $idan = $2
        $idac = $3
        if $idan.to_i < 100
            $ida = $page + "A0" + $idan + $idac
        else
            $ida = $page + "A" + $idan + $idac
        end
        
        if $idan != $lastidan and $idan.to_i != $lastidan.to_i + 1 
            fout.print "校注號碼不連續 : #{line}\n"
        end
        if $idan == $lastidan  # 數字相同, 比較後面的文字
            $tmp1 = $lastidac.empty? ? 0 : $lastidac.ord
            $tmp2 = $idac.empty? ? 0 : $idac.ord
            if $tmp2 != $tmp1 + 1
                fout.print "校注號碼不連續 : #{line}\n"
            end
        end
        if $idan != $lastidan  # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
            if ($lastidac == "A") or ($lastidac == "a")
                fout.print "前一個校注不應該是 A#{$lastidan}#{$lastidac} : #{line}\n"
            end
            if ($idac != "") and ($idac != "A") and ($idac != "a")
                fout.print "校注不應該是 A#{$idan}#{$idac} : #{line}\n"
            end
        end
        if $ida <= $lastida
            # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
            if ($lastida !~ /^p[a-z]/i) || ($ida !~ /^p\d/)
                fout.print "頁碼+校注號碼小於前一個 : #{line}\n"
            end
        end
        
        $hash[$ida] = 1
        
        $lastida = $ida
        $lastidan = $idan
        $lastidac = $idac
    #  01 省略觀無量壽佛經文
    elsif line =~ /^\s*((\d\d\d?)([a-z]?))\s*/i
        #$id = $page + $1
        $idn = $2
        $idc = $3
          
        if $idn.to_i < 100
            $id = $page + "0" + $idn + $idc
        else
            $id = $page + $idn + $idc
        end
        
        if $idn != $lastidn and $idn.to_i != $lastidn.to_i + 1 
            if $newpage0.to_i == 0 || $idn.to_i != 1
                fout.print "校注號碼不連續 : #{line}\n"
            end
        end
        if $idn == $lastidn    # 數字相同, 比較後面的文字
            $tmp1 = $lastidc.empty? ? 0 : $lastidc.ord
            $tmp2 = $idc.empty? ? 0 : $idc.ord
            if $tmp2 != $tmp1 + 1
                fout.print "校注號碼不連續 : #{line}\n"
            end
        end
        if $idn != $lastidn    # 數字不相同, 則前一個不可以是 [XXA], 我自己若有字母,一定要是 [XXA]
            if ($lastidc == "A") or ($lastidc == "a")
                fout.print "前一個校注不應該是 [#{$lastidn}#{$lastidc}] : #{line}\n"
            end
            if ($idc != "") and ($idc != "A") and ($idc != "a")
                fout.print "校注不應該是 [#{$idn}#{$idc}] : #{line}\n"
            end
        end
        if $id <= $lastid
            if $newpage0.to_i == 0 || $idn.to_i != 1
                # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                if ($lastid !~ /^p[a-z]/i) || ($id !~ /^p\d/)
                    fout.print "頁碼+校注號碼小於前一個 : #{line}\n"
                end
            end
        end
        
        $hash[$id] = 1
        
        $lastid = $id
        $lastidn = $idn
        $lastidc = $idc
    elsif line =~ /^\s*<[Fc][\s\d,>]/
        # 沒事，有時校注內文會有<c> 或 <F> 開頭的表格
    else
        fout.print "有問題的格式 : #{line}\n"
    end
}
fin.close

################ 檢查經文裡的校注 ###################

$lastpage = "" # 上一個頁碼 : p0001

$lastid = ""   # 上一個 id : p0001-01
$lastida = ""  # 上一個 ida : p0001-A01
$lastidk = ""  # 上一個 idk : p0001-科01
$lastidb = ""  # 上一個 idb : p0001-標01
$lastidj = ""  # 上一個 idj : p0001-解01
$lastidabc = Array.new     # 上一個有 ABC 的校注, 因為 [04C] 一定要在 [04B] 之後, 但可能在 [06] 之後. 所以每一組數字要記錄最後一筆

$lastidn = 0   # 本頁上一個 id 數字
$lastidan = 0  # 本頁上一個 ida 數字
$lastidkn = 0  # 本頁上一個 idk 數字
$lastidbn = 0  # 本頁上一個 idb 數字
$lastidjn = 0  # 本頁上一個 idj 數字

$lastidc = ""  # 本頁上一個 id 數字後面的英文字母
$lastidac = "" # 本頁上一個 ida 數字後面的英文字母
$lastidkc = "" # 本頁上一個 idk 數字後面的英文字母
$lastidbc = "" # 本頁上一個 idb 數字後面的英文字母
$lastidjc = "" # 本頁上一個 idj 數字後面的英文字母

fin = File.open($infile2, 'r')

fout.print "=== 檢查 #{$vol} 經文中的校注 ===\n"

fin.each_line {|line|

    line.chomp!
    #X01n0008_p0238a04_##云何為卑陋。何因而卑陋。云何六[01]節攝。云何一闡提。
    
    if line =~ /^#{$vol}n.{5}(p.\d{3})/
        $page = $1
        
        if ($lastpage != "") and ($page < $lastpage)
            # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
            if ($lastpage !~ /^p[a-z]/i) || ($page !~ /^p\d/)
                fout.print "頁碼小於前一頁 : #{line}\n"     # 頁碼比之前的還要小
            end
        end
        
        if $page != $lastpage
            # 歸零
            if $newpage0.to_i == 0
                $lastidn = 0   # 本頁上一個 id 數字
                $lastidc = ""  # 本頁上一個 id 數字後面的英文字母
            end
            
            $lastidan = 0  # 本頁上一個 ida 數字
            $lastidkn = 0  # 本頁上一個 idk 數字
            $lastidbn = 0  # 本頁上一個 idb 數字
            $lastidjn = 0  # 本頁上一個 idj 數字
            
            $lastidac = "" # 本頁上一個 ida 數字後面的英文字母
            $lastidkc = "" # 本頁上一個 idk 數字後面的英文字母
            $lastidbc = "" # 本頁上一個 idb 數字後面的英文字母
            $lastidjc = "" # 本頁上一個 idj 數字後面的英文字母

            $lastpage = $page
        end
        
        line.scan(/\[((\d\d\d?)([a-z]?))\]/i) do
            $id = $page + $1    # p000101A
            $idall = $1         # 01A
            $idn = $2           # 01
            $idc = $3           # A

            if $idn.to_i < 100
                $id = $page + "0" + $idn + $idc
            else
                $id = $page + $idn + $idc
            end

            if $idn != $lastidn and $idn.to_i != $lastidn.to_i + 1 
                if $idc !~ /[b-z]/i        # [XXC] 這種格式可能不連續
                    if $newpage0.to_i == 0 || $idn.to_i != 1
                        fout.print "[#{$idall}]校注號碼不連續 : #{line}\n"
                    end
                end
            end
            if $id <= $lastid
                if $idc !~ /[b-z]/i        # [XXC] 這種格式可能不連續
                    # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                    if ($lastid !~ /^p[a-z]/i) || ($id !~ /^p\d/)
                        if $newpage0.to_i == 0 || $idn.to_i != 1
                            fout.print "[#{$idall}]頁碼+校注號碼小於前一個 : #{$id} : #{$lastid} : #{line}\n"
                        end
                    end
                end
            end
            
            if $hash[$id] != 1
                fout.print "[#{$idall}]校注不在校注檔 : #{line}\n"
            else
                $hash[$id] = 0
            end
            
            if $idc !~ /[b-z]/i        # [XXC] 這種格式可能不連續
                $lastid = $id
                $lastidn = $idn
                $lastidc = $idc
            end
            
            if $idc =~ /[a-z]/i    # 有 abc 的要獨自比對
                if $id <= $lastidabc[$idn]     # 小於等於前一個有 abc 的校注
                    fout.print "[#{$idall}]頁碼+校注號碼小於前一個有 ABC 的校注 : #{line}\n"
                end
                $lastidabc[$idn] = $id
            end
            
        end
        
        line.scan(/\[(A(\d\d\d?)([a-z]?))\]/i) do
            $id = $page + $1    # p0001A01a
            $idall = $1         # A01a
            $idn = $2           # 01      
            $idc = $3           # a       
            
            if $idn.to_i < 100
                $id = $page + "A0" + $idn + $idc
            else
                $id = $page + "A" + $idn + $idc
            end

            if $idn != $lastidan and $idn.to_i != $lastidan.to_i + 1 
                fout.print "[#{$idall}]校注號碼不連續 : #{line}\n"
            end
            if $id <= $lastida
                # 如果上一頁是 pa001 下一頁是 p0001 , 則不受比較的限制
                if ($lastida !~ /^p[a-z]/i) || ($id !~ /^p\d/)
                    fout.print "[#{$idall}]頁碼+校注號碼小於前一個 : #{line}\n"
                end
            end
            
            if $hash[$id] != 1
                fout.print "[#{$idall}]校注不在校注檔 : #{line}\n"
            else
                $hash[$id] = 0
            end
            
            $lastida = $id
            $lastidan = $idn
            $lastidac = $idc
        end

        line.scan(/【(科(\d\d)([a-z]?))】/i) do
            $id = $page + $1            # p0001科01A
            $idall = $1         # 科01A
            $idn = $2           # 01      
            $idc = $3           # A       
            
            if $idn != $lastidkn and $idn.to_i != $lastidkn.to_i + 1 
                fout.print "【#{$idall}】校注號碼不連續 : #{line}\n"
            end
            if $id <= $lastidk
                fout.print "【#{$idall}】頁碼+校注號碼小於前一個 : #{line}\n"
            end
            
            if $hash[$id] != 1
                fout.print "【#{$idall}】校注不在校注檔 : #{line}\n"
            else
                $hash[$id] = 0
            end
            
            $lastidk = $id
            $lastidkn = $idn
            $lastidkc = $idc
        end
        
        line.scan(/【(標(\d\d)([a-z]?))】/i) do
            $id = $page + $1            # p0001標01A
            $idall = $1         # 標01A
            $idn = $2           # 01      
            $idc = $3           # A       
            
            if $idn != $lastidbn and $idn.to_i != $lastidbn.to_i + 1 
                fout.print "【#{$idall}】校注號碼不連續 : #{line}\n"
            end
            if $id <= $lastidb
                fout.print "【#{$idall}】頁碼+校注號碼小於前一個 : #{line}\n"
            end
            
            if $hash[$id] != 1
                fout.print "【#{$idall}】校注不在校注檔 : #{line}\n"
            else
                $hash[$id] = 0
            end
            
            $lastidb = $id
            $lastidbn = $idn
            $lastidbc = $idc
        end
        
        line.scan(/【(解(\d\d)([a-z]?))】/i) do
            $id = $page + $1            # p0001解01A
            $idall = $1         # 解01A
            $idn = $2           # 01      
            $idc = $3           # A       
            
            if $idn != $lastidjn and $idn.to_i != $lastidjn.to_i + 1 
                fout.print "【#{$idall}】校注號碼不連續 : #{line}\n"
            end
            if $id <= $lastidj
                fout.print "【#{$idall}】頁碼+校注號碼小於前一個 : #{line}\n"
            end
            
            if $hash[$id] != 1
                fout.print "【#{$idall}】校注不在校注檔 : #{line}\n"
            else
                $hash[$id] = 0
            end
            
            $lastidj = $id
            $lastidjn = $idn
            $lastidjc = $idc
        end
    else
        fout.print "經文格式有問題 : #{line}\n"
    end
}
fin.close

fout.print "=== 檢查校注是否出現在經文中 ===\n"

$hash = $hash.sort.to_h	
$hash.each_key {|key|
    if $hash[key] != 0
        key =~ /(p....)(.*)/
        fout.print "#{$1} , [#{$2}] 沒出現在經文中\n"
    end
}

fout.close
