#######################################################################
# 將指定冊數的經文壓縮成 epub 格式
# 主要的結構有三個：
#
#       mimetype (檔案, 不可以壓縮)
#       META-INF (目錄, 裡面只有 container.xml 該檔)
#       OPS      (目錄, 裡面有經文, 目錄及一些必要檔案)
#
#       OPS 目錄內容有分別放在二個地方, 一個是 standard_epub 目錄中, 
#           另一個是在 $sutra_dir 目錄 (c:/release/epub)
#
# 使用方式  zip_epub.pl T01
#######################################################################

use Archive::Zip;
use Archive::Zip::Tree;

my $vol = shift;	# 冊數


########################################
# 參數
########################################

my $sutra_dir = "c:/release/epub_unzip_tmp";		# 要壓縮的經文所在目錄
my $epub_out = "c:/release/epub_ziped_tmp";			# 輸出的目錄
my $standard_epub = "standard_epub";			# 標準檔案的目錄

########################################
# 主程式
########################################

my $dirs_name = $sutra_dir . "/" . $vol;

mkdir("${epub_out}");	# 輸出目錄
mkdir("${epub_out}/${vol}");	# 輸出目錄

opendir(DIR, $dirs_name ) || die "Error in opening dir $dirs_name\n";
while(($dirname = readdir(DIR)))
{
	next if($dirname =~ /^\./);
	# 取得的 $filename 沒有父目錄資料, 只有單純的目錄或檔名, 例如 T01n0001
	print("Zip $dirname...\n");
	zip_file($dirname);
}
closedir(DIR);

sub zip_file
{
	my $file = shift;
	
	my $zip = Archive::Zip->new();
	my $member = $zip->addFile( "${standard_epub}/mimetype" , "mimetype");
	$member->desiredCompressionMethod( COMPRESSION_STORED );

	$zip->addTree( "${standard_epub}/META-INF", "META-INF", sub { -f && -r } );
	$zip->addTree( "${standard_epub}/OPS", "OPS", sub { -f && -r } );
	$zip->addTree( "${sutra_dir}/${vol}/${file}", "OPS", sub { -f && -r } );

	$zip->writeToFileNamed("${epub_out}/${vol}/${file}.epub");
}