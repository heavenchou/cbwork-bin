# checkxml.pl
# 檢查 XML 檔
#
# 使用方法:
#       單冊 checkxml.pl t01
#       全部 checkxml.pl
#
# Log:
# 括號跨行 2005/11/28 10:28 by Ray
# v 0.01, 2003/3/11 02:19PM by Ray
# v 0.2.0, 檢查缺字圖檔是否存在, 2003/6/9 01:43下午 by Ray
# v 0.3.1, 把參數放到 config.pl, 2003/12/3 02:40下午 by Ray
# v 0.4.1, 來查悉曇字圖檔是否存在, 2003/12/30 01:32下午 by Ray
# v 0.5.1, 略過 <!--\n .... -->\n 之間的東西不檢查, 2004/1/2 04:32下午 by Ray
# v 0.6.1, 檢查不對稱括號, 2004/2/19 12:00下午 by Ray
# v 0.7.1, 檢查組字式(應該轉成entity), 2004/6/2 09:42上午 by Ray
# v 0.7.2, 2004/6/3 03:04下午 by Ray
# v 0.8.1, 2004/6/7 03:07下午 by Ray
# v 0.9.1, 2004/6/8 08:44上午 by Ray

use utf8;
use Encode;
require "config.pl";

print STDERR u82b5("輸出記錄檔: $log_file\n");
print STDERR u82b5("來源 XML 檔目錄:$xml_in_dir\n");
print STDERR u82b5("缺字圖檔目錄: $gaiji_cb_in_dir\n");
print STDERR u82b5("悉曇字圖檔目錄: $sd_gif_in_dir\n");
print STDERR u82b5("蘭札字圖檔目錄: $rj_gif_in_dir\n");
print STDERR u82b5("內文附圖圖檔目錄: $figure_in_dir\n");

$vol=shift;

if ($vol ne '') { print STDERR "vol=$vol\n"; }

open O, ">:utf8", $log_file or die;
select O;

%figures = ();
%gaijis = ();

if ($vol eq '') {
        $all = 1;
        read_figures("$figure_in_dir/B");
        read_figures("$figure_in_dir/C");
        read_figures("$figure_in_dir/D");
        read_figures("$figure_in_dir/F");
        read_figures("$figure_in_dir/GA");
        read_figures("$figure_in_dir/H");
        read_figures("$figure_in_dir/I");
        read_figures("$figure_in_dir/J");
        read_figures("$figure_in_dir/K");
        read_figures("$figure_in_dir/L");
        read_figures("$figure_in_dir/P");
        read_figures("$figure_in_dir/T");
        read_figures("$figure_in_dir/W");
        read_figures("$figure_in_dir/X");
        read_gaijis($gaiji_cb_in_dir);
        read_gaijis($sd_gif_in_dir);
        read_gaijis($rj_gif_in_dir);
        opendir DIR, "$xml_in_dir" or die "open $xml_in_dir error $!";
        @alldir = grep /^[A-Z]/, readdir DIR;
        
        closedir(DIR);
        foreach $vol (@alldir) 
        {
        	if( -d "$xml_in_dir/$vol")
        	{
				do_vol("$xml_in_dir/$vol");
			}
        }
} else {
        $all = 0;
        $vol=uc($vol);
        my $vol2 = $vol;
        $vol2 =~ s/\d//g;
        do_vol2("$xml_in_dir/$vol2/$vol");
}
closedir DIR;

if ($all) 
{
    foreach  $k (sort keys %figures) 
    {
    	if($figures{$k} != 1)
    	{
			print "圖檔沒用到: $k\n";
		}
    }
    foreach  $k (sort keys %gaijis) 
    {
    	if($gaijis{$k} != 1)
    	{
            print "缺字圖檔沒用到: [$k]\n";
        }
    }
}
close O;

sub do_vol {
	my $vol = shift;
    opendir DIR2, "$vol" or die "open $vol error $!";
    my @alldir = grep /^[A-Z]/, readdir DIR2;
    
    closedir(DIR);
            
    foreach $vol2 (@alldir) 
    {
    	if( -d "$vol/$vol2")
    	{
			do_vol2("$vol/$vol2");
		}
    }
}

sub do_vol2 {
	my $vol = shift;
    opendir (INDIR, "$vol") or die "open $vol error $!";
    my @allfiles = grep(/\.xml$/i, readdir(INDIR));
    closedir(INDIR);
    foreach $f (@allfiles) {
            do1file("$vol/$f");
    }
}

sub do1file {
        local $file=shift;	# 不可用 my 宣告, 副程式會用到
        print STDERR "$file\n";
        open I, "<:utf8" , "$file" or die;
        my $in_remark=0;
        $body=0;
        $old_brace1=0;
        $old_brace2=0;
        @braces = ();
        while(<I>) {
                $t=$_;
                if ($in_remark) {
                        if (/^\-\->\n$/) {
                                $in_remark=0;
                        }
                        next;
                }
                if (/^<!\-\-\n$/) {
                        $in_remark=1;
                } elsif (/(<[^>]*?)\n/) {
                        $s=$1;
                        if ($t!~/^<!/) {
                                print "Tag 跨行\n";
                                print "$file $t\n";
                        }
                }
                $line=$t;
                $brace1=0;
                $brace2=0;
                #$t=~s/(&CB.*?;|&SD.*?;|<figure.*?>)/&rep($1)/eg;
                if ($t=~/<body/) {
                        $body=1;
                }
                # 檢查轉寫字是否都已轉 entity
                if ($body) { 
                        $temp = $t;
                        $temp =~ s/<[^>]+?>/ /g; # 去掉標記
                        #$temp =~ s/[\x80-\xff][\x00-\xff]/ /g; # 去掉中文
                        $temp =~ s/&.*?;/ /g;
                        $temp =~ s/\d+\./ /g;
                        $temp =~ s/V?I{2,3}\.?/ /g;
                        if ($temp =~ /^(.*)(\`s|aa|ii|uu|\.[dhlmnrst]|\^[amn]|\~n)/i) {
                                $temp1 = $1;
                                print "轉寫 $2 未轉 entity: $file\n";
                                print " $t \n";
                        }
                }
                $t=~s#(&CB.*?;|&CI.*?;|&SD.*?;|&RJ.*?;|\[([^a-zA-Z0-9]|\+|\-|\*|\/|\@|\?|\(|\)){2,}\]|<graphic.*?>|<g .*?>|<p[^>]*?></p>|<p.*?>|［|］|（|）)#&rep($1)#eg;
        }
        close I;
}

sub rep{
        my $s=shift;
        my $cb;
        if ($s=~/&(.*?);/) {
                $cb=$1;
        }
        if ($cb=~/^CB|CI|SD|RJ/) {
                print "不應該有 \&${cb}\; \n";
                print "$file\n$t\n";
        } elsif ($s=~/\[([^a-zA-Z0-9]|\+|\-|\*|\/|\@|\?|\(|\))+\]/)
        {
            if ($body == 1)
            { 
            	if($s =~ /\+|\-|\*|\/|\@|\?/)	# 至少有一個連結符號 才是組字式
            	{
                    print "含組字式 $s\n";
                    print "$file\n$t\n";
                }
            }
        } elsif ($s=~/^<g /){
                if($s=~/ref="#(CB.*?)"/)
                {
                	my $ent=$1;
                	check_cb($ent);
                }
                elsif($s=~/ref="#(SD.*?)"/)
                {
                	my $ent=$1;
                	check_sd($ent);
                }
                elsif($s=~/ref="#(RJ.*?)"/)
                {
                	my $ent=$1;
                	check_rj($ent);
                }
        } elsif ($s=~/^<graphic/){
                $s=~/url=".*?figures\/(.+?)\/(.*?)\.gif"/;
                my $ent=$2;
                my $s1=$1;
                my $path="$figure_in_dir/$s1/$ent.gif";
                if (not -e $path) {
                        print "內文附圖圖檔不存在: $path \n";
                        print "$file\n$t\n";
                }
                 $figures{$ent} = 1;
        } elsif ($s=~/^<p[^>]*?><\/p>/){
                if ($s=~/^<pb/) {                       
                        print "</p>應該移到上一行\n";
                } else {
                        print "空的段落\n";
                }
                print "$file\n$t\n";
        #} elsif ($body and $s=~/^<p(.*?)>/){
        #       my $s=$1;
        #       if ($s !~ /id=/) {
        #               print "<p> 少了 id 屬性\n";
        #               print "$file $t\n";
        #       }
        } elsif ($s =~ /［|］|（|）/) {
                $i = scalar @braces;
                if ($i==0) {
                        if ($s eq "〕" or $s eq "）") {
                                brace_err();
                        } elsif ($s eq "〔" or $s eq "（") {
                                push @braces, $s;
                        }
                } else {
                        if ($s eq "〔" or $s eq "（") {
                                push @braces, $s;
                        } elsif ($s eq "〕") {
                                if ($braces[$i-1] eq "〔") {
                                        pop @braces;
                                } else {
                                        brace_err();
                                }
                        } elsif ($s eq "）") {
                                if ($braces[$i-1] eq "（") {
                                        pop @braces;
                                } else {
                                        brace_err();
                                }
                        }
                }
        }
        return $s;
}

sub brace_err {
        print "$file 括號不對稱 $line\n";
}

sub read_figures {
        $path = shift;
        opendir DIR, $path or die "cannot open dir $path\n";
        @alldir = grep /\.gif$/, readdir DIR;
        closedir(DIR);
        foreach $s (@alldir) {
                $s =~ /^(.*)\.gif$/;
                $figures{$1} = 0;
        }
}

sub read_gaijis {
        $path = shift;
        opendir DIR, $path or die "open $path error";
        @alldir = grep !/^\.\.?$/, readdir DIR;
        closedir(DIR);

        foreach $d (@alldir) {
                opendir DIR, "$path/$d" or die "open $path/$d error";
                @allfile = grep !/^\.\.?$/, readdir DIR;
                foreach $s (@allfile) {
                        if ($s !~ /\.gif$/i) {
                                print "缺字圖檔不是 GIF 檔: $s\n";
                                next;
                        }
                        $s =~ /^(.*)\.gif$/i;
                        $gaijis{$1} = 0;
                }
        }
}

sub check_ci() {
        my $s=shift;
        if ($s eq "CI0001") { check_cb("CB00269"); }
        elsif ($s eq "CI0002") { check_cb("CB00277"); }
        elsif ($s eq "CI0003") { check_cb("CB00662"); }
        elsif ($s eq "CI0004") { check_cb("CB00566"); }
        elsif ($s eq "CI0005") { check_cb("CB00247"); }
        elsif ($s eq "CI0006") { check_cb("CB00662"); }
        elsif ($s eq "CI0007") { check_cb("CB13514"); }
        elsif ($s eq "CI0009") { check_cb("CB04612"); check_cb("CB00269"); }
        elsif ($s eq "CI0010") { check_cb("CB04712"); }
        elsif ($s eq "CI0011") { check_cb("CB04608"); check_cb("CB00224"); }
        elsif ($s eq "CI0012") { check_cb("CB05088"); check_cb("CB05087"); }
        elsif ($s eq "CI0013") { check_cb("CB00662"); }
        elsif ($s eq "CI0014") { check_cb("CB13566"); check_cb("CB00300"); }
        elsif ($s eq "CI0015") { check_cb("CB04712"); }
}

sub check_cb {
        my $cb = shift;
        my $s1=substr($cb,2,2);
        if($gaijis{$cb} != 1)
        {
	        if (not -e "$gaiji_cb_in_dir/$s1/$cb.gif") 
	        {
	                print "缺字 $cb 圖檔不存在\n";
	                print "$file $t\n";
	        }
	        $gaijis{$cb} = 1;
	    }
}

sub check_sd {
        my $cb = shift;
        my $s1=substr($cb,3,2);
        if($gaijis{$cb} != 1)
        {
	        if (not -e "$sd_gif_in_dir/$s1/$cb.gif") 
	        {
	                print "悉曇字 $cb 圖檔不存在\n";
	                print "$file $t\n";
	        }
	        $gaijis{$cb} = 1;
	    }
}

sub check_rj {
        my $cb = shift;
        my $s1=substr($cb,3,2);
        if($gaijis{$cb} != 1)
        {
	        if (not -e "$rj_gif_in_dir/$s1/$cb.gif") {
	                print "蘭札字 $cb 圖檔不存在\n";
	                print "$file $t\n";
	        }
	        $gaijis{$cb} = 1;
	    }
}

sub u82b5 
{
	local $_ = shift;
	return Encode::encode("big5","$_");
}