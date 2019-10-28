##################################################################
# 產生要滙入 Drupal 的 import 資料
#
# 來源是 mysql_catalog.txt 及 juandata 目錄下的 all.txt
##################################################################

use utf8;

##################################################################
# 常數
##################################################################

my $catalog_file = "mysql_catalog.txt";			# 經文的來源檔
my $juandata_file = "./juandata/all.txt";		# 卷資料相關的來源檔
my $out_sutra = "drupal_import_sutra.csv";		# 輸出檔
my $out_juan = "drupal_import_juan.csv";		# 輸出檔

##################################################################
# 變數
##################################################################

my %sutra_name; 	# 全部的經名 $sutra_name{'T01n0001'} = "長阿含經";

##################################################################
# 主程式
##################################################################

do_sutra_import();	# 產生各經的 import 檔
do_juan_import();	# 產生各卷的 import 檔
exit;

##################################################################
# 先取得全部的經名
##################################################################
##################################################################
# 產生各經的 import 檔
##################################################################

sub do_sutra_import
{
	open IN, "<:utf8", "$catalog_file" or die "open $catalog_file error";
	open OUT, ">:utf8", "$out_sutra" or die "open $out_sutra error";
	print OUT '"title","body","path"' . "\n";
	while(<IN>)
	{
		# A091n1066,A,091,1066,2,1,新譯大方廣佛華嚴經音義,唐 慧菀述
		
		@sutra = split(/,/,$_);
		$id = $sutra[0];
		$name = $sutra[6];
		$sutra_name{$id} = $name;	# 先將經名存起來
		
print OUT << "SUTRA"
"$id $name","<?php
include_once('./cb_tripitaka_php/function.php');
cb_show_one_sutra('$id');
?>","$id"
SUTRA

	}
}

##################################################################
# 產生各卷的 import 檔
##################################################################

sub do_juan_import
{
	open IN, "<:utf8", "$juandata_file" or die "open $juandata_file error";
	open OUT, ">:utf8", "$out_juan" or die "open $out_juan error";
	print OUT '"title","body","path"' . "\n";
	while(<IN>)
	{
		# A091n1066,A,091,1066,1,1,0311b01
		# A091n1066,A,091,1066,2,2,0363b01
		
		@juan = split(/,/,$_);
		$id = $juan[0];
		$juan = $juan[5];
		$jid = $id . "_" . sprintf("%03d",$juan);
		$name = $sutra_name{$id};	# 取得經名
		
print OUT << "JUAN"
"$jid $name 第${juan}卷","<?php
include_once('./cb_tripitaka_php/function.php');
cb_show_one_juan('$jid');
?>","$jid"
JUAN

	}
}

##################################################################
# The END
##################################################################