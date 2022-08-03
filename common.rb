WITS = {
  'A'  => '【金藏】',
  'B'  => '【補編】',
  'C'  => '【中華】',
  'D'  => '【國圖】',
  'DA' => '【道安】',
  'F'  => '【房山】',
  'G'  => '【佛教】',
  'GA' => '【志彙】',
  'GB' => '【志叢】',
  'HM' => '【惠敏】',
  'I'  => '【佛拓】',
  'J'  => '【嘉興】',
  'K'  => '【麗】',
  'L'  => '【龍】',
  'LC' => '【呂澂】',
  'M'  => '【卍正】',
  'N'  => '【南傳】',
  'P'  => '【北藏】',
  'Q'  => '【磧砂】',
  'S'  => '【宋遺】',
  'T'  => '【大】',
  'TX' => '【太虛】',
  'U'  => '【洪武】',
  'X'  => '【卍續】',
  'Y'  => '【印順】',
  'ZS' => '【正史】',
  'ZW' => '【藏外】',
  'ZY' => '【智諭】',
}

module Slop
  # 命令列參數 指定必須大寫
  class UpcaseOption < Option
    def call(value)
      value.upcase
    end
  end
end

def git_update_date(xml_fn)
  folder = File.dirname(xml_fn)
  basename = File.basename(xml_fn)
  # 西蓮專案的 git 目錄不同, 所以要另外處理
  if %w(DA ZY HM).include? basename[0..1]
    # c:/cbwork/xml-p5a/HM/HM01\HM01n0001.xml
	  # c:/cbwork/cbeta_project/HM/xml-p5a/HM01\HM01n0001.xml
    folder.sub!(/xml\-p5a\/((DA)|(ZY)|(HM))/,'cbeta_project\/\1\/xml-p5a')
  end
  r = nil
  Dir.chdir(folder) do
    r = `git log -1 --pretty=format:"%ai" #{basename}`
  end
  r
end

def spend_time(secs)
  if secs < 60
    s = '%.2f seconds' % secs
  else
    s = '%.1f minutes' % (secs/60)
  end

  "Spend time: #{s}"
end