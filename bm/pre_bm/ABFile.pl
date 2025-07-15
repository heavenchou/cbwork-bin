# 將比對檔分割成二個檔案
# 例如檔案 input.txt 內容是 123{{abc||xyz}}456
# 執行 perl ABFile.pl input.txt out1.txt out2.txt
# 會產生二個檔案。
# 檔案 out1.txt 內容為 123abc456
# 檔案 out2.txt 內容為 123xyz456

use utf8;
my $infile = shift;
my $file1 = shift;
my $file2 = shift;
if($file2 eq "") {
    print "perl ABFile.pl input.txt out1.txt out2.txt\n";
    exit;
}

open IN, "<:utf8", $infile;
open OUT1, ">:utf8", $file1;
open OUT2, ">:utf8", $file2;

while(<IN>) {
    my $line = $_;
    s/\{\{(.*?)\|\|.*?\}\}/$1/g;
    $line =~ s/\{\{.*?\|\|(.*?)\}\}/$1/g;
    print OUT1 $_;
    print OUT2 $line;
}

close IN;
close OUT1;
close OUT2;
