# 由 sutralist.txt 和 book_nav.txt 產生 book_nav.xhtml 原書目錄  by heaven 2018/03/17

use utf8;
use strict;
use warnings;
use lib "../sutralist";
use SutraList;
use lib ".";
use BookNav;   # 原書結構樹狀目錄

my $infile = shift;     # 來源檔, 特別注意西蓮版是 seeland_nav.txt
my $outfile = $infile;  # 輸出檔

if($infile eq "")
{
    print "perl create_book_nav.pl xxx.txt\n";
    exit;
}
$outfile =~ s/\.txt/_gaiji.xhtml/;

my $sutralist = SutraList->new;
my $book_nav = BookNav->new;

# 判斷是不是西蓮專案
if($infile eq "seeland_nav.txt") {
    $sutralist->initial("../sutralist/sutralist_see.txt");
} else {
    $sutralist->initial("../sutralist/sutralist.txt");
}

$book_nav->initial($infile);

my $pre_level = 0;

# 這是用來判斷是否是第一組的 <li> ... </li> , 是的話就不要呈現 
my $IsFirstLi = 1;

open OUT, ">:utf8", $outfile;
my $xhtml = "";
create_head();
create_body();
create_foot();
print OUT $xhtml;
close OUT;

###############################
# 印出檔頭
sub create_head
{
    $xhtml .= "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<html>
	<head>
		<meta charset=\"UTF-8\" />
		<title>目次</title>
	</head>
<body>
<nav type=\"catalog\">
";
}

# 印出中間的身體
sub create_body
{
    for(my $i=0; $i<=$#{$book_nav->data}; $i++)
    {
        # 取得上一層和本層的關係
        my $gap = get_level_gap($pre_level, $book_nav->level->[$i]);
        if($gap eq "")
        {
            print "資料行數 : $i\n";
            <>;
        }
        $xhtml .= $gap;

        # 印出本身

        if($book_nav->type->[$i] eq "")
        {
            # 純標題
            $xhtml .= "<span>" . $book_nav->data->[$i] . "</span>";
        }
        elsif($book_nav->type->[$i] eq "L")
        {
            # 網頁連結
            # XXX.htm 說明檔
            if($book_nav->data->[$i] =~ /^(.+\.[0-9A-Za-z]+) +(.+)$/i)    # 空格不可以用 \s , 因為有全型空格會在文字中
            {
                my $link = $1;
                my $name = $2;
                $xhtml .= "<a href=\"" . $link . "\">" . $name . "</a>";
            }
            else
            {
                # 經文連結
                # 有一種是有經名的, 要移除
                # T0001 長阿含 => T0001
                if($book_nav->data->[$i] =~ /^(\S+)\s/)
                {
                    $book_nav->data->[$i] = $1;
                }

                my @keys = ();
                # 傳入範圍, 例如 T01,T02 or T0001,T0005, 傳回所有符合的 sutraid 
                # 放在 keys 陣列中
                $sutralist->get_keys(\@keys, $book_nav->data->[$i]);
                
                if($#keys < 0)
                {
                    print "error " . $book_nav->data->[$i] . " 沒傳回範圍";
                    <>;
                }
                
                # @keys 可能會有重複的 (跨冊經文), 要過濾掉
                unique_list(\@keys);

                for(my $k=0; $k<=$#keys; $k++)
                {
                    my $key = $keys[$k];
                    my $index = $sutralist->index_by_id->{$key};
                    my $link = $sutralist->link->[$index];
                    my $name = $sutralist->name->[$index];
                    $name =~ s/\(第.*?卷\)$//;  # 去除卷數
                    $name =~ s/（上）$// if($name !~ /紀念集（上）/); # ZY47 特例
                    $name =~ s/（一）$// if($name !~ /華雨集（一）/); # 特例
                    $key =~ s/^T0220a$/T0220/; # 特例 
                    $link =~ s/T05n0220a_001/T05n0220_001/; # 特例
                    $link = "XML/" . $link;
                    $xhtml .= "<cblink href=\"" . $link . "\">" . $key . " " . $name . "</cblink>";
                
                    if($k != $#keys)
                    {
                        $xhtml .= "</li>\n";
                        $xhtml .= "\t" x $book_nav->level->[$i];
                        $xhtml .= "<li>";
                    }
                }
            }
        }
        else
        {
            print "error type.";
            <>;
        }
        $pre_level = $book_nav->level->[$i];
    }
}

###############################
# 印出檔尾
sub create_foot
{
    my $gap = get_level_gap($pre_level,1,"end");
    $xhtml .= $gap;
    #$xhtml .= "</ol>\n";
    $xhtml .= "</nav>\n";
    $xhtml .= "</body>\n";
    $xhtml .= "</html>\n";
}

###############################
# 印出上一層和本層的關係
# 傳入上一層, 本層, 還有是否是最後結尾
# 第一層就表示要有一層的 tab
sub get_level_gap
{
    my $pre = shift;    # 上一層的層次
    my $this = shift;   # 本層的層次
    my $last = shift;   # 有傳入表示是最後了
    my $text = "";

    if(not defined $last)
    {
        $last = "";
    }

    # 如果我是上一筆的子層, 要先印出 <ol>
    # 如果我是上一筆的母層, 要結束上一筆的結構
    if($this == $pre + 1)
    {
        if($this != 1 || $IsFirstLi == 0)   # 只有第一組的 li 不用印
        {
            # 我是上一筆的子層, 要先印出 <ol>
            $text .= "\n" . "\t" x $pre;     # <ol> 前的空白
            $text .= "<ol>\n";
            $text .= "\t" x $this;    # <li> 前的空白
            $text .= "<li>";
        }
        else
        {
            $text .= "\t" x $this;    # <li> 前的空白
        }
    }
    elsif($this < $pre)
    {
        # 我是上一筆的母層, 要結束上一筆的結構
        $text .= "</li>\n";
        for(my $i=$pre-1; $i>=$this; $i--)
        {
            $text .= "\t" x $i;
            $text .= "</ol>\n";
            if($i != 1 || $IsFirstLi == 0)   # 只有第一組 li 不用印
            {
                $text .= "\t" x $i;
                $text .= "</li>\n";
            }
            if($i == 1 && $IsFirstLi > 0) 
            {
                $IsFirstLi = 0; # 第一組結束了
            }
        }
        # 最後就不用印 <li>
        if($last eq "")
        {
            $text .= "\t" x $this;
            $text .= "<li>";
        }
    }
    elsif($this == $pre)
    {
        # 同一層
        $text .= "</li>\n"; # 先結束上一層
        # 最後就不用印 <li>
        if($last eq "")
        {
            $text .= "\t" x $this;
            $text .= "<li>";
        }
    }
    elsif($this > $pre + 1)
    {
        print "error 目錄跳太多層\n";
    }
    return $text;
}

# 將陣列的資料變成唯一, 去掉重複的
sub unique_list
{
    my $array = shift;
    my @tmp = ();
    my $pre = "";

    for(my $i=0; $i<=$#{$array}; $i++)
    {
        # 大般若經要過濾掉
        if($array->[$i] ne $pre &&  $array->[$i] !~ /T0220[b-z]/)
        {
            push(@tmp, $array->[$i]);
            $pre = $array->[$i];
        }
    }

    @$array = ();

    for(my $i=0; $i<=$#tmp; $i++)
    {
        push(@$array, $tmp[$i]);
    }
}

# 範本
=begin
<?xml version="1.0" encoding="utf-8"?>
<html>
	<head>
		<meta charset="UTF-8" />
		<title>目次</title>
	</head>
<body>
<nav type="catalog">
<h1>本經目錄</h1>
<ol>
 	<li><span>大正藏 T01</span>
 	<ol>
		<li><cblink href="XML/T/T01/T01n0001_001.xml">長阿含經</cblink></li>
		<li><cblink href="XML/T/T01/T01n0026_001.xml">中阿含經</cblink>
        <ol>
            <li><cblink href="XML/T/T02/T02n0099_001.xml">雜阿含經</cblink></li>
        </ol>
        </li>
 	</ol>
 	</li> 
 	<li><span>大正藏 T02</span>
 	<ol>
		<li><cblink href="XML/T/T02/T02n0099_001.xml">雜阿含經</cblink></li>
		<li><cblink href="XML/T/T02/T02n0125_001.xml">增壹阿含經</cblink></li>
 	</ol>
	</li> 
</ol>
</nav>
</body>
</html>
=end
=cut