# bulei_nav.xhtml 部類目錄導覽檔案 產生程式     by Heaven 2018/03/14
#
# 需要讀取 ../bulei/bulei.txt , 此為部類目錄架構
# 需要讀取 ../sutralist/sutralist.txt , 此為各經的基本資料

use utf8;
use strict;
use warnings;
use lib "../sutralist";
use SutraList;
use lib "../bulei";
use Bulei;

my $sutralist = SutraList->new;
my $bulei = Bulei->new;

$sutralist->initial("../sutralist/sutralist.txt");
$bulei->initial("../bulei/bulei.txt");

my $pre_level = 0;

# 這是用來判斷是否是第一組的 <li> ... </li> , 是的話就不要呈現 
my $IsFirstLi = 1;

open OUT, ">:utf8", "bulei_nav_gaiji.xhtml";
my $xhtml = "";
create_head();
create_body();
create_foot();
print OUT $xhtml;
close OUT;

#########################################
# 產生目錄結果
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

#########################################
# 產生目錄結果
sub create_body
{
    # 用變數比較好處理
    my $bulei_data = $bulei->data;
    my $bulei_level = $bulei->level;
    my $bulei_type = $bulei->type;
    my $bulei_link = $bulei->link;
    
    for(my $i=0; $i<=$#$bulei_data; $i++)
    {
        # 取得上一層和本層的關係
        my $gap = get_level_gap($pre_level, $bulei_level->[$i]);
        if($gap eq "")
        {
            print "資料行數 : $i\n";
            <>;
        }
        $xhtml .= $gap;

        # 印出本身
        
        if($bulei_type->[$i] eq "")
        {
            # 純標題
            $xhtml .= "<span>" . $bulei_data->[$i] . "</span>";
        }
        elsif($bulei_type->[$i] eq "L")
        {
            # 一般連結
            $xhtml .= "<a href=\"" . $bulei_link->[$i] . "\">" . $bulei_data->[$i] . "</a>";
        }
        elsif($bulei_type->[$i] eq "C")
        {
            # CBETA 經文
            my $sutraid = $bulei_data->[$i];
            my $index = $sutralist->index_by_id->{$sutraid}; 
            my $link = "";
            my $name = ""; 
            if(defined $index)
            {
                $link = $sutralist->link->[$index];
                $name = $sutralist->name->[$index];
                $link = "XML/" . $link;
            }
            $name =~ s/\(第.*?卷\)$//;  # 去除卷數
            $name =~ s/（上）$//;
            $name =~ s/（一）$// if($name !~ /華雨集（一）/); # 特例
            #$sutraid =~ s/^T0220a$/T0220/; # 部類的版本不取消 a
            $link =~ s/(T0[567]n0220)[a-z]/$1/; # 特例
            $xhtml .= "<cblink href=\"" . $link . "\">" . $sutraid . " " . $name . "</cblink>";
        }
        else
        {
            print "error type.";
            <>;
        }
        $pre_level = $bulei_level->[$i];
    }
}

###############################
# 印出檔尾
sub create_foot
{
    my $gap = get_level_gap($pre_level,1,"end");
    $xhtml .= $gap;
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