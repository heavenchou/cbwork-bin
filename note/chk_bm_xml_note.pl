######################################################################################
# 檢查 BM 和 XML P5 的註解  by heaven 2017/10/29
# 使用法
#   perl chk_bm_xml_note.pl BM目錄 XML-P5目錄
#        BM 目錄下應該要有 notes.txt 的校註檔
#   例:
#      perl chk_bm_xml_note.pl c:\cbwork\bm\T\T01 c:\cbwork\p5\T\T01
######################################################################################

use lib "..";
use CBETA;
use utf8;
use autodie;
use strict;

#########################################################
# 參數
#########################################################

my $bmvol = shift;						# 傳入 BM 的冊數
my $xmlvol = shift;						# 傳入 XML 的冊數

my %bm_note = ();	# 記錄 BM 的校註, $bm_note{"0001001[A]?"} = "xxxx";
my %xml_note = ();

my $logfile = "chk_bm_xml_note_log.txt";

#########################################################
# 主程式
#########################################################

my $gaiji = new Gaiji();
$gaiji->load_access_db();

load_bm_note();		# 載入 BM 校註
load_xmls_note();	# 載入 XML 校註
comp_note();		# 比對校註

#########################################################
# 載入 BM 校註
#########################################################

sub load_bm_note
{
	my $bmfile = $bmvol . "\\notes.txt";
	my $page;

	open IN, "<:utf8", $bmfile;
	print "reading ... $bmfile\n";
	while(<IN>)
	{
		#p0018
  		#A01 《成唯識論述記》卷9(CBETA, T43, no. 1830, p. 548, b23)

		if(/^p(.\d{3})/)
		{
			$page = $1;
		}
		else
		{
			# 新增校註
			# 01 《成唯識論述記》卷9(CBETA, T43, no. 1830, p. 548, b23)
			# A01 《成唯識論述記》卷9(CBETA, T43, no. 1830, p. 548, b23)
			if(/^\s*(A?)(\d{2,3})(\-\d+)?\s*(.*)/)
			{
				my $a = $1;
				my $id = $2;
				my $id2 = $3;
				my $note = $4;

				$id =~ s/^(\d\d)$/0$1/;

				$bm_note{$a . $page . $id . $id2} = $note;
			}
		}
	}
}

#########################################################
# 載入全部 XML 校註
#########################################################

sub load_xmls_note
{
	my $dir = $xmlvol . "\\*.xml";
	my @xmlfiles = <${dir}>;

	foreach my $file (sort(@xmlfiles))
	{
		print "reading ... $file\n";
		load_xml_note($file);
	}
}

#########################################################
# 載入一個 XML 校註
#########################################################

sub load_xml_note
{
	my $file = shift;

	open IN, "<:utf8", $file;
	while(<IN>)
	{
		#<note n="0239001" ... type="add"...>.........</note>
		#<note n="0239001" ... type="orig"...>.........</note>

		if(/^(<note[^>]*type="((?:add)|(?:orig))"[^>]*>)(.*)<\/note>/)
		{
			my $tag = $1;
			my $type = $2;
			my $note = $3;

			$tag =~ /n="(.*?)"/;
			my $id = $1;
			if($type eq "add") {$id = "A" . $id;}


			# 處理 <corr> 裡面的 <note type="cf1">...</note>
			$note =~ s/<note[^>]*?type="cf\d"[^>]*?>.*?<\/note>//g;
			# 處理雙行小註 <note place="inline">...</note>
			$note =~ s/<note[^>]*?place="inline2?"[^>]*?>(.*?)<\/note>/\($1\)/g;

			# 處理修訂文字 
			# <choice cb:resp="正聞出版社"><corr>二九</corr><sic>二八</sic></choice>
			$note =~ s/<choice[^>]*><corr>(.*?)<\/corr><sic>(.*?)<\/sic><\/choice>/[$2>$1]/g;
			$note =~ s/<choice[^>]*><sic>(.*?)<\/sic><corr>(.*?)<\/corr><\/choice>/[$1>$2]/g;

			# 處理規範文字
			# <choice cb:type="規範字詞"><orig>同[1]</orig><reg>....</reg></choice>
			$note =~ s/<choice[^>]*><orig>(.*?)<\/orig><reg>(.*?)<\/reg><\/choice>/[$1=$2]/g;
			$note =~ s/<choice[^>]*><reg>(.*?)<\/reg><orig>(.*?)<\/orig><\/choice>/[$2=$1]/g;
			
			# 把缺字換成組字式 <g ref="#CB04974">󱍮</g>
			$note =~ s/<g ref="#CB(.{5})">.*?<\/g>/$gaiji->cb2uniword("$1")||$gaiji->cb2des("$1")/eg;
			$note =~ s/<.*?>//g;	# 移除標記

			$xml_note{$id} = $note;
		}
	}
}

#########################################################
# 比對校註
#########################################################

sub comp_note
{
	# 先由 BM 去找 XML
	# 再看 BM 及 XML 是否有對方沒有的校註

	my $same = 0;		# 相同校註
	my $notsame = 0;	# 不同校註
	my $onlybm = 0;		# BM 特有校註
	my $onlyxml = 0;	# XML 特有校註

	my $notsamelog = "";
	my $onlybmlog = "";
	my $onlyxmllog = "";

	foreach my $key (sort(keys(%bm_note)))
	{
		if($xml_note{$key})
		{
			if($bm_note{$key} eq $xml_note{$key})
			{
				# 二者校註相同
				$same++;
				$bm_note{$key} = "";
				$xml_note{$key} = "";
			}
			else
			{
				# 二者校註不同
				$notsame++;
				$notsamelog .= "BM : $key : " . $bm_note{$key} . "\n";
				$notsamelog .= "XML: $key : " . $xml_note{$key} . "\n\n";
				$bm_note{$key} = "";
				$xml_note{$key} = "";
			}
		}
		else
		{
			# BM 特有的
			$onlybm++;
			$onlybmlog .= "BM : $key : " . $bm_note{$key} . "\n";
			$bm_note{$key} = "";
		}
	}

	# 處理 XML 特有的校註
	foreach my $key (sort(keys(%xml_note)))
	{
		if($xml_note{$key})
		{
			# XML 特有的
			$onlyxml++;
			$onlyxmllog .= "XML: $key : " . $xml_note{$key} . "\n";
			$xml_note{$key} = "";
		}
	}

	open OUT, ">:utf8", $logfile;
	{
		print OUT "相同校註 : $same\n";
		print OUT "不同校註 : $notsame\n";
		print OUT "BM 特有校註 : $onlybm\n";
		print OUT "XML特有校註 : $onlyxml\n\n";

		if($notsame)
		{
			print OUT "######################\n";
			print OUT "# 不同校註           #\n";
			print OUT "######################\n\n";
			print OUT $notsamelog;
		}

		if($onlybm)
		{
			print OUT "######################\n";
			print OUT "# BM 特有校註        #\n";
			print OUT "######################\n\n";
			print OUT $onlybmlog . "\n";
		}

		if($onlyxml)
		{
			print OUT "######################\n";
			print OUT "# XML 特有校註       #\n";
			print OUT "######################\n\n";
			print OUT $onlyxmllog . "\n";
		}
	}
	close OUT;
}

# END ###################################