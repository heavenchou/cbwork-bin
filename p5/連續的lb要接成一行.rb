# 在 XML 中，如果連續二行行首的 lb 標記相同，則應該將兩行合併成一行。
# 例如：
# <lb ed="D" n="0365a07"/>門<note type="cf1">T59n2217_p0713a10</note></lem><rdg wit="【國圖】">々々々々
# <lb ed="D" n="0365a07"/>々</rdg></app>以上十住地名信解行地<note place="inline">文</note>私云此釋𨿽似同大師
# 應該改成：
# <lb ed="D" n="0365a07"/>門<note type="cf1">T59n2217_p0713a10</note></lem><rdg wit="【國圖】">々々々々<lb ed="D" n="0365a07"/>々</rdg></app>以上十住地名信解行地<note place="inline">文</note>私云此釋𨿽似同大師

require 'fileutils'

def 合併lb(lines)
	# 逐一處理每一行
	pre_lb = ""
	$hasChange = false
	lines.each_with_index do |line, index|
		# 如果是行首的 lb 標記
		if line =~ /^(<lb.*?>)/
			# 如果前一行也是 lb 標記
			if pre_lb != ""
				# 如果兩行的 lb 標記相同
				if pre_lb == $1
					if lines[index-1] =~ /<\/lem><rdg/ && lines[index] =~ /<\/rdg><\/app>/
						# 將兩行合併
						lines[index-1] = lines[index-1].chop + line
						lines[index] = ""
						$hasChange = true
						# 印出檔名（不要路徑）、行號、內容
						puts "#{File.basename($dst_file)} : #{index} : #{lines[index-1]}"
					end
				end
			end
			pre_lb = $1
		else
			pre_lb = ""
		end
	end
	return lines
end

#=================================================================
# 主程式
# 來源目錄
src_dir = '/cbwork/xml-p5a'
# 目的目錄
dst_dir = '/cbwork/xml-p5a-lb2'

# 建立目的目錄
FileUtils.mkdir_p(dst_dir)
# 逐一處理來源目錄下的 XML 檔案
Dir["#{src_dir}/**/*.xml"].each do |src_file|
	# 取得檔名
	$dst_file = src_file
	# 目的檔名
	$dst_file = $dst_file.sub(src_dir, dst_dir)
	# puts $dst_file
	# 處理 XML 檔案
	lines = []
	File.open(src_file, 'r') do |fin|
		lines = fin.readlines
		lines = 合併lb(lines)
	end
	# 內容有變就寫回檔案
	if $hasChange
		# 建立目的目錄
		FileUtils.mkdir_p(File.dirname($dst_file))
		File.open($dst_file, 'w') do |fout|
			lines.each do |line|
				if line != ""
					fout.puts line
				end
			end
		end
	end
end