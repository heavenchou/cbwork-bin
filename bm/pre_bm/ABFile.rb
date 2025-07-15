# 將比對檔分割成二個檔案
# 例如檔案 input.txt 內容是 123{{abc||xyz}}456
# 執行 ruby ABFile.rb input.txt out1.txt out2.txt
# 會產生二個檔案。
# 檔案 out1.txt 內容為 123abc456
# 檔案 out2.txt 內容為 123xyz456

# encoding: UTF-8

infile = ARGV[0]
file1 = ARGV[1]
file2 = ARGV[2]

if file2.nil?
  puts "ruby ABFile.rb input.txt out1.txt out2.txt"
  exit
end

File.open(infile, "r:utf-8") do |fin|
  File.open(file1, "w:utf-8") do |fout1|
    File.open(file2, "w:utf-8") do |fout2|
      fin.each_line do |line|
        out1 = line.gsub(/\{\{(.*?)\|\|.*?\}\}/, '\1')
        out2 = line.gsub(/\{\{.*?\|\|(.*?)\}\}/, '\1')
        fout1.print out1
        fout2.print out2
      end
    end
  end
end
