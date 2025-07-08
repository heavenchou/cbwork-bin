################################################################
# 檢查簡單標記經文中行首資訊的合理性
################################################################

# 參數
$infile = "a_out.txt"		# 來源檔名
$outfile = "b_out.txt"	# 輸出檔名
$max_line = 30		# 一欄最大行數
$min_line = 2		# 一欄最小行數

# 前一行的行首資訊
$p_ed = ""
$p_vol = ""
$p_sutra_num = ""
$p_page = ""
$p_field = ""
$p_line = ""

# 行首資訊
$ed
$vol
$sutra_num
$page
$field
$line
$outtxt = ""
$errtxt = ""
$line_num = 0	# 行數
$line6 = 0	# 行數 (六位數)
$hanbook_msg = "#{$infile} :   : found 1 => ︴"

def main
	lines = File.readlines($infile)  # 一次讀入所有行
	fout = File.open($outfile, 'w')

	lines.each_with_index { |line, index|
		$line_num += 1
		$line6 = "%06d" % $line_num
		is_last = (index == lines.length - 1)
		check_this_line(line, is_last)
	}

	fout.write $errtxt
	fout.write $hanbook_msg

	fout.close
end

# 開始檢查

def check_this_line(line, is_last)
	
	if line.match(/^(\D{1,3})(\d{2,3})n([AB]?\d{3,4}[a-zA-Z_]?)p(.\d{3})([a-z])(\d{2,})/)
		$ed = $1;
		$vol = $2;
		$sutra_num = $3;
		$page = $4;
		$field = $5;
		$line = $6;
	else
		$errtxt += "#{$line6}:首行資訊格式不正確\n";
		return;
	end
	
	# 以下第一行不用檢查
	
	if $p_ed != ""
		# 換欄時, 檢查前一行是否在範圍中
		
		if "#{$page}#{$field}" != "#{$p_page}#{$p_field}"
			$p_line6 = "%06d" % ($line_num-1)
			
			if $p_line.to_i > $max_line
				$errtxt += "#{$p_line6}:行數 #{$p_line} 超過最大限制 #{$max_line} \n"
			end
			
			if $p_line.to_i < $min_line
				$errtxt += "#{$p_line6}:行數 #{$p_line} 小於最小限制 #{$min_line} \n"
			end

			if $page.to_i > $p_page.to_i + 1
				$errtxt += "#{$p_line6}:頁碼 #{$p_page} 不連續\n"
				$errtxt += "#{$line6}:頁碼 #{$page} 不連續\n"
			end
		end
		
		# 檢查最後一行

		if is_last
			$line6 = "%06d" % ($line_num)
			
			if $line.to_i > $max_line
				$errtxt += "#{$line6}:行數 #{$line} 超過最大限制 #{$max_line} \n"
			end
			
			if $line.to_i < $min_line
				$errtxt += "#{$line6}:行數 #{$line} 小於最小限制 #{$min_line} \n"
			end
		end

		if $ed != $p_ed
			$errtxt += "#{$line6}:書本版本 #{$ed} 與前一行不同\n"
		end
			
		if $vol != $p_vol
			$errtxt += "#{$line6}:書本冊數 #{$vol} 與前一行不同\n"
		end
		
		if $sutra_num < $p_sutra_num
			$errtxt += "#{$line6}:經號 #{$sutra_num} 比前一行還小\n"
		end
		
		if $page < $p_page
			$errtxt += "#{$line6}:頁碼 #{$page} 比前一行還小\n"
		end
		
		if "#{$page}#{$field}" < "#{$p_page}#{$p_field}"
			$errtxt += "#{$line6}:頁碼及欄 #{$page} #{$field} 比前一行還小\n"
		end
		
		if $line <= $p_line && $line.to_i != 1
			$errtxt += "#{$line6}:行數 #{$line} 比前一行還小或相等, 而且不是 1\n"
		end
		
		if "#{$page}#{$field}#{$line}" <= "#{$p_page}#{$p_field}#{$p_line}"
			$errtxt += "#{$line6}:頁欄行 #{$page} #{$field} #{$line} 比前一行還小或相等\n"
		end
	end
	
	$p_ed = $ed
	$p_vol = $vol
	$p_sutra_num = $sutra_num
	$p_page = $page
	$p_field = $field
	$p_line = $line
end

main
