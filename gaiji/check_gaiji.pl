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

