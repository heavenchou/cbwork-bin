# CBETA XML P5a 轉 EPUB
# 設定檔: ../cbwork_bin.ini
# 命令列參數:
# 	ruby xml2epub.rb 參數 年度.季
# 範例: ruby xml2epub.rb ALL  2022.Q1 (無參數，全部執行)
# 範例: ruby xml2epub.rb T    2022.Q1 (只執行 T 大正藏)
# 範例: ruby xml2epub.rb A..D 2022.Q1 (執行 A 到 D 等藏經)
# 原始來源: https://github.com/DILA-edu/cbeta-api.git
# 作者: 周邦信(Ray Chou)
#
# Heaven 修改：
# 2022-04-19 由 ray 的 cbeta-api.git 原始資料取出 epub 的部份

require_relative 'epub-main'

class XML2EPUB
  def initialize(arg, year)
    if arg == 'ALL'
      arg = nil
    end
    @config = get_config()
    @config[:quarter] = year  # 2022.Q1
    # 轉全部: convert()
    # 只轉嘉興藏: convert('J')
    # 從 J 轉到 ZW: convert('J..ZW') 
    CbetaEbook.new(@config).convert(arg)
  end

  def get_config(env=nil)
    r = { v: 1 } # 影響 /var/www 下資料夾名稱
    # r[:q1]      = '2021Q4' # 製作 change log 時比對 q1, q2
    # r[:q2]      = '2022Q1'
    # r[:publish] = '2022-01' # 版權資訊 => 版本記錄 => 發行日期

    # r[:quarter] = r[:q2].sub(/^(\d+)(Q\d)$/, '\1.\2')
    # r[:env] = env

    # case env
    # when 'production'
    #   r[:git]           = '/home/ray/git-repos'
    #   r[:old]           = "/var/www/cbapi#{r[:v]-1}/shared"
    #   r[:old_data]      = File.join(r[:old],  'data')
    #   r[:root]          = "/var/www/cbapi#{r[:v]}/shared"
    #   r[:change_log]    = '/home/ray/cbeta-change-log'
    #   r[:ebook_convert] = '/usr/bin/ebook-convert'
    # when 'development'
    #   r[:git]           = '/Users/ray/git-repos'
    #   r[:root]          = "/Users/ray/git-repos/cbeta-api"
    #   r[:change_log]    = '/Users/ray/Documents/Projects/CBETA/ChangeLog'
    #   r[:ebook_convert] = '/Applications/calibre.app/Contents/MacOS/ebook-convert'
    # when 'cn'
    #   r[:git] = '/mnt/CBETAOnline/git-repos'
    #   r[:root] = "/mnt/CBETAOnline/cbdata/shared"
    # end

    # r[:git]         = '/Users/ray/git-repos'
    # r[:root]          = "/cbwork/cbeta-api"
    r[:git_cbr2x]     = "/cbwork/CBReader2X/Bookcase/CBETA"
    # r[:ebook_convert] = '/usr/bin/ebook-convert'

    
    # mimetype 先改名為 !mimetype
    # 7z 的處理法，要先把 !mimetype 壓縮進去，再壓其它，再把 !mimetype 改回 mimetype 才行。
    # windows 7z 壓縮命令， 7z0 表示不壓縮， rn 表示改名
    r[:zip0] = '"C:/Program Files/7-Zip/7z" a -mx0 '
    r[:zip]  = '"C:/Program Files/7-Zip/7z" a -x!!mimetype '
    r[:ziprn]  = '"C:/Program Files/7-Zip/7z" rn '
    # mac 版的 zip 壓縮命令， zip0 表示不壓縮
    # r[:zip0]  = 'zip -0Xq '
    # r[:zip]   = 'zip -Xr9Dq '

    # r[:data]     = File.join(r[:root], 'data')
    # r[:public]     = File.join(r[:root], 'public')
    # r[:juanline] = File.join(r[:data], 'juan-line')
    r[:figures]    = "/cbwork/CBReader2X/Bookcase/CBETA/figures"
    r[:figures_seeland]    = "/cbwork/SLReader2X/Bookcase/SEELAND/figures"

    # eBook
    # r[:download] = File.join(r[:public], 'download')
    r[:epub] = '/temp/epub'
    # r[:mobi] = File.join(r[:download], 'mobi')
    r[:epub_template] = './epub-template'

    # GitHub Repositories
    # r[:authority]   = '/cbwork/Authority-Databases'
    #r[:cbr_figures] = File.join(r[:git], 'CBR2X-figures')
    r[:covers]      = '/cbwork/ebook-covers'
    r[:gaiji]       = '/cbwork/cbeta_gaiji'
    # r[:metadata]    = '/cbwork/cbeta-metadata'
    r[:xml]         = '/cbwork/xml-p5a'
    r
  end
end

#################################
# 主程式
#################################

$seeland_canon = ['DA','ZY','HM']   # 西蓮專案

if ARGV[0] && ARGV[1]
  arg = ARGV[0].upcase
  year = ARGV[1].upcase
  XML2EPUB.new(arg, year)
else
  puts 'CBETA XML P5a 轉出 EPUB'
  puts '用法：'
  puts '  ruby xml2epub.rb ALL  2022.Q1 (全部)'
  puts '  ruby xml2epub.rb T    2022.Q1 (只有大正藏 T)'
  puts '  ruby xml2epub.rb A..D 2022.Q1 (處理範圍從 A 到 D)'
end
