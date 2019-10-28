##################################################################
# 將 catalog.txt 轉成 mysql 需要用的格式
##################################################################
use utf8;
use lib "/cbwork/bin";
use cbeta;

##################################################################
# 常數
##################################################################


##################################################################
# 變數
##################################################################


##################################################################
# 主程式
##################################################################

$gaiji = new Gaiji();
$gaiji->load_access_db();

open IN, "<:utf8", "catalog.txt" or die "open catalog.txt error";
open OUT, ">:utf8", "mysql_catalog.txt" or die "open catalog_mysql.txt error";

while(<IN>)
{
	# <g ref="#CB00178">㮈</g>
	# <g ref="#CB00003">󰀃</g>
	s/<g ref="#CB(\d{5})">.*?<\/g>/&getcb($1)/eg;
	print OUT $_;
}

close IN;
close OUT;

print "\nOK\n";
<>;

##################################################################
# 把 CB 碼的字換成 unicode 或 組字式
##################################################################

sub getcb
{
	my $cb = shift;
	
	# 缺字原則
	# 1. 有 unicode 1.0 之內的字就用 unicode 1.0 的字
	# 2. 若無, 若有 unicode 1.0 的通用 unicode , 則採用之
	# 3. 若無, 若有一般通用字, 則採用之
	# 4. 若無, 則採用組字式
	
	my $uni = $gaiji->cb2uni($cb);
	
	if($uni ne "")
	{
		if($gaiji->get_unicode_ver($uni) eq "1.0")
		{
			return $gaiji->cb2uniword($cb);
		}
	}
	
	# 2. 若無, 若有 unicode 1.0 的通用 unicode , 則採用之
	my $noruni = $gaiji->cb2noruni($cb);
	
	if($noruni ne "")
	{
		if($gaiji->get_unicode_ver($noruni) eq "1.0")
		{
			return $gaiji->cb2noruniword($cb);
		}
	}
	
	# 3. 若無, 若有一般通用字, 則採用之
	if($gaiji->cb2nor($cb) ne "")
	{
		return $gaiji->cb2nor($cb);
	}
	else
	{
		return $gaiji->cb2des($cb);
	}
}

##################################################################
# The END
##################################################################