


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
	def initialize(baseDir, vol: "X", file: '*')
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


files = GetFiles.new('d:/cbwork/xml-p5a', file: '*.xml' )

# 逐一列出 XML 檔案中的 title 和判斷是否有 gif 檔

files.allFiles.each { |f|
	id = ""
	if f =~ /.*\/(\D+\d+n.*)\.xml/
		id = $1
	end
	file = File.open(f)
	title = ""
	juan = ""
	punc = ""
	gif = false
	file.each { |line|
	  # <title level="m" xml:lang="zh-Hant">別譯雜阿含經</title>
		if line =~ /<title level="m"[^>]*>(.*?)<\/title>/
			title = $1
		end
		# <extent>2卷</extent>
		if line =~ /<extent>(.*?)<\/extent>/
			juan = $1
		end
		# <punctuation resp="CBETA"><p>新式標點</p></punctuation>
		if line =~ /<punctuation resp="(.*?)"><p>(.*?)<\/p><\/punctuation>/
			punc = $1 + ":" + $2
			break
		end
	}
	file.close
	
	puts "#{id}\t#{title}(#{juan})\t【#{punc}】"
		
}