
# 檢查XML中是否有相容表意字
# 相容表意字有二段
# 中日韓相容表意文字
# U+F900...U+FAD9  豈更車……𧻓齃龎
# 中日韓相容表意文字補充
# U+2F800..U+2FA1D 丽丸乁……鼖鼻𪘀（Unicode 3.1）

# 由指定目錄列出所有的檔名，包括子目錄中的檔案
def list_all_files(directory)
  all_files = []
  Dir.glob(File.join(directory, '**', '*.xml')) do |file|
    all_files << file if File.file?(file)
  end
  all_files
end

# 開啟檔案，逐行檢查是否包含相容表意字
def check相容表意字(file_path)
  pre_line = ''
  File.open(file_path, 'r:UTF-8') do |file|
    file.each_line do |line|

      if line =~ /[豈-龎丽-𪘀]/
        line.gsub!(/([豈-龎丽-𪘀])/,'【\1】')
        puts line
      end
    end
  end
end

all_files = list_all_files('d:/cbwork/xml-p5a/')

all_files.each do |file|
  # 忽略這些大藏經，因為已經先查過了
  #unless file =~ /\/[CDIJTX]\//
    puts
    puts file
    check相容表意字(file)
  #end
end