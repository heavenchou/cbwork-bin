# 把有 <g> 標記換成 unicode 或組字式

use utf8;
use Cwd;
#use warnings;
use strict;
use lib "/cbwork/bin";
use CBETA;

my $gaiji = new Gaiji();
$gaiji->load_access_db();

my $SourcePath = "/cbwork/bin/cbreader2X/toc/toc/Y";			# 初始目錄, 最後不用加斜線 /
my $OutputPath = "/cbwork/bin/cbreader2X/toc/toc_new/Y";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /

my $MakeOutputPath = 1;		# 1 : 產生對應的輸出目錄
my $IsIncludeSubDir = 1;	# 1 : 包含子目錄 0: 不含子目錄
my $FilePattern = "*.*";		# 要找的檔案類型

SearchDir($SourcePath, $OutputPath);

##########################################################################

sub SearchDir
{
	my $ThisDir = shift;		# 新的所在的目錄
	my $ThisOutputDir = shift;	# 新的的輸出目錄
	
	print "find dir <$ThisDir>\n";
	
	if($MakeOutputPath)	# 如果需要建立對應子目錄
	{
		mkdir($ThisOutputDir) unless(-d $ThisOutputDir);
	}
	
	my $myPath = getcwd();		# 目前路徑
	chdir($ThisDir);
	my @files = glob($FilePattern);
	chdir($myPath);				# 回到目前路徑
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);		# 不要 . 與 ..
		my $NewFile = $ThisDir . "/" . $file ;
		my $NewOutputFile = $ThisOutputDir . "/" . $file ;
		if (-f $NewFile)
		{
			SearchFile($NewFile , $NewOutputFile);
		}
	}
	return unless($IsIncludeSubDir);	# 若不搜尋子目錄就離開
	
	opendir (DIR, "$ThisDir");
	@files = readdir(DIR);
	closedir(DIR);
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);
		my $NewDir = $ThisDir . "/" . $file ;
		my $NewOutputDir = $ThisOutputDir . "/" . $file ; 
		if (-d $NewDir)
		{
			SearchDir($NewDir, $NewOutputDir);
		}
	}	
}

##########################################################################

sub SearchFile
{
	local $_;
	my $file = shift;
	my $outfile = shift;

    runfile($file, $outfile);
}


sub runfile
{
    local $_;
    my $infile = shift;
    my $outfile = shift;

    open IN, "<:utf8", $infile;
    open OUT, ">:utf8", $outfile;
    while(<IN>)
    {
        if(/<g/)
        {
            # 在 <cbline ..> 後面加空格, 以避免標記後第一個字是 ext-b, Mac parser 會錯誤
            $_ =~ s/(<cblink[^>]*?>)(<g)/$1 $2/g;   
            $_ =~ s/(<span>)(<g)/$1 $2/g;

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
                print " $CB : $uni : $univer \n";
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
                    print " $CB : $uni : $univer \n";
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
            print "error : $CB can not chang\n";
            <>;
        }
        s/<g ref="#CB${CB}".*?>/$word/g;
    }
    return $_;
}