
# 檢查二行 xml
# <lb>......
# <lb>abc
# 若第二行一開始是英文或羅馬轉寫，而前一行行尾不是標點或中文
# 則列出來檢查，因為第二行可能要加上空格

# 由指定目錄列出所有的檔名，包括子目錄中的檔案
def list_all_files(directory)
  all_files = []
  Dir.glob(File.join(directory, '**', '*.xml')) do |file|
    all_files << file if File.file?(file)
  end
  all_files
end

# 開啟檔案，逐行檢查是否包含指定的字串
def checkeng(file_path)
  pre_line = ''
  File.open(file_path, 'r:UTF-8') do |file|
    file.each_line do |line|

      if line =~ /<lb[^>]*>[a-zA-ZÀ-ʸᴀ-ᶿḀ-ỿ]/
        if pre_line =~ /[^\-\/，（）>；：。、》」一-龎]\n/
            puts file_path
            puts pre_line
            puts line
            puts
        end
      end
      if line =~ /<lb/
        pre_line = line
      end
    end
  end
end

all_files = list_all_files('d:/cbwork/xml-p5a/')

all_files.each do |file|
  # 忽略這些大藏經，因為已經先查過了
  unless file =~ /\/[CDIJTX]\//
    # puts file
    checkeng(file)
  end
end