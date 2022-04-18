# 將 epub 轉成 pdf 的程式
# 主要是執行 Calibre 的 ebook-convert.exe 工具
# 參數如下:
# 	ebook-convert.exe $file $outfile --paper-size a4 --pdf-serif-family MingLiU

use utf8;
use Cwd;
use strict;

my $SourcePath = "d:/cbeta.www/download/epub/cbeta_epub_2022q2";			# 初始目錄, 最後不用加斜線 /
my $OutputPath = "d:/cbeta.www/download/pdf_a4/cbeta_pdf_2022q2";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /
#$SourcePath = "d:/cbwork/cbeta-api/public/download/epub";			# 初始目錄, 最後不用加斜線 /
#$OutputPath = "d:/cbwork/cbeta-api/public/download/pdf";		# 目地初始目錄, 如果有需要的話. 最後不用加斜線 /
my $MakeOutputPath = 1;		# 1 : 產生對應的輸出目錄
my $IsIncludeSubDir = 1;	# 1 : 包含子目錄 0: 不含子目錄
my $FilePattern = "*.epub";		# 要找的檔案類型

SearchDir($SourcePath, $OutputPath);
#system("shutdown.exe /h");

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
	
	#### 要做的事
	$outfile =~ s/\.epub/.pdf/;

	print $file . "\n";
	
	# PMingLiU
	# DFKai-SB
	# SimSun

	#my $cmd = "\"c:/Program Files/Calibre2/ebook-convert.exe\" $file $outfile --paper-size a4 --pdf-serif-family DFKai-SB --pdf-mono-family DFKai-SB --pdf-sans-family DFKai-SB --pdf-standard-font serif --input-encoding UTF-8 --uncompressed-pdf --embed-all-fonts --subset-embedded-fonts";
	my $cmd = "\"c:/App/Calibre5.14/Calibre Portable/Calibre/ebook-convert.exe\" $file $outfile --paper-size a4 --pdf-serif-family MingLiU --pdf-page-numbers";
	print $cmd . "\n";
	system($cmd);
}