################################################################
# 將沒有格式化的經文轉成有行首資料的標準格式經文
#
# 底下是特殊格式，分別是冊、經號、頁碼
# vol:T02
# N0001
# p0001a
#
################################################################

$infile = "a.txt"		# 來源檔名
$outfile = "a_out.txt"	# 輸出檔名

# 行首資訊

$vol = ""
$sutra = "0000_"
$page = ''
$line = 0

$outtxt = ""	# 輸出結果

$line2 = 0	# 行數 (二位數)

fin = File.open($infile)
fout = File.open($outfile, 'w')

fin.each_line { |line|
	# p0001a 就是頁碼
	if line.match(/^(p.\d{3}[a-z])/)
		$page = $1
		$line = 0
	elsif line.match(/^.?vol:(.*)/)
		$vol = $1
	elsif line.match(/^N(\d+)([a-zA-Z]?)/)
		$sutra = "%04d" % $1.to_i
		$other = $2
		if $other == ""
			$sutra += "_"
		else
			$sutra += $other
		end	
	else
		$line += 1

		# 遇到新的一經, 取得新的經號
		if line.match(/No\.\s*(\d+)([a-z]?)/)
			$sutra = "%04d" % $1
			$other = $2
			if $other == ""
				$sutra += "_";
			else
				$sutra += $other;
			end
		end
		$outtxt += $vol + "n" + $sutra + $page + "%02d" % $line  + "︴" + line;
	end
}

fout.write $outtxt

fin.close
fout.close
