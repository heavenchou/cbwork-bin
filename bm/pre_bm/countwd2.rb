################################################################
# 頻次統計
################################################################

# 參數
infile = "abc.txt"		# 來源檔名
outfile = "wordcount.txt"	# 輸出檔名

hash = Hash.new
# 讀入檔案
fin = File.open(infile)
fin.each_char { |c|
    hash[c] = hash[c].nil? ? 1 : hash[c] + 1
}
fin.close

# 輸出結果
fout = File.open(outfile, 'w')
hash.sort.each { |key,value| 
    out = "%06d\t%05X\t" % [key.ord, key.ord]
    out += "#{key}\t"
    out += "%08d" % value
    fout.puts out
}
fout.close