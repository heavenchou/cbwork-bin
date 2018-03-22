package BookNav;
use utf8;
use strict;
use warnings;

# 物件 Tiny 用法
# http://search.cpan.org/~dagolden/Class-Tiny-1.006/lib/Class/Tiny.pm

use Class::Tiny qw( data level type );

my @datas = ();     # 記錄每一行
my @levels = ();     # 要記錄 level
my @types = ();     # 記錄每一筆的 type , "L" 表示要進一步找出資料

#########################################
# 初始化資料
sub initial
{
    my $self = shift;
    my $file = shift;
    local $_;
    print "BookNav initialing...\n";
    if(not defined $file)
    {
        print "Error : BookNav 要傳入book_nav.txt 的位置\n";
        exit;
    }

    $self->data(\@datas);
    $self->level(\@levels);
    $self->type(\@types);
    
    open IN, "<:utf8", $file;
    @datas = <IN>;
    close IN;

    # 大正新脩大藏經					
	#   T 大正新脩大藏經 (T01-55 & T85)				
	# 	    阿含部			
	# 		    T01,T02	
    #
    # 記錄成
    #
    # 1,大正新脩大藏經					
	# 2,T 大正新脩大藏經 (T01-55 & T85)				
	# 3,阿含部			
	# 4,T01,T02
    #
    # 如果沒有下一層, 則此層 type 就是 "L" , 要在 sutralist 找出全部資料
    # 也就是要列出 T01~T02 之間的內容

    # 先把 level 取出來, 只留下資料

    for(my $i=0; $i<=$#datas; $i++)
    {
        my $level = 1;  # 預設就要是 1
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

    # 如果沒有子層, 則本層只留下經號
    for(my $i=0; $i<=$#datas; $i++)
    {
        $types[$i] = "";    # 初值化
        if($i == $#datas || $levels[$i] > $levels[$i+1])
        {
            $types[$i] = "L";   # 表示這一筆要進一步找出 SutraList 中的資料
        }
        elsif($levels[$i] == $levels[$i+1])
        {
            print "error , 不應該出現同一層的結構 : 行數 : $i\n";
            <>;
        }
    }
}
1;