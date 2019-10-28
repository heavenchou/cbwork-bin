use utf8;

#dofile1("buleiBL_orig.txt", "buleiBL.txt");
#dofile("buleiT_orig.txt", "buleiT.txt");	# 沒有階層的格式
#dofile1("buleiX_orig.txt", "buleiX.txt");
#dofile1("buleiXB_orig.txt", "buleiXB.txt");
#dofile1("buleiJ_orig.txt", "buleiJ.txt");
#dofile("buleiH_orig.txt", "buleiH.txt");	# 沒有階層的格式
#dofile1("buleiW_orig.txt", "buleiW.txt");
#dofile("buleiI_orig.txt", "buleiI.txt");	# 沒有階層的格式
#dofile("buleiA_orig.txt", "buleiA.txt");	# 沒有階層的格式
#dofile("buleiC_orig.txt", "buleiC.txt");	# 沒有階層的格式
#dofile("buleiD_orig.txt", "buleiD.txt");	# 沒有階層的格式
#dofile("buleiF_orig.txt", "buleiF.txt");	# 沒有階層的格式
#dofile("buleiG_orig.txt", "buleiG.txt");	# 沒有階層的格式
#dofile("buleiK_orig.txt", "buleiK.txt");	# 沒有階層的格式
#dofile("buleiL_orig.txt", "buleiL.txt");	# 沒有階層的格式
#dofile("buleiM_orig.txt", "buleiM.txt");	# 沒有階層的格式
#dofile("buleiN_orig.txt", "buleiN.txt");	# 沒有階層的格式
#dofile1("buleiNB_orig.txt", "buleiNB.txt");
#dofile("buleiP_orig.txt", "buleiP.txt");	# 沒有階層的格式
#dofile("buleiS_orig.txt", "buleiS.txt");	# 沒有階層的格式
#dofile("buleiU_orig.txt", "buleiU.txt");	# 沒有階層的格式
#dofile1("buleiB_orig.txt", "buleiB.txt");
#dofile("buleiGA_orig.txt", "buleiGA.txt");	# 沒有階層的格式
#dofile("buleiGB_orig.txt", "buleiGB.txt");	# 沒有階層的格式
dofile1("buleiGAB_orig.txt", "buleiGAB.txt");

#dofile("buleiZY_orig.txt", "buleiZY.txt");	# 沒有階層的格式
#dofile1("buleiZYB_orig.txt", "buleiZYB.txt");

#dofile1("buleinewsign_orig.txt", "buleinewsign.txt");	# 新式標點目錄

#dofile1("buleifuyan_orig.txt", "buleifuyan.txt");		# 福嚴三年讀經目錄
#dofile1("buleilichan_orig.txt", "buleilichan.txt");	# 杜老師做的禮懺部

sub dofile
{
	$infile = shift;
	$outfile = shift;

	open IN, "<:utf8", $infile;
	open OUT, ">:utf8", $outfile;

	$lasthead = "";
	$num = 0;

	while(<IN>)
	{
		# 001##0001   22,長阿含經    ,【後秦 佛陀耶舍共竺佛念譯】
		/(...)(##.*?)\s*$/;
		$head = $1;
		$data = $2;
		if($head == $lasthead)
		{
			$num++;
		}
		else
		{
			$num = 1;
		}
		$num = sprintf("%03d",$num);
		print OUT "$head$num$data\n";
		$lasthead = $head;
	}

	close IN;
	close OUT;
}

sub dofile1
{

#01 阿含部類 T01-02,25,33
#	T0001-25 長阿含經類 T01
#		T0001 長阿含經22卷
#		T0002-25 長阿含經單本
#			T0002 七佛經1卷
#			T0003 毘婆尸佛經2卷
#			T0004 七佛父母姓字經1卷
#
# 要變成
#
#001##01 阿含部類 T01-02,25,33
#001001##T0001-25 長阿含經類 T01
#001001001##T0001 長阿含經22卷
#001001002##T0002-25 長阿含經單本
#001001002001##T0002 七佛經1卷
#001001002002##T0003 毘婆尸佛經2卷
#001001002003##T0004 七佛父母姓字經1卷

	$infile = shift;
	$outfile = shift;

	open IN, "<:utf8", $infile;
	open OUT, ">:utf8", $outfile;

	$lasttab = 0;
	$tab[0] = 0;

	while(<IN>)
	{
		/^(\s*)(\S.*?)\s*$/;
		$head = $1;
		$data = $2;
		
		$tabnum = 0;
		while($head ne "")
		{
			if($head =~ /^(\t)(.*)/)
			{
				$tabnum++;
				$head = $2;
			}
			else
			{
				print "not tab err : $head$data\n";
				exit;
			}
		}
		
		if($tabnum <= $lasttab)
		{
			for($i = 0 ; $i<$tabnum ; $i++)
			{
				$num = sprintf("%03d",$tab[$i]);
				print OUT "$num";
			}
			$tab[$tabnum] = $tab[$tabnum] + 1;
			$num = sprintf("%03d",$tab[$tabnum]);
			print OUT "$num";
		}
		elsif($tabnum == $lasttab + 1)		# 多了一層
		{
			for($i = 0 ; $i<$tabnum ; $i++)
			{
				$num = sprintf("%03d",$tab[$i]);
				print OUT "$num";
			}
			$tab[$tabnum] = 1;				# 新的一層
			print OUT "001";
		}
		else
		{
			print "err : 怎麼可能? $head$data\n";
			exit;
		}
		
		print OUT "##$data\n";
		
		$lasttab = $tabnum;
	}

	close IN;
	close OUT;
}