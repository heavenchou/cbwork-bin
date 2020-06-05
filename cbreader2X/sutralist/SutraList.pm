package SutraList;
use utf8;
use strict;
use warnings;

# 物件 Tiny 用法
# http://search.cpan.org/~dagolden/Class-Tiny-1.006/lib/Class/Tiny.pm

=begin

原始資料結構
藏,冊,經,卷,第一卷,頁欄行,經名,作譯者
T,01,0001,22,1,0001a01,長阿含經,後秦 佛陀耶舍共竺佛念譯

【SutraList 物件使用方法】

use lib "../sutralist";             # 指到 SutraList 物件的目錄
use SutraList;                      # 使用物件
my $sutralist = SutraList->new;     # 宣告
$sutralist->initial($file);         # 初始化, 要傳入 sutralist.txt 的位置

# 由 id 找尋 index
my $index = $sutralist->index_by_id->{"T0001"};

注意 : 找到 index 之後, 可能下一個依然是跨冊的同一經

# 由 index 找經名 (及其他所有欄位)
my $name = $sutralist->name->[$index]};

# 傳入 @keys 陣列位置, 傳入範圍, 則傳回符合範圍的 keys
# 範圍種類有底下五種
# T ; T01 ; T01,T02 ; T0001 ; T0001,T0005
$sutralist->get_keys(\@keys, "T")

=end
=cut

use Class::Tiny qw( index_by_id book volnum volid sutranum sutraid juan first_juan pageline name byline link);

my %index_hash = ();   # $index_hash{"T0001"} = 1;

my @books = ();         # 記錄 book 的陣列 # T
my @volnums = ();       # 冊 01
my @volids = ();        # 冊 T01
my @sutranums = ();     # 0001
my @sutraids = ();      # T0001
my @juans = ();         # 卷數
my @first_juans = ();   # 第一卷
my @pagelines = ();     # 頁欄行
my @names = ();         # 經名
my @bylines = ();       # 作譯者
my @links = ();         # 連結 XML/T/T01/T01n0001_001.xml

#########################################
# 初始化資料
sub initial
{
    my $self = shift;
    my $file = shift;
    local $_;

    print "SutraList Initialing ...\n";
    unless(defined $file)
    {
        print "Error : SutraList 要傳入 sutralist.txt 的位置\n";
        exit;
    }

    $self->index_by_id(\%index_hash);   # $index_hash{"T0001"} = 1;

    $self->book(\@books);       # 記錄 book 的陣列 # T
    $self->volnum(\@volnums);       # 冊 01
    $self->volid(\@volids);         # 冊 T01
    $self->sutranum(\@sutranums);     # 0001
    $self->sutraid(\@sutraids);      # T0001
    $self->juan(\@juans);           # 卷數
    $self->first_juan(\@first_juans);   # 第一卷
    $self->pageline(\@pagelines);     # 頁欄行
    $self->name(\@names);         # 經名
    $self->byline(\@bylines);       # 作譯者
    $self->link(\@links);         # 連結 XML/T/T01/T01n0001_001.xml

    my $i = 0;
    open IN, "<:utf8", $file;
    while(<IN>)
    {
        # 藏,冊,經,卷,第一卷,頁欄行,經名,作譯者
        # T,01,0001,22,1,0001a01,長阿含經,後秦 佛陀耶舍共竺佛念譯
        chomp;
        my @d = split(/,/,$_);
        if(not defined $d[7]) { $d[7] = "";}    # 若沒譯者, 會變成 undef
        my $key = $d[0] . $d[2];    # key = T0001
        my $volid = $d[0] . $d[1];    # T01
        
        my $juan = sprintf("%03d",$d[4]);   # 第一卷
        my $link = $d[0]."/".$d[0].$d[1]."/".$d[0].$d[1] ."n".$d[2]."_".$juan.".xml";
        
        if(not defined $self->index_by_id->{$key})
        {
            $self->index_by_id->{$key} = $i;
        }

        push(@books, $d[0]);         # 記錄 book 的陣列 # T
        push(@volnums, $d[1]);       # 冊 01
        push(@volids, $volid);        # 冊 T01
        push(@sutranums, $d[2]);     # 0001
        push(@sutraids, $key);      # T0001
        push(@juans, $d[3]);         # 卷數
        push(@first_juans, $juan);   # 第一卷
        push(@pagelines, $d[5]);     # 頁欄行
        push(@names, $d[6]);         # 經名
        push(@bylines, $d[7]);       # 作譯者
        push(@links, $link);         # 連結 T/T01/T01n0001_001.xml

        $i++;
    }
    close IN;
}

# 傳入範圍, 例如 T01,T02 or T0001,T0005, 傳回所有符合的 sutraid 
# 放在 keys 陣列中
# ex : $sutralist->get_keys(\@keys, $book_nav->data->[$i])
sub get_keys
{
    my $self = shift;
    my $keys = shift;
    my $range = shift;
    local $_;

    my $from = "";  # 範圍
    my $to = "";

    # range 的種類有
    # 1. T  全藏
    # 2. T01 全冊
    # 3. T01,T02 冊範圍
    # 4. T0001 單經
    # 5. T0001,T0005 經範圍

    if($range =~ /^([^,]+),?(.*)$/)
    {
        $from = $1;
        $to = $2;
    }

    if($to eq "")
    {
        if($from =~ /^\D+$/)
        {
            # T 全藏
            $self->get_keys_by_book($keys,$from);
        }
        elsif($from =~ /^[A-Z]+\d{2,3}$/ && $from !~ /^J[AB]\d{3}$/)
        {
            # T01 全冊
            $self->get_keys_by_vol($keys,$from);
        }
        elsif($from =~ /^[A-Z]+a?\d{3,4}.?$/)
        {
            # T0001 , JA001 , T0001a 全經
            $self->get_keys_by_sutra($keys,$from);
        }
    }
    else
    {
        if($from =~ /^\D+\d{2,3}$/ && $from !~ /^J[AB]\d{3}$/)
        {
            # T01,T02 冊範圍
            $self->get_keys_by_vols($keys,$from,$to);
        }
        elsif($from =~ /^\D+\d{3,4}.?$/)
        {
            # T0001,T0005 經範圍
            $self->get_keys_by_sutras($keys,$from,$to);
        }
    }
}

# 取出全藏的 sutraid T 全藏
sub get_keys_by_book
{
    my $self = shift;
    my $keys = shift;
    my $book = shift;

    for(my $i=0; $i<=$#books; $i++)
    {
        if($books[$i] eq $book)
        {
            push(@$keys,$sutraids[$i]);
        }
    }
}

# 取出全冊的 sutraid T01 全冊
sub get_keys_by_vol
{
    my $self = shift;
    my $keys = shift;
    my $vol = shift;

    for(my $i=0; $i<=$#volids; $i++)
    {
        if($volids[$i] eq $vol)
        {
            push(@$keys,$sutraids[$i]);
        }
    }
}

# 取出單經的 sutraid T0001
sub get_keys_by_sutra
{
    my $self = shift;
    my $keys = shift;
    my $sutra = shift;

    for(my $i=0; $i<=$#sutraids; $i++)
    {
        if($sutraids[$i] eq $sutra)
        {
            push(@$keys,$sutraids[$i]);
        }
    }
}

# 取出冊範圍的 sutraid T01,T02 冊
sub get_keys_by_vols
{
    my $self = shift;
    my $keys = shift;
    my $vol_from = shift;
    my $vol_to = shift;

    for(my $i=0; $i<=$#volids; $i++)
    {

        if($volids[$i] ge $vol_from && $volids[$i] le $vol_to)
        {
            push(@$keys,$sutraids[$i]);
        }
    }
}

# 取出經範圍的 sutraid T0001,T0005 經
sub get_keys_by_sutras
{
    my $self = shift;
    my $keys = shift;
    my $sutra_from = shift;
    my $sutra_to = shift;

    for(my $i=0; $i<=$#sutraids; $i++)
    {
        if($sutraids[$i] ge $sutra_from && $sutraids[$i] le $sutra_to)
        {
            push(@$keys,$sutraids[$i]);
        }
    }
}
1;