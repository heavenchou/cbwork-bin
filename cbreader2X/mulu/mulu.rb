require 'nokogiri'
require 'json'
require 'cbeta'

# 結構如下：
# @mulu_json = {
# "T01n0001.xml" => [["0001a01",01,"Milestone",1],["0002a01",2,"Mulu","XX品"],["0003a01",20,"Mulu","XX品"]] ,
# "T01n0002.xml" => [["0004a01",30,"Mulu","XX品"],["0005a01",40,"Mulu","XX品"],["0006a01",50,"Mulu","XX品"]] , .... }
# 中間的數字是行數
# "Mulu" 和 "Milestone" 二種

class MuluJson
    def initialize
        @root = Hash.new
    end
    # 將一個陣列推到 file 的目錄陣列中
    # 例：push("T01n0001.xml",["0001a01",01,"XX品"])
    def push(file, array)
        if !@root.include? file
            @root[file] = Array.new
        end
        @root[file].push array
    end

    # 整理資料，例如
    # 0314a11,359,Mulu,2 鬱單越洲品
    # 0316a25,547,Milestone,2
    # 0317a18,627,Mulu,3 轉輪聖王品
    # 0320b23,922,Mulu,4 地獄品
    # 0321c25,1040,Milestone,3
    # 0327a26,1505,Milestone,4
    # 0332b10,1953,Milestone,5
    # 0332b15,1958,Mulu,5 諸龍金翅鳥品
    # 可整理成
    # 0314a11,359,Mulu,2 鬱單越洲品
    # 0317a18,627,Mulu,3 轉輪聖王品
    # 0320b23,922,Mulu,4 地獄品
    # 0332b10,1953,Mulu,5 諸龍金翅鳥品

    # 原則，如果前面是空白的或卷，而且行距小於 10，就可以合併，
    # 0332b10,1953,Milestone,5
    # 0332b15,1958,Mulu,5 諸龍金翅鳥品
    # 合併成
    # 0332b10,1953,Mulu,5 諸龍金翅鳥品

    def zip
        @root.each { |file, array|
            for i in 0...array.length-1
                if array[i][2] == "Milestone" 
                    if array[i+1][1] - array[i][1] < 10
                        array[i+1][0] = array[i][0]
                        array[i+1][1] = array[i][1]
                        array[i][2] = "Del"
                    elsif array[i+1][1] - array[i][1] < 50
                        $check_50 = true
                        array[i+1][0] += "((#{array[i+1][1] - array[i][1]}))"
                    end
                end
            end
        }
    end

    def get_result
        result = ""
        @root.each { |file, array|
            result += "=" * 50 + "\n#{file}\n" + "=" * 50 + "\n"
            for i in 0...array.length
                if array[i][2] == "Mulu" 
                    result += "#{array[i][0]} , #{array[i][3]}\n"
                end
            end
        }
        return result
    end

    def get_js_result
        result = ""
        @root.each { |file, array|
            # "xxx.xml":[[xxx],[xxx]],
            shortfile = file.sub(/^.*[\\\/]/,"")
            result += "\"#{shortfile}\":[\n"
            for i in 0...array.length
                if array[i][2] == "Mulu" 
                    result += "\t[\"#{array[i][0]}\",\"#{array[i][3]}\"],\n"
                end
            end
            # 處理最後一筆
            # ["0445a25" ,  "2 業相應品．20 波羅牢經"],\n
            # 改成
            # ["0445a25" ,  "2 業相應品．20 波羅牢經"]],\n
            result.chomp!
            result.chop!
            result += "],\n"
        }
        return result
    end
end

####################################################

class XMLFile
    # 建構式
    def initialize(filename)
        @fileName = filename
        @lbCount = 0        # lb 的數量，也就是行數
        @lb = ""            # 目前 lb 的位置
        @mulus = Array.new(10)   # 放目錄名 [xx分,xx會,xx品]
        @getText = false    # 為 true 時才能讀取文字節點
        @findMilestone = false  # 遇到 milestone，準備印出此卷的 lb
        @milestone = 0     # 目前卷數
        @maxPinLevel = 0    # 發現品最大的層數
        @maxMuluLevel = 0   # 目錄最大層數

        @first_level = 0    # 最終版要呈現的最小層數
        @last_level = 999   # 最終版要呈現的最大層數

        if $ok_data
            @first_level = $file_mulu.get_first_level(filename)
            @last_level = $file_mulu.get_last_level(filename)
        end

        if @fileName.match(/(([A-Z]+)(\d+))n(.*?)\.xml/)
            @ed = $2
            @volnum = $3
            @vol = $1
            @sutra = $4
        end
    end
    
    # 處理
    def run
        xmlfile = File.new(@fileName)
        doc = Nokogiri::XML(xmlfile)
        doc.remove_namespaces!()
        
        # root = doc.root
        # node = doc.at_xpath("//cb:text", "cb"=>"http://www.cbeta.org/ns/1.0")
        node = doc.at_xpath("//text")
        result = parseNode(node)
        xmlfile.close
        return result
    end

    # 分析一個節點
    def parseNode(node)
        text = ""
        if node.element?    # 1, element
            # 處理標記元素
            tagName = node.name
            case tagName
            when "lb"
                text = tagLb(node)
            when 'milestone'
                text = tagMilestone(node)
            when 'mulu'
                text = tagMulu(node)
            when 'g'
                text = tagG(node)
            else
                text = tagDefault(node)
            end
        elsif node.text?     # 3,text
            # 處理純文字
            if @getText
                text = node.content
            end
        end
        return text
    end

    # 分析子節點
    def parseChild(node)
        text = ""
        node.children.each { |n|
            text += parseNode(n)
        }
        return text
    end
     
    # MARK: 處理各個標記
    # <lb n="0058c23" ed="T"/>
    # <lb n="0004a01" ed="Y" type="old"/>
    def tagLb(node)
        text = ""
    
        # 取得特定屬性
        ed = getAttr(node, 'ed')
        if ed != @ed
            return ""
        end
        type = getAttr(node, 'type')
        if type == "old"
            return ""
        end

        @lbCount = @lbCount + 1
        @lb = getAttr(node, 'n')

        if @findMilestone
            @findMilestone = false
            $mulu_json.push(@fileName,[@lb,@lbCount.to_i,"Milestone",@milestone])
            return "#{@lb},#{@lbCount},M,#{@milestone}\n"
        end

        return ""
    end
    
    # <milestone n="3" unit="juan"/>
    def tagMilestone(node)
        n = getAttr(node, 'n')
        unit = getAttr(node, 'unit')
        return "" if unit != 'juan'
        @findMilestone = true
        @milestone = n.to_i
        return ""
    end

    # <g ref="#CB08016"/>
    def tagG(node)
        ref = getAttr(node, 'ref')
        gid = ref[1..-1]
        g = $gaijis[gid]

        r = ''

        if g.key?('uni_char')
            r += g['uni_char']
        elsif g.key?('norm_uni_char')
            r += g['norm_uni_char']
        elsif g.key?('norm_big5_char')
            r += g['norm_big5_char']
        elsif g.key?('composition')
            r += g['composition']
        end

        return r
    end

    #<cb:mulu n="003" type="卷">
    #<cb:mulu n="79" level="1" type="品">79 善達品</cb:mulu>
    def tagMulu(node)
        n = getAttr(node, 'n')
        type = getAttr(node, 'type')
        level = getAttr(node, 'level')
        
        @getText = true
        text = parseChild(node)
        @getText = false

        if level.to_i > @last_level
            return ""
        end
        
        if type != "卷"
            if type == '品' || text.match(/品/)
                if level.to_i > @maxPinLevel
                    @maxPinLevel = level.to_i
                end
            end

            if level.to_i > @maxMuluLevel
                @maxMuluLevel = level.to_i
            end

            # 組合出名稱
            if level != "" || level.to_i < 6
                @mulus[level.to_i - 1] = text
                mulu_name = ""
                for i in 1..level.to_i
                    if i >= @first_level && i <= @last_level
                        tmp = @mulus[i-1]
                        tmp = "" if tmp.nil?
                        mulu_name += tmp + "．"
                    end
                end
                if mulu_name == ""
                    return ""
                end
                mulu_name.chop!
                $mulu_json.push(@fileName,[@lb,@lbCount.to_i,"Mulu",mulu_name])
                return "#{@lb},#{@lbCount},#{mulu_name}\n"
            end
        end
        return ""
    end

    # 處理預設的標記
    def tagDefault(node)
        # 分析子節點
        text = parseChild(node)
        return text
    end

    # 取得節點屬性
    def getAttr(node, attr)
        return "" if !node.element?
        value = node.attribute(attr)
        value == nil ? '' : value.to_s
    end

    def getMaxPinLevel()
        return @maxPinLevel
    end

    def getMaxMuluLevel()
        return @maxMuluLevel
    end
end



# 讀取各冊的檔案資訊，裡面會記錄各經要讀取多少目錄，例：
# d:/cbwork/xml-p5b/T/T01/T01n0001.xml , 2 , 3
# 表示 T01n0001 要讀取 2 和 3 層目錄，也就是
# 4 分．30 世記經．1 閻浮提州品
# 只需要 "30 世記經．1 閻浮提州品" 這二層

class GetFileMulu
    def initialize(vol)
        @filename = Array.new
        @first_level = Array.new
        @last_level = Array.new

        file = "#{vol}_config.txt"
        if !File.exists?(file)
            return
        end
        $ok_data = true
        fin = File.open(file, 'r')
        fin.each_line { |line|
            # d:/cbwork/xml-p5b/T/T01/T01n0001.xml , 2 , 3
            line.chomp!
            array = line.split(/\s*,\s*/)
            @filename.push(array[0])
            @first_level.push(array[1].to_i)
            @last_level.push(array[2].to_i)
        }
        fin.close
    end

    def get_first_level(file)
        if @filename.include? file
            index = @filename.index(file)
            return @first_level[index]
        end
        return 0
    end

    def get_last_level(file)
        if @filename.include? file
            index = @filename.index(file)
            return @last_level[index]
        end
        return 0
    end

    def has_file?(file)
        if @filename.include? file
            return true
        end
        return false
    end
end

# files = GetFiles.new(basepath, vol:, file:)
# basepath 是要處理的目錄。
# vol 是要處理的子目錄，屬於 CBEAT 特有結構，T 表示 T 目錄，T01 表示 T/T01 目錄，預設為空字串
# file 是要處理的檔案，可用萬用字元，預設為 *
#
# 預設處理 baseDir/*.*
# vol = T , 表示處理 baseDir/T/*.*
# vol = T01 , 表示處理 baseDir/T/T01/*.*
# vol = T01, file = *.xml, 表示處理 baseDir/T/T01/*.xml
# files.allFiles 是全部檔名陣列

class GetFiles
    attr_reader :allFiles
    def initialize(baseDir, vol: "", file: '*')
        # T01 => T/T01
        if vol =~ /^\D+\d+/
            vol = vol.sub(/^(\D+)/, '\1/\1')
        end
        path = File.join(baseDir, vol)

        @allFiles = Dir.glob('**/' + file, base: path)
        @allFiles.map! { |f|
            f = File.join(path, f)  # 加入目錄成為全名
        }
    end
end



def run_file(file)
    xml = XMLFile.new(file)
    result = xml.run
    pinLevel = xml.getMaxPinLevel
    muluLevel = xml.getMaxMuluLevel
    file_info = "#{file} , #{muluLevel} , #{pinLevel}\n"
    if muluLevel == 0
        return "",""
    end
    return file_info, result;
end

#======================================================
# 主程式
#======================================================

vol = ARGV[0]

# 如果有 T01_config.txt 這種來源，就設為 true，表示産生最終結果。
# 否則就是原始資料。
$ok_data = false    

# 檢查 xx_.js 有沒有 (( 符號
$check_50 = false

# 讀取 T01_config.txt 這種檔案
$file_mulu = GetFileMulu.new(vol)

# 目錄的總結構
$mulu_json = MuluJson.new

# 缺字
$gaijis = CBETA::Gaiji.new('d:/cbwork/cbeta_gaiji')

files = GetFiles.new('d:/cbwork/xml-p5b', vol: vol, file: '*.xml' )
if $ok_data
    # 印出最後的結果
#    fout = File.open("#{vol}_mulu_nozip.txt","w") # 列出處理過的目錄
    files.allFiles.each { |file|
        if $file_mulu.has_file? file
            file_info, result = run_file(file)
#            fout.puts "=" * 50
#            fout.puts file_info
#            fout.puts "=" * 50
#            fout.puts result
        end
    }
#    fout.close

    $mulu_json.zip
#    fout = File.open("#{vol}_mulu.txt","w") # 列出最後目錄
#    fout.puts $mulu_json.get_result
#    fout.close

    fout = File.open("#{vol}_mulu.js","w") # 列出最後目錄
    # "001.xml":[[xxx],[xxx]],\n
    # "002.xml":[[xxx],[xxx]],\n
    # "003.xml":[[xxx],[xxx]],\n
    result = $mulu_json.get_js_result
    result.chomp!
    result.chop!
    
    result = "var mulu_txt = `{" + result + "}`;\n"
    result += "var mulu_json = JSON.parse(mulu_txt);\n"
    fout.puts result
    fout.close
else
    # 印出初步成果
    fout = File.open("#{vol}_raw.txt","w")     # 列出原始目錄
    fout2 = File.open("#{vol}_info.txt","w")    # 列出各檔目錄層次
    files.allFiles.each { |file|
        file_info, result = run_file(file)
        if file_info != ""
            fout2.puts file_info
            fout.puts "=" * 50
            fout.puts file_info
            fout.puts "=" * 50
            fout.puts result
        end
    }
    fout.close
    fout2.close
end

if $check_50
    puts "注意！注意！\n在 js 檢查雙引號 (( ，它是行數小於 50 。"
end