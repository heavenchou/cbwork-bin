# 將缺字資料庫 XML 轉成 JSON    by Heaven

use utf8;
my $count = 0;
open IN, "<:utf8", "../../cbeta_gaiji/cbeta_gaiji.xml";
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
    }
    elsif(/^<unicode>(.*?)<\/unicode>/)
    {
        print OUT "    \"unicode\": \"$1\"";
    }
    elsif(/^<([^>]*)>(.*?)<\/\1>/)
    {
        print OUT ",\n    \"$1\": \"$2\"";
    }
    elsif(/^<\/cbeta_gaiji>/)
    {
        print OUT "\n  }";
    }
}
print OUT "\n}";
close IN;
close OUT;