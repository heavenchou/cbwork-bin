# 將缺字資料庫 XML 轉成 JSON    by Heaven

use utf8;
my $count = 0;
my $item_count = 0; # 每一筆的欄位數
open IN, "<:utf8", "../../cbeta_gaiji/cbeta_gaiji_orig.xml";
open OUT, ">:utf8", "../../cbeta_gaiji/cbeta_gaiji.json";
print OUT "{\n";
while(<IN>)
{
    # <cb>00001</cb>
    # "00001": {
    
    # <unicode>6B35</unicode>
    # "unicode": "6B35"

    if(/^<ID>(.*?)<\/ID>/)
    {
        if($count)
        {
            print OUT ",\n";    # 第二筆之後
        }
        $count++;
        print OUT "  \"$1\": {\n";
        $item_count = 0; # 每一筆的欄位數
    }
    elsif(/^<([^>]*)>(.+?)<\/\1>/)
    {
        if($item_count > 0)
        {
            print OUT ",\n";
        }
        print OUT "    \"$1\": \"$2\"";
        $item_count++;
    }
    elsif(/^<\/cbeta_gaiji>/)
    {
        print OUT "\n  }";
    }
}
print OUT "\n}";
close IN;
close OUT;