#######################################################################
# �N���w�U�ƪ��g�����Y�� epub �榡
# �D�n�����c���T�ӡG
#
#       mimetype (�ɮ�, ���i�H���Y)
#       META-INF (�ؿ�, �̭��u�� container.xml ����)
#       OPS      (�ؿ�, �̭����g��, �ؿ��Τ@�ǥ��n�ɮ�)
#
#       OPS �ؿ����e�����O��b�G�Ӧa��, �@�ӬO standard_epub �ؿ���, 
#           �t�@�ӬO�b $sutra_dir �ؿ� (c:/release/epub)
#
# �ϥΤ覡  zip_epub.pl T01
#######################################################################

use Archive::Zip;
use Archive::Zip::Tree;

my $vol = shift;	# �U��


########################################
# �Ѽ�
########################################

my $sutra_dir = "c:/release/epub_unzip_tmp";		# �n���Y���g��Ҧb�ؿ�
my $epub_out = "c:/release/epub_ziped_tmp";			# ��X���ؿ�
my $standard_epub = "standard_epub";			# �з��ɮת��ؿ�

########################################
# �D�{��
########################################

my $dirs_name = $sutra_dir . "/" . $vol;

mkdir("${epub_out}");	# ��X�ؿ�
mkdir("${epub_out}/${vol}");	# ��X�ؿ�

opendir(DIR, $dirs_name ) || die "Error in opening dir $dirs_name\n";
while(($dirname = readdir(DIR)))
{
	next if($dirname =~ /^\./);
	# ���o�� $filename �S�����ؿ����, �u����ª��ؿ����ɦW, �Ҧp T01n0001
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