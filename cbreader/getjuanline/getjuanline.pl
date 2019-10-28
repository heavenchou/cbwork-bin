# 使用方法
#
# perl getjuan1line.pl T01
#
# 取得某一冊所有經所有卷的第一行的行首標記
#

use utf8;

# command line parameters
$vol = uc(shift);
$ed = $vol;		# T01
$ed =~ s/\d+//;	# T

# configuration
$sourcePath = "C:/Temp/p5xml-p5noru8/$ed/$vol";
$outPath = "c:/release/Juanline";
mkdir($outPath);

$outfile = "$outPath/${vol}.txt";

opendir (INDIR, $sourcePath);
@allfiles = grep(/\.txt$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;


open OUT, ">:utf8", "$outfile" || die "open outfile $outfile error!$!";

for $file (sort(@allfiles)) 
{
	do1file("$sourcePath/$file");
}

close OUT;

#################################################

sub do1file 
{

	my $file = shift;
	print $file . "\n";
	
	open IN, "<:utf8", $file;
	
	$file =~ /\/.(.....)_?(...)\.txt$/;		# 當經號有 ab 時, p5totxt 產生的一卷一檔檔名依然有 _ , 例如 T0128a_001.txt
	$sutra = $1;
	$juan = $2;
	
	while(<IN>)
	{
		if (/[TXJHWIABCDFGKLMNPQSU]+\d*n(.{5})p(.{7})║/)
		{
			$sutra = $1;
			$line = $2;
			if($sutra=~/(....)_/)
			{
				$sutra = $1 . " ";
			}
			print OUT "$line, $sutra, $juan\n";
			last;
		}
	}
	close IN;
}
