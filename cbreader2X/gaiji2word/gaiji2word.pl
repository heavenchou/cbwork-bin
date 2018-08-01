# 把有 <g> 標記換成 unicode 或組字式

use utf8;
#use warnings;
use strict;
use lib "/cbwork/bin";
use CBETA;


# 參數

my $argv = shift;   # 參數有二種 nav , slreader_nav 則處理目錄, catlog,slreader_catlog 則處理 catlog

my $infile = "";
my $outfile = "";
my $gaiji = new Gaiji();
$gaiji->load_access_db();

if($argv eq "nav")
{
    $infile = "/cbwork/bin/cbreader2x/nav/simple_nav_gaiji.xhtml";
    $outfile = "/cbwork/bin/cbreader2x/nav/simple_nav.xhtml"; 
    runfile();
    $infile = "/cbwork/bin/cbreader2x/nav/advance_nav_gaiji.xhtml";
    $outfile = "/cbwork/bin/cbreader2x/nav/advance_nav.xhtml"; 
    runfile();
    $infile = "/cbwork/bin/cbreader2x/nav/bulei_nav_gaiji.xhtml";
    $outfile = "/cbwork/bin/cbreader2x/nav/bulei_nav.xhtml"; 
    runfile();
}
elsif($argv eq "slreader_nav")
{
    $infile = "/cbwork/bin/cbreader2x/nav/slreader_nav_gaiji.xhtml";
    $outfile = "/cbwork/bin/cbreader2x/nav/slreader_nav.xhtml"; 
    runfile();
}
elsif($argv eq "catalog")
{
    $infile = "/cbwork/bin/cbreader2x/catalog/catalog_gaiji.txt";
    $outfile = "/cbwork/bin/cbreader2x/catalog/catalog.txt"; 
    runfile();
}
elsif($argv eq "slreader_catalog")
{
    $infile = "/cbwork/bin/cbreader2x/catalog/slreader_catalog_gaiji.txt";
    $outfile = "/cbwork/bin/cbreader2x/catalog/slreader_catalog.txt"; 
    runfile();
}

sub runfile
{
    local $_;

    open IN, "<:utf8", $infile;
    open OUT, ">:utf8", $outfile;
    while(<IN>)
    {
        if(/<g/)
        {
            $_ = change_gaiji($_);
        }
        print OUT $_;
    }
    close OUT;
    close IN;
}
sub change_gaiji
{
    local $_ = shift;

    # 比丘道<g ref="#CB07018"/>造像記

    while(/<g ref="#CB(.*?)".*?>/)
    {
        my $CB = $1;
        
        
        # 1. unicode
        my $word = $gaiji->cb2uniword($CB);
        if($word ne "")
        {
            my $uni = $gaiji->cb2uni($CB);
            my $univer = $gaiji->get_unicode_ver($uni);
            if($univer > 3.1)
            {
                $word = "";
            }
            else
            {
                #print " $CB : $uni : $univer \n";
            }
        }
        # nor unicode
        if($word eq "")
        {
            $word = $gaiji->cb2noruniword($CB);
            if($word ne "")
            {
                my $uni = $gaiji->cb2noruni($CB);
                my $univer = $gaiji->get_unicode_ver($uni);
                if($univer > 3.1)
                {
                    $word = "";
                }
                else
                {
                    #print " $CB : $uni : $univer \n";
                }
            }
        }
        # nor
        if($word eq "")
        {
            $word = $gaiji->cb2nor($CB);
        }
        # des
        if($word eq "")
        {
            $word = $gaiji->cb2des($CB);
        }
        
        if($word eq "")
        {
            print "$infile error : $CB can not chang\n";
            <>;
        }
        s/<g ref="#CB${CB}".*?>/$word/g;
    }
    return $_;
}