# 檢查缺字資料庫有沒有什麼問題    by heaven 2018/08/01
# 目前僅檢查
# 1. 組字式是否有重複
# 2. unicode 是否有重複

use utf8;
use lib "/cbwork/bin";
use CBETA;
use strict;

my $gaiji = new Gaiji();
$gaiji->load_access_db();

check_same_des();   # 檢查有沒有重複的組字式
check_same_uni();   # 檢查有沒有重複的unicode
check_uni_and_uniword();   # 檢查 unicode 和文字有沒有匹配
print "any key to exit";
<>;

# 檢查有沒有重複的組字式
sub check_same_des()
{
    my %record = ();
    my $key;
    my $cb2des = $gaiji->{"cb2des"};
    foreach $key (sort(keys(%$cb2des)))
    {
        my $des = $cb2des->{$key};
        if($record{$des} eq "")
        {
            $record{$des} = $key;
        }
        else
        {
            $record{$des} .= "," . $key;
            print "same des : " . $des . " : ". $record{$des} . "\n";
        }
    }
}
# 檢查有沒有重複的unicode
sub check_same_uni()
{
    my %record = ();
    my $key;
    my $cb2uni = $gaiji->{"cb2uni"};
    foreach $key (sort(keys(%$cb2uni)))
    {
        my $uni = $cb2uni->{$key};
        if($record{$uni} eq "")
        {
            $record{$uni} = $key;
        }
        else
        {
            $record{$uni} .= "," . $key;
            print "same uni : " . $uni . " : " . $gaiji->cb2uniword($key) . " : " . $record{$uni} . "\n";
        }
    }
}

# 檢查 unicode 和文字有沒有匹配
sub check_uni_and_uniword()
{
    local $_;
    open IN, "<:utf8", "../../cbeta_gaiji/cbeta_gaiji.csv";
    <IN>;
    while(<IN>)
    {
        my @items = split(/\t/,$_);
        my $uni = $items[1];
        my $word = $items[2];
        my $nor_uni = $items[3];
        my $nor_word = $items[4];
        if($uni ne "" || $word ne "")
        {
            my $w = chr(hex($uni));
            if($w ne $word)
            {
                # uniword 不等於 uni 的轉換
                print $items[0] . " : uni != uniword\n";
            }
        }
        if($nor_uni ne "" || $nor_word ne "")
        {
            my $w = chr(hex($nor_uni));
            if($w ne $nor_word)
            {
                # uniword 不等於 uni 的轉換
                print $items[0] . " : nor_uni != nor_uniword\n";
            }
        }
    }
    close IN;
}
