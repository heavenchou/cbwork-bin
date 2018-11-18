# 將缺字資料庫原始的 XML 轉成要上傳至 GitHub 的 XML    by Heaven
# 主要是移除空白的欄位

use utf8;
open IN, "<:utf8", "../../cbeta_gaiji/cbeta_gaiji_orig.xml";
open OUT, ">:utf8", "../../cbeta_gaiji/cbeta_gaiji.xml";
while(<IN>)
{
    # 移除空內容 ex
    # <norm_unicode></norm_unicode>
    if($_ !~ /^<([^>]*)><\/\1>/)
    {
        print OUT $_;
    }
}
close IN;
close OUT;