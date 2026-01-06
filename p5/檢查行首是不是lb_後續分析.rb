# 分析資料中錯誤行的統計
# 錯誤行格式如下：
# error: /cbwork/xml-p5a-2025/I/I01/I01n0100.xml 第 67 行: <body>
# error: /cbwork/xml-p5a-2025/I/I01/I01n0100.xml 第 68 行: <cb:div>
# error: /cbwork/xml-p5a-2025/I/I01/I01n0100.xml 第 99 行: </cb:div>
# 要統計「第 n 行:」 之後的標記及數量

hash = Hash.new(0)
hash2 = Hash.new(0)
File.open('nolb.txt', 'r') do |fin|
	lines = fin.readlines
	# 統計
	err_count = 0
	tag_count = 0
	err_lines = []
	lines.each do |line|
		if line.include?("error:")
			err_count += 1
			# 判斷標記為何？
			if line =~ /第 (\d+) 行: (<\/?.*?[ >])/
				hash[$2] += 1
				tag_count += 1
			else
				line =~ /第 (\d+) 行: (.*)/
				hash2[$2] += 1
			end
		end
	end
	puts "Total error lines: #{err_count}"
	puts "Total tag lines: #{tag_count}"
	hash.each do |key, value|
		puts "#{key}: #{value}"
	end
	hash2.each do |key, value|
		puts "#{key}: #{value}"
	end
end