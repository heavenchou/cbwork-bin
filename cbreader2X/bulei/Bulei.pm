package Bulei;
use utf8;
use strict;
use warnings;

# 物件 Tiny 用法
# http://search.cpan.org/~dagolden/Class-Tiny-1.006/lib/Class/Tiny.pm

=begin

【Bulei 物件使用方法】

部類格式大概有這些種類 :

01 阿含部類              => level = 1, data = "01 阿含部類", type = "", link = ""
    T0001-25 長阿含經    => level = 2, data = "T0001-25 長阿含經", type = "", link = ""
        T0002 七佛經1卷  => level = 3, data = "T0002", type = "C", link = "" 
        readme.htm 說明 => level = 3, data = "說明", type = "L", link = "readme.htm" 

use lib "../bulei";             # 指到 SutraList 物件的目錄
use Bulei;                      # 使用物件
my $bulei = Bulei->new;         # 宣告
$bulei->initial($file);         # 初始化, 要傳入 bulei.txt 的位置

my $bulei_id = $bulei->buleiid_by_sutraid->{"T0001"};  # 傳回 0
my $bulei_name = $bulei->bulei_name->[$bulei_id];   # 傳回 "阿含部類"

my $bulei_name = $bulei->bulei_name_by_sutraid("T0001");   # 傳回 "阿含部類"

=end
=cut

use Class::Tiny qw( buleiid_by_sutraid bulei_name level data type link );

my %bulei_hash = ();    # 記錄由 T0001 查到 "阿含部類"
my @bulei_names = ();    # 記錄每一個部類的名字, 例 : $bulei_name[0]= "阿含部類";
my @datas = ();     # 記錄每一行
my @levels = ();     # 要記錄 level
my @types = ();     # 記錄每一筆的 type , 若為 "C", 則表示有CB連結, "L" 表示一般連結
my @links = ();       # 連結 , 內容可能是 CBETA 經文或 HTML 或其他

#########################################
# 初始化資料
sub initial
{
    my $self = shift;
    my $file = shift;
    local $_;

    print "Bulei Initialing ...\n";
    if(not defined $file)
    {
        print "Error : Bulei 要傳入 bulei.txt 的位置\n";
        exit;
    }
    $self->buleiid_by_sutraid(\%bulei_hash);
    $self->bulei_name(\@bulei_names);
    $self->level(\@levels);
    $self->data(\@datas);
    $self->type(\@types);
    $self->link(\@links);
    
    open IN, "<:utf8", $file;
    @datas = <IN>;

    # 01 阿含部類 T01-02,25,33 etc.
    #   T0001-25 長阿含經 etc. T01
    #       T0002 七佛經1卷	
    #
    # 記錄成
    #
    # 1,阿含部類 T01-02,25,33 etc
    # 2,T0001-25 長阿含經 etc. T01
    # 3,T0002
    #
    # 如果沒有下一層, 則此層只留下經號

    # 先把 level 取出來, 只留下資料

    for(my $i=0; $i<=$#datas; $i++)
    {
        my $level = 1;
        $_ = $datas[$i];
        chomp;
        $_ =~ s/\s*$//;
        while(/^\t/)
        {
            $level += 1;
            s/^\t//;
        }
        push(@levels,$level);
        $datas[$i] = $_;
    }

    # 進一步處理 data, type, link 及記錄部類
    # 如果沒有子層, 則本層只留下經號
    my $bulei_id = -1;

    for(my $i=0; $i<=$#datas; $i++)
    {
        # 先判斷是否有換部類
        if($levels[$i] == 1)
        {
            $bulei_id = $self->get_bulei_id_and_name($datas[$i]);
        }

        if($i == $#datas || $levels[$i] >= $levels[$i+1])
        {
            # T0001 , T0001a
            if($datas[$i] =~ /^([A-Z]+a?\d+[A-Za-z]?)\s/) 
            {
                $datas[$i] = $1;
                $types[$i] = "C";   # 表示這一筆是 CBETA 經文
                $links[$i] = "";
                # 部類名會重複, 以第一筆為主
                if(not defined($bulei_hash{$datas[$i]}))
                {
                    $bulei_hash{$datas[$i]} = $bulei_id;    # $bulei_hash{"T0001"} = 0
                }
            }
            # xxx.html , xxx.htm
            elsif($datas[$i] =~ /^(\S+\.html?)[ \t]+(.*)$/i) # [ \t]+ 不能用 \s+ 因為可能有全型空格
            {
                $links[$i] = $1;
                $datas[$i] = $2;
                $types[$i] = "L";   # 表示這一筆是一般連結
            }
            else
            {
                $types[$i] = "";
                $links[$i] = "";
                print "error format " . $datas[$i] . "\n";
                <>;
            }
        }
        else
        {
            # 這是上層目錄, 底下是資料初始化
            $types[$i] = "";
            $links[$i] = "";
        }
    }
}

# 由傳入的字串 "01 阿含部類 xxxx"
# 記錄 $bulei_names[0] = "阿含部類";
sub get_bulei_id_and_name
{
    my $self = shift;
    local $_ = shift;

    # 記錄部類資料
    my $index = "";
    my $name = "";

    if(/^(\d+)\s+(\S+部類)\s/)
    {
        $index = $1 - 1;
        $name = $2;
        $bulei_names[$index] = $name;
    }
    else
    {
        print "error : 部類名稱不合規定, 應為 nn xxxx部類 $_ \n";
        <>;
        exit;
    }
    return $index;
}

# $bulei_name = $bulei->bulei_name_by_sutraid("T0001");   # 傳回 "阿含部類"
sub bulei_name_by_sutraid
{
    my $self = shift;
    my $sutra_id = shift;

    my $bulei_id = $self->buleiid_by_sutraid->{$sutra_id};
    if(not defined $bulei_id)
    {
        return "";  # 無此 id , 傳回空字串
    }
    my $bulei_name = $self->bulei_name->[$bulei_id];
    return $bulei_name;
}

1;