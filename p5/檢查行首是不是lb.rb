# 檢查 XML 的行首是不是 <lb n="xxx"/>，如果不是，就列出來檢查

require 'fileutils'

def 檔案檢查(lines)
	# 檢查行首是不是 <lb n="xxx"/>
	# 不過要遇到 <text> 之後才檢查
	inText = false
	$hasChange = false
	lines.each_with_index do |line, index|
		if line.include?('<text>')
			inText = true
			next 
		end
		if inText 
			if not line.start_with?('<lb ')
				# !~ /^<lb n="\d{3,4}\/>/
				if not line.start_with?('<pb ')
					if not line.start_with?('</body>')
						if not line.start_with?('<milestone ')
							puts "error: #{$dst_file} 第 #{index+1} 行: #{line}"
							# 如果前一行是空白，就接到前二行，依此類推
							i = 1
							while lines[index-i] == ""
								i += 1
							end
							# 這一行要接到前一行
							if lines[index-i].end_with?("\n")
								lines[index-i] = lines[index-i].chop
							end
							lines[index-i] += line
							lines[index] = ""
							$hasChange = true
						end
					end
				end
			end
		end
	end
	return lines
end

# 若行中有 <lb>，則 <lb> 前面加上換行，變成 "...\n<lb>..."
# 二種特例是不要加上換行的
# 1. <lb type="old">，這是印順導師舊的 lb，不要加上換行
# 2. <lb ed="Rxxx">，這是舊版卍續藏 的 lb，不要加上換行
def lb在行首(lines)
	lines.each_with_index do |l, index|
		# 真正在行首的 <lb> 就不處理，所以要暫時換成其它字串，例如用大寫 <LB>
		line = l
		line = line.sub(/^<lb /, '<LB ')

		# 二種特例是不要加上換行的
		line.gsub!(/<lb([^>]*type="old"[^>]*>)/, '<LB\1')
		line.gsub!(/<lb([^>]*ed="R.*?>)/, '<LB\1')
		# <lb> 前面加上換行
		if line.include?('<lb')
			puts "error lb: #{$dst_file} 第 #{index+1} 行: #{line}"
			line = line.gsub('<lb', "\n<lb")
			$hasChange = true
		end
		# 還原 <lb> 的大小寫
		line = line.gsub('<LB', '<lb')
		lines[index] = line
	end
	return lines
end

#=================================================================
# 主程式
# 來源目錄
src_dir = '/cbwork/xml-p5a-2025/'
# 目的目錄
dst_dir = '/cbwork/xml-p5a-lb/'

# 建立目的目錄
FileUtils.mkdir_p(dst_dir)
# 逐一處理來源目錄下的 XML 檔案
Dir["#{src_dir}/**/*.xml"].each do |src_file|
	# 取得檔名
	$dst_file = src_file
	# 目的檔名
	$dst_file = $dst_file.sub(src_dir, dst_dir)
	# puts $dst_file
	# 建立目的目錄
	FileUtils.mkdir_p(File.dirname($dst_file))
	# 處理 XML 檔案
	lines = []
	File.open(src_file, 'r') do |fin|
			lines = fin.readlines
			lines = 檔案檢查(lines)
			#lines2 = lb在行首(lines)	# 若行中有 <lb>，就移到行首，變成 "...\n<lb>..."
	end
	# 內容有變就寫回檔案
	#if $hasChange
		File.open($dst_file, 'w') do |fout|
			lines.each do |line|
				if line != ""
					fout.puts line
				end
			end
		end
	#end
end