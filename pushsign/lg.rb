##################################################################################
# 執行方式：ruby lg.rb 來源檔 輸出檔
#
# 將 <lg...><l>「  改成  <lg ... style="margin-left:1em;text-indent:-1em"><l>「 
# 將 <lg...><l>「『  改成  <lg ... style="margin-left:2em;text-indent:-2em"><l>「『 
# 將 <lg...><l>　「  改成  <lg ... style="margin-left:2em;text-indent:-1em"><l>「 
# 將 <lg...><l>　「『  改成  <lg ... style="margin-left:3em;text-indent:-2em"><l>「『  
##################################################################################

infile = ARGV[0];		# 輸入檔名
outfile = ARGV[1];		# 輸出檔名

if infile == "" or infile == nil or outfile == "" or outfile == nil
	puts "執行方式：ruby lg.rb 來源檔 輸出檔"
	exit
end

fin = File.open(infile, 'r')
fout = File.open(outfile, 'w')

fin.each_line { |line|
	m = line.match(/(<lg\s*[^>]*?>)(<l[^>]*?>)(　*)([「『]+)/)
	if m
		lg = m[1]
		sp = m[3]
		second = m[4]
		
		indent1 = sp.size + second.size
		indent2 = second.size
		
		if (lg.include? "style")	# 有 style 了, 加上 xxx , 讓它 parse 不過請手動處理
			lg.sub!('>', %( 請手動加style="margin-left:#{indent1};text-indent:-#{indent2}">))
		else
			lg.sub!('>', %( style="margin-left:#{indent1};text-indent:-#{indent2}">))
		end

		line.sub!(/(<lg\s*[^>]*?>)(<l[^>]*?>)(　*)([「『]+)/, "#{lg}\\2\\4")
	end
	fout.puts line
}
fin.close
fout.close
puts 'ok'