################################################################
# 頻次統計
################################################################

# 參數
infile = "a_out.txt"		# 來源檔名
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
    fout.puts "%06d\t%05X\t#{key}\t%08d" % [key.ord, key.ord, value]
}
fout.close