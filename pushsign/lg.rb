##################################################################################
# 執行方式：ruby lg.rb 來源檔 輸出檔
#
# <l> 前面的全形空白數 + 「『 引號數，換算成 margin-left；「『 引號數換算成 text-indent 的負值，
# 兩者皆以 em 為單位。例如：
# 將 <lg...><l>「  改成  <lg ... style="margin-left:1em;text-indent:-1em"><l>「
# 將 <lg...><l>「『  改成  <lg ... style="margin-left:2em;text-indent:-2em"><l>「『
# 將 <lg...><l>　「  改成  <lg ... style="margin-left:2em;text-indent:-1em"><l>「
# 將 <lg...><l>　「『  改成  <lg ... style="margin-left:3em;text-indent:-2em"><l>「『
# 上面只是舉例，全形空白與引號的數量並不限於此，皆會依實際數量計算縮排。
#
# <lg...> 與 <l...> 之間可以隔著換行與半形空白（排版縮排），故整檔讀入後用 gsub 處理，
# 不再逐行比對。
##################################################################################

infile = ARGV[0];		# 輸入檔名
outfile = ARGV[1];		# 輸出檔名

if infile == "" or infile == nil or outfile == "" or outfile == nil
	puts "執行方式：ruby lg.rb 來源檔 輸出檔"
	exit
end

content = File.read(infile)

content.gsub!(/(<lg\s*[^>]*?>)([ \t\r\n]*)(<l[^>]*?>)(　*)([「『]+)/) do
	lg = $1
	between = $2
	l = $3
	sp = $4
	second = $5

	indent1 = sp.size + second.size
	indent2 = second.size

	if (lg.include? "style")	# 有 style 了, 加上 xxx , 讓它 parse 不過請手動處理
		lg = lg.sub('>', %( 請手動加style="margin-left:#{indent1}em;text-indent:-#{indent2}em">))
	else
		lg = lg.sub('>', %( style="margin-left:#{indent1}em;text-indent:-#{indent2}em">))
	end

	"#{lg}#{between}#{l}#{second}"
end

File.write(outfile, content)
puts 'ok'