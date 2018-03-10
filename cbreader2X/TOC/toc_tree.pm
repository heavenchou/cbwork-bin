use utf8;
package toc_tree;

# 物件 Tiny 用法
# http://search.cpan.org/~dagolden/Class-Tiny-1.006/lib/Class/Tiny.pm

# 資料用外部的 @::mulu_tree , 裡面每一筆有 層次, 內容, 連結位置 , 例 :
# 1,第一分,T01n0001_001.xml#p0001a01
# 2,第一誦,T01n0001_001.xml#p0002a02
#
# 另一個是卷 @::juan_tree , 裡面每一筆有 卷數, 連結位置 , 例 :
# 1,T01n0001_001.xml#p0001a01
# 2,T01n0001_002.xml#p0010a01

use Class::Tiny qw( book volnum sutra juan lb outpath errmsg);

#########################################
# 初始化資料
sub initial
{
    my $self = shift;

    @::mulu_tree = ();
    @::juan_tree = ();

    $self->book("");
    $self->volnum("");
    $self->sutra("");
    $self->juan("");
    $self->lb("");
}

#########################################
# 取得連結 : XML/T/T01/T01n0001_001.xml#p0001a01
sub get_link
{
    my $self = shift;

    my $link = "XML/" . $self->book . "/" . $self->book . $self->volnum . "/";
    $link .= $self->book . $self->volnum . "n" .  $self->sutra . "_";
    $link .= sprintf("%03d", $self->juan);
    $link .= ".xml#p" . $self->lb;

    return $link;
}

#########################################
# 產生結果
sub output
{
    my $self = shift;
    my $file = $self->outpath . "/" . $self->book;
    mkdir($file);
    $file .= "/" .   $self->book . $self->sutra . ".xml";
    open OUT, ">:utf8", $file;

    $self->output_head();   # 印出前面
    $self->output_mulu();   # 印出目錄
    $self->output_jaun();   # 印出卷目錄
    close OUT;

    $self->initial();
}

#########################################
# 產生目錄結果
sub output_head
{
    my $self = shift;
    print OUT "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<html>
	<head>
		<meta charset=\"UTF-8\" />
		<title>本經目次</title>
	</head>
<body>
";
}

#########################################
# 產生目錄結果
sub output_mulu
{
    my $self = shift;

    if($#::mulu_tree < 0)
    {
        return; # 沒有任何目錄標記, 離開吧
    }

    my @level = ();
    my @text = ();
    my @link = ();

    # 先分析資料
    for(my $i=0; $i<=$#::mulu_tree; $i++)
    {
        my $data = $::mulu_tree[$i];
        $data =~ /^(.*?),(.*?),(.*)$/;
        $level[$i] = $1;
        $text[$i] = $2;
        $link[$i] = $3;
    }
    print OUT "<nav type=\"catalog\">\n";
    print OUT "<h1>目錄</h1>\n";
    # 輸出

    my $pre_level = 0;
    for(my $i=0; $i<=$#level; $i++)
    {
        # 如果我是上一筆的子層, 要先印出 <ol>
        # 如果我是上一筆的母層, 要結束上一筆的結構
        if($level[$i] == $pre_level + 1)
        {
            # 我是上一筆的子層, 要先印出 <ol>
            print OUT "\t" x $pre_level;    # <ol> 前的空白
            print OUT "<ol>\n";
        }
        elsif($level[$i] < $pre_level)
        {
            # 我是上一筆的母層, 要結束上一筆的結構
            for(my $j=$pre_level-1; $j>=$level[$i]; $j--)
            {
                print OUT "\t" x $j;
                print OUT "</ol>\n";
                print OUT "\t" x $j;
                print OUT "</li>\n";
            }
        }
        elsif($level[$i] > $pre_level + 1)
        {
            $self->errmsg .= $self->book . $self->volnum . "n" . $self->sutra . "\n";
            $self->errmsg .= "error 目錄跳太多層 : " . $::mulu_tree[$i] . "\n\n";
        }

        # 印出本身

        print OUT "\t" x $level[$i];
        print OUT "<li><cblink href=\"" . $link[$i] . "\">" . $text[$i] . "</cblink>";

        # 判斷下一筆是不是子層, 若是就不用印 </li>

        if($i == $#level || $level[$i] >= $level[$i+1])
        {
            print OUT "</li>";
        }
        print OUT "\n";
        
        $pre_level = $level[$i];
    }

    # 最後一筆若是子層, 還要還原到最上一層
    if($pre_level > 1)
    {
        for(my $i=$pre_level-1; $i>=1; $i--)
        {
            print OUT "\t" x $i;
            print OUT "</ol>\n";
            print OUT "\t" x $i;
            print OUT "</li>\n";            
        }
    }
    print OUT "</ol>\n";
    print OUT "</nav>\n";
}

#########################################
# 產生卷數結果
sub output_jaun
{
    my $self = shift;

    if($#::juan_tree < 0)
    {
        $self->errmsg .= $self->book . $self->volnum . "n" . $self->sutra . "\n";
        $self->errmsg .= "error , 沒有卷目錄\n";
        return; # 沒有任何目錄標記, 離開吧
    }

    my @text = ();
    my @link = ();

    # 先分析資料
    for(my $i=0; $i<=$#::juan_tree; $i++)
    {
        my $data = $::juan_tree[$i];
        $data =~ /^(.*?),(.*)$/;
        $text[$i] = $1;
        $link[$i] = $2;
    }
    print OUT "<nav type=\"juan\">\n";
    print OUT "<h1>卷</h1>\n";
    print OUT "<ol>\n";
    # 輸出

    for(my $i=0; $i<=$#text; $i++)
    {
        # 印出本身
        print OUT "\t<li><cblink href=\"" . $link[$i] . "\">第" . cNum($text[$i]) . "</cblink></li>\n";
    }

    print OUT "</ol>\n";
    print OUT "</nav>\n";
}
#######################
# 數字換成國字
sub cNum {
	my $num = shift;
	my $i, $str;
	my @char=("","一","二","三","四","五","六","七","八","九");

	$i = int($num/100);
	$str = $char[$i];
	if ($i != 0) { $str .= "百"; }
	
	$num = $num % 100;
	$i = int($num/10);
	if ($i==0) {
		if ($str ne "" and $num != 0) { $str .= "零"; }
	} else {
		if ($i ==1) {
			if ($str eq "") {
				$str = "十";
			} else {
				$str .= "一十";
 			}
		} else {
 		  $str .= $char[$i] . "十";
 		}
 	}
	
 	$i = $num % 10;
 	$str .= $char[$i];
 	return $str;
}
1;

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