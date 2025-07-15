# 使用取代表進行檔案取代
# 使用參數
#
# perl replace 來源檔名.txt 輸出檔名.txt 取代表.txt
#
use utf8;
my $infile = shift;
my $outfile = shift;
my $tablefile = shift;

my @search = ();
my @replace = ();

exit if (CheckPara() == 0);
GetReplaceTable();
ReplaceFile();

###################

sub CheckPara {
    if($tablefile eq "") {
        ShowHelp();
        return 0;
    }
    return 1;
}

sub ShowHelp {
    print "
perl replace.pl infile.txt outfile.txt table.txt

table.txt

aa=bb
=!
cc!dd
==
xx=yy
";
}

sub GetReplaceTable {
    local $_;
    open TABLE, "<:utf8", $tablefile || die "open $tablefile error!";
    my $sign = "=";
    while(<TABLE>) {
        s/^\x{FEFF}//;
        if(/^=(.)$/) {
            $sign = $1;
        } elsif (/^(.*?)${sign}(.*)/) {
            push(@search, $1);
            push(@replace, $2);
        }
    }
    close TABLE;
}

sub ReplaceFile {
    local $_;
    open IN, "<:utf8", $infile || die "open $infile error!";
    open OUT, ">:utf8", $outfile || die "open $outfile error!";
    while(<IN>) {
        $_ = ReplaceLine($_);
        print OUT $_;
    }
    close IN;
    close OUT;
}

sub ReplaceLine {
    local $_ = shift;
    for (my $i=0; $i<=$#search; $i++) {
        my $s = $search[$i];
        my $p = $replace[$i];
        s/\Q$s\E/$p/g;
    }
    return $_;
}