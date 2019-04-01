# 由 P5a 經文找出全部的悉曇與蘭扎字

use utf8;

use File::Find;

my $path = "c:/cbwork/xml-p5a";
my %sank = ();
find(\&findfile, $path);

open OUT, ">:utf8", "all_sanskrit.txt";
foreach my $key (sort(keys(%sank)))
{
    print OUT "$key\n";
}
close OUT;

sub findfile
{
	local $_ = $_;
	#print $_ . "\n";				# 檔名
	#print $File::Find::dir . "\n";	# 目錄

    return if(-d $File::Find::name);
    return if($File::Find::name !~ /\.xml$/);
	print $File::Find::name . "\n";	# 完整檔名
    runfile($File::Find::name);
}

sub runfile
{
    my $file = shift;
    local $_;

    open IN, "<:utf8", $file;
    while(<IN>)
    {
        last if(/<body/);
    }
    while(<IN>)
    {
        while(/(((SD)|(RJ))\-[0-9ABCDEF]+)/g)
        {
            $sank{$1} = 1;
        }
    }
    close IN;
}