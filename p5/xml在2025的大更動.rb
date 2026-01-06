# 將 /cbwork/xml-p5a 底下的所有 XML 檔案更新內容，另外依原來的架構産生在 /cbwork/xml-p5a-2025 底下

require 'fileutils'


# 檔案轉換
# lines: 來源檔案的內容
# 傳回轉換後的內容
# 原本的 XML 檔頭有如下結構

# <titleStmt>
#			<title>Jin Edition of the Canon, Electronic version, No. 1057 新譯大方廣佛華嚴經音義</title>
#			<title xml:lang="zh-Hant">趙城金藏數位版, No. 1057 新譯大方廣佛華嚴經音義</title>
#			......
#	<sourceDesc>
#		<bibl>
#			<title level="s">Jin Edition of the Canon</title>
#			<title level="s" xml:lang="zh-Hant">趙城金藏</title>
#			<title level="m" xml:lang="zh-Hant">新譯大方廣佛華嚴經音義</title>
#		</bibl>
#	</sourceDesc>

# 要改成如下，將原來的 sourceDesc 移到 titleStmt 中，原來的 sourceDesc 只留下 <title level="s"> 的內容，如下：

# <titleStmt>
#			<title level="s">Jin Edition of the Canon</title>
#			<title level="s" xml:lang="zh-Hant">趙城金藏</title>
#			<title level="m" xml:lang="zh-Hant">新譯大方廣佛華嚴經音義</title>
#			<title>Jin Edition of the Canon, Electronic version, No. 1057 新譯大方廣佛華嚴經音義</title>
#			<title xml:lang="zh-Hant">趙城金藏數位版, No. 1057 新譯大方廣佛華嚴經音義</title>
#			......
#	<sourceDesc>
#		<bibl>趙城金藏</bibl>
#	</sourceDesc>

# CC 的 bibl 要特別處理，如下：
# CC001n0001 => bibl = "《比丘尼傳暨續比丘尼傳》（大千出版社，2006）"
# CC002n0002 => bibl = "《敦博本六祖壇經校釋》（萬卷樓，2006）"
# CC003n0003 => bibl = "《解深密經疏（下冊）》（佛陀教育基金會，2010）"
# CC004n0004 => bibl = "《成唯識論測疏》（金陵刻經處，2014）"
# CC005n0005 => bibl = "《般若融心論》（文明書局，1940）"

def 檔案轉換(lines)
	# 先取得 <sourceDesc> 的內容，要忽略 <bible>
	sourceDesc = []
	inSourceDesc = false
	lines.each_with_index do |line, index|
		if line.include?('<sourceDesc>')
			inSourceDesc = true
		end
		if inSourceDesc
			if line.include?('title')
				sourceDesc << line.strip
				lines[index] = ""
			end
			if line.include?('bibl')
				lines[index] = ""
			end
		end
		if line.include?('</sourceDesc>')
			inSourceDesc = false
		end
	end
	
	# 重新建立 lines，找到 <titleStmt> 的位置，將 sourceDesc 插入

	new_lines = []
	lines.each do |line|
		new_lines << line
		if line.include?('<titleStmt>')
			sourceDesc.each do |sline|
				new_lines << "\t\t\t#{sline}"
			end
		end
		if line.include?('<sourceDesc>')
			# CC 則為特例，要另外處理
			bibl = sourceDesc[1].gsub(/<[^>]+>/, '')
			if $dst_file.include?('CC001n0001')
				bibl = "《比丘尼傳暨續比丘尼傳》（大千出版社，2006）"
			elsif $dst_file.include?('CC002n0002')
				bibl = "《敦博本六祖壇經校釋》（萬卷樓，2006）"
			elsif $dst_file.include?('CC003n0003')
				bibl = "《解深密經疏（下冊）》（佛陀教育基金會，2010）"
			elsif $dst_file.include?('CC004n0004')
				bibl = "《成唯識論測疏》（金陵刻經處，2014）"
			elsif $dst_file.include?('CC005n0005')
				bibl = "《般若融心論》（文明書局，1940）"
			end
			new_lines << "\t\t\t<bibl>#{bibl}</bibl>"
		end
		# 把 <name>中華電子佛典協會 (CBETA)</name> 換成 <name>財團法人佛教電子佛典基金會 (CBETA)</name>
		if line.include?('<name>中華電子佛典協會 (CBETA)</name>')
			new_lines[-1] = "\t\t\t\t<name>財團法人佛教電子佛典基金會 (CBETA)</name>"
		end
		# <editorialDecl> 標記有時後面會有空白，要去掉，前面的空白不要去掉
		if line.include?('<editorialDecl>')
			new_lines[-1] = new_lines[-1].rstrip
		end
	end
	return new_lines
end


#=================================================================
# 主程式
# 來源目錄
src_dir = '/cbwork/xml-p5a'
# 目的目錄
dst_dir = '/cbwork/xml-p5a-2025'

# 建立目的目錄
FileUtils.mkdir_p(dst_dir)
# 逐一處理來源目錄下的 XML 檔案
Dir["#{src_dir}/**/*.xml"].each do |src_file|
	# 取得檔名
	$dst_file = src_file
	# 目的檔名
	$dst_file = $dst_file.sub(src_dir, dst_dir)
	puts $dst_file
	# 建立目的目錄
	FileUtils.mkdir_p(File.dirname($dst_file))
	# 處理 XML 檔案
	lines = []
	File.open(src_file, 'r') do |fin|
			lines = fin.readlines
			lines = 檔案轉換(lines)
	end
	File.open($dst_file, 'w') do |fout|
		lines.each do |line|
			if line != ""
				fout.puts line
			end
		end
	end
end