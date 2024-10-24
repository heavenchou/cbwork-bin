# 本程式的目的是要將 XML 裡面的【圖】換成標記 <figure><graphic url="..."/></figure>
# 例如：
# <lb ed="GA" n="0681a02"/>之楞伽丈室鶴園居士書【圖】【圖】
# 程式將之處理成：
# <lb ed="GA" n="0681a02"/>之楞伽丈室鶴園居士書<figure><graphic url="../figures/GA/GA037p0681_01.gif"/></figure><figure><graphic url="../figures/GA/GA037p0681_02.gif"/></figure>
#
# 使用方法：
#
# 將本程式和要處理的 XML 各冊目錄放在一起，
# 例如要處理 "GA056，GA057" 二個目錄，本程式就和此目錄在同一層目錄中。
# 程式最後二行表示要執行那二個目錄。可以寫很多行，每行一個目錄。
# run("GA056")
# run("GA057")
# 程式會先産生一個 output 目錄，裡面就會有改好的各冊目錄及檔案。
# by Heaven + ChatGPT 2024-10-23

require 'fileutils'

def run(input_dir)
  # 定義目錄路徑

  ed = input_dir.gsub(/\d/, "") # 取得藏經代碼
  output_dir = 'output/' + input_dir  # 輸出目錄

  # 確保 output 目錄存在
  FileUtils.mkdir_p(output_dir)

  # 遍歷 GA056 目錄中的所有 .xml 檔案
  Dir.glob("#{input_dir}/*.xml") do |file_path|
    # 讀取檔案
    lines = File.readlines(file_path, encoding: 'UTF-8')

    # 初始化流水號
    counter = 1
    # 逐行處理
    modified_lines = lines.map do |line|

      # 流水號歸 1
      if line.match(/<pb .*?>/)
        counter = 1
      end

      # <lb ed="GA" n="b003a01"/>
      page = "xxx"
      if line.match(/<lb.*?n="(....)/)
        page = $1
      end

      # 使用 gsub 的區塊功能來替換 "【圖】"
      line.gsub("【圖】") do
        # 格式化流水號為兩位數字
        graphic_number = format('%02d', counter)
        counter += 1
        if page.size != 4
          puts "行首 <lb> 有誤，找不到行號：#{line}"
          puts "按 enter 繼續"
          gets
        end
        # 生成替換字串
        "<figure><graphic url=\"../figures/#{ed}/#{input_dir}p#{page}_#{graphic_number}.gif\"/></figure>"
      end
    end

    # 取得檔名並寫入 output 目錄
    file_name = File.basename(file_path)
    output_path = File.join(output_dir, file_name)

    # 將修改過的行寫回新的檔案
    File.write(output_path, modified_lines.join, encoding: 'UTF-8')
  end
end

run("GA056")
run("GA057")

