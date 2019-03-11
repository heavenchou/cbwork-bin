################################
# 移除 “ 符號前後的 </p><p> 標記
# 例如
#  “</p><p>
#  </p>“<p>
#  </p><p>“
################################
use utf8;

$infile = "T25n1509(nsm)out.xml";
$outfile = "T25n1509(nsm)outout.xml";

open IN, "<:utf8", $infile or die "open $infile error";
@lines = <IN>;
close IN;

open OUT, ">:utf8", $outfile or die "open $outfile error";

for($i = 0; $i< $#lines; $i++)
{
    $lines[$i] =~ s/<\/p><p [^>]*>(「|『)?“/$1/g;
    
    if($lines[$i] =~ /^<lb [^>]*><p [^>]*>(「|『)?“/)
    {
        if($lines[$i-1] =~ /<\/p>$/)
        {
            $lines[$i] =~ s/^(<lb [^>]*>)<p [^>]*>(「|『)?“/$1$2/;
            $lines[$i-1] =~ s/<\/p>$//;
        }
        elsif($lines[$i-1] =~ /^<pb /)
        {
            if($lines[$i-2] =~ /<\/p>$/)
            {
                $lines[$i] =~ s/^(<lb [^>]*>)<p [^>]*>(「|『)?“/$1$2/;
                $lines[$i-2] =~ s/<\/p>$//;
            }
        }
    }
}

for($i = 0; $i< $#lines; $i++)
{
    print OUT $lines[$i];
}
close OUT;