=begin
由 sutralist 產生 catalog.txt        by heaven 2018/03/19

產生格式為 
藏,部類,部別,冊,經,卷數,經名,作譯者

T,阿含部類,阿含部,01,0001 , 22,長阿含經                                 ,【後秦 佛陀耶舍共竺佛念譯】
T,阿含部類,阿含部,01,0002 ,  1,七佛經                                   ,【宋 法天譯】
T,阿含部類,阿含部,01,0003 ,  2,毘婆尸佛經                               ,【宋 法天譯】

=end
=cut

use utf8;
use strict;
use warnings;
use lib "../sutralist";
use SutraList;
use lib "../bulei";
use Bulei;
use lib "../..";
use CBETA;

my $para = shift;	# 傳入的參數，主要是 see 是處理西蓮

my $sutralist = SutraList->new;     # 宣告
my $bulei = Bulei->new;
my $outfile = "__catalog_gaiji.txt";

# 判斷是不是西蓮專案
if($para eq "see") {
    $sutralist->initial("../sutralist/sutralist_see.txt");  # 初始化, 要傳入 sutralist.txt 的位置
    $outfile = "__catalog_see_gaiji.txt";
} else {
    $sutralist->initial("../sutralist/sutralist.txt");  # 初始化, 要傳入 sutralist.txt 的位置
}

$bulei->initial("../bulei/bulei.txt");

open OUT, ">:utf8", $outfile;

for(my $i=0; $i<=$#{$sutralist->book}; $i++)
{
    my $key = $sutralist->sutraid->[$i];
    my $bulei_name = $bulei->bulei_name_by_sutraid($key);

    # 處理大般若經
    if($sutralist->book->[$i] eq "T")
    {
        if($sutralist->volnum->[$i] >=5 && $sutralist->volnum->[$i] <=7)
        {
            if($sutralist->sutranum->[$i] =~ /0220[d-o]/)
            {
                next;
            }
            $sutralist->sutranum->[$i] = "0220";
            $sutralist->juan->[$i] = 200;
        }
    }

    print OUT $sutralist->book->[$i] . " , ";
    # 處理大正藏的部別
    if($sutralist->book->[$i] eq "T")
    {
        print OUT $bulei_name . " , " . Taisho::get_part_by_sutranum($sutralist->sutranum->[$i]) . " , ";
    }
    else
    {
        print OUT $bulei_name . " , , ";
    }
    print OUT $sutralist->volnum->[$i] . " , ";
    print OUT $sutralist->sutranum->[$i] . " , ";
    print OUT $sutralist->juan->[$i] . " , ";
    print OUT $sutralist->name->[$i] . " , ";
    print OUT $sutralist->byline->[$i] . "\n";
}

close OUT;
