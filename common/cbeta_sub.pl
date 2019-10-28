use utf8;

# cbdia2unicode
# cbdia2smdia
# num2CBBuLei 由經號查 CBETA 的部類
# num2TaishoBoo 由經號查大正藏的部
# num2vol 由經號查冊數

sub cbdia2unicode {
	my $s=shift;
	$s=~s/n~/&#x00F1;/g;
	$s=~s/a\^/&#x0101;/g;
	$s=~s/i\^/&#x012B;/g;
	$s=~s/s\//&#x015B;/g;
	$s=~s/u\^/&#x016B;/g;
	$s=~s/d!/&#x1E0D;/g;
	$s=~s/h!/&#x1E25;/g;
	$s=~s/l!\^/&#x1E39;/g;
	$s=~s/l!/&#x1E37;/g;
	$s=~s/m!/&#x1E43;/g;
	$s=~s/n%/&#x1E45;/g;
	$s=~s/n!/&#x1E47;/g;
	$s=~s/r!\^/&#x1E5D;/g;
	$s=~s/r!/&#x1E5B;/g;
	$s=~s/s!/&#x1E63;/g;
	$s=~s/t!/&#x1E6D;/g;
	return $s;
}

sub cbdia2smdia {
	my $s=shift;
	$s=~s/n~/~n/g;
	$s=~s/a\^/aa/g;
	$s=~s/i\^/ii/g;
	$s=~s/s\//`s/g;
	$s=~s/u\^/uu/g;
	$s=~s/d!/\.d/g;
	$s=~s/h!/\.h/g;
	$s=~s/l!\^/\.ll/g;
	$s=~s/l!/\.l/g;
	$s=~s/m!/\.m/g;
	$s=~s/n%/^n/g;
	$s=~s/n!/\.n/g;
	$s=~s/r!\^/\.rr/g;
	$s=~s/r!/\.r/g;
	$s=~s/s!/\.s/g;
	$s=~s/t!/\.t/g;
	return $s;
}

#-----------------------------------------------------------------------
# 由經號查冊數
#-----------------------------------------------------------------------
sub num2vol {
	my $num = shift;
	my $book = shift;
	
	$book = "T" if($book eq "");
	
	if($book eq "T")
	{
		if ($num lt "0099") { return "T01"; }
		elsif ($num lt "0152") { return "T02"; }
		elsif ($num lt "0192") { return "T03"; }
		elsif ($num lt "0220a") { return "T04"; }
		elsif ($num lt "0220b") { return "T05"; }
		elsif ($num lt "0220c") { return "T06"; }
		elsif ($num le "0220o") { return "T07"; }
		elsif ($num lt "0262") { return "T08"; }
		elsif ($num lt "0279") { return "T09"; }
		elsif ($num lt "0310") { return "T10"; }
		elsif ($num lt "0321") { return "T11"; }
		elsif ($num lt "0397") { return "T12"; }
		elsif ($num lt "0425") { return "T13"; }
		elsif ($num lt "0585") { return "T14"; }
		elsif ($num lt "0656") { return "T15"; }
		elsif ($num lt "0721") { return "T16"; }
		elsif ($num lt "0848") { return "T17"; }
		elsif ($num lt "0918") { return "T18"; }
		elsif ($num lt "1030") { return "T19"; }
		elsif ($num lt "1199") { return "T20"; }
		elsif ($num lt "1421") { return "T21"; }
		elsif ($num lt "1435") { return "T22"; }
		elsif ($num lt "1448") { return "T23"; }
		elsif ($num lt "1505") { return "T24"; }
		elsif ($num lt "1519") { return "T25"; }
		elsif ($num lt "1545") { return "T26"; }
		elsif ($num eq "1545") { return "T27"; }
		elsif ($num le "1557") { return "T28"; }
		elsif ($num le "1563") { return "T29"; }
		elsif ($num le "1584") { return "T30"; }
		elsif ($num le "1627") { return "T31"; }
		elsif ($num le "1692") { return "T32"; }
		elsif ($num le "1717") { return "T33"; }
		elsif ($num le "1730") { return "T34"; }
		elsif ($num le "1735") { return "T35"; }
		elsif ($num le "1743") { return "T36"; }
		elsif ($num le "1764") { return "T37"; }
		elsif ($num le "1782") { return "T38"; }
		elsif ($num le "1803") { return "T39"; }
		elsif ($num le "1820") { return "T40"; }
		elsif ($num le "1823") { return "T41"; }
		elsif ($num le "1828") { return "T42"; }
		elsif ($num le "1834") { return "T43"; }
		elsif ($num le "1851") { return "T44"; }
		elsif ($num le "1910") { return "T45"; }
		elsif ($num le "1956") { return "T46"; }
		elsif ($num le "2000") { return "T47"; }
		elsif ($num le "2025") { return "T48"; }
		elsif ($num le "2039") { return "T49"; }
		elsif ($num le "2065") { return "T50"; }
		elsif ($num le "2101") { return "T51"; }
		elsif ($num le "2120") { return "T52"; }
		elsif ($num le "2122") { return "T53"; }
		elsif ($num le "2144") { return "T54"; }
		elsif ($num le "2184") { return "T55"; }
		elsif ($num le "2200") { return "T56"; }
		elsif ($num le "2210") { return "T57"; }
		else { return "T85"; }
    }
    elsif($book eq "X")
    {
	    if ($num le "0051") { return "X01"; }
	    elsif ($num le "0207") { return "X02"; }
	    elsif ($num le "0221") { return "X03"; }
	    elsif ($num le "0225") { return "X04"; }
	    elsif ($num le "0232") { return "X05"; }
	    elsif ($num le "0233a") { return "X06"; }
	    elsif ($num le "0234") { return "X07"; }
	    elsif ($num le "0240a") { return "X08"; }
	    elsif ($num le "0248") { return "X09"; }
	    elsif ($num le "0266") { return "X10"; }
	    elsif ($num le "0271") { return "X11"; }
	    elsif ($num le "0281") { return "X12"; }
	    elsif ($num le "0287") { return "X13"; }
	    elsif ($num le "0298") { return "X14"; }
	    elsif ($num le "0306") { return "X15"; }
	    elsif ($num le "0318") { return "X16"; }
	    elsif ($num le "0331") { return "X17"; }
	    elsif ($num le "0340") { return "X18"; }
	    elsif ($num le "0353") { return "X19"; }
	    elsif ($num le "0367a") { return "X20"; }
	    elsif ($num le "0394") { return "X21"; }
	    elsif ($num le "0435") { return "X22"; }
	    elsif ($num le "0447") { return "X23"; }
	    elsif ($num le "0470") { return "X24"; }
	    elsif ($num le "0510") { return "X25"; }
	    elsif ($num le "0576") { return "X26"; }
	    elsif ($num le "0584") { return "X27"; }
	    elsif ($num le "0593") { return "X28"; }
	    elsif ($num le "0599") { return "X29"; }
	    elsif ($num le "0605") { return "X30"; }
	    elsif ($num le "0614") { return "X31"; }
	    elsif ($num le "0623") { return "X32"; }
	    elsif ($num le "0634") { return "X33"; }
	    elsif ($num le "0639") { return "X34"; }
	    elsif ($num le "0654") { return "X35"; }
	    elsif ($num le "0659") { return "X36"; }
	    elsif ($num le "0675") { return "X37"; }
	    elsif ($num le "0698") { return "X38"; }
	    elsif ($num le "0714a") { return "X39"; }
	    elsif ($num le "0726") { return "X40"; }
	    elsif ($num le "0732") { return "X41"; }
	    elsif ($num le "0736") { return "X42"; }
	    elsif ($num le "0739") { return "X43"; }
	    elsif ($num le "0751") { return "X44"; }
	    elsif ($num le "0772") { return "X45"; }
	    elsif ($num le "0792") { return "X46"; }
	    elsif ($num le "0795") { return "X47"; }
	    elsif ($num le "0808") { return "X48"; }
	    elsif ($num le "0815") { return "X49"; }
	    elsif ($num le "0822a") { return "X50"; }
	    elsif ($num le "0833") { return "X51"; }
	    elsif ($num le "0835") { return "X52"; }
	    elsif ($num le "0862") { return "X53"; }
	    elsif ($num le "0880") { return "X54"; }
	    elsif ($num le "0920") { return "X55"; }
	    elsif ($num le "0949") { return "X56"; }
	    elsif ($num le "0980") { return "X57"; }
	    elsif ($num le "1033") { return "X58"; }
	    elsif ($num le "1109") { return "X59"; }
	    elsif ($num le "1139") { return "X60"; }
	    elsif ($num le "1169") { return "X61"; }
	    elsif ($num le "1216") { return "X62"; }
	    elsif ($num le "1259") { return "X63"; }
	    elsif ($num le "1276") { return "X64"; }
	    elsif ($num le "1295") { return "X65"; }
	    elsif ($num le "1298") { return "X66"; }
	    elsif ($num le "1313") { return "X67"; }
	    elsif ($num le "1319") { return "X68"; }
	    elsif ($num le "1372") { return "X69"; }
	    elsif ($num le "1403") { return "X70"; }
	    elsif ($num le "1426") { return "X71"; }
	    elsif ($num le "1444") { return "X72"; }
	    elsif ($num le "1458") { return "X73"; }
	    elsif ($num le "1507") { return "X74"; }
	    elsif ($num le "1515") { return "X75"; }
	    elsif ($num le "1520") { return "X76"; }
	    elsif ($num le "1538") { return "X77"; }
	    elsif ($num le "1556") { return "X78"; }
	    elsif ($num le "1563") { return "X79"; }
	    elsif ($num le "1568a") { return "X80"; }
	    elsif ($num le "1571a") { return "X81"; }
	    elsif ($num le "1571b") { return "X82"; }
	    elsif ($num le "1578") { return "X83"; }
	    elsif ($num le "1585") { return "X84"; }
	    elsif ($num le "1594") { return "X85"; }
	    elsif ($num le "1611") { return "X86"; }
	    elsif ($num le "1639") { return "X87"; }
	    elsif ($num le "1671") { return "X88"; }
    }
    elsif($book eq "J")
    {
	    if ($num le "A042") { return "J01"; }
	    elsif ($num le "A123") { return "J07"; }
	    elsif ($num le "A158") { return "J10"; }
	    elsif ($num le "B005") { return "J15"; }
	    elsif ($num le "B048") { return "J19"; }
	    elsif ($num le "B103") { return "J20"; }
	    elsif ($num le "B110") { return "J21"; }
	    elsif ($num le "B116") { return "J22"; }
	    elsif ($num le "B135") { return "J23"; }
	    elsif ($num le "B138") { return "J24"; }
	    elsif ($num le "B176") { return "J25"; }
	    elsif ($num le "B188") { return "J26"; }
	    elsif ($num le "B200") { return "J27"; }
	    elsif ($num le "B221") { return "J28"; }
	    elsif ($num le "B249") { return "J29"; }
	    elsif ($num le "B260") { return "J30"; }
	    elsif ($num le "B271a") { return "J31"; }
	    elsif ($num le "B277a") { return "J32"; }
	    elsif ($num le "B294") { return "J33"; }
	    elsif ($num le "B313") { return "J34"; }
	    elsif ($num le "B343") { return "J35"; }
	    elsif ($num le "B369") { return "J36"; }
	    elsif ($num le "B402") { return "J37"; }
	    elsif ($num le "B434") { return "J38"; }
	    elsif ($num le "B471") { return "J39"; }
	    elsif ($num le "B497") { return "J40"; }
    }
    elsif($book eq "H")
    {
	    if ($num le "0001") { return "H01"; }
	}
    elsif($book eq "W")
    {
	    if ($num le "0016") { return "W01"; }
	    elsif ($num le "0022") { return "W02"; }
	    elsif ($num le "0032") { return "W03"; }
	    elsif ($num le "0044") { return "W04"; }
	    elsif ($num le "0050") { return "W05"; }
	    elsif ($num le "0057") { return "W06"; }
	    elsif ($num le "0066") { return "W07"; }
	    elsif ($num le "0071") { return "W08"; }
	    elsif ($num le "0077") { return "W09"; }
	}
    elsif($book eq "I")
    {
	    if ($num le "0100") { return "I01"; }
	}
    elsif($book eq "A")
    {
	    if ($num le "1066") { return "A091"; }
	    elsif ($num le "1276a") { return "A097"; }
	    elsif ($num le "1276b") { return "A098"; }
	    elsif ($num le "1499") { return "A110"; }
	    elsif ($num le "1501a") { return "A111"; }
	    elsif ($num le "1502") { return "A112"; }
	    elsif ($num le "1511") { return "A114"; }
	    elsif ($num le "1553") { return "A119"; }
	    elsif ($num le "1565a") { return "A120"; }
	    elsif ($num le "1565b") { return "A121"; }
	}
	elsif($book eq "B")
    {
	    if ($num le "0001a") { return "B01"; }
	    elsif ($num le "0001b") { return "B02"; }
	    elsif ($num le "0002a") { return "B03"; }
	    elsif ($num le "0002b") { return "B04"; }
	    elsif ($num le "0002c") { return "B05"; }
	    elsif ($num le "0009") { return "B06"; }
	    elsif ($num le "0025") { return "B07"; }
	    elsif ($num le "0029") { return "B08"; }
	    elsif ($num le "0047") { return "B09"; }
	    elsif ($num le "0068") { return "B10"; }
	    elsif ($num le "0076") { return "B11"; }
	    elsif ($num le "0078") { return "B12"; }
	    elsif ($num le "0080") { return "B13"; }
	    elsif ($num le "0087") { return "B14"; }
	    elsif ($num le "0088a") { return "B15"; }
	    elsif ($num le "0088b") { return "B16"; }
	    elsif ($num le "0094") { return "B17"; }
	    elsif ($num le "0101") { return "B18"; }
	    elsif ($num le "0103") { return "B19"; }
	    elsif ($num le "0116") { return "B21"; }
	    elsif ($num le "0119") { return "B22"; }
	    elsif ($num le "0130") { return "B23"; }
	    elsif ($num le "0141") { return "B24"; }
	    elsif ($num le "0145") { return "B25"; }
	    elsif ($num le "0150") { return "B26"; }
	    elsif ($num le "0153") { return "B27"; }
	    elsif ($num le "0159") { return "B28"; }
	    elsif ($num le "0161") { return "B29"; }
	    elsif ($num le "0163") { return "B30"; }
	    elsif ($num le "0170") { return "B31"; }
	    elsif ($num le "0191") { return "B32"; }
	    elsif ($num le "0192") { return "B33"; }
	    elsif ($num le "0193") { return "B34"; }
	    elsif ($num le "0196") { return "B35"; }
	    elsif ($num le "0198") { return "B36"; }
	}
    elsif($book eq "C")
    {
	    if ($num le "1163a") { return "C056"; }
	    elsif ($num le "1163b") { return "C057"; }
	    elsif ($num le "1169") { return "C059"; }
	    elsif ($num le "1666") { return "C071"; }
	    elsif ($num le "1680") { return "C073"; }
	    elsif ($num le "1710") { return "C077"; }
	    elsif ($num le "1720") { return "C078"; }
	    elsif ($num le "1821") { return "C097"; }
	    elsif ($num le "1937") { return "C106"; }
	}
    elsif($book eq "D")
    {
	    if    ($num le "8679") { return "D01"; }
		elsif ($num le "8680") { return "D02"; }
		elsif ($num le "8701") { return "D03"; }
		elsif ($num le "8724") { return "D04"; }
		elsif ($num le "8774") { return "D05"; }
		elsif ($num le "8775") { return "D06"; }
		elsif ($num le "8779") { return "D07"; }
		elsif ($num le "8780") { return "D08"; }
		elsif ($num le "8790") { return "D09"; }
		elsif ($num le "8814") { return "D10"; }
		elsif ($num le "8817") { return "D11"; }
		elsif ($num le "8820") { return "D12"; }
		elsif ($num le "8838") { return "D13"; }
		elsif ($num le "8842") { return "D14"; }
		elsif ($num le "8853") { return "D15"; }
		elsif ($num le "8859") { return "D16"; }
		elsif ($num le "8862") { return "D17"; }
		elsif ($num le "8863") { return "D18"; }
		elsif ($num le "8864") { return "D19"; }
		elsif ($num le "8869") { return "D20"; }
		elsif ($num le "8871") { return "D21"; }
		elsif ($num le "8874") { return "D22"; }
		elsif ($num le "8879") { return "D23"; }
		elsif ($num le "8880") { return "D24"; }
		elsif ($num le "8881") { return "D25"; }
		elsif ($num le "8882") { return "D26"; }
		elsif ($num le "8883") { return "D27"; }
		elsif ($num le "8885") { return "D28"; }
		elsif ($num le "8888") { return "D29"; }
		elsif ($num le "8889") { return "D30"; }
		elsif ($num le "8890") { return "D31"; }
		elsif ($num le "8891") { return "D32"; }
		elsif ($num le "8892") { return "D33"; }
		elsif ($num le "8893") { return "D34"; }
		elsif ($num le "8894") { return "D35"; }
		elsif ($num le "8895") { return "D36"; }
		elsif ($num le "8896") { return "D37"; }
		elsif ($num le "8898") { return "D38"; }
		elsif ($num le "8899") { return "D39"; }
		elsif ($num le "8903") { return "D40"; }
		elsif ($num le "8904") { return "D41"; }
		elsif ($num le "8905") { return "D42"; }
		elsif ($num le "8913") { return "D43"; }
		elsif ($num le "8914") { return "D44"; }
		elsif ($num le "8915") { return "D45"; }
		elsif ($num le "8930") { return "D46"; }
		elsif ($num le "8936") { return "D47"; }
		elsif ($num le "8939") { return "D48"; }
		elsif ($num le "8942") { return "D49"; }
		elsif ($num le "8945") { return "D50"; }
		elsif ($num le "8948") { return "D51"; }
		elsif ($num le "8951") { return "D52"; }
		elsif ($num le "8952") { return "D53"; }
		elsif ($num le "8953") { return "D54"; }
		elsif ($num le "8954") { return "D55"; }
		elsif ($num le "8980") { return "D56"; }
		elsif ($num le "9000") { return "D57"; }
		elsif ($num le "9010") { return "D58"; }
		elsif ($num le "9011") { return "D59"; }
		elsif ($num le "9021") { return "D60"; }
		elsif ($num le "9025") { return "D61"; }
		elsif ($num le "9026") { return "D62"; }
		elsif ($num le "9027") { return "D63"; }
		elsif ($num le "9031") { return "D64"; }
	}
    elsif($book eq "F")
    {
	    if ($num le "0016") { return "F01"; }
	    elsif ($num le "0069") { return "F02"; }
	    elsif ($num le "0248") { return "F03"; }
	    elsif ($num le "0546") { return "F12"; }
	    elsif ($num le "0761") { return "F24"; }
	    elsif ($num le "1064") { return "F27"; }
	    elsif ($num le "1084") { return "F28"; }
	    elsif ($num le "1099") { return "F29"; }
	}
    elsif($book eq "G")
    {
	    if ($num le "1222") { return "G052"; }
	    elsif ($num le "1977") { return "G069"; }
	    elsif ($num le "2075") { return "G083"; }
	    elsif ($num le "2086") { return "G084"; }
	}
    elsif($book eq "GA")
    {
	    if ($num le "0008") { return "GA009"; }
	    elsif ($num le "0009") { return "GA010"; }
	    elsif ($num le "0010a") { return "GA011"; }
	    elsif ($num le "0011") { return "GA012"; }
	    elsif ($num le "0017") { return "GA020"; }
	    elsif ($num le "0032a") { return "GA031"; }
	    elsif ($num le "0032b") { return "GA032"; }
	    elsif ($num le "0043") { return "GA043"; }
	    elsif ($num le "0049") { return "GA045"; }
	    elsif ($num le "0062") { return "GA058"; }
	    elsif ($num le "0077") { return "GA072"; }
	    elsif ($num le "0081") { return "GA079"; }
	    elsif ($num le "0084a") { return "GA081"; }
	    elsif ($num le "0084b") { return "GA082"; }
	    elsif ($num le "0086") { return "GA084"; }
	    elsif ($num le "0089a") { return "GA088"; }
	    elsif ($num le "0089b") { return "GA089"; }
	    elsif ($num le "0089c") { return "GA090"; }
	}
    elsif($book eq "GB")
    {
	    if ($num le "0109") { return "GB078"; }
	}
    elsif($book eq "K")
    {
	    if ($num le "0016") { return "K05"; }
	    elsif ($num le "1064") { return "K32"; }
	    elsif ($num le "1257a") { return "K34"; }
	    elsif ($num le "1261") { return "K35"; }
	    elsif ($num le "1402") { return "K38"; }
	    elsif ($num le "1482") { return "K41"; }
	}
    elsif($book eq "L")
    {
	    if ($num le "1490a") { return "L115"; }
	    elsif ($num le "1490b") { return "L116"; }
	    elsif ($num le "1557a") { return "L130"; }
	    elsif ($num le "1557b") { return "L131"; }
	    elsif ($num le "1557c") { return "L132"; }
	    elsif ($num le "1557d") { return "L133"; }
	    elsif ($num le "1571") { return "L135"; }
	    elsif ($num le "1600") { return "L141"; }
	    elsif ($num le "1608") { return "L143"; }
	    elsif ($num le "1629") { return "L149"; }
	    elsif ($num le "1638a") { return "L153"; }
	    elsif ($num le "1641") { return "L154"; }
	    elsif ($num le "1643") { return "L155"; }
	    elsif ($num le "1651") { return "L157"; }
	    elsif ($num le "1652") { return "L158"; }
	    elsif ($num le "1666") { return "L162"; }
	    elsif ($num le "1669") { return "L164"; }
	}
    elsif($book eq "M")
    {
	    if ($num le "1540") { return "M059"; }
	}
    elsif($book eq "N")
    {
	    if ($num le "0001a") { return "N01"; }
		elsif ($num le "0001b") { return "N02"; }
		elsif ($num le "0002a") { return "N03"; }
		elsif ($num le "0002b") { return "N04"; }
		elsif ($num le "0003") { return "N05"; }
		elsif ($num le "0004a") { return "N06"; }
		elsif ($num le "0004b") { return "N07"; }
		elsif ($num le "0004c") { return "N08"; }
		elsif ($num le "0005a") { return "N09"; }
		elsif ($num le "0005b") { return "N10"; }
		elsif ($num le "0005c") { return "N11"; }
		elsif ($num le "0005d") { return "N12"; }
		elsif ($num le "0006a") { return "N13"; }
		elsif ($num le "0006b") { return "N14"; }
		elsif ($num le "0006c") { return "N15"; }
		elsif ($num le "0006d") { return "N16"; }
		elsif ($num le "0006e") { return "N17"; }
		elsif ($num le "0006f") { return "N18"; }
		elsif ($num le "0007a") { return "N19"; }
		elsif ($num le "0007b") { return "N20"; }
		elsif ($num le "0007c") { return "N21"; }
		elsif ($num le "0007d") { return "N22"; }
		elsif ($num le "0007e") { return "N23"; }
		elsif ($num le "0007f") { return "N24"; }
		elsif ($num le "0007g") { return "N25"; }
		elsif ($num le "0011") { return "N26"; }
		elsif ($num le "0013") { return "N27"; }
		elsif ($num le "0016") { return "N28"; }
		elsif ($num le "0017a") { return "N29"; }
		elsif ($num le "0017b") { return "N30"; }
		elsif ($num le "0018a") { return "N31"; }
		elsif ($num le "0018b") { return "N32"; }
		elsif ($num le "0018c") { return "N33"; }
		elsif ($num le "0018d") { return "N34"; }
		elsif ($num le "0018e") { return "N35"; }
		elsif ($num le "0018f") { return "N36"; }
		elsif ($num le "0018g") { return "N37"; }
		elsif ($num le "0018h") { return "N38"; }
		elsif ($num le "0018i") { return "N39"; }
		elsif ($num le "0018j") { return "N40"; }
		elsif ($num le "0018k") { return "N41"; }
		elsif ($num le "0018l") { return "N42"; }
		elsif ($num le "0019a") { return "N43"; }
		elsif ($num le "0021") { return "N44"; }
		elsif ($num le "0022a") { return "N45"; }
		elsif ($num le "0022b") { return "N46"; }
		elsif ($num le "0023") { return "N47"; }
		elsif ($num le "0024") { return "N48"; }
		elsif ($num le "0025a") { return "N49"; }
		elsif ($num le "0027") { return "N50"; }
		elsif ($num le "0028a") { return "N51"; }
		elsif ($num le "0028b") { return "N52"; }
		elsif ($num le "0028c") { return "N53"; }
		elsif ($num le "0029a") { return "N54"; }
		elsif ($num le "0029b") { return "N55"; }
		elsif ($num le "0029c") { return "N56"; }
		elsif ($num le "0029d") { return "N57"; }
		elsif ($num le "0029e") { return "N58"; }
		elsif ($num le "0029f") { return "N59"; }
		elsif ($num le "0029g") { return "N60"; }
		elsif ($num le "0030a") { return "N61"; }
		elsif ($num le "0030b") { return "N62"; }
		elsif ($num le "0031a") { return "N63"; }
		elsif ($num le "0031b") { return "N64"; }
		elsif ($num le "0033") { return "N65"; }
		elsif ($num le "0034") { return "N66"; }
		elsif ($num le "0035a") { return "N67"; }
		elsif ($num le "0035b") { return "N68"; }
		elsif ($num le "0035c") { return "N69"; }
		elsif ($num le "0038") { return "N70"; }
	}
    elsif($book eq "P")
    {
	    if ($num le "1519a") { return "P154"; }
	    elsif ($num le "1519b") { return "P155"; }
	    elsif ($num le "1573") { return "P167"; }
	    elsif ($num le "1581") { return "P168"; }
	    elsif ($num le "1590") { return "P174"; }
	    elsif ($num le "1611a") { return "P178"; }
	    elsif ($num le "1612a") { return "P179"; }
	    elsif ($num le "1612b") { return "P180"; }
	    elsif ($num le "1615a") { return "P181"; }
	    elsif ($num le "1615b") { return "P182"; }
	    elsif ($num le "1615c") { return "P183"; }
	    elsif ($num le "1617a") { return "P184"; }
	    elsif ($num le "1618") { return "P185"; }
	    elsif ($num le "1624") { return "P187"; }
	    elsif ($num le "1630") { return "P189"; }
	}
    elsif($book eq "S")
    {
	    if ($num le "0047") { return "S06"; }
	}
    elsif($book eq "U")
    {
	    if ($num le "1368") { return "U205"; }
	    elsif ($num le "1418a") { return "U222"; }
	    elsif ($num le "1418b") { return "U223"; }
	}
    elsif($book eq "ZY")
    {
	    if ($num le "0003") { return "ZY01"; }
	    elsif ($num le "0004") { return "ZY02"; }
	    elsif ($num le "0005a") { return "ZY03"; }
	    elsif ($num le "0005b") { return "ZY04"; }
	    elsif ($num le "0005c") { return "ZY05"; }
	    elsif ($num le "0006") { return "ZY06"; }
	    elsif ($num le "0008") { return "ZY07"; }
	    elsif ($num le "0009") { return "ZY08"; }
	    elsif ($num le "0011") { return "ZY09"; }
	    elsif ($num le "0013") { return "ZY10"; }
	    elsif ($num le "0015") { return "ZY11"; }
	    elsif ($num le "0016") { return "ZY12"; }
	    elsif ($num le "0017") { return "ZY13"; }
	    elsif ($num le "0018") { return "ZY14"; }
	    elsif ($num le "0020") { return "ZY15"; }
	    elsif ($num le "0021") { return "ZY16"; }
	    elsif ($num le "0022a") { return "ZY17"; }
	    elsif ($num le "0022b") { return "ZY18"; }
	    elsif ($num le "0023a") { return "ZY19"; }
	    elsif ($num le "0023b") { return "ZY20"; }
	    elsif ($num le "0024") { return "ZY21"; }
	    elsif ($num le "0027") { return "ZY22"; }
	    elsif ($num le "0028") { return "ZY23"; }
	    elsif ($num le "0029") { return "ZY24"; }
	    elsif ($num le "0030") { return "ZY25"; }
	    elsif ($num le "0031") { return "ZY26"; }
	    elsif ($num le "0032") { return "ZY27"; }
	    elsif ($num le "0036") { return "ZY28"; }
	    elsif ($num le "0038") { return "ZY29"; }
	    elsif ($num le "0039") { return "ZY30"; }
	    elsif ($num le "0040") { return "ZY31"; }
	    elsif ($num le "0041") { return "ZY32"; }
	    elsif ($num le "0043") { return "ZY33"; }
	    elsif ($num le "0044") { return "ZY34"; }
	    elsif ($num le "0046") { return "ZY35"; }
	    elsif ($num le "0047a") { return "ZY36"; }
	    elsif ($num le "0047b") { return "ZY37"; }
	    elsif ($num le "0047c") { return "ZY38"; }
	    elsif ($num le "0047d") { return "ZY39"; }
	    elsif ($num le "0048") { return "ZY40"; }
	    elsif ($num le "0049") { return "ZY41"; }
	    elsif ($num le "0050") { return "ZY42"; }
	    elsif ($num le "0051") { return "ZY43"; }
	    elsif ($num le "0052") { return "ZY44"; }
	}
    elsif($book eq "DA")
    {
	    if ($num le "0001") { return "DA01"; }
	    elsif ($num le "0002") { return "DA02"; }
	    elsif ($num le "0003") { return "DA03"; }
	    elsif ($num le "0004a") { return "DA04"; }
	    elsif ($num le "0004b") { return "DA05"; }
	    elsif ($num le "0005a") { return "DA06"; }
	    elsif ($num le "0005b") { return "DA07"; }
	    elsif ($num le "0005c") { return "DA08"; }
	    elsif ($num le "0005d") { return "DA09"; }
	    elsif ($num le "0005e") { return "DA10"; }
	    elsif ($num le "0005f") { return "DA11"; }
	    elsif ($num le "0005g") { return "DA12"; }
	    elsif ($num le "0005h") { return "DA13"; }
	    elsif ($num le "0006") { return "DA14"; }
	    elsif ($num le "0007") { return "DA15"; }
	    elsif ($num le "0008") { return "DA16"; }
	    elsif ($num le "0009") { return "DA17"; }
	    elsif ($num le "0010") { return "DA18"; }
	}
}

#-----------------------------------------------------------------------
# 由經號查大正藏的部
# written by Ray 2001/5/31 12:03下午
#-----------------------------------------------------------------------
sub num2TaishoBoo {
	my $num = shift;
	if ($num le "0151") { return "阿含部"; }
	elsif ($num le "0219") { return "本緣部"; }
	elsif ($num le "0261") { return "般若部"; }
	elsif ($num le "0277") { return "法華部"; }
	elsif ($num le "0309") { return "華嚴部"; }
	elsif ($num le "0373") { return "寶積部"; }
	elsif ($num le "0396") { return "涅槃部"; }
	elsif ($num le "0424") { return "大集部"; }
	elsif ($num le "0847") { return "經集部"; }
	elsif ($num le "1420") { return "密教部"; }
	elsif ($num le "1504") { return "律部"; }
	elsif ($num le "1535") { return "釋經論部"; }
	elsif ($num le "1563") { return "毗曇部"; }
	elsif ($num le "1578") { return "中觀部"; }
	elsif ($num le "1627") { return "瑜伽部"; }
	elsif ($num le "1692") { return "論集部"; }
	elsif ($num le "1803") { return "經疏部"; }
	elsif ($num le "1815") { return "律疏部"; }
	elsif ($num le "1850") { return "論疏部"; }
	elsif ($num le "2025") { return "諸宗部"; }
	elsif ($num le "2120") { return "史傳部"; }
	elsif ($num le "2136") { return "事彙部"; }
	elsif ($num le "2144") { return "外教部"; }
	elsif ($num le "2184") { return "目錄部"; }
	elsif ($num le "2245") { return "續經疏部"; }
	elsif ($num le "2248") { return "續經律部"; }
	elsif ($num le "2295") { return "續經論部"; }
	elsif ($num le "2700") { return "續諸宗部"; }
	elsif ($num le "2731") { return "悉曇部"; }
	elsif ($num le "2864") { return "古逸部"; }
	elsif ($num le "2920") { return "疑似部"; }
	else { return "error: out of range"; }
}


#-----------------------------------------------------------------------
# 由經號查 CBETA 的部類
# written by Ray 2001/5/31 01:56下午
#-----------------------------------------------------------------------
sub num2CBBuLei {
	$num = shift;
	if ($num eq "0001") { return "01AHan"; }
	if ($num eq "0002") { return "01AHan"; }
	if ($num eq "0003") { return "01AHan"; }
	if ($num eq "0004") { return "01AHan"; }
	if ($num eq "0005") { return "01AHan"; }
	if ($num eq "0006") { return "01AHan"; }
	if ($num eq "0007") { return "01AHan"; }
	if ($num eq "0008") { return "01AHan"; }
	if ($num eq "0009") { return "01AHan"; }
	if ($num eq "0010") { return "01AHan"; }
	if ($num eq "0011") { return "01AHan"; }
	if ($num eq "0012") { return "01AHan"; }
	if ($num eq "0013") { return "01AHan"; }
	if ($num eq "0014") { return "01AHan"; }
	if ($num eq "0015") { return "01AHan"; }
	if ($num eq "0016") { return "01AHan"; }
	if ($num eq "0017") { return "01AHan"; }
	if ($num eq "0018") { return "01AHan"; }
	if ($num eq "0019") { return "01AHan"; }
	if ($num eq "0020") { return "01AHan"; }
	if ($num eq "0021") { return "01AHan"; }
	if ($num eq "0022") { return "01AHan"; }
	if ($num eq "0023") { return "01AHan"; }
	if ($num eq "0024") { return "01AHan"; }
	if ($num eq "0025") { return "01AHan"; }
	if ($num eq "0026") { return "01AHan"; }
	if ($num eq "0027") { return "01AHan"; }
	if ($num eq "0028") { return "01AHan"; }
	if ($num eq "0029") { return "01AHan"; }
	if ($num eq "0030") { return "01AHan"; }
	if ($num eq "0031") { return "01AHan"; }
	if ($num eq "0032") { return "01AHan"; }
	if ($num eq "0033") { return "01AHan"; }
	if ($num eq "0034") { return "01AHan"; }
	if ($num eq "0035") { return "01AHan"; }
	if ($num eq "0036") { return "01AHan"; }
	if ($num eq "0037") { return "01AHan"; }
	if ($num eq "0038") { return "01AHan"; }
	if ($num eq "0039") { return "01AHan"; }
	if ($num eq "0040") { return "01AHan"; }
	if ($num eq "0041") { return "01AHan"; }
	if ($num eq "0042") { return "01AHan"; }
	if ($num eq "0043") { return "01AHan"; }
	if ($num eq "0044") { return "01AHan"; }
	if ($num eq "0045") { return "01AHan"; }
	if ($num eq "0046") { return "01AHan"; }
	if ($num eq "0047") { return "01AHan"; }
	if ($num eq "0048") { return "01AHan"; }
	if ($num eq "0049") { return "01AHan"; }
	if ($num eq "0050") { return "01AHan"; }
	if ($num eq "0051") { return "01AHan"; }
	if ($num eq "0052") { return "01AHan"; }
	if ($num eq "0053") { return "01AHan"; }
	if ($num eq "0054") { return "01AHan"; }
	if ($num eq "0055") { return "01AHan"; }
	if ($num eq "0056") { return "01AHan"; }
	if ($num eq "0057") { return "01AHan"; }
	if ($num eq "0058") { return "01AHan"; }
	if ($num eq "0059") { return "01AHan"; }
	if ($num eq "0060") { return "01AHan"; }
	if ($num eq "0061") { return "01AHan"; }
	if ($num eq "0062") { return "01AHan"; }
	if ($num eq "0063") { return "01AHan"; }
	if ($num eq "0064") { return "01AHan"; }
	if ($num eq "0065") { return "01AHan"; }
	if ($num eq "0066") { return "01AHan"; }
	if ($num eq "0067") { return "01AHan"; }
	if ($num eq "0068") { return "01AHan"; }
	if ($num eq "0069") { return "01AHan"; }
	if ($num eq "0070") { return "01AHan"; }
	if ($num eq "0071") { return "01AHan"; }
	if ($num eq "0072") { return "01AHan"; }
	if ($num eq "0073") { return "01AHan"; }
	if ($num eq "0074") { return "01AHan"; }
	if ($num eq "0075") { return "01AHan"; }
	if ($num eq "0076") { return "01AHan"; }
	if ($num eq "0077") { return "01AHan"; }
	if ($num eq "0078") { return "01AHan"; }
	if ($num eq "0079") { return "01AHan"; }
	if ($num eq "0080") { return "01AHan"; }
	if ($num eq "0081") { return "01AHan"; }
	if ($num eq "0082") { return "01AHan"; }
	if ($num eq "0083") { return "01AHan"; }
	if ($num eq "0084") { return "01AHan"; }
	if ($num eq "0085") { return "01AHan"; }
	if ($num eq "0086") { return "01AHan"; }
	if ($num eq "0087") { return "01AHan"; }
	if ($num eq "0088") { return "01AHan"; }
	if ($num eq "0089") { return "01AHan"; }
	if ($num eq "0090") { return "01AHan"; }
	if ($num eq "0091") { return "01AHan"; }
	if ($num eq "0092") { return "01AHan"; }
	if ($num eq "0093") { return "01AHan"; }
	if ($num eq "0094") { return "01AHan"; }
	if ($num eq "0095") { return "01AHan"; }
	if ($num eq "0096") { return "01AHan"; }
	if ($num eq "0097") { return "01AHan"; }
	if ($num eq "0098") { return "01AHan"; }
	if ($num eq "0099") { return "01AHan"; }
	if ($num eq "0100") { return "01AHan"; }
	if ($num eq "0101") { return "01AHan"; }
	if ($num eq "0102") { return "01AHan"; }
	if ($num eq "0103") { return "01AHan"; }
	if ($num eq "0104") { return "01AHan"; }
	if ($num eq "0105") { return "01AHan"; }
	if ($num eq "0106") { return "01AHan"; }
	if ($num eq "0107") { return "01AHan"; }
	if ($num eq "0108") { return "01AHan"; }
	if ($num eq "0109") { return "01AHan"; }
	if ($num eq "0110") { return "01AHan"; }
	if ($num eq "0111") { return "01AHan"; }
	if ($num eq "0112") { return "01AHan"; }
	if ($num eq "0113") { return "01AHan"; }
	if ($num eq "0114") { return "01AHan"; }
	if ($num eq "0115") { return "01AHan"; }
	if ($num eq "0116") { return "01AHan"; }
	if ($num eq "0117") { return "01AHan"; }
	if ($num eq "0118") { return "01AHan"; }
	if ($num eq "0119") { return "01AHan"; }
	if ($num eq "0120") { return "01AHan"; }
	if ($num eq "0121") { return "01AHan"; }
	if ($num eq "0122") { return "01AHan"; }
	if ($num eq "0123") { return "01AHan"; }
	if ($num eq "0124") { return "01AHan"; }
	if ($num eq "0125") { return "01AHan"; }
	if ($num eq "0126") { return "01AHan"; }
	if ($num eq "0127") { return "01AHan"; }
	if ($num eq "0128a") { return "01AHan"; }
	if ($num eq "0128b") { return "01AHan"; }
	if ($num eq "0129") { return "01AHan"; }
	if ($num eq "0130") { return "01AHan"; }
	if ($num eq "0131") { return "01AHan"; }
	if ($num eq "0132a") { return "01AHan"; }
	if ($num eq "0132b") { return "01AHan"; }
	if ($num eq "0133") { return "01AHan"; }
	if ($num eq "0134") { return "01AHan"; }
	if ($num eq "0135") { return "01AHan"; }
	if ($num eq "0136") { return "01AHan"; }
	if ($num eq "0137") { return "01AHan"; }
	if ($num eq "0138") { return "01AHan"; }
	if ($num eq "0139") { return "01AHan"; }
	if ($num eq "0140") { return "01AHan"; }
	if ($num eq "0141") { return "01AHan"; }
	if ($num eq "0142a") { return "01AHan"; }
	if ($num eq "0142b") { return "01AHan"; }
	if ($num eq "0143") { return "01AHan"; }
	if ($num eq "0144") { return "01AHan"; }
	if ($num eq "0145") { return "01AHan"; }
	if ($num eq "0146") { return "01AHan"; }
	if ($num eq "0147") { return "01AHan"; }
	if ($num eq "0148") { return "01AHan"; }
	if ($num eq "0149") { return "01AHan"; }
	if ($num eq "0150A") { return "01AHan"; }
	if ($num eq "0150B") { return "01AHan"; }
	if ($num eq "0151") { return "01AHan"; }
	if ($num eq "1505") { return "01AHan"; }
	if ($num eq "1506") { return "01AHan"; }
	if ($num eq "1507") { return "01AHan"; }
	if ($num eq "1508") { return "01AHan"; }
	if ($num eq "1693") { return "01AHan"; }
	if ($num eq "1694") { return "01AHan"; }
	if ($num eq "0152") { return "02BenYuan"; }
	if ($num eq "0153") { return "02BenYuan"; }
	if ($num eq "0154") { return "02BenYuan"; }
	if ($num eq "0155") { return "02BenYuan"; }
	if ($num eq "0156") { return "02BenYuan"; }
	if ($num eq "0157") { return "02BenYuan"; }
	if ($num eq "0158") { return "02BenYuan"; }
	if ($num eq "0159") { return "02BenYuan"; }
	if ($num eq "0160") { return "02BenYuan"; }
	if ($num eq "0161") { return "02BenYuan"; }
	if ($num eq "0162") { return "02BenYuan"; }
	if ($num eq "0163") { return "02BenYuan"; }
	if ($num eq "0164") { return "02BenYuan"; }
	if ($num eq "0165") { return "02BenYuan"; }
	if ($num eq "0166") { return "02BenYuan"; }
	if ($num eq "0167") { return "02BenYuan"; }
	if ($num eq "0168") { return "02BenYuan"; }
	if ($num eq "0169") { return "02BenYuan"; }
	if ($num eq "0170") { return "02BenYuan"; }
	if ($num eq "0171") { return "02BenYuan"; }
	if ($num eq "0172") { return "02BenYuan"; }
	if ($num eq "0173") { return "02BenYuan"; }
	if ($num eq "0174") { return "02BenYuan"; }
	if ($num eq "0175a") { return "02BenYuan"; }
	if ($num eq "0175b") { return "02BenYuan"; }
	if ($num eq "0175c") { return "02BenYuan"; }
	if ($num eq "0176") { return "02BenYuan"; }
	if ($num eq "0177") { return "02BenYuan"; }
	if ($num eq "0178") { return "02BenYuan"; }
	if ($num eq "0179") { return "02BenYuan"; }
	if ($num eq "0180") { return "02BenYuan"; }
	if ($num eq "0181a") { return "02BenYuan"; }
	if ($num eq "0181b") { return "02BenYuan"; }
	if ($num eq "0182a") { return "02BenYuan"; }
	if ($num eq "0182b") { return "02BenYuan"; }
	if ($num eq "0183") { return "02BenYuan"; }
	if ($num eq "0184") { return "02BenYuan"; }
	if ($num eq "0185") { return "02BenYuan"; }
	if ($num eq "0186") { return "02BenYuan"; }
	if ($num eq "0187") { return "02BenYuan"; }
	if ($num eq "0188") { return "02BenYuan"; }
	if ($num eq "0189") { return "02BenYuan"; }
	if ($num eq "0190") { return "02BenYuan"; }
	if ($num eq "0191") { return "02BenYuan"; }
	if ($num eq "0192") { return "02BenYuan"; }
	if ($num eq "0193") { return "02BenYuan"; }
	if ($num eq "0194") { return "02BenYuan"; }
	if ($num eq "0195") { return "02BenYuan"; }
	if ($num eq "0196") { return "02BenYuan"; }
	if ($num eq "0197") { return "02BenYuan"; }
	if ($num eq "0198") { return "02BenYuan"; }
	if ($num eq "0199") { return "02BenYuan"; }
	if ($num eq "0200") { return "02BenYuan"; }
	if ($num eq "0201") { return "02BenYuan"; }
	if ($num eq "0202") { return "02BenYuan"; }
	if ($num eq "0203") { return "02BenYuan"; }
	if ($num eq "0204") { return "02BenYuan"; }
	if ($num eq "0205") { return "02BenYuan"; }
	if ($num eq "0206") { return "02BenYuan"; }
	if ($num eq "0207") { return "02BenYuan"; }
	if ($num eq "0208") { return "02BenYuan"; }
	if ($num eq "0209") { return "02BenYuan"; }
	if ($num eq "0210") { return "02BenYuan"; }
	if ($num eq "0211") { return "02BenYuan"; }
	if ($num eq "0212") { return "02BenYuan"; }
	if ($num eq "0213") { return "02BenYuan"; }
	if ($num eq "0214") { return "02BenYuan"; }
	if ($num eq "0215") { return "02BenYuan"; }
	if ($num eq "0216") { return "02BenYuan"; }
	if ($num eq "0217") { return "02BenYuan"; }
	if ($num eq "0218") { return "02BenYuan"; }
	if ($num eq "0219") { return "02BenYuan"; }
	if ($num eq "0220a") { return "03BoRuo"; }
	if ($num eq "0220b") { return "03BoRuo"; }
	if ($num eq "0220c") { return "03BoRuo"; }
	if ($num eq "0221") { return "03BoRuo"; }
	if ($num eq "0222") { return "03BoRuo"; }
	if ($num eq "0223") { return "03BoRuo"; }
	if ($num eq "1509") { return "03BoRuo"; }
	if ($num eq "1696") { return "03BoRuo"; }
	if ($num eq "1697") { return "03BoRuo"; }
	if ($num eq "0220d") { return "03BoRuo"; }
	if ($num eq "0224") { return "03BoRuo"; }
	if ($num eq "0225") { return "03BoRuo"; }
	if ($num eq "0226") { return "03BoRuo"; }
	if ($num eq "0227") { return "03BoRuo"; }
	if ($num eq "0228") { return "03BoRuo"; }
	if ($num eq "0229") { return "03BoRuo"; }
	if ($num eq "1516") { return "03BoRuo"; }
	if ($num eq "1517") { return "03BoRuo"; }
	if ($num eq "1518") { return "03BoRuo"; }
	if ($num eq "0220e") { return "03BoRuo"; }
	if ($num eq "0231") { return "03BoRuo"; }
	if ($num eq "0220f") { return "03BoRuo"; }
	if ($num eq "0232") { return "03BoRuo"; }
	if ($num eq "0233") { return "03BoRuo"; }
	if ($num eq "0220g") { return "03BoRuo"; }
	if ($num eq "0234") { return "03BoRuo"; }
	if ($num eq "0220h") { return "03BoRuo"; }
	if ($num eq "0235") { return "03BoRuo"; }
	if ($num eq "0236a") { return "03BoRuo"; }
	if ($num eq "0236b") { return "03BoRuo"; }
	if ($num eq "0237") { return "03BoRuo"; }
	if ($num eq "0238") { return "03BoRuo"; }
	if ($num eq "0239") { return "03BoRuo"; }
	if ($num eq "1510a") { return "03BoRuo"; }
	if ($num eq "1510b") { return "03BoRuo"; }
	if ($num eq "1511") { return "03BoRuo"; }
	if ($num eq "1512") { return "03BoRuo"; }
	if ($num eq "1513") { return "03BoRuo"; }
	if ($num eq "1514") { return "03BoRuo"; }
	if ($num eq "1515") { return "03BoRuo"; }
	if ($num eq "1698") { return "03BoRuo"; }
	if ($num eq "1699") { return "03BoRuo"; }
	if ($num eq "1700") { return "03BoRuo"; }
	if ($num eq "1701") { return "03BoRuo"; }
	if ($num eq "1702") { return "03BoRuo"; }
	if ($num eq "1703") { return "03BoRuo"; }
	if ($num eq "1704") { return "03BoRuo"; }
	if ($num eq "1816") { return "03BoRuo"; }
	if ($num eq "1817") { return "03BoRuo"; }
	if ($num eq "2732") { return "03BoRuo"; }
	if ($num eq "2733") { return "03BoRuo"; }
	if ($num eq "2734") { return "03BoRuo"; }
	if ($num eq "2735") { return "03BoRuo"; }
	if ($num eq "2736") { return "03BoRuo"; }
	if ($num eq "2737") { return "03BoRuo"; }
	if ($num eq "2738") { return "03BoRuo"; }
	if ($num eq "2739") { return "03BoRuo"; }
	if ($num eq "2740") { return "03BoRuo"; }
	if ($num eq "2741") { return "03BoRuo"; }
	if ($num eq "2742") { return "03BoRuo"; }
	if ($num eq "2743") { return "03BoRuo"; }
	if ($num eq "0220i") { return "03BoRuo"; }
	if ($num eq "0240") { return "03BoRuo"; }
	if ($num eq "0241") { return "03BoRuo"; }
	if ($num eq "0242") { return "03BoRuo"; }
	if ($num eq "0243") { return "03BoRuo"; }
	if ($num eq "0244") { return "03BoRuo"; }
	if ($num eq "1695") { return "03BoRuo"; }
	if ($num eq "0220j") { return "03BoRuo"; }
	if ($num eq "0220k") { return "03BoRuo"; }
	if ($num eq "0220l") { return "03BoRuo"; }
	if ($num eq "0220m") { return "03BoRuo"; }
	if ($num eq "0220n") { return "03BoRuo"; }
	if ($num eq "0220o") { return "03BoRuo"; }
	if ($num eq "0250") { return "03BoRuo"; }
	if ($num eq "0251") { return "03BoRuo"; }
	if ($num eq "0252") { return "03BoRuo"; }
	if ($num eq "0253") { return "03BoRuo"; }
	if ($num eq "0254") { return "03BoRuo"; }
	if ($num eq "0255") { return "03BoRuo"; }
	if ($num eq "0256") { return "03BoRuo"; }
	if ($num eq "0257") { return "03BoRuo"; }
	if ($num eq "1710") { return "03BoRuo"; }
	if ($num eq "1711") { return "03BoRuo"; }
	if ($num eq "1712") { return "03BoRuo"; }
	if ($num eq "1713") { return "03BoRuo"; }
	if ($num eq "1714") { return "03BoRuo"; }
	if ($num eq "2746") { return "03BoRuo"; }
	if ($num eq "2747") { return "03BoRuo"; }
	if ($num eq "0245") { return "03BoRuo"; }
	if ($num eq "0246") { return "03BoRuo"; }
	if ($num eq "1705") { return "03BoRuo"; }
	if ($num eq "1706") { return "03BoRuo"; }
	if ($num eq "1707") { return "03BoRuo"; }
	if ($num eq "1708") { return "03BoRuo"; }
	if ($num eq "1709") { return "03BoRuo"; }
	if ($num eq "2744") { return "03BoRuo"; }
	if ($num eq "2745") { return "03BoRuo"; }
	if ($num eq "0230") { return "03BoRuo"; }
	if ($num eq "0247") { return "03BoRuo"; }
	if ($num eq "0248") { return "03BoRuo"; }
	if ($num eq "0249") { return "03BoRuo"; }
	if ($num eq "0258") { return "03BoRuo"; }
	if ($num eq "0259") { return "03BoRuo"; }
	if ($num eq "0260") { return "03BoRuo"; }
	if ($num eq "0261") { return "03BoRuo"; }
	if ($num eq "0262") { return "04FaHua"; }
	if ($num eq "0263") { return "04FaHua"; }
	if ($num eq "0264") { return "04FaHua"; }
	if ($num eq "0265") { return "04FaHua"; }
	if ($num eq "1715") { return "04FaHua"; }
	if ($num eq "1716") { return "04FaHua"; }
	if ($num eq "1717") { return "04FaHua"; }
	if ($num eq "1718") { return "04FaHua"; }
	if ($num eq "1719") { return "04FaHua"; }
	if ($num eq "1720") { return "04FaHua"; }
	if ($num eq "1721") { return "04FaHua"; }
	if ($num eq "1722") { return "04FaHua"; }
	if ($num eq "1723") { return "04FaHua"; }
	if ($num eq "1724") { return "04FaHua"; }
	if ($num eq "1725") { return "04FaHua"; }
	if ($num eq "1726") { return "04FaHua"; }
	if ($num eq "1727") { return "04FaHua"; }
	if ($num eq "1728") { return "04FaHua"; }
	if ($num eq "1729") { return "04FaHua"; }
	if ($num eq "2748") { return "04FaHua"; }
	if ($num eq "2749") { return "04FaHua"; }
	if ($num eq "2750") { return "04FaHua"; }
	if ($num eq "2751") { return "04FaHua"; }
	if ($num eq "2752") { return "04FaHua"; }
	if ($num eq "0266") { return "04FaHua"; }
	if ($num eq "0267") { return "04FaHua"; }
	if ($num eq "0268") { return "04FaHua"; }
	if ($num eq "0269") { return "04FaHua"; }
	if ($num eq "0270") { return "04FaHua"; }
	if ($num eq "0271") { return "04FaHua"; }
	if ($num eq "0272") { return "04FaHua"; }
	if ($num eq "0273") { return "04FaHua"; }
	if ($num eq "1730") { return "04FaHua"; }
	if ($num eq "0274") { return "04FaHua"; }
	if ($num eq "0275") { return "04FaHua"; }
	if ($num eq "0276") { return "04FaHua"; }
	if ($num eq "0277") { return "04FaHua"; }
	if ($num eq "1519") { return "04FaHua"; }
	if ($num eq "1520") { return "04FaHua"; }
	if ($num eq "1818") { return "04FaHua"; }
	if ($num eq "1911") { return "04FaHua"; }
	if ($num eq "1912") { return "04FaHua"; }
	if ($num eq "1913") { return "04FaHua"; }
	if ($num eq "1914") { return "04FaHua"; }
	if ($num eq "1915") { return "04FaHua"; }
	if ($num eq "1916") { return "04FaHua"; }
	if ($num eq "1917") { return "04FaHua"; }
	if ($num eq "1918") { return "04FaHua"; }
	if ($num eq "1919") { return "04FaHua"; }
	if ($num eq "1920") { return "04FaHua"; }
	if ($num eq "1921") { return "04FaHua"; }
	if ($num eq "1922") { return "04FaHua"; }
	if ($num eq "1923") { return "04FaHua"; }
	if ($num eq "1924") { return "04FaHua"; }
	if ($num eq "1925") { return "04FaHua"; }
	if ($num eq "1926") { return "04FaHua"; }
	if ($num eq "1927") { return "04FaHua"; }
	if ($num eq "1928") { return "04FaHua"; }
	if ($num eq "1929") { return "04FaHua"; }
	if ($num eq "1930") { return "04FaHua"; }
	if ($num eq "1931") { return "04FaHua"; }
	if ($num eq "1932") { return "04FaHua"; }
	if ($num eq "1933") { return "04FaHua"; }
	if ($num eq "1934") { return "04FaHua"; }
	if ($num eq "1935") { return "04FaHua"; }
	if ($num eq "1936") { return "04FaHua"; }
	if ($num eq "1937") { return "04FaHua"; }
	if ($num eq "1938") { return "04FaHua"; }
	if ($num eq "1939") { return "04FaHua"; }
	if ($num eq "1940") { return "04FaHua"; }
	if ($num eq "1941") { return "04FaHua"; }
	if ($num eq "1942") { return "04FaHua"; }
	if ($num eq "1943") { return "04FaHua"; }
	if ($num eq "1944") { return "04FaHua"; }
	if ($num eq "1945") { return "04FaHua"; }
	if ($num eq "1946") { return "04FaHua"; }
	if ($num eq "1947") { return "04FaHua"; }
	if ($num eq "1948") { return "04FaHua"; }
	if ($num eq "1949") { return "04FaHua"; }
	if ($num eq "1950") { return "04FaHua"; }
	if ($num eq "1951") { return "04FaHua"; }
	if ($num eq "0278") { return "05HuaYan"; }
	if ($num eq "1731") { return "05HuaYan"; }
	if ($num eq "1732") { return "05HuaYan"; }
	if ($num eq "1733") { return "05HuaYan"; }
	if ($num eq "1734") { return "05HuaYan"; }
	if ($num eq "2753") { return "05HuaYan"; }
	if ($num eq "2754") { return "05HuaYan"; }
	if ($num eq "2756") { return "05HuaYan"; }
	if ($num eq "2757") { return "05HuaYan"; }
	if ($num eq "0279") { return "05HuaYan"; }
	if ($num eq "1735") { return "05HuaYan"; }
	if ($num eq "1736") { return "05HuaYan"; }
	if ($num eq "1737") { return "05HuaYan"; }
	if ($num eq "1738") { return "05HuaYan"; }
	if ($num eq "1739") { return "05HuaYan"; }
	if ($num eq "1740") { return "05HuaYan"; }
	if ($num eq "1741") { return "05HuaYan"; }
	if ($num eq "1742") { return "05HuaYan"; }
	if ($num eq "1743") { return "05HuaYan"; }
	if ($num eq "2755") { return "05HuaYan"; }
	if ($num eq "0280") { return "05HuaYan"; }
	if ($num eq "0281") { return "05HuaYan"; }
	if ($num eq "0282") { return "05HuaYan"; }
	if ($num eq "0283") { return "05HuaYan"; }
	if ($num eq "0284") { return "05HuaYan"; }
	if ($num eq "0285") { return "05HuaYan"; }
	if ($num eq "0286") { return "05HuaYan"; }
	if ($num eq "0287") { return "05HuaYan"; }
	if ($num eq "0288") { return "05HuaYan"; }
	if ($num eq "0289") { return "05HuaYan"; }
	if ($num eq "0290") { return "05HuaYan"; }
	if ($num eq "0291") { return "05HuaYan"; }
	if ($num eq "0292") { return "05HuaYan"; }
	if ($num eq "0293") { return "05HuaYan"; }
	if ($num eq "0294") { return "05HuaYan"; }
	if ($num eq "0295") { return "05HuaYan"; }
	if ($num eq "0296") { return "05HuaYan"; }
	if ($num eq "0297") { return "05HuaYan"; }
	if ($num eq "0298") { return "05HuaYan"; }
	if ($num eq "0299") { return "05HuaYan"; }
	if ($num eq "0300") { return "05HuaYan"; }
	if ($num eq "0301") { return "05HuaYan"; }
	if ($num eq "0302") { return "05HuaYan"; }
	if ($num eq "0303") { return "05HuaYan"; }
	if ($num eq "0304") { return "05HuaYan"; }
	if ($num eq "0305") { return "05HuaYan"; }
	if ($num eq "0306") { return "05HuaYan"; }
	if ($num eq "0307") { return "05HuaYan"; }
	if ($num eq "0308") { return "05HuaYan"; }
	if ($num eq "0309") { return "05HuaYan"; }
	if ($num eq "1521") { return "05HuaYan"; }
	if ($num eq "1522") { return "05HuaYan"; }
	if ($num eq "2758") { return "05HuaYan"; }
	if ($num eq "2799") { return "05HuaYan"; }
	if ($num eq "1866") { return "05HuaYan"; }
	if ($num eq "1867") { return "05HuaYan"; }
	if ($num eq "1868") { return "05HuaYan"; }
	if ($num eq "1869") { return "05HuaYan"; }
	if ($num eq "1870") { return "05HuaYan"; }
	if ($num eq "1871") { return "05HuaYan"; }
	if ($num eq "1872") { return "05HuaYan"; }
	if ($num eq "1873") { return "05HuaYan"; }
	if ($num eq "1874") { return "05HuaYan"; }
	if ($num eq "1875") { return "05HuaYan"; }
	if ($num eq "1876") { return "05HuaYan"; }
	if ($num eq "1877") { return "05HuaYan"; }
	if ($num eq "1878") { return "05HuaYan"; }
	if ($num eq "1879a") { return "05HuaYan"; }
	if ($num eq "1879b") { return "05HuaYan"; }
	if ($num eq "1880") { return "05HuaYan"; }
	if ($num eq "1881") { return "05HuaYan"; }
	if ($num eq "1882") { return "05HuaYan"; }
	if ($num eq "1883") { return "05HuaYan"; }
	if ($num eq "1884") { return "05HuaYan"; }
	if ($num eq "1885") { return "05HuaYan"; }
	if ($num eq "1886") { return "05HuaYan"; }
	if ($num eq "1887A") { return "05HuaYan"; }
	if ($num eq "1887B") { return "05HuaYan"; }
	if ($num eq "1888") { return "05HuaYan"; }
	if ($num eq "1889") { return "05HuaYan"; }
	if ($num eq "1890") { return "05HuaYan"; }
	if ($num eq "1891") { return "05HuaYan"; }
	if ($num eq "0310") { return "06BaoJi"; }
	if ($num eq "0311") { return "06BaoJi"; }
	if ($num eq "0312") { return "06BaoJi"; }
	if ($num eq "0313") { return "06BaoJi"; }
	if ($num eq "0314") { return "06BaoJi"; }
	if ($num eq "0315a") { return "06BaoJi"; }
	if ($num eq "0315b") { return "06BaoJi"; }
	if ($num eq "0316") { return "06BaoJi"; }
	if ($num eq "0317") { return "06BaoJi"; }
	if ($num eq "0318") { return "06BaoJi"; }
	if ($num eq "0319") { return "06BaoJi"; }
	if ($num eq "0320") { return "06BaoJi"; }
	if ($num eq "0321") { return "06BaoJi"; }
	if ($num eq "0322") { return "06BaoJi"; }
	if ($num eq "0323") { return "06BaoJi"; }
	if ($num eq "0324") { return "06BaoJi"; }
	if ($num eq "0325") { return "06BaoJi"; }
	if ($num eq "0326") { return "06BaoJi"; }
	if ($num eq "0327") { return "06BaoJi"; }
	if ($num eq "0328") { return "06BaoJi"; }
	if ($num eq "0329") { return "06BaoJi"; }
	if ($num eq "0330") { return "06BaoJi"; }
	if ($num eq "0331") { return "06BaoJi"; }
	if ($num eq "0332") { return "06BaoJi"; }
	if ($num eq "0333") { return "06BaoJi"; }
	if ($num eq "0334") { return "06BaoJi"; }
	if ($num eq "0335") { return "06BaoJi"; }
	if ($num eq "0336") { return "06BaoJi"; }
	if ($num eq "0337") { return "06BaoJi"; }
	if ($num eq "0338") { return "06BaoJi"; }
	if ($num eq "0339") { return "06BaoJi"; }
	if ($num eq "0340") { return "06BaoJi"; }
	if ($num eq "0341") { return "06BaoJi"; }
	if ($num eq "0342") { return "06BaoJi"; }
	if ($num eq "0343") { return "06BaoJi"; }
	if ($num eq "0344") { return "06BaoJi"; }
	if ($num eq "0345") { return "06BaoJi"; }
	if ($num eq "0346") { return "06BaoJi"; }
	if ($num eq "0347") { return "06BaoJi"; }
	if ($num eq "0348") { return "06BaoJi"; }
	if ($num eq "0349") { return "06BaoJi"; }
	if ($num eq "0350") { return "06BaoJi"; }
	if ($num eq "0351") { return "06BaoJi"; }
	if ($num eq "0352") { return "06BaoJi"; }
	if ($num eq "0353") { return "06BaoJi"; }
	if ($num eq "0354") { return "06BaoJi"; }
	if ($num eq "0355") { return "06BaoJi"; }
	if ($num eq "0356") { return "06BaoJi"; }
	if ($num eq "0357") { return "06BaoJi"; }
	if ($num eq "0358") { return "06BaoJi"; }
	if ($num eq "0359") { return "06BaoJi"; }
	if ($num eq "0353") { return "06BaoJi"; }
	if ($num eq "1744") { return "06BaoJi"; }
	if ($num eq "2761") { return "06BaoJi"; }
	if ($num eq "2762") { return "06BaoJi"; }
	if ($num eq "2763") { return "06BaoJi"; }
	if ($num eq "0360") { return "06BaoJi"; }
	if ($num eq "0361") { return "06BaoJi"; }
	if ($num eq "0362") { return "06BaoJi"; }
	if ($num eq "0363") { return "06BaoJi"; }
	if ($num eq "0364") { return "06BaoJi"; }
	if ($num eq "1745") { return "06BaoJi"; }
	if ($num eq "1746") { return "06BaoJi"; }
	if ($num eq "1747") { return "06BaoJi"; }
	if ($num eq "1748") { return "06BaoJi"; }
	if ($num eq "2759") { return "06BaoJi"; }
	if ($num eq "2760") { return "06BaoJi"; }
	if ($num eq "0365") { return "06BaoJi"; }
	if ($num eq "1749") { return "06BaoJi"; }
	if ($num eq "1750") { return "06BaoJi"; }
	if ($num eq "1751") { return "06BaoJi"; }
	if ($num eq "1752") { return "06BaoJi"; }
	if ($num eq "1753") { return "06BaoJi"; }
	if ($num eq "1754") { return "06BaoJi"; }
	if ($num eq "0366") { return "06BaoJi"; }
	if ($num eq "0367") { return "06BaoJi"; }
	if ($num eq "1755") { return "06BaoJi"; }
	if ($num eq "1756") { return "06BaoJi"; }
	if ($num eq "1757") { return "06BaoJi"; }
	if ($num eq "1758") { return "06BaoJi"; }
	if ($num eq "1759") { return "06BaoJi"; }
	if ($num eq "1760") { return "06BaoJi"; }
	if ($num eq "1761") { return "06BaoJi"; }
	if ($num eq "1762") { return "06BaoJi"; }
	if ($num eq "0368") { return "06BaoJi"; }
	if ($num eq "0369") { return "06BaoJi"; }
	if ($num eq "0370") { return "06BaoJi"; }
	if ($num eq "0371") { return "06BaoJi"; }
	if ($num eq "0372") { return "06BaoJi"; }
	if ($num eq "0373") { return "06BaoJi"; }
	if ($num eq "1524") { return "06BaoJi"; }
	if ($num eq "1819") { return "06BaoJi"; }
	if ($num eq "1523") { return "06BaoJi"; }
	if ($num eq "1525") { return "06BaoJi"; }
	if ($num eq "0374") { return "07NiePan"; }
	if ($num eq "1764") { return "07NiePan"; }
	if ($num eq "0375") { return "07NiePan"; }
	if ($num eq "1763") { return "07NiePan"; }
	if ($num eq "1765") { return "07NiePan"; }
	if ($num eq "1766") { return "07NiePan"; }
	if ($num eq "1767") { return "07NiePan"; }
	if ($num eq "1768") { return "07NiePan"; }
	if ($num eq "1769") { return "07NiePan"; }
	if ($num eq "2764A") { return "07NiePan"; }
	if ($num eq "2764B") { return "07NiePan"; }
	if ($num eq "2765") { return "07NiePan"; }
	if ($num eq "0376") { return "07NiePan"; }
	if ($num eq "0377") { return "07NiePan"; }
	if ($num eq "0378") { return "07NiePan"; }
	if ($num eq "0379") { return "07NiePan"; }
	if ($num eq "0380") { return "07NiePan"; }
	if ($num eq "0381") { return "07NiePan"; }
	if ($num eq "0382") { return "07NiePan"; }
	if ($num eq "0383") { return "07NiePan"; }
	if ($num eq "0384") { return "07NiePan"; }
	if ($num eq "0385") { return "07NiePan"; }
	if ($num eq "0386") { return "07NiePan"; }
	if ($num eq "0387") { return "07NiePan"; }
	if ($num eq "0388") { return "07NiePan"; }
	if ($num eq "0390") { return "07NiePan"; }
	if ($num eq "0391") { return "07NiePan"; }
	if ($num eq "0392") { return "07NiePan"; }
	if ($num eq "0393") { return "07NiePan"; }
	if ($num eq "0394") { return "07NiePan"; }
	if ($num eq "0395") { return "07NiePan"; }
	if ($num eq "0396") { return "07NiePan"; }
	if ($num eq "0389") { return "07NiePan"; }
	if ($num eq "1529") { return "07NiePan"; }
	if ($num eq "1820") { return "07NiePan"; }
	if ($num eq "1527") { return "07NiePan"; }
	if ($num eq "1528") { return "07NiePan"; }
	if ($num eq "0397") { return "08DaJi"; }
	if ($num eq "0398") { return "08DaJi"; }
	if ($num eq "0399") { return "08DaJi"; }
	if ($num eq "0400") { return "08DaJi"; }
	if ($num eq "0401") { return "08DaJi"; }
	if ($num eq "0402") { return "08DaJi"; }
	if ($num eq "0403") { return "08DaJi"; }
	if ($num eq "0404") { return "08DaJi"; }
	if ($num eq "0405") { return "08DaJi"; }
	if ($num eq "0406") { return "08DaJi"; }
	if ($num eq "0407") { return "08DaJi"; }
	if ($num eq "0408") { return "08DaJi"; }
	if ($num eq "0409") { return "08DaJi"; }
	if ($num eq "0410") { return "08DaJi"; }
	if ($num eq "0411") { return "08DaJi"; }
	if ($num eq "0412") { return "08DaJi"; }
	if ($num eq "0413") { return "08DaJi"; }
	if ($num eq "0414") { return "08DaJi"; }
	if ($num eq "0415") { return "08DaJi"; }
	if ($num eq "0416") { return "08DaJi"; }
	if ($num eq "0417") { return "08DaJi"; }
	if ($num eq "0418") { return "08DaJi"; }
	if ($num eq "0419") { return "08DaJi"; }
	if ($num eq "0420") { return "08DaJi"; }
	if ($num eq "0421") { return "08DaJi"; }
	if ($num eq "0422") { return "08DaJi"; }
	if ($num eq "0423") { return "08DaJi"; }
	if ($num eq "0424") { return "08DaJi"; }
	if ($num eq "1526") { return "08DaJi"; }
	if ($num eq "0425") { return "09JingJi"; }
	if ($num eq "0426") { return "09JingJi"; }
	if ($num eq "0427") { return "09JingJi"; }
	if ($num eq "0428") { return "09JingJi"; }
	if ($num eq "0429") { return "09JingJi"; }
	if ($num eq "0430") { return "09JingJi"; }
	if ($num eq "0431") { return "09JingJi"; }
	if ($num eq "0432") { return "09JingJi"; }
	if ($num eq "0433") { return "09JingJi"; }
	if ($num eq "0434") { return "09JingJi"; }
	if ($num eq "0435") { return "09JingJi"; }
	if ($num eq "0436") { return "09JingJi"; }
	if ($num eq "0437") { return "09JingJi"; }
	if ($num eq "0438") { return "09JingJi"; }
	if ($num eq "0439") { return "09JingJi"; }
	if ($num eq "0440") { return "09JingJi"; }
	if ($num eq "0441") { return "09JingJi"; }
	if ($num eq "0442") { return "09JingJi"; }
	if ($num eq "0443") { return "09JingJi"; }
	if ($num eq "0444") { return "09JingJi"; }
	if ($num eq "0445") { return "09JingJi"; }
	if ($num eq "0446a") { return "09JingJi"; }
	if ($num eq "0446b") { return "09JingJi"; }
	if ($num eq "0447a") { return "09JingJi"; }
	if ($num eq "0447b") { return "09JingJi"; }
	if ($num eq "0448a") { return "09JingJi"; }
	if ($num eq "0448b") { return "09JingJi"; }
	if ($num eq "0449") { return "09JingJi"; }
	if ($num eq "0450") { return "09JingJi"; }
	if ($num eq "0451") { return "09JingJi"; }
	if ($num eq "0922") { return "09JingJi"; }
	if ($num eq "1331") { return "09JingJi"; }
	if ($num eq "1770") { return "09JingJi"; }
	if ($num eq "2766") { return "09JingJi"; }
	if ($num eq "2767") { return "09JingJi"; }
	if ($num eq "0452") { return "09JingJi"; }
	if ($num eq "0453") { return "09JingJi"; }
	if ($num eq "0454") { return "09JingJi"; }
	if ($num eq "0455") { return "09JingJi"; }
	if ($num eq "0456") { return "09JingJi"; }
	if ($num eq "0457") { return "09JingJi"; }
	if ($num eq "1771") { return "09JingJi"; }
	if ($num eq "1772") { return "09JingJi"; }
	if ($num eq "1773") { return "09JingJi"; }
	if ($num eq "1774") { return "09JingJi"; }
	if ($num eq "0458") { return "09JingJi"; }
	if ($num eq "0459") { return "09JingJi"; }
	if ($num eq "0460") { return "09JingJi"; }
	if ($num eq "0461") { return "09JingJi"; }
	if ($num eq "0462") { return "09JingJi"; }
	if ($num eq "0463") { return "09JingJi"; }
	if ($num eq "0464") { return "09JingJi"; }
	if ($num eq "0465") { return "09JingJi"; }
	if ($num eq "0466") { return "09JingJi"; }
	if ($num eq "0467") { return "09JingJi"; }
	if ($num eq "0468") { return "09JingJi"; }
	if ($num eq "0469") { return "09JingJi"; }
	if ($num eq "0470") { return "09JingJi"; }
	if ($num eq "0471") { return "09JingJi"; }
	if ($num eq "0472") { return "09JingJi"; }
	if ($num eq "0473") { return "09JingJi"; }
	if ($num eq "0474") { return "09JingJi"; }
	if ($num eq "0475") { return "09JingJi"; }
	if ($num eq "0476") { return "09JingJi"; }
	if ($num eq "1775") { return "09JingJi"; }
	if ($num eq "1776") { return "09JingJi"; }
	if ($num eq "1777") { return "09JingJi"; }
	if ($num eq "1778") { return "09JingJi"; }
	if ($num eq "1779") { return "09JingJi"; }
	if ($num eq "1780") { return "09JingJi"; }
	if ($num eq "1781") { return "09JingJi"; }
	if ($num eq "1782") { return "09JingJi"; }
	if ($num eq "2768") { return "09JingJi"; }
	if ($num eq "2769") { return "09JingJi"; }
	if ($num eq "2770") { return "09JingJi"; }
	if ($num eq "2771") { return "09JingJi"; }
	if ($num eq "2772") { return "09JingJi"; }
	if ($num eq "2773") { return "09JingJi"; }
	if ($num eq "2774") { return "09JingJi"; }
	if ($num eq "2775") { return "09JingJi"; }
	if ($num eq "2776") { return "09JingJi"; }
	if ($num eq "2777") { return "09JingJi"; }
	if ($num eq "2778") { return "09JingJi"; }
	if ($num eq "2824") { return "09JingJi"; }
	if ($num eq "0477") { return "09JingJi"; }
	if ($num eq "0478") { return "09JingJi"; }
	if ($num eq "0479") { return "09JingJi"; }
	if ($num eq "0480") { return "09JingJi"; }
	if ($num eq "0481") { return "09JingJi"; }
	if ($num eq "0482") { return "09JingJi"; }
	if ($num eq "0483") { return "09JingJi"; }
	if ($num eq "0484") { return "09JingJi"; }
	if ($num eq "0485") { return "09JingJi"; }
	if ($num eq "0486") { return "09JingJi"; }
	if ($num eq "0487") { return "09JingJi"; }
	if ($num eq "0488") { return "09JingJi"; }
	if ($num eq "0489") { return "09JingJi"; }
	if ($num eq "0490") { return "09JingJi"; }
	if ($num eq "0491") { return "09JingJi"; }
	if ($num eq "0492a") { return "09JingJi"; }
	if ($num eq "0492b") { return "09JingJi"; }
	if ($num eq "0493") { return "09JingJi"; }
	if ($num eq "0494") { return "09JingJi"; }
	if ($num eq "0495") { return "09JingJi"; }
	if ($num eq "0496") { return "09JingJi"; }
	if ($num eq "0497") { return "09JingJi"; }
	if ($num eq "0498") { return "09JingJi"; }
	if ($num eq "0499") { return "09JingJi"; }
	if ($num eq "0500") { return "09JingJi"; }
	if ($num eq "0501") { return "09JingJi"; }
	if ($num eq "0502") { return "09JingJi"; }
	if ($num eq "0503") { return "09JingJi"; }
	if ($num eq "0504") { return "09JingJi"; }
	if ($num eq "0505") { return "09JingJi"; }
	if ($num eq "0506") { return "09JingJi"; }
	if ($num eq "0507") { return "09JingJi"; }
	if ($num eq "0508") { return "09JingJi"; }
	if ($num eq "0509") { return "09JingJi"; }
	if ($num eq "0510") { return "09JingJi"; }
	if ($num eq "0511") { return "09JingJi"; }
	if ($num eq "0512") { return "09JingJi"; }
	if ($num eq "0513") { return "09JingJi"; }
	if ($num eq "0514") { return "09JingJi"; }
	if ($num eq "0515") { return "09JingJi"; }
	if ($num eq "0516") { return "09JingJi"; }
	if ($num eq "0517") { return "09JingJi"; }
	if ($num eq "0518") { return "09JingJi"; }
	if ($num eq "0519") { return "09JingJi"; }
	if ($num eq "0520") { return "09JingJi"; }
	if ($num eq "0521") { return "09JingJi"; }
	if ($num eq "0522") { return "09JingJi"; }
	if ($num eq "0523") { return "09JingJi"; }
	if ($num eq "0524") { return "09JingJi"; }
	if ($num eq "0525") { return "09JingJi"; }
	if ($num eq "0526") { return "09JingJi"; }
	if ($num eq "0527") { return "09JingJi"; }
	if ($num eq "0528") { return "09JingJi"; }
	if ($num eq "0529") { return "09JingJi"; }
	if ($num eq "0530") { return "09JingJi"; }
	if ($num eq "0531") { return "09JingJi"; }
	if ($num eq "0532") { return "09JingJi"; }
	if ($num eq "0533") { return "09JingJi"; }
	if ($num eq "0534") { return "09JingJi"; }
	if ($num eq "0535") { return "09JingJi"; }
	if ($num eq "0536") { return "09JingJi"; }
	if ($num eq "0537") { return "09JingJi"; }
	if ($num eq "0538") { return "09JingJi"; }
	if ($num eq "0539") { return "09JingJi"; }
	if ($num eq "0540a") { return "09JingJi"; }
	if ($num eq "0540b") { return "09JingJi"; }
	if ($num eq "0541") { return "09JingJi"; }
	if ($num eq "0542") { return "09JingJi"; }
	if ($num eq "0543") { return "09JingJi"; }
	if ($num eq "0544") { return "09JingJi"; }
	if ($num eq "0545") { return "09JingJi"; }
	if ($num eq "0546") { return "09JingJi"; }
	if ($num eq "0547") { return "09JingJi"; }
	if ($num eq "0548") { return "09JingJi"; }
	if ($num eq "0549") { return "09JingJi"; }
	if ($num eq "0550") { return "09JingJi"; }
	if ($num eq "0551") { return "09JingJi"; }
	if ($num eq "0552") { return "09JingJi"; }
	if ($num eq "0553") { return "09JingJi"; }
	if ($num eq "0554") { return "09JingJi"; }
	if ($num eq "0555a") { return "09JingJi"; }
	if ($num eq "0555b") { return "09JingJi"; }
	if ($num eq "0556") { return "09JingJi"; }
	if ($num eq "0557") { return "09JingJi"; }
	if ($num eq "0558") { return "09JingJi"; }
	if ($num eq "0559") { return "09JingJi"; }
	if ($num eq "0560") { return "09JingJi"; }
	if ($num eq "0561") { return "09JingJi"; }
	if ($num eq "0562") { return "09JingJi"; }
	if ($num eq "0563") { return "09JingJi"; }
	if ($num eq "0564") { return "09JingJi"; }
	if ($num eq "0565") { return "09JingJi"; }
	if ($num eq "0566") { return "09JingJi"; }
	if ($num eq "0567") { return "09JingJi"; }
	if ($num eq "0568") { return "09JingJi"; }
	if ($num eq "0569") { return "09JingJi"; }
	if ($num eq "0570") { return "09JingJi"; }
	if ($num eq "0571") { return "09JingJi"; }
	if ($num eq "0572") { return "09JingJi"; }
	if ($num eq "0573") { return "09JingJi"; }
	if ($num eq "0574") { return "09JingJi"; }
	if ($num eq "0575") { return "09JingJi"; }
	if ($num eq "0576") { return "09JingJi"; }
	if ($num eq "0577") { return "09JingJi"; }
	if ($num eq "0578") { return "09JingJi"; }
	if ($num eq "0579") { return "09JingJi"; }
	if ($num eq "0580") { return "09JingJi"; }
	if ($num eq "0581") { return "09JingJi"; }
	if ($num eq "0582") { return "09JingJi"; }
	if ($num eq "0583") { return "09JingJi"; }
	if ($num eq "0584") { return "09JingJi"; }
	if ($num eq "0585") { return "09JingJi"; }
	if ($num eq "0586") { return "09JingJi"; }
	if ($num eq "0587") { return "09JingJi"; }
	if ($num eq "0588") { return "09JingJi"; }
	if ($num eq "0589") { return "09JingJi"; }
	if ($num eq "0590") { return "09JingJi"; }
	if ($num eq "0591") { return "09JingJi"; }
	if ($num eq "0592") { return "09JingJi"; }
	if ($num eq "2786") { return "09JingJi"; }
	if ($num eq "0593") { return "09JingJi"; }
	if ($num eq "0594") { return "09JingJi"; }
	if ($num eq "0595") { return "09JingJi"; }
	if ($num eq "0596") { return "09JingJi"; }
	if ($num eq "0597") { return "09JingJi"; }
	if ($num eq "0598") { return "09JingJi"; }
	if ($num eq "0599") { return "09JingJi"; }
	if ($num eq "0600") { return "09JingJi"; }
	if ($num eq "0601") { return "09JingJi"; }
	if ($num eq "0602") { return "09JingJi"; }
	if ($num eq "0603") { return "09JingJi"; }
	if ($num eq "0604") { return "09JingJi"; }
	if ($num eq "0605") { return "09JingJi"; }
	if ($num eq "0606") { return "09JingJi"; }
	if ($num eq "0607") { return "09JingJi"; }
	if ($num eq "0608") { return "09JingJi"; }
	if ($num eq "0609") { return "09JingJi"; }
	if ($num eq "0610") { return "09JingJi"; }
	if ($num eq "0611") { return "09JingJi"; }
	if ($num eq "0612") { return "09JingJi"; }
	if ($num eq "0613") { return "09JingJi"; }
	if ($num eq "0614") { return "09JingJi"; }
	if ($num eq "0615") { return "09JingJi"; }
	if ($num eq "0616") { return "09JingJi"; }
	if ($num eq "0617") { return "09JingJi"; }
	if ($num eq "0618") { return "09JingJi"; }
	if ($num eq "0619") { return "09JingJi"; }
	if ($num eq "0620") { return "09JingJi"; }
	if ($num eq "0621") { return "09JingJi"; }
	if ($num eq "0622") { return "09JingJi"; }
	if ($num eq "0623") { return "09JingJi"; }
	if ($num eq "0624") { return "09JingJi"; }
	if ($num eq "0625") { return "09JingJi"; }
	if ($num eq "0626") { return "09JingJi"; }
	if ($num eq "0627") { return "09JingJi"; }
	if ($num eq "0628") { return "09JingJi"; }
	if ($num eq "0629") { return "09JingJi"; }
	if ($num eq "0630") { return "09JingJi"; }
	if ($num eq "0631") { return "09JingJi"; }
	if ($num eq "0632") { return "09JingJi"; }
	if ($num eq "0633") { return "09JingJi"; }
	if ($num eq "0634") { return "09JingJi"; }
	if ($num eq "0635") { return "09JingJi"; }
	if ($num eq "0636") { return "09JingJi"; }
	if ($num eq "0637") { return "09JingJi"; }
	if ($num eq "0638") { return "09JingJi"; }
	if ($num eq "0639") { return "09JingJi"; }
	if ($num eq "0640") { return "09JingJi"; }
	if ($num eq "0641") { return "09JingJi"; }
	if ($num eq "0642") { return "09JingJi"; }
	if ($num eq "0643") { return "09JingJi"; }
	if ($num eq "0644") { return "09JingJi"; }
	if ($num eq "0645") { return "09JingJi"; }
	if ($num eq "0646") { return "09JingJi"; }
	if ($num eq "0647") { return "09JingJi"; }
	if ($num eq "0648") { return "09JingJi"; }
	if ($num eq "0649") { return "09JingJi"; }
	if ($num eq "0650") { return "09JingJi"; }
	if ($num eq "0651") { return "09JingJi"; }
	if ($num eq "0652") { return "09JingJi"; }
	if ($num eq "0653") { return "09JingJi"; }
	if ($num eq "0654") { return "09JingJi"; }
	if ($num eq "0655") { return "09JingJi"; }
	if ($num eq "0656") { return "09JingJi"; }
	if ($num eq "0657") { return "09JingJi"; }
	if ($num eq "0658") { return "09JingJi"; }
	if ($num eq "0659") { return "09JingJi"; }
	if ($num eq "0660") { return "09JingJi"; }
	if ($num eq "0661") { return "09JingJi"; }
	if ($num eq "0662") { return "09JingJi"; }
	if ($num eq "0663") { return "09JingJi"; }
	if ($num eq "0664") { return "09JingJi"; }
	if ($num eq "0665") { return "09JingJi"; }
	if ($num eq "1783") { return "09JingJi"; }
	if ($num eq "1784") { return "09JingJi"; }
	if ($num eq "1785") { return "09JingJi"; }
	if ($num eq "1786") { return "09JingJi"; }
	if ($num eq "1787") { return "09JingJi"; }
	if ($num eq "1788") { return "09JingJi"; }
	if ($num eq "0666") { return "09JingJi"; }
	if ($num eq "0667") { return "09JingJi"; }
	if ($num eq "0668") { return "09JingJi"; }
	if ($num eq "0669") { return "09JingJi"; }
	if ($num eq "0670") { return "09JingJi"; }
	if ($num eq "0671") { return "09JingJi"; }
	if ($num eq "0672") { return "09JingJi"; }
	if ($num eq "0673") { return "09JingJi"; }
	if ($num eq "0674") { return "09JingJi"; }
	if ($num eq "1789") { return "09JingJi"; }
	if ($num eq "1790") { return "09JingJi"; }
	if ($num eq "1791") { return "09JingJi"; }
	if ($num eq "2779") { return "09JingJi"; }
	if ($num eq "0675") { return "09JingJi"; }
	if ($num eq "0676") { return "09JingJi"; }
	if ($num eq "0677") { return "09JingJi"; }
	if ($num eq "0678") { return "09JingJi"; }
	if ($num eq "0679") { return "09JingJi"; }
	if ($num eq "0680") { return "09JingJi"; }
	if ($num eq "0681") { return "09JingJi"; }
	if ($num eq "0682") { return "09JingJi"; }
	if ($num eq "0683") { return "09JingJi"; }
	if ($num eq "0684") { return "09JingJi"; }
	if ($num eq "0685") { return "09JingJi"; }
	if ($num eq "1792") { return "09JingJi"; }
	if ($num eq "2781") { return "09JingJi"; }
	if ($num eq "0686") { return "09JingJi"; }
	if ($num eq "0687") { return "09JingJi"; }
	if ($num eq "0688") { return "09JingJi"; }
	if ($num eq "0689") { return "09JingJi"; }
	if ($num eq "0690") { return "09JingJi"; }
	if ($num eq "0691") { return "09JingJi"; }
	if ($num eq "0692") { return "09JingJi"; }
	if ($num eq "0693") { return "09JingJi"; }
	if ($num eq "0694") { return "09JingJi"; }
	if ($num eq "0695") { return "09JingJi"; }
	if ($num eq "0696") { return "09JingJi"; }
	if ($num eq "0697") { return "09JingJi"; }
	if ($num eq "0698") { return "09JingJi"; }
	if ($num eq "0699") { return "09JingJi"; }
	if ($num eq "0700") { return "09JingJi"; }
	if ($num eq "0701") { return "09JingJi"; }
	if ($num eq "1793") { return "09JingJi"; }
	if ($num eq "2780") { return "09JingJi"; }
	if ($num eq "0702") { return "09JingJi"; }
	if ($num eq "0703") { return "09JingJi"; }
	if ($num eq "0704") { return "09JingJi"; }
	if ($num eq "0705") { return "09JingJi"; }
	if ($num eq "0706") { return "09JingJi"; }
	if ($num eq "0707") { return "09JingJi"; }
	if ($num eq "0708") { return "09JingJi"; }
	if ($num eq "0709") { return "09JingJi"; }
	if ($num eq "0710") { return "09JingJi"; }
	if ($num eq "0711") { return "09JingJi"; }
	if ($num eq "0712") { return "09JingJi"; }
	if ($num eq "2782") { return "09JingJi"; }
	if ($num eq "2783") { return "09JingJi"; }
	if ($num eq "0713") { return "09JingJi"; }
	if ($num eq "0714") { return "09JingJi"; }
	if ($num eq "0715") { return "09JingJi"; }
	if ($num eq "0716") { return "09JingJi"; }
	if ($num eq "0717") { return "09JingJi"; }
	if ($num eq "0718") { return "09JingJi"; }
	if ($num eq "0719") { return "09JingJi"; }
	if ($num eq "0720") { return "09JingJi"; }
	if ($num eq "0721") { return "09JingJi"; }
	if ($num eq "0722") { return "09JingJi"; }
	if ($num eq "0723") { return "09JingJi"; }
	if ($num eq "0724") { return "09JingJi"; }
	if ($num eq "0725") { return "09JingJi"; }
	if ($num eq "0726") { return "09JingJi"; }
	if ($num eq "0727") { return "09JingJi"; }
	if ($num eq "0728") { return "09JingJi"; }
	if ($num eq "0729") { return "09JingJi"; }
	if ($num eq "0730") { return "09JingJi"; }
	if ($num eq "0731") { return "09JingJi"; }
	if ($num eq "0732") { return "09JingJi"; }
	if ($num eq "0733") { return "09JingJi"; }
	if ($num eq "0734") { return "09JingJi"; }
	if ($num eq "0735") { return "09JingJi"; }
	if ($num eq "0736") { return "09JingJi"; }
	if ($num eq "0737") { return "09JingJi"; }
	if ($num eq "0738") { return "09JingJi"; }
	if ($num eq "0739") { return "09JingJi"; }
	if ($num eq "0740") { return "09JingJi"; }
	if ($num eq "0741") { return "09JingJi"; }
	if ($num eq "0742") { return "09JingJi"; }
	if ($num eq "0743") { return "09JingJi"; }
	if ($num eq "0744") { return "09JingJi"; }
	if ($num eq "0745") { return "09JingJi"; }
	if ($num eq "0746") { return "09JingJi"; }
	if ($num eq "0747a") { return "09JingJi"; }
	if ($num eq "0747b") { return "09JingJi"; }
	if ($num eq "0748") { return "09JingJi"; }
	if ($num eq "0749") { return "09JingJi"; }
	if ($num eq "0750") { return "09JingJi"; }
	if ($num eq "0751a") { return "09JingJi"; }
	if ($num eq "0751b") { return "09JingJi"; }
	if ($num eq "0752") { return "09JingJi"; }
	if ($num eq "0753") { return "09JingJi"; }
	if ($num eq "0754") { return "09JingJi"; }
	if ($num eq "0755") { return "09JingJi"; }
	if ($num eq "0756") { return "09JingJi"; }
	if ($num eq "0757") { return "09JingJi"; }
	if ($num eq "0758") { return "09JingJi"; }
	if ($num eq "0759") { return "09JingJi"; }
	if ($num eq "0760") { return "09JingJi"; }
	if ($num eq "0761") { return "09JingJi"; }
	if ($num eq "0762") { return "09JingJi"; }
	if ($num eq "0763") { return "09JingJi"; }
	if ($num eq "0764") { return "09JingJi"; }
	if ($num eq "0765") { return "09JingJi"; }
	if ($num eq "0766") { return "09JingJi"; }
	if ($num eq "0767") { return "09JingJi"; }
	if ($num eq "0768") { return "09JingJi"; }
	if ($num eq "0769") { return "09JingJi"; }
	if ($num eq "0770") { return "09JingJi"; }
	if ($num eq "0771") { return "09JingJi"; }
	if ($num eq "0772") { return "09JingJi"; }
	if ($num eq "0773") { return "09JingJi"; }
	if ($num eq "0774") { return "09JingJi"; }
	if ($num eq "0775") { return "09JingJi"; }
	if ($num eq "0776") { return "09JingJi"; }
	if ($num eq "0777") { return "09JingJi"; }
	if ($num eq "0778") { return "09JingJi"; }
	if ($num eq "0779") { return "09JingJi"; }
	if ($num eq "0780") { return "09JingJi"; }
	if ($num eq "0781") { return "09JingJi"; }
	if ($num eq "0782") { return "09JingJi"; }
	if ($num eq "0783") { return "09JingJi"; }
	if ($num eq "0784") { return "09JingJi"; }
	if ($num eq "1794") { return "09JingJi"; }
	if ($num eq "0785") { return "09JingJi"; }
	if ($num eq "0786") { return "09JingJi"; }
	if ($num eq "0787") { return "09JingJi"; }
	if ($num eq "0788") { return "09JingJi"; }
	if ($num eq "0789") { return "09JingJi"; }
	if ($num eq "0790") { return "09JingJi"; }
	if ($num eq "0791") { return "09JingJi"; }
	if ($num eq "0792") { return "09JingJi"; }
	if ($num eq "0793") { return "09JingJi"; }
	if ($num eq "0794a") { return "09JingJi"; }
	if ($num eq "0794b") { return "09JingJi"; }
	if ($num eq "0795") { return "09JingJi"; }
	if ($num eq "0796") { return "09JingJi"; }
	if ($num eq "0797a") { return "09JingJi"; }
	if ($num eq "0797b") { return "09JingJi"; }
	if ($num eq "0798") { return "09JingJi"; }
	if ($num eq "0799") { return "09JingJi"; }
	if ($num eq "0800") { return "09JingJi"; }
	if ($num eq "0801") { return "09JingJi"; }
	if ($num eq "0802") { return "09JingJi"; }
	if ($num eq "0803") { return "09JingJi"; }
	if ($num eq "0804") { return "09JingJi"; }
	if ($num eq "0805") { return "09JingJi"; }
	if ($num eq "0806") { return "09JingJi"; }
	if ($num eq "0807") { return "09JingJi"; }
	if ($num eq "0808") { return "09JingJi"; }
	if ($num eq "0809") { return "09JingJi"; }
	if ($num eq "0810") { return "09JingJi"; }
	if ($num eq "0811") { return "09JingJi"; }
	if ($num eq "0812") { return "09JingJi"; }
	if ($num eq "0813") { return "09JingJi"; }
	if ($num eq "0814") { return "09JingJi"; }
	if ($num eq "0815") { return "09JingJi"; }
	if ($num eq "0816") { return "09JingJi"; }
	if ($num eq "0817") { return "09JingJi"; }
	if ($num eq "0818") { return "09JingJi"; }
	if ($num eq "0819") { return "09JingJi"; }
	if ($num eq "0820") { return "09JingJi"; }
	if ($num eq "0821") { return "09JingJi"; }
	if ($num eq "0822") { return "09JingJi"; }
	if ($num eq "0823") { return "09JingJi"; }
	if ($num eq "0824") { return "09JingJi"; }
	if ($num eq "0825") { return "09JingJi"; }
	if ($num eq "0826") { return "09JingJi"; }
	if ($num eq "0827") { return "09JingJi"; }
	if ($num eq "0828") { return "09JingJi"; }
	if ($num eq "0829") { return "09JingJi"; }
	if ($num eq "0830") { return "09JingJi"; }
	if ($num eq "0831") { return "09JingJi"; }
	if ($num eq "0832") { return "09JingJi"; }
	if ($num eq "0833") { return "09JingJi"; }
	if ($num eq "0834") { return "09JingJi"; }
	if ($num eq "0835") { return "09JingJi"; }
	if ($num eq "0836") { return "09JingJi"; }
	if ($num eq "0837") { return "09JingJi"; }
	if ($num eq "0838") { return "09JingJi"; }
	if ($num eq "0839") { return "09JingJi"; }
	if ($num eq "0840") { return "09JingJi"; }
	if ($num eq "0841") { return "09JingJi"; }
	if ($num eq "0842") { return "09JingJi"; }
	if ($num eq "1795") { return "09JingJi"; }
	if ($num eq "0843") { return "09JingJi"; }
	if ($num eq "0844") { return "09JingJi"; }
	if ($num eq "0845") { return "09JingJi"; }
	if ($num eq "0846") { return "09JingJi"; }
	if ($num eq "0847") { return "09JingJi"; }
	if ($num eq "1530") { return "09JingJi"; }
	if ($num eq "1531") { return "09JingJi"; }
	if ($num eq "1532") { return "09JingJi"; }
	if ($num eq "1533") { return "09JingJi"; }
	if ($num eq "1534") { return "09JingJi"; }
	if ($num eq "1535") { return "09JingJi"; }
	if ($num eq "2784") { return "09JingJi"; }
	if ($num eq "2785") { return "09JingJi"; }
	if ($num eq "0848") { return "10MiJiao"; }
	if ($num eq "0849") { return "10MiJiao"; }
	if ($num eq "0850") { return "10MiJiao"; }
	if ($num eq "0851") { return "10MiJiao"; }
	if ($num eq "0852a") { return "10MiJiao"; }
	if ($num eq "0852b") { return "10MiJiao"; }
	if ($num eq "0853") { return "10MiJiao"; }
	if ($num eq "0854") { return "10MiJiao"; }
	if ($num eq "0855") { return "10MiJiao"; }
	if ($num eq "0856") { return "10MiJiao"; }
	if ($num eq "0857") { return "10MiJiao"; }
	if ($num eq "0858") { return "10MiJiao"; }
	if ($num eq "0859") { return "10MiJiao"; }
	if ($num eq "0860") { return "10MiJiao"; }
	if ($num eq "0861") { return "10MiJiao"; }
	if ($num eq "0862") { return "10MiJiao"; }
	if ($num eq "0863") { return "10MiJiao"; }
	if ($num eq "0864A") { return "10MiJiao"; }
	if ($num eq "0864B") { return "10MiJiao"; }
	if ($num eq "0865") { return "10MiJiao"; }
	if ($num eq "0866") { return "10MiJiao"; }
	if ($num eq "0867") { return "10MiJiao"; }
	if ($num eq "0868") { return "10MiJiao"; }
	if ($num eq "0869") { return "10MiJiao"; }
	if ($num eq "0870") { return "10MiJiao"; }
	if ($num eq "0871") { return "10MiJiao"; }
	if ($num eq "0872") { return "10MiJiao"; }
	if ($num eq "0873") { return "10MiJiao"; }
	if ($num eq "0874") { return "10MiJiao"; }
	if ($num eq "0875") { return "10MiJiao"; }
	if ($num eq "0876") { return "10MiJiao"; }
	if ($num eq "0877") { return "10MiJiao"; }
	if ($num eq "0878") { return "10MiJiao"; }
	if ($num eq "0879") { return "10MiJiao"; }
	if ($num eq "0880") { return "10MiJiao"; }
	if ($num eq "0881") { return "10MiJiao"; }
	if ($num eq "0882") { return "10MiJiao"; }
	if ($num eq "0883") { return "10MiJiao"; }
	if ($num eq "0884") { return "10MiJiao"; }
	if ($num eq "0885") { return "10MiJiao"; }
	if ($num eq "0886") { return "10MiJiao"; }
	if ($num eq "0887") { return "10MiJiao"; }
	if ($num eq "0888") { return "10MiJiao"; }
	if ($num eq "0889") { return "10MiJiao"; }
	if ($num eq "0890") { return "10MiJiao"; }
	if ($num eq "0891") { return "10MiJiao"; }
	if ($num eq "0892") { return "10MiJiao"; }
	if ($num eq "0893a") { return "10MiJiao"; }
	if ($num eq "0893b") { return "10MiJiao"; }
	if ($num eq "0893c") { return "10MiJiao"; }
	if ($num eq "0894a") { return "10MiJiao"; }
	if ($num eq "0894b") { return "10MiJiao"; }
	if ($num eq "0895a") { return "10MiJiao"; }
	if ($num eq "0895b") { return "10MiJiao"; }
	if ($num eq "0896") { return "10MiJiao"; }
	if ($num eq "0897") { return "10MiJiao"; }
	if ($num eq "0898") { return "10MiJiao"; }
	if ($num eq "0899") { return "10MiJiao"; }
	if ($num eq "0900") { return "10MiJiao"; }
	if ($num eq "0901") { return "10MiJiao"; }
	if ($num eq "0902") { return "10MiJiao"; }
	if ($num eq "0903") { return "10MiJiao"; }
	if ($num eq "0904") { return "10MiJiao"; }
	if ($num eq "0905") { return "10MiJiao"; }
	if ($num eq "0906") { return "10MiJiao"; }
	if ($num eq "0907") { return "10MiJiao"; }
	if ($num eq "0908") { return "10MiJiao"; }
	if ($num eq "0909") { return "10MiJiao"; }
	if ($num eq "0910") { return "10MiJiao"; }
	if ($num eq "0911") { return "10MiJiao"; }
	if ($num eq "0912") { return "10MiJiao"; }
	if ($num eq "0913") { return "10MiJiao"; }
	if ($num eq "0914") { return "10MiJiao"; }
	if ($num eq "0915") { return "10MiJiao"; }
	if ($num eq "0916") { return "10MiJiao"; }
	if ($num eq "0917") { return "10MiJiao"; }
	if ($num eq "0918") { return "10MiJiao"; }
	if ($num eq "0919") { return "10MiJiao"; }
	if ($num eq "0920") { return "10MiJiao"; }
	if ($num eq "0921") { return "10MiJiao"; }
	if ($num eq "0922") { return "10MiJiao"; }
	if ($num eq "0923") { return "10MiJiao"; }
	if ($num eq "0924A") { return "10MiJiao"; }
	if ($num eq "0924B") { return "10MiJiao"; }
	if ($num eq "0924C") { return "10MiJiao"; }
	if ($num eq "0925") { return "10MiJiao"; }
	if ($num eq "0926") { return "10MiJiao"; }
	if ($num eq "0927") { return "10MiJiao"; }
	if ($num eq "0928") { return "10MiJiao"; }
	if ($num eq "0929") { return "10MiJiao"; }
	if ($num eq "0930") { return "10MiJiao"; }
	if ($num eq "0931") { return "10MiJiao"; }
	if ($num eq "0932") { return "10MiJiao"; }
	if ($num eq "0933") { return "10MiJiao"; }
	if ($num eq "0934") { return "10MiJiao"; }
	if ($num eq "0935") { return "10MiJiao"; }
	if ($num eq "0936") { return "10MiJiao"; }
	if ($num eq "0937") { return "10MiJiao"; }
	if ($num eq "0938") { return "10MiJiao"; }
	if ($num eq "0939") { return "10MiJiao"; }
	if ($num eq "0940") { return "10MiJiao"; }
	if ($num eq "0941") { return "10MiJiao"; }
	if ($num eq "0942") { return "10MiJiao"; }
	if ($num eq "0943") { return "10MiJiao"; }
	if ($num eq "0944A") { return "10MiJiao"; }
	if ($num eq "0944B") { return "10MiJiao"; }
	if ($num eq "0945") { return "10MiJiao"; }
	if ($num eq "0946") { return "10MiJiao"; }
	if ($num eq "0947") { return "10MiJiao"; }
	if ($num eq "0948") { return "10MiJiao"; }
	if ($num eq "0949") { return "10MiJiao"; }
	if ($num eq "0950") { return "10MiJiao"; }
	if ($num eq "0951") { return "10MiJiao"; }
	if ($num eq "0952") { return "10MiJiao"; }
	if ($num eq "0953") { return "10MiJiao"; }
	if ($num eq "0954A") { return "10MiJiao"; }
	if ($num eq "0954B") { return "10MiJiao"; }
	if ($num eq "0955") { return "10MiJiao"; }
	if ($num eq "0956") { return "10MiJiao"; }
	if ($num eq "0957") { return "10MiJiao"; }
	if ($num eq "0958") { return "10MiJiao"; }
	if ($num eq "0959") { return "10MiJiao"; }
	if ($num eq "0960") { return "10MiJiao"; }
	if ($num eq "0961") { return "10MiJiao"; }
	if ($num eq "0962") { return "10MiJiao"; }
	if ($num eq "0963") { return "10MiJiao"; }
	if ($num eq "0964") { return "10MiJiao"; }
	if ($num eq "0965") { return "10MiJiao"; }
	if ($num eq "0966") { return "10MiJiao"; }
	if ($num eq "0967") { return "10MiJiao"; }
	if ($num eq "0968") { return "10MiJiao"; }
	if ($num eq "0969") { return "10MiJiao"; }
	if ($num eq "0970") { return "10MiJiao"; }
	if ($num eq "0971") { return "10MiJiao"; }
	if ($num eq "0972") { return "10MiJiao"; }
	if ($num eq "0973") { return "10MiJiao"; }
	if ($num eq "0974A") { return "10MiJiao"; }
	if ($num eq "0974B") { return "10MiJiao"; }
	if ($num eq "0974C") { return "10MiJiao"; }
	if ($num eq "0974D") { return "10MiJiao"; }
	if ($num eq "0974E") { return "10MiJiao"; }
	if ($num eq "0974F") { return "10MiJiao"; }
	if ($num eq "0975") { return "10MiJiao"; }
	if ($num eq "0976") { return "10MiJiao"; }
	if ($num eq "0977") { return "10MiJiao"; }
	if ($num eq "0978") { return "10MiJiao"; }
	if ($num eq "0979") { return "10MiJiao"; }
	if ($num eq "0980") { return "10MiJiao"; }
	if ($num eq "0981") { return "10MiJiao"; }
	if ($num eq "0982") { return "10MiJiao"; }
	if ($num eq "0983A") { return "10MiJiao"; }
	if ($num eq "0983B") { return "10MiJiao"; }
	if ($num eq "0984") { return "10MiJiao"; }
	if ($num eq "0985") { return "10MiJiao"; }
	if ($num eq "0986") { return "10MiJiao"; }
	if ($num eq "0987") { return "10MiJiao"; }
	if ($num eq "0988") { return "10MiJiao"; }
	if ($num eq "0989") { return "10MiJiao"; }
	if ($num eq "0990") { return "10MiJiao"; }
	if ($num eq "0991") { return "10MiJiao"; }
	if ($num eq "0992") { return "10MiJiao"; }
	if ($num eq "0993") { return "10MiJiao"; }
	if ($num eq "0994") { return "10MiJiao"; }
	if ($num eq "0995") { return "10MiJiao"; }
	if ($num eq "0996") { return "10MiJiao"; }
	if ($num eq "0997") { return "10MiJiao"; }
	if ($num eq "0998") { return "10MiJiao"; }
	if ($num eq "0999") { return "10MiJiao"; }
	if ($num eq "1000") { return "10MiJiao"; }
	if ($num eq "1001") { return "10MiJiao"; }
	if ($num eq "1002") { return "10MiJiao"; }
	if ($num eq "1003") { return "10MiJiao"; }
	if ($num eq "1004") { return "10MiJiao"; }
	if ($num eq "1005A") { return "10MiJiao"; }
	if ($num eq "1005B") { return "10MiJiao"; }
	if ($num eq "1006") { return "10MiJiao"; }
	if ($num eq "1007") { return "10MiJiao"; }
	if ($num eq "1008") { return "10MiJiao"; }
	if ($num eq "1009") { return "10MiJiao"; }
	if ($num eq "1010") { return "10MiJiao"; }
	if ($num eq "1011") { return "10MiJiao"; }
	if ($num eq "1012") { return "10MiJiao"; }
	if ($num eq "1013") { return "10MiJiao"; }
	if ($num eq "1014") { return "10MiJiao"; }
	if ($num eq "1015") { return "10MiJiao"; }
	if ($num eq "1016") { return "10MiJiao"; }
	if ($num eq "1017") { return "10MiJiao"; }
	if ($num eq "1018") { return "10MiJiao"; }
	if ($num eq "1019") { return "10MiJiao"; }
	if ($num eq "1020") { return "10MiJiao"; }
	if ($num eq "1021") { return "10MiJiao"; }
	if ($num eq "1022A") { return "10MiJiao"; }
	if ($num eq "1022B") { return "10MiJiao"; }
	if ($num eq "1023") { return "10MiJiao"; }
	if ($num eq "1024") { return "10MiJiao"; }
	if ($num eq "1025") { return "10MiJiao"; }
	if ($num eq "1026") { return "10MiJiao"; }
	if ($num eq "1027a") { return "10MiJiao"; }
	if ($num eq "1027b") { return "10MiJiao"; }
	if ($num eq "1028A") { return "10MiJiao"; }
	if ($num eq "1028B") { return "10MiJiao"; }
	if ($num eq "1029") { return "10MiJiao"; }
	if ($num eq "1030") { return "10MiJiao"; }
	if ($num eq "1031") { return "10MiJiao"; }
	if ($num eq "1032") { return "10MiJiao"; }
	if ($num eq "1033") { return "10MiJiao"; }
	if ($num eq "1034") { return "10MiJiao"; }
	if ($num eq "1035") { return "10MiJiao"; }
	if ($num eq "1036") { return "10MiJiao"; }
	if ($num eq "1037") { return "10MiJiao"; }
	if ($num eq "1038") { return "10MiJiao"; }
	if ($num eq "1039") { return "10MiJiao"; }
	if ($num eq "1040") { return "10MiJiao"; }
	if ($num eq "1041") { return "10MiJiao"; }
	if ($num eq "1042") { return "10MiJiao"; }
	if ($num eq "1043") { return "10MiJiao"; }
	if ($num eq "1044") { return "10MiJiao"; }
	if ($num eq "1045a") { return "10MiJiao"; }
	if ($num eq "1045b") { return "10MiJiao"; }
	if ($num eq "1046") { return "10MiJiao"; }
	if ($num eq "1047") { return "10MiJiao"; }
	if ($num eq "1048") { return "10MiJiao"; }
	if ($num eq "1049") { return "10MiJiao"; }
	if ($num eq "1050") { return "10MiJiao"; }
	if ($num eq "1051") { return "10MiJiao"; }
	if ($num eq "1052") { return "10MiJiao"; }
	if ($num eq "1053") { return "10MiJiao"; }
	if ($num eq "1054") { return "10MiJiao"; }
	if ($num eq "1055") { return "10MiJiao"; }
	if ($num eq "1056") { return "10MiJiao"; }
	if ($num eq "1057a") { return "10MiJiao"; }
	if ($num eq "1057b") { return "10MiJiao"; }
	if ($num eq "1058") { return "10MiJiao"; }
	if ($num eq "1059") { return "10MiJiao"; }
	if ($num eq "1060") { return "10MiJiao"; }
	if ($num eq "1061") { return "10MiJiao"; }
	if ($num eq "1062A") { return "10MiJiao"; }
	if ($num eq "1062B") { return "10MiJiao"; }
	if ($num eq "1063") { return "10MiJiao"; }
	if ($num eq "1064") { return "10MiJiao"; }
	if ($num eq "1065") { return "10MiJiao"; }
	if ($num eq "1066") { return "10MiJiao"; }
	if ($num eq "1067") { return "10MiJiao"; }
	if ($num eq "1068") { return "10MiJiao"; }
	if ($num eq "1069") { return "10MiJiao"; }
	if ($num eq "1070") { return "10MiJiao"; }
	if ($num eq "1071") { return "10MiJiao"; }
	if ($num eq "1072A") { return "10MiJiao"; }
	if ($num eq "1072B") { return "10MiJiao"; }
	if ($num eq "1073") { return "10MiJiao"; }
	if ($num eq "1074") { return "10MiJiao"; }
	if ($num eq "1075") { return "10MiJiao"; }
	if ($num eq "1076") { return "10MiJiao"; }
	if ($num eq "1077") { return "10MiJiao"; }
	if ($num eq "1078") { return "10MiJiao"; }
	if ($num eq "1079") { return "10MiJiao"; }
	if ($num eq "1080") { return "10MiJiao"; }
	if ($num eq "1081") { return "10MiJiao"; }
	if ($num eq "1082") { return "10MiJiao"; }
	if ($num eq "1083") { return "10MiJiao"; }
	if ($num eq "1084") { return "10MiJiao"; }
	if ($num eq "1085") { return "10MiJiao"; }
	if ($num eq "1086") { return "10MiJiao"; }
	if ($num eq "1087") { return "10MiJiao"; }
	if ($num eq "1088") { return "10MiJiao"; }
	if ($num eq "1089") { return "10MiJiao"; }
	if ($num eq "1090") { return "10MiJiao"; }
	if ($num eq "1091") { return "10MiJiao"; }
	if ($num eq "1092") { return "10MiJiao"; }
	if ($num eq "1093") { return "10MiJiao"; }
	if ($num eq "1094") { return "10MiJiao"; }
	if ($num eq "1095") { return "10MiJiao"; }
	if ($num eq "1096") { return "10MiJiao"; }
	if ($num eq "1097") { return "10MiJiao"; }
	if ($num eq "1098") { return "10MiJiao"; }
	if ($num eq "1099") { return "10MiJiao"; }
	if ($num eq "1100") { return "10MiJiao"; }
	if ($num eq "1101") { return "10MiJiao"; }
	if ($num eq "1102") { return "10MiJiao"; }
	if ($num eq "1103a") { return "10MiJiao"; }
	if ($num eq "1103b") { return "10MiJiao"; }
	if ($num eq "1104") { return "10MiJiao"; }
	if ($num eq "1105") { return "10MiJiao"; }
	if ($num eq "1106") { return "10MiJiao"; }
	if ($num eq "1107") { return "10MiJiao"; }
	if ($num eq "1109") { return "10MiJiao"; }
	if ($num eq "1108A") { return "10MiJiao"; }
	if ($num eq "1108B") { return "10MiJiao"; }
	if ($num eq "1110") { return "10MiJiao"; }
	if ($num eq "1111") { return "10MiJiao"; }
	if ($num eq "1112") { return "10MiJiao"; }
	if ($num eq "1113A") { return "10MiJiao"; }
	if ($num eq "1113B") { return "10MiJiao"; }
	if ($num eq "1114") { return "10MiJiao"; }
	if ($num eq "1115") { return "10MiJiao"; }
	if ($num eq "1116") { return "10MiJiao"; }
	if ($num eq "1117") { return "10MiJiao"; }
	if ($num eq "1118") { return "10MiJiao"; }
	if ($num eq "1119") { return "10MiJiao"; }
	if ($num eq "1120A") { return "10MiJiao"; }
	if ($num eq "1120B") { return "10MiJiao"; }
	if ($num eq "1121") { return "10MiJiao"; }
	if ($num eq "1122") { return "10MiJiao"; }
	if ($num eq "1123") { return "10MiJiao"; }
	if ($num eq "1124") { return "10MiJiao"; }
	if ($num eq "1125") { return "10MiJiao"; }
	if ($num eq "1126") { return "10MiJiao"; }
	if ($num eq "1127") { return "10MiJiao"; }
	if ($num eq "1128") { return "10MiJiao"; }
	if ($num eq "1129") { return "10MiJiao"; }
	if ($num eq "1130") { return "10MiJiao"; }
	if ($num eq "1131") { return "10MiJiao"; }
	if ($num eq "1132") { return "10MiJiao"; }
	if ($num eq "1133") { return "10MiJiao"; }
	if ($num eq "1134A") { return "10MiJiao"; }
	if ($num eq "1134B") { return "10MiJiao"; }
	if ($num eq "1135") { return "10MiJiao"; }
	if ($num eq "1136") { return "10MiJiao"; }
	if ($num eq "1137") { return "10MiJiao"; }
	if ($num eq "1138a") { return "10MiJiao"; }
	if ($num eq "1138b") { return "10MiJiao"; }
	if ($num eq "1139") { return "10MiJiao"; }
	if ($num eq "1140") { return "10MiJiao"; }
	if ($num eq "1141") { return "10MiJiao"; }
	if ($num eq "1142") { return "10MiJiao"; }
	if ($num eq "1143") { return "10MiJiao"; }
	if ($num eq "1144") { return "10MiJiao"; }
	if ($num eq "1145") { return "10MiJiao"; }
	if ($num eq "1146") { return "10MiJiao"; }
	if ($num eq "1147") { return "10MiJiao"; }
	if ($num eq "1148") { return "10MiJiao"; }
	if ($num eq "1149") { return "10MiJiao"; }
	if ($num eq "1150") { return "10MiJiao"; }
	if ($num eq "1151") { return "10MiJiao"; }
	if ($num eq "1152") { return "10MiJiao"; }
	if ($num eq "1153") { return "10MiJiao"; }
	if ($num eq "1154") { return "10MiJiao"; }
	if ($num eq "1155") { return "10MiJiao"; }
	if ($num eq "1156A") { return "10MiJiao"; }
	if ($num eq "1156B") { return "10MiJiao"; }
	if ($num eq "1157") { return "10MiJiao"; }
	if ($num eq "1158") { return "10MiJiao"; }
	if ($num eq "1159A") { return "10MiJiao"; }
	if ($num eq "1159B") { return "10MiJiao"; }
	if ($num eq "1160") { return "10MiJiao"; }
	if ($num eq "1161") { return "10MiJiao"; }
	if ($num eq "1162") { return "10MiJiao"; }
	if ($num eq "1163") { return "10MiJiao"; }
	if ($num eq "1164") { return "10MiJiao"; }
	if ($num eq "1165") { return "10MiJiao"; }
	if ($num eq "1166") { return "10MiJiao"; }
	if ($num eq "1167") { return "10MiJiao"; }
	if ($num eq "1168A") { return "10MiJiao"; }
	if ($num eq "1168B") { return "10MiJiao"; }
	if ($num eq "1169") { return "10MiJiao"; }
	if ($num eq "1170") { return "10MiJiao"; }
	if ($num eq "1171") { return "10MiJiao"; }
	if ($num eq "1172") { return "10MiJiao"; }
	if ($num eq "1173") { return "10MiJiao"; }
	if ($num eq "1174") { return "10MiJiao"; }
	if ($num eq "1175") { return "10MiJiao"; }
	if ($num eq "1176") { return "10MiJiao"; }
	if ($num eq "1177A") { return "10MiJiao"; }
	if ($num eq "1177B") { return "10MiJiao"; }
	if ($num eq "1178") { return "10MiJiao"; }
	if ($num eq "1179") { return "10MiJiao"; }
	if ($num eq "1180") { return "10MiJiao"; }
	if ($num eq "1181") { return "10MiJiao"; }
	if ($num eq "1182") { return "10MiJiao"; }
	if ($num eq "1183") { return "10MiJiao"; }
	if ($num eq "1184") { return "10MiJiao"; }
	if ($num eq "1185A") { return "10MiJiao"; }
	if ($num eq "1185B") { return "10MiJiao"; }
	if ($num eq "1186") { return "10MiJiao"; }
	if ($num eq "1187") { return "10MiJiao"; }
	if ($num eq "1188") { return "10MiJiao"; }
	if ($num eq "1189") { return "10MiJiao"; }
	if ($num eq "1190") { return "10MiJiao"; }
	if ($num eq "1191") { return "10MiJiao"; }
	if ($num eq "1192") { return "10MiJiao"; }
	if ($num eq "1193") { return "10MiJiao"; }
	if ($num eq "1194") { return "10MiJiao"; }
	if ($num eq "1195") { return "10MiJiao"; }
	if ($num eq "1196") { return "10MiJiao"; }
	if ($num eq "1197") { return "10MiJiao"; }
	if ($num eq "1198") { return "10MiJiao"; }
	if ($num eq "1199") { return "10MiJiao"; }
	if ($num eq "1200") { return "10MiJiao"; }
	if ($num eq "1201") { return "10MiJiao"; }
	if ($num eq "1202") { return "10MiJiao"; }
	if ($num eq "1203") { return "10MiJiao"; }
	if ($num eq "1204") { return "10MiJiao"; }
	if ($num eq "1205") { return "10MiJiao"; }
	if ($num eq "1206") { return "10MiJiao"; }
	if ($num eq "1207") { return "10MiJiao"; }
	if ($num eq "1208") { return "10MiJiao"; }
	if ($num eq "1209") { return "10MiJiao"; }
	if ($num eq "1210") { return "10MiJiao"; }
	if ($num eq "1211") { return "10MiJiao"; }
	if ($num eq "1212") { return "10MiJiao"; }
	if ($num eq "1213") { return "10MiJiao"; }
	if ($num eq "1214") { return "10MiJiao"; }
	if ($num eq "1215") { return "10MiJiao"; }
	if ($num eq "1216") { return "10MiJiao"; }
	if ($num eq "1217") { return "10MiJiao"; }
	if ($num eq "1218") { return "10MiJiao"; }
	if ($num eq "1219") { return "10MiJiao"; }
	if ($num eq "1220") { return "10MiJiao"; }
	if ($num eq "1221") { return "10MiJiao"; }
	if ($num eq "1222a") { return "10MiJiao"; }
	if ($num eq "1222b") { return "10MiJiao"; }
	if ($num eq "1223") { return "10MiJiao"; }
	if ($num eq "1224") { return "10MiJiao"; }
	if ($num eq "1225") { return "10MiJiao"; }
	if ($num eq "1226") { return "10MiJiao"; }
	if ($num eq "1227") { return "10MiJiao"; }
	if ($num eq "1228") { return "10MiJiao"; }
	if ($num eq "1229") { return "10MiJiao"; }
	if ($num eq "1230") { return "10MiJiao"; }
	if ($num eq "1231") { return "10MiJiao"; }
	if ($num eq "1232") { return "10MiJiao"; }
	if ($num eq "1233") { return "10MiJiao"; }
	if ($num eq "1234") { return "10MiJiao"; }
	if ($num eq "1235") { return "10MiJiao"; }
	if ($num eq "1236") { return "10MiJiao"; }
	if ($num eq "1237") { return "10MiJiao"; }
	if ($num eq "1238") { return "10MiJiao"; }
	if ($num eq "1239") { return "10MiJiao"; }
	if ($num eq "1240") { return "10MiJiao"; }
	if ($num eq "1241") { return "10MiJiao"; }
	if ($num eq "1242") { return "10MiJiao"; }
	if ($num eq "1243") { return "10MiJiao"; }
	if ($num eq "1244") { return "10MiJiao"; }
	if ($num eq "1245") { return "10MiJiao"; }
	if ($num eq "1246") { return "10MiJiao"; }
	if ($num eq "1247") { return "10MiJiao"; }
	if ($num eq "1248") { return "10MiJiao"; }
	if ($num eq "1249") { return "10MiJiao"; }
	if ($num eq "1250") { return "10MiJiao"; }
	if ($num eq "1251") { return "10MiJiao"; }
	if ($num eq "1252a") { return "10MiJiao"; }
	if ($num eq "1252b") { return "10MiJiao"; }
	if ($num eq "1253") { return "10MiJiao"; }
	if ($num eq "1254") { return "10MiJiao"; }
	if ($num eq "1255a") { return "10MiJiao"; }
	if ($num eq "1255b") { return "10MiJiao"; }
	if ($num eq "1256") { return "10MiJiao"; }
	if ($num eq "1257") { return "10MiJiao"; }
	if ($num eq "1258") { return "10MiJiao"; }
	if ($num eq "1259") { return "10MiJiao"; }
	if ($num eq "1260") { return "10MiJiao"; }
	if ($num eq "1261") { return "10MiJiao"; }
	if ($num eq "1262") { return "10MiJiao"; }
	if ($num eq "1263") { return "10MiJiao"; }
	if ($num eq "1264a") { return "10MiJiao"; }
	if ($num eq "1264b") { return "10MiJiao"; }
	if ($num eq "1265") { return "10MiJiao"; }
	if ($num eq "1266") { return "10MiJiao"; }
	if ($num eq "1267") { return "10MiJiao"; }
	if ($num eq "1268") { return "10MiJiao"; }
	if ($num eq "1269") { return "10MiJiao"; }
	if ($num eq "1270") { return "10MiJiao"; }
	if ($num eq "1271") { return "10MiJiao"; }
	if ($num eq "1272") { return "10MiJiao"; }
	if ($num eq "1273") { return "10MiJiao"; }
	if ($num eq "1274") { return "10MiJiao"; }
	if ($num eq "1275") { return "10MiJiao"; }
	if ($num eq "1276") { return "10MiJiao"; }
	if ($num eq "1277") { return "10MiJiao"; }
	if ($num eq "1278") { return "10MiJiao"; }
	if ($num eq "1279") { return "10MiJiao"; }
	if ($num eq "1280") { return "10MiJiao"; }
	if ($num eq "1281") { return "10MiJiao"; }
	if ($num eq "1282") { return "10MiJiao"; }
	if ($num eq "1283") { return "10MiJiao"; }
	if ($num eq "1284") { return "10MiJiao"; }
	if ($num eq "1285") { return "10MiJiao"; }
	if ($num eq "1286") { return "10MiJiao"; }
	if ($num eq "1287") { return "10MiJiao"; }
	if ($num eq "1288") { return "10MiJiao"; }
	if ($num eq "1289") { return "10MiJiao"; }
	if ($num eq "1290") { return "10MiJiao"; }
	if ($num eq "1291") { return "10MiJiao"; }
	if ($num eq "1292") { return "10MiJiao"; }
	if ($num eq "1293") { return "10MiJiao"; }
	if ($num eq "1294") { return "10MiJiao"; }
	if ($num eq "1295") { return "10MiJiao"; }
	if ($num eq "1296") { return "10MiJiao"; }
	if ($num eq "1297") { return "10MiJiao"; }
	if ($num eq "1298") { return "10MiJiao"; }
	if ($num eq "1299") { return "10MiJiao"; }
	if ($num eq "1300") { return "10MiJiao"; }
	if ($num eq "1301") { return "10MiJiao"; }
	if ($num eq "1302") { return "10MiJiao"; }
	if ($num eq "1303") { return "10MiJiao"; }
	if ($num eq "1304") { return "10MiJiao"; }
	if ($num eq "1305") { return "10MiJiao"; }
	if ($num eq "1306") { return "10MiJiao"; }
	if ($num eq "1307") { return "10MiJiao"; }
	if ($num eq "1308") { return "10MiJiao"; }
	if ($num eq "1309") { return "10MiJiao"; }
	if ($num eq "1310") { return "10MiJiao"; }
	if ($num eq "1311") { return "10MiJiao"; }
	if ($num eq "1312") { return "10MiJiao"; }
	if ($num eq "1313") { return "10MiJiao"; }
	if ($num eq "1314") { return "10MiJiao"; }
	if ($num eq "1315") { return "10MiJiao"; }
	if ($num eq "1316") { return "10MiJiao"; }
	if ($num eq "1317") { return "10MiJiao"; }
	if ($num eq "1318") { return "10MiJiao"; }
	if ($num eq "1319") { return "10MiJiao"; }
	if ($num eq "1320") { return "10MiJiao"; }
	if ($num eq "1321") { return "10MiJiao"; }
	if ($num eq "1322") { return "10MiJiao"; }
	if ($num eq "1323") { return "10MiJiao"; }
	if ($num eq "1324") { return "10MiJiao"; }
	if ($num eq "1325") { return "10MiJiao"; }
	if ($num eq "1326") { return "10MiJiao"; }
	if ($num eq "1327") { return "10MiJiao"; }
	if ($num eq "1328") { return "10MiJiao"; }
	if ($num eq "1329") { return "10MiJiao"; }
	if ($num eq "1330") { return "10MiJiao"; }
	if ($num eq "1331") { return "10MiJiao"; }
	if ($num eq "1332") { return "10MiJiao"; }
	if ($num eq "1333") { return "10MiJiao"; }
	if ($num eq "1334") { return "10MiJiao"; }
	if ($num eq "1335") { return "10MiJiao"; }
	if ($num eq "1336") { return "10MiJiao"; }
	if ($num eq "1337") { return "10MiJiao"; }
	if ($num eq "1338") { return "10MiJiao"; }
	if ($num eq "1339") { return "10MiJiao"; }
	if ($num eq "1340") { return "10MiJiao"; }
	if ($num eq "1341") { return "10MiJiao"; }
	if ($num eq "1342") { return "10MiJiao"; }
	if ($num eq "1343") { return "10MiJiao"; }
	if ($num eq "1344") { return "10MiJiao"; }
	if ($num eq "1345") { return "10MiJiao"; }
	if ($num eq "1346") { return "10MiJiao"; }
	if ($num eq "1347") { return "10MiJiao"; }
	if ($num eq "1348") { return "10MiJiao"; }
	if ($num eq "1349") { return "10MiJiao"; }
	if ($num eq "1350") { return "10MiJiao"; }
	if ($num eq "1351") { return "10MiJiao"; }
	if ($num eq "1352") { return "10MiJiao"; }
	if ($num eq "1353") { return "10MiJiao"; }
	if ($num eq "1354") { return "10MiJiao"; }
	if ($num eq "1355") { return "10MiJiao"; }
	if ($num eq "1356") { return "10MiJiao"; }
	if ($num eq "1357") { return "10MiJiao"; }
	if ($num eq "1358") { return "10MiJiao"; }
	if ($num eq "1359") { return "10MiJiao"; }
	if ($num eq "1360") { return "10MiJiao"; }
	if ($num eq "1361") { return "10MiJiao"; }
	if ($num eq "1362") { return "10MiJiao"; }
	if ($num eq "1363") { return "10MiJiao"; }
	if ($num eq "1364") { return "10MiJiao"; }
	if ($num eq "1365") { return "10MiJiao"; }
	if ($num eq "1366") { return "10MiJiao"; }
	if ($num eq "1367") { return "10MiJiao"; }
	if ($num eq "1368") { return "10MiJiao"; }
	if ($num eq "1369a") { return "10MiJiao"; }
	if ($num eq "1369b") { return "10MiJiao"; }
	if ($num eq "1370") { return "10MiJiao"; }
	if ($num eq "1371") { return "10MiJiao"; }
	if ($num eq "1372") { return "10MiJiao"; }
	if ($num eq "1373") { return "10MiJiao"; }
	if ($num eq "1374") { return "10MiJiao"; }
	if ($num eq "1375") { return "10MiJiao"; }
	if ($num eq "1376") { return "10MiJiao"; }
	if ($num eq "1377") { return "10MiJiao"; }
	if ($num eq "1378a") { return "10MiJiao"; }
	if ($num eq "1378b") { return "10MiJiao"; }
	if ($num eq "1379") { return "10MiJiao"; }
	if ($num eq "1380") { return "10MiJiao"; }
	if ($num eq "1381") { return "10MiJiao"; }
	if ($num eq "1382") { return "10MiJiao"; }
	if ($num eq "1383") { return "10MiJiao"; }
	if ($num eq "1384") { return "10MiJiao"; }
	if ($num eq "1385") { return "10MiJiao"; }
	if ($num eq "1386") { return "10MiJiao"; }
	if ($num eq "1387") { return "10MiJiao"; }
	if ($num eq "1388") { return "10MiJiao"; }
	if ($num eq "1389") { return "10MiJiao"; }
	if ($num eq "1390") { return "10MiJiao"; }
	if ($num eq "1391") { return "10MiJiao"; }
	if ($num eq "1392") { return "10MiJiao"; }
	if ($num eq "1393") { return "10MiJiao"; }
	if ($num eq "1394") { return "10MiJiao"; }
	if ($num eq "1395") { return "10MiJiao"; }
	if ($num eq "1396") { return "10MiJiao"; }
	if ($num eq "1397") { return "10MiJiao"; }
	if ($num eq "1398") { return "10MiJiao"; }
	if ($num eq "1399") { return "10MiJiao"; }
	if ($num eq "1400") { return "10MiJiao"; }
	if ($num eq "1401") { return "10MiJiao"; }
	if ($num eq "1402") { return "10MiJiao"; }
	if ($num eq "1403") { return "10MiJiao"; }
	if ($num eq "1404") { return "10MiJiao"; }
	if ($num eq "1405") { return "10MiJiao"; }
	if ($num eq "1406") { return "10MiJiao"; }
	if ($num eq "1407") { return "10MiJiao"; }
	if ($num eq "1408") { return "10MiJiao"; }
	if ($num eq "1409") { return "10MiJiao"; }
	if ($num eq "1410") { return "10MiJiao"; }
	if ($num eq "1411") { return "10MiJiao"; }
	if ($num eq "1412") { return "10MiJiao"; }
	if ($num eq "1413") { return "10MiJiao"; }
	if ($num eq "1414") { return "10MiJiao"; }
	if ($num eq "1415") { return "10MiJiao"; }
	if ($num eq "1416") { return "10MiJiao"; }
	if ($num eq "1417") { return "10MiJiao"; }
	if ($num eq "1418") { return "10MiJiao"; }
	if ($num eq "1419") { return "10MiJiao"; }
	if ($num eq "1420") { return "10MiJiao"; }
	if ($num eq "1796") { return "10MiJiao"; }
	if ($num eq "1797") { return "10MiJiao"; }
	if ($num eq "1798") { return "10MiJiao"; }
	if ($num eq "1799") { return "10MiJiao"; }
	if ($num eq "1800") { return "10MiJiao"; }
	if ($num eq "1801") { return "10MiJiao"; }
	if ($num eq "1802") { return "10MiJiao"; }
	if ($num eq "1803") { return "10MiJiao"; }
	if ($num eq "1952") { return "10MiJiao"; }
	if ($num eq "1953") { return "10MiJiao"; }
	if ($num eq "1954") { return "10MiJiao"; }
	if ($num eq "1955") { return "10MiJiao"; }
	if ($num eq "1956") { return "10MiJiao"; }
	if ($num eq "1421") { return "11Vinaya"; }
	if ($num eq "1422a") { return "11Vinaya"; }
	if ($num eq "1422b") { return "11Vinaya"; }
	if ($num eq "1423") { return "11Vinaya"; }
	if ($num eq "1424") { return "11Vinaya"; }
	if ($num eq "1425") { return "11Vinaya"; }
	if ($num eq "1426") { return "11Vinaya"; }
	if ($num eq "1427") { return "11Vinaya"; }
	if ($num eq "1428") { return "11Vinaya"; }
	if ($num eq "1429") { return "11Vinaya"; }
	if ($num eq "1430") { return "11Vinaya"; }
	if ($num eq "1431") { return "11Vinaya"; }
	if ($num eq "1432") { return "11Vinaya"; }
	if ($num eq "1433") { return "11Vinaya"; }
	if ($num eq "1434") { return "11Vinaya"; }
	if ($num eq "1435") { return "11Vinaya"; }
	if ($num eq "1436") { return "11Vinaya"; }
	if ($num eq "1437") { return "11Vinaya"; }
	if ($num eq "1438") { return "11Vinaya"; }
	if ($num eq "1439") { return "11Vinaya"; }
	if ($num eq "1440") { return "11Vinaya"; }
	if ($num eq "1441") { return "11Vinaya"; }
	if ($num eq "1442") { return "11Vinaya"; }
	if ($num eq "1443") { return "11Vinaya"; }
	if ($num eq "1444") { return "11Vinaya"; }
	if ($num eq "1445") { return "11Vinaya"; }
	if ($num eq "1446") { return "11Vinaya"; }
	if ($num eq "1447") { return "11Vinaya"; }
	if ($num eq "1448") { return "11Vinaya"; }
	if ($num eq "1449") { return "11Vinaya"; }
	if ($num eq "1450") { return "11Vinaya"; }
	if ($num eq "1451") { return "11Vinaya"; }
	if ($num eq "1452") { return "11Vinaya"; }
	if ($num eq "1453") { return "11Vinaya"; }
	if ($num eq "1454") { return "11Vinaya"; }
	if ($num eq "1455") { return "11Vinaya"; }
	if ($num eq "1456") { return "11Vinaya"; }
	if ($num eq "1457") { return "11Vinaya"; }
	if ($num eq "1458") { return "11Vinaya"; }
	if ($num eq "1459") { return "11Vinaya"; }
	if ($num eq "1460") { return "11Vinaya"; }
	if ($num eq "1461") { return "11Vinaya"; }
	if ($num eq "1462") { return "11Vinaya"; }
	if ($num eq "1463") { return "11Vinaya"; }
	if ($num eq "1464") { return "11Vinaya"; }
	if ($num eq "1465") { return "11Vinaya"; }
	if ($num eq "1466") { return "11Vinaya"; }
	if ($num eq "1467a") { return "11Vinaya"; }
	if ($num eq "1467b") { return "11Vinaya"; }
	if ($num eq "1468") { return "11Vinaya"; }
	if ($num eq "1469") { return "11Vinaya"; }
	if ($num eq "1470") { return "11Vinaya"; }
	if ($num eq "1471") { return "11Vinaya"; }
	if ($num eq "1472") { return "11Vinaya"; }
	if ($num eq "1473") { return "11Vinaya"; }
	if ($num eq "1474") { return "11Vinaya"; }
	if ($num eq "1475") { return "11Vinaya"; }
	if ($num eq "1476") { return "11Vinaya"; }
	if ($num eq "1477") { return "11Vinaya"; }
	if ($num eq "1478") { return "11Vinaya"; }
	if ($num eq "1479") { return "11Vinaya"; }
	if ($num eq "1480") { return "11Vinaya"; }
	if ($num eq "1481") { return "11Vinaya"; }
	if ($num eq "1482") { return "11Vinaya"; }
	if ($num eq "1483a") { return "11Vinaya"; }
	if ($num eq "1483b") { return "11Vinaya"; }
	if ($num eq "1484") { return "11Vinaya"; }
	if ($num eq "1811") { return "11Vinaya"; }
	if ($num eq "1812") { return "11Vinaya"; }
	if ($num eq "1813") { return "11Vinaya"; }
	if ($num eq "1814") { return "11Vinaya"; }
	if ($num eq "1815") { return "11Vinaya"; }
	if ($num eq "2797") { return "11Vinaya"; }
	if ($num eq "1485") { return "11Vinaya"; }
	if ($num eq "2798") { return "11Vinaya"; }
	if ($num eq "1486") { return "11Vinaya"; }
	if ($num eq "1487") { return "11Vinaya"; }
	if ($num eq "1488") { return "11Vinaya"; }
	if ($num eq "1489") { return "11Vinaya"; }
	if ($num eq "1490") { return "11Vinaya"; }
	if ($num eq "1491") { return "11Vinaya"; }
	if ($num eq "1492") { return "11Vinaya"; }
	if ($num eq "1493") { return "11Vinaya"; }
	if ($num eq "1494") { return "11Vinaya"; }
	if ($num eq "1495") { return "11Vinaya"; }
	if ($num eq "1496") { return "11Vinaya"; }
	if ($num eq "1497") { return "11Vinaya"; }
	if ($num eq "1498") { return "11Vinaya"; }
	if ($num eq "1499") { return "11Vinaya"; }
	if ($num eq "1500") { return "11Vinaya"; }
	if ($num eq "1501") { return "11Vinaya"; }
	if ($num eq "1502") { return "11Vinaya"; }
	if ($num eq "1503") { return "11Vinaya"; }
	if ($num eq "1504") { return "11Vinaya"; }
	if ($num eq "1804") { return "11Vinaya"; }
	if ($num eq "1805") { return "11Vinaya"; }
	if ($num eq "1806") { return "11Vinaya"; }
	if ($num eq "1807") { return "11Vinaya"; }
	if ($num eq "1808") { return "11Vinaya"; }
	if ($num eq "1809") { return "11Vinaya"; }
	if ($num eq "1810") { return "11Vinaya"; }
	if ($num eq "2787") { return "11Vinaya"; }
	if ($num eq "2788") { return "11Vinaya"; }
	if ($num eq "2789") { return "11Vinaya"; }
	if ($num eq "2790") { return "11Vinaya"; }
	if ($num eq "2791") { return "11Vinaya"; }
	if ($num eq "2792") { return "11Vinaya"; }
	if ($num eq "2793") { return "11Vinaya"; }
	if ($num eq "2794") { return "11Vinaya"; }
	if ($num eq "2795") { return "11Vinaya"; }
	if ($num eq "2796") { return "11Vinaya"; }
	if ($num eq "1892") { return "11Vinaya"; }
	if ($num eq "1893") { return "11Vinaya"; }
	if ($num eq "1894") { return "11Vinaya"; }
	if ($num eq "1895") { return "11Vinaya"; }
	if ($num eq "1896") { return "11Vinaya"; }
	if ($num eq "1897") { return "11Vinaya"; }
	if ($num eq "1898") { return "11Vinaya"; }
	if ($num eq "1899") { return "11Vinaya"; }
	if ($num eq "1900") { return "11Vinaya"; }
	if ($num eq "1901") { return "11Vinaya"; }
	if ($num eq "1902") { return "11Vinaya"; }
	if ($num eq "1903") { return "11Vinaya"; }
	if ($num eq "1904") { return "11Vinaya"; }
	if ($num eq "1905") { return "11Vinaya"; }
	if ($num eq "1906") { return "11Vinaya"; }
	if ($num eq "1907") { return "11Vinaya"; }
	if ($num eq "1908") { return "11Vinaya"; }
	if ($num eq "1909") { return "11Vinaya"; }
	if ($num eq "1910") { return "11Vinaya"; }
	if ($num eq "1536") { return "12PiTan"; }
	if ($num eq "1537") { return "12PiTan"; }
	if ($num eq "1538") { return "12PiTan"; }
	if ($num eq "1539") { return "12PiTan"; }
	if ($num eq "1540") { return "12PiTan"; }
	if ($num eq "1541") { return "12PiTan"; }
	if ($num eq "1542") { return "12PiTan"; }
	if ($num eq "1543") { return "12PiTan"; }
	if ($num eq "1544") { return "12PiTan"; }
	if ($num eq "1545") { return "12PiTan"; }
	if ($num eq "1546") { return "12PiTan"; }
	if ($num eq "1547") { return "12PiTan"; }
	if ($num eq "1548") { return "12PiTan"; }
	if ($num eq "1549") { return "12PiTan"; }
	if ($num eq "1550") { return "12PiTan"; }
	if ($num eq "1551") { return "12PiTan"; }
	if ($num eq "1552") { return "12PiTan"; }
	if ($num eq "1553") { return "12PiTan"; }
	if ($num eq "1554") { return "12PiTan"; }
	if ($num eq "1555") { return "12PiTan"; }
	if ($num eq "1556") { return "12PiTan"; }
	if ($num eq "1557") { return "12PiTan"; }
	if ($num eq "1558") { return "12PiTan"; }
	if ($num eq "1559") { return "12PiTan"; }
	if ($num eq "1560") { return "12PiTan"; }
	if ($num eq "1561") { return "12PiTan"; }
	if ($num eq "1562") { return "12PiTan"; }
	if ($num eq "1563") { return "12PiTan"; }
	if ($num eq "1821") { return "12PiTan"; }
	if ($num eq "1822") { return "12PiTan"; }
	if ($num eq "1823") { return "12PiTan"; }
	if ($num eq "2840") { return "12PiTan"; }
	if ($num eq "1564") { return "13ZhongGuan"; }
	if ($num eq "1565") { return "13ZhongGuan"; }
	if ($num eq "1566") { return "13ZhongGuan"; }
	if ($num eq "1567") { return "13ZhongGuan"; }
	if ($num eq "1824") { return "13ZhongGuan"; }
	if ($num eq "1568") { return "13ZhongGuan"; }
	if ($num eq "1825") { return "13ZhongGuan"; }
	if ($num eq "1826") { return "13ZhongGuan"; }
	if ($num eq "1569") { return "13ZhongGuan"; }
	if ($num eq "1827") { return "13ZhongGuan"; }
	if ($num eq "1570") { return "13ZhongGuan"; }
	if ($num eq "1571") { return "13ZhongGuan"; }
	if ($num eq "2800") { return "13ZhongGuan"; }
	if ($num eq "1572") { return "13ZhongGuan"; }
	if ($num eq "1573") { return "13ZhongGuan"; }
	if ($num eq "1574") { return "13ZhongGuan"; }
	if ($num eq "1575") { return "13ZhongGuan"; }
	if ($num eq "1576") { return "13ZhongGuan"; }
	if ($num eq "1577") { return "13ZhongGuan"; }
	if ($num eq "1578") { return "13ZhongGuan"; }
	if ($num eq "1852") { return "13ZhongGuan"; }
	if ($num eq "1853") { return "13ZhongGuan"; }
	if ($num eq "1854") { return "13ZhongGuan"; }
	if ($num eq "1855") { return "13ZhongGuan"; }
	if ($num eq "1856") { return "13ZhongGuan"; }
	if ($num eq "1857") { return "13ZhongGuan"; }
	if ($num eq "1858") { return "13ZhongGuan"; }
	if ($num eq "1859") { return "13ZhongGuan"; }
	if ($num eq "1860") { return "13ZhongGuan"; }
	if ($num eq "1579") { return "14Yogacara"; }
	if ($num eq "1580") { return "14Yogacara"; }
	if ($num eq "1581") { return "14Yogacara"; }
	if ($num eq "1582") { return "14Yogacara"; }
	if ($num eq "1583") { return "14Yogacara"; }
	if ($num eq "1584") { return "14Yogacara"; }
	if ($num eq "1828") { return "14Yogacara"; }
	if ($num eq "1829") { return "14Yogacara"; }
	if ($num eq "2801") { return "14Yogacara"; }
	if ($num eq "2802") { return "14Yogacara"; }
	if ($num eq "2803") { return "14Yogacara"; }
	if ($num eq "1585") { return "14Yogacara"; }
	if ($num eq "1586") { return "14Yogacara"; }
	if ($num eq "1587") { return "14Yogacara"; }
	if ($num eq "1618") { return "14Yogacara"; }
	if ($num eq "1830") { return "14Yogacara"; }
	if ($num eq "1831") { return "14Yogacara"; }
	if ($num eq "1832") { return "14Yogacara"; }
	if ($num eq "1833") { return "14Yogacara"; }
	if ($num eq "2804") { return "14Yogacara"; }
	if ($num eq "1588") { return "14Yogacara"; }
	if ($num eq "1589") { return "14Yogacara"; }
	if ($num eq "1590") { return "14Yogacara"; }
	if ($num eq "1591") { return "14Yogacara"; }
	if ($num eq "1834") { return "14Yogacara"; }
	if ($num eq "1592") { return "14Yogacara"; }
	if ($num eq "1593") { return "14Yogacara"; }
	if ($num eq "1594") { return "14Yogacara"; }
	if ($num eq "1595") { return "14Yogacara"; }
	if ($num eq "1596") { return "14Yogacara"; }
	if ($num eq "1597") { return "14Yogacara"; }
	if ($num eq "1598") { return "14Yogacara"; }
	if ($num eq "2805") { return "14Yogacara"; }
	if ($num eq "2806") { return "14Yogacara"; }
	if ($num eq "2807") { return "14Yogacara"; }
	if ($num eq "2808") { return "14Yogacara"; }
	if ($num eq "2809") { return "14Yogacara"; }
	if ($num eq "1599") { return "14Yogacara"; }
	if ($num eq "1600") { return "14Yogacara"; }
	if ($num eq "1601") { return "14Yogacara"; }
	if ($num eq "1616") { return "14Yogacara"; }
	if ($num eq "1835") { return "14Yogacara"; }
	if ($num eq "1602") { return "14Yogacara"; }
	if ($num eq "1603") { return "14Yogacara"; }
	if ($num eq "1617") { return "14Yogacara"; }
	if ($num eq "1604") { return "14Yogacara"; }
	if ($num eq "1605") { return "14Yogacara"; }
	if ($num eq "1606") { return "14Yogacara"; }
	if ($num eq "1607") { return "14Yogacara"; }
	if ($num eq "1608") { return "14Yogacara"; }
	if ($num eq "1609") { return "14Yogacara"; }
	if ($num eq "1610") { return "14Yogacara"; }
	if ($num eq "1611") { return "14Yogacara"; }
	if ($num eq "1626") { return "14Yogacara"; }
	if ($num eq "1627") { return "14Yogacara"; }
	if ($num eq "1838") { return "14Yogacara"; }
	if ($num eq "1612") { return "14Yogacara"; }
	if ($num eq "1613") { return "14Yogacara"; }
	if ($num eq "1614") { return "14Yogacara"; }
	if ($num eq "1836") { return "14Yogacara"; }
	if ($num eq "1837") { return "14Yogacara"; }
	if ($num eq "2810") { return "14Yogacara"; }
	if ($num eq "2811") { return "14Yogacara"; }
	if ($num eq "2812") { return "14Yogacara"; }
	if ($num eq "1615") { return "14Yogacara"; }
	if ($num eq "1619") { return "14Yogacara"; }
	if ($num eq "1624") { return "14Yogacara"; }
	if ($num eq "1625") { return "14Yogacara"; }
	if ($num eq "1620") { return "14Yogacara"; }
	if ($num eq "1621") { return "14Yogacara"; }
	if ($num eq "1622") { return "14Yogacara"; }
	if ($num eq "1623") { return "14Yogacara"; }
	if ($num eq "1851") { return "14Yogacara"; }
	if ($num eq "1861") { return "14Yogacara"; }
	if ($num eq "1862") { return "14Yogacara"; }
	if ($num eq "1863") { return "14Yogacara"; }
	if ($num eq "1864") { return "14Yogacara"; }
	if ($num eq "2823") { return "14Yogacara"; }
	if ($num eq "1865") { return "14Yogacara"; }
	if ($num eq "1628") { return "15LunJi"; }
	if ($num eq "1629") { return "15LunJi"; }
	if ($num eq "1630") { return "15LunJi"; }
	if ($num eq "1631") { return "15LunJi"; }
	if ($num eq "1632") { return "15LunJi"; }
	if ($num eq "1633") { return "15LunJi"; }
	if ($num eq "1839") { return "15LunJi"; }
	if ($num eq "1840") { return "15LunJi"; }
	if ($num eq "1841") { return "15LunJi"; }
	if ($num eq "1842") { return "15LunJi"; }
	if ($num eq "1634") { return "15LunJi"; }
	if ($num eq "1635") { return "15LunJi"; }
	if ($num eq "1636") { return "15LunJi"; }
	if ($num eq "1637") { return "15LunJi"; }
	if ($num eq "1638") { return "15LunJi"; }
	if ($num eq "1639") { return "15LunJi"; }
	if ($num eq "1640") { return "15LunJi"; }
	if ($num eq "1641") { return "15LunJi"; }
	if ($num eq "1642") { return "15LunJi"; }
	if ($num eq "1643") { return "15LunJi"; }
	if ($num eq "1644") { return "15LunJi"; }
	if ($num eq "1645") { return "15LunJi"; }
	if ($num eq "1646") { return "15LunJi"; }
	if ($num eq "1647") { return "15LunJi"; }
	if ($num eq "1648") { return "15LunJi"; }
	if ($num eq "1649") { return "15LunJi"; }
	if ($num eq "1650") { return "15LunJi"; }
	if ($num eq "1651") { return "15LunJi"; }
	if ($num eq "1652") { return "15LunJi"; }
	if ($num eq "1653") { return "15LunJi"; }
	if ($num eq "1654") { return "15LunJi"; }
	if ($num eq "2816") { return "15LunJi"; }
	if ($num eq "1655") { return "15LunJi"; }
	if ($num eq "1656") { return "15LunJi"; }
	if ($num eq "1657") { return "15LunJi"; }
	if ($num eq "1658") { return "15LunJi"; }
	if ($num eq "1659") { return "15LunJi"; }
	if ($num eq "1660") { return "15LunJi"; }
	if ($num eq "1661") { return "15LunJi"; }
	if ($num eq "1662") { return "15LunJi"; }
	if ($num eq "1663") { return "15LunJi"; }
	if ($num eq "1664") { return "15LunJi"; }
	if ($num eq "1665") { return "15LunJi"; }
	if ($num eq "1666") { return "15LunJi"; }
	if ($num eq "1667") { return "15LunJi"; }
	if ($num eq "1668") { return "15LunJi"; }
	if ($num eq "1669") { return "15LunJi"; }
	if ($num eq "1843") { return "15LunJi"; }
	if ($num eq "1844") { return "15LunJi"; }
	if ($num eq "1845") { return "15LunJi"; }
	if ($num eq "1846") { return "15LunJi"; }
	if ($num eq "1847") { return "15LunJi"; }
	if ($num eq "1848") { return "15LunJi"; }
	if ($num eq "1849") { return "15LunJi"; }
	if ($num eq "1850") { return "15LunJi"; }
	if ($num eq "2813") { return "15LunJi"; }
	if ($num eq "2814") { return "15LunJi"; }
	if ($num eq "2815") { return "15LunJi"; }
	if ($num eq "1670A") { return "15LunJi"; }
	if ($num eq "1670B") { return "15LunJi"; }
	if ($num eq "1671") { return "15LunJi"; }
	if ($num eq "1672") { return "15LunJi"; }
	if ($num eq "1673") { return "15LunJi"; }
	if ($num eq "1674") { return "15LunJi"; }
	if ($num eq "1675") { return "15LunJi"; }
	if ($num eq "1676") { return "15LunJi"; }
	if ($num eq "1677") { return "15LunJi"; }
	if ($num eq "1678") { return "15LunJi"; }
	if ($num eq "1679") { return "15LunJi"; }
	if ($num eq "1680") { return "15LunJi"; }
	if ($num eq "1681") { return "15LunJi"; }
	if ($num eq "1682") { return "15LunJi"; }
	if ($num eq "1683") { return "15LunJi"; }
	if ($num eq "1684") { return "15LunJi"; }
	if ($num eq "1685") { return "15LunJi"; }
	if ($num eq "1686") { return "15LunJi"; }
	if ($num eq "1687") { return "15LunJi"; }
	if ($num eq "1688") { return "15LunJi"; }
	if ($num eq "1689") { return "15LunJi"; }
	if ($num eq "1690") { return "15LunJi"; }
	if ($num eq "1691") { return "15LunJi"; }
	if ($num eq "1692") { return "15LunJi"; }
	if ($num eq "1957") { return "16PureLand"; }
	if ($num eq "1978") { return "16PureLand"; }
	if ($num eq "1958") { return "16PureLand"; }
	if ($num eq "1959") { return "16PureLand"; }
	if ($num eq "1979") { return "16PureLand"; }
	if ($num eq "1980") { return "16PureLand"; }
	if ($num eq "1981") { return "16PureLand"; }
	if ($num eq "1960") { return "16PureLand"; }
	if ($num eq "1961") { return "16PureLand"; }
	if ($num eq "1962") { return "16PureLand"; }
	if ($num eq "1963") { return "16PureLand"; }
	if ($num eq "1964") { return "16PureLand"; }
	if ($num eq "1965") { return "16PureLand"; }
	if ($num eq "1966") { return "16PureLand"; }
	if ($num eq "1967") { return "16PureLand"; }
	if ($num eq "1968") { return "16PureLand"; }
	if ($num eq "1969A") { return "16PureLand"; }
	if ($num eq "1969B") { return "16PureLand"; }
	if ($num eq "1970") { return "16PureLand"; }
	if ($num eq "1971") { return "16PureLand"; }
	if ($num eq "1972") { return "16PureLand"; }
	if ($num eq "1973") { return "16PureLand"; }
	if ($num eq "1974") { return "16PureLand"; }
	if ($num eq "1975") { return "16PureLand"; }
	if ($num eq "1976") { return "16PureLand"; }
	if ($num eq "1977") { return "16PureLand"; }
	if ($num eq "1978") { return "16PureLand"; }
	if ($num eq "1979") { return "16PureLand"; }
	if ($num eq "1980") { return "16PureLand"; }
	if ($num eq "1981") { return "16PureLand"; }
	if ($num eq "1982") { return "16PureLand"; }
	if ($num eq "1983") { return "16PureLand"; }
	if ($num eq "1984") { return "16PureLand"; }
	if ($num eq "2826") { return "16PureLand"; }
	if ($num eq "2827") { return "16PureLand"; }
	if ($num eq "2828") { return "16PureLand"; }
	if ($num eq "2829") { return "16PureLand"; }
	if ($num eq "2830A") { return "16PureLand"; }
	if ($num eq "2830B") { return "16PureLand"; }
	if ($num eq "1985") { return "17Chan"; }
	if ($num eq "1992") { return "17Chan"; }
	if ($num eq "1993") { return "17Chan"; }
	if ($num eq "1994A") { return "17Chan"; }
	if ($num eq "1994B") { return "17Chan"; }
	if ($num eq "1995") { return "17Chan"; }
	if ($num eq "1997") { return "17Chan"; }
	if ($num eq "1998A") { return "17Chan"; }
	if ($num eq "1998B") { return "17Chan"; }
	if ($num eq "1999") { return "17Chan"; }
	if ($num eq "2000") { return "17Chan"; }
	if ($num eq "1986A") { return "17Chan"; }
	if ($num eq "1986B") { return "17Chan"; }
	if ($num eq "1987A") { return "17Chan"; }
	if ($num eq "1987B") { return "17Chan"; }
	if ($num eq "2001") { return "17Chan"; }
	if ($num eq "2002A") { return "17Chan"; }
	if ($num eq "2002B") { return "17Chan"; }
	if ($num eq "1988") { return "17Chan"; }
	if ($num eq "1996") { return "17Chan"; }
	if ($num eq "1989") { return "17Chan"; }
	if ($num eq "1990") { return "17Chan"; }
	if ($num eq "1991") { return "17Chan"; }
	if ($num eq "2003") { return "17Chan"; }
	if ($num eq "2004") { return "17Chan"; }
	if ($num eq "2005") { return "17Chan"; }
	if ($num eq "2006") { return "17Chan"; }
	if ($num eq "2007") { return "17Chan"; }
	if ($num eq "2008") { return "17Chan"; }
	if ($num eq "2009") { return "17Chan"; }
	if ($num eq "2010") { return "17Chan"; }
	if ($num eq "2011") { return "17Chan"; }
	if ($num eq "2012A") { return "17Chan"; }
	if ($num eq "2012B") { return "17Chan"; }
	if ($num eq "2013") { return "17Chan"; }
	if ($num eq "2014") { return "17Chan"; }
	if ($num eq "2015") { return "17Chan"; }
	if ($num eq "2016") { return "17Chan"; }
	if ($num eq "2017") { return "17Chan"; }
	if ($num eq "2018") { return "17Chan"; }
	if ($num eq "2019A") { return "17Chan"; }
	if ($num eq "2019B") { return "17Chan"; }
	if ($num eq "2020") { return "17Chan"; }
	if ($num eq "2021") { return "17Chan"; }
	if ($num eq "2022") { return "17Chan"; }
	if ($num eq "2023") { return "17Chan"; }
	if ($num eq "2024") { return "17Chan"; }
	if ($num eq "2025") { return "17Chan"; }
	if ($num eq "2831") { return "17Chan"; }
	if ($num eq "2832") { return "17Chan"; }
	if ($num eq "2833") { return "17Chan"; }
	if ($num eq "2834") { return "17Chan"; }
	if ($num eq "2835") { return "17Chan"; }
	if ($num eq "2836") { return "17Chan"; }
	if ($num eq "2837") { return "17Chan"; }
	if ($num eq "2838") { return "17Chan"; }
	if ($num eq "2839") { return "17Chan"; }
	if ($num eq "2026") { return "18History"; }
	if ($num eq "2027") { return "18History"; }
	if ($num eq "2028") { return "18History"; }
	if ($num eq "2029") { return "18History"; }
	if ($num eq "2030") { return "18History"; }
	if ($num eq "2031") { return "18History"; }
	if ($num eq "2032") { return "18History"; }
	if ($num eq "2033") { return "18History"; }
	if ($num eq "2034") { return "18History"; }
	if ($num eq "2035") { return "18History"; }
	if ($num eq "2036") { return "18History"; }
	if ($num eq "2037") { return "18History"; }
	if ($num eq "2038") { return "18History"; }
	if ($num eq "2039") { return "18History"; }
	if ($num eq "2040") { return "18History"; }
	if ($num eq "2041") { return "18History"; }
	if ($num eq "2042") { return "18History"; }
	if ($num eq "2043") { return "18History"; }
	if ($num eq "2044") { return "18History"; }
	if ($num eq "2045") { return "18History"; }
	if ($num eq "2046") { return "18History"; }
	if ($num eq "2047a") { return "18History"; }
	if ($num eq "2047b") { return "18History"; }
	if ($num eq "2048") { return "18History"; }
	if ($num eq "2049") { return "18History"; }
	if ($num eq "2050") { return "18History"; }
	if ($num eq "2051") { return "18History"; }
	if ($num eq "2052") { return "18History"; }
	if ($num eq "2053") { return "18History"; }
	if ($num eq "2054") { return "18History"; }
	if ($num eq "2055") { return "18History"; }
	if ($num eq "2056") { return "18History"; }
	if ($num eq "2057") { return "18History"; }
	if ($num eq "2058") { return "18History"; }
	if ($num eq "2059") { return "18History"; }
	if ($num eq "2060") { return "18History"; }
	if ($num eq "2061") { return "18History"; }
	if ($num eq "2062") { return "18History"; }
	if ($num eq "2063") { return "18History"; }
	if ($num eq "2064") { return "18History"; }
	if ($num eq "2065") { return "18History"; }
	if ($num eq "2066") { return "18History"; }
	if ($num eq "2126") { return "18History"; }
	if ($num eq "2067") { return "18History"; }
	if ($num eq "2068") { return "18History"; }
	if ($num eq "2069") { return "18History"; }
	if ($num eq "2070") { return "18History"; }
	if ($num eq "2071") { return "18History"; }
	if ($num eq "2072") { return "18History"; }
	if ($num eq "2073") { return "18History"; }
	if ($num eq "2074") { return "18History"; }
	if ($num eq "2075") { return "18History"; }
	if ($num eq "2076") { return "18History"; }
	if ($num eq "2077") { return "18History"; }
	if ($num eq "2078") { return "18History"; }
	if ($num eq "2079") { return "18History"; }
	if ($num eq "2080") { return "18History"; }
	if ($num eq "2081") { return "18History"; }
	if ($num eq "2082") { return "18History"; }
	if ($num eq "2083") { return "18History"; }
	if ($num eq "2084") { return "18History"; }
	if ($num eq "2085") { return "18History"; }
	if ($num eq "2086") { return "18History"; }
	if ($num eq "2087") { return "18History"; }
	if ($num eq "2088") { return "18History"; }
	if ($num eq "2089") { return "18History"; }
	if ($num eq "2090") { return "18History"; }
	if ($num eq "2091") { return "18History"; }
	if ($num eq "2125") { return "18History"; }
	if ($num eq "2092") { return "18History"; }
	if ($num eq "2093") { return "18History"; }
	if ($num eq "2094") { return "18History"; }
	if ($num eq "2095") { return "18History"; }
	if ($num eq "2096") { return "18History"; }
	if ($num eq "2097") { return "18History"; }
	if ($num eq "2098") { return "18History"; }
	if ($num eq "2099") { return "18History"; }
	if ($num eq "2100") { return "18History"; }
	if ($num eq "2101") { return "18History"; }
	if ($num eq "2102") { return "18History"; }
	if ($num eq "2103") { return "18History"; }
	if ($num eq "2104") { return "18History"; }
	if ($num eq "2105") { return "18History"; }
	if ($num eq "2108") { return "18History"; }
	if ($num eq "2109") { return "18History"; }
	if ($num eq "2110") { return "18History"; }
	if ($num eq "2111") { return "18History"; }
	if ($num eq "2112") { return "18History"; }
	if ($num eq "2113") { return "18History"; }
	if ($num eq "2114") { return "18History"; }
	if ($num eq "2115") { return "18History"; }
	if ($num eq "2116") { return "18History"; }
	if ($num eq "2117") { return "18History"; }
	if ($num eq "2118") { return "18History"; }
	if ($num eq "2106") { return "18History"; }
	if ($num eq "2107") { return "18History"; }
	if ($num eq "2119") { return "18History"; }
	if ($num eq "2120") { return "18History"; }
	if ($num eq "2121") { return "19Misc"; }
	if ($num eq "2122") { return "19Misc"; }
	if ($num eq "2123") { return "19Misc"; }
	if ($num eq "2124") { return "19Misc"; }
	if ($num eq "2127") { return "19Misc"; }
	if ($num eq "2128") { return "19Misc"; }
	if ($num eq "2129") { return "19Misc"; }
	if ($num eq "2130") { return "19Misc"; }
	if ($num eq "2131") { return "19Misc"; }
	if ($num eq "2132") { return "19Misc"; }
	if ($num eq "2133A") { return "19Misc"; }
	if ($num eq "2133B") { return "19Misc"; }
	if ($num eq "2134") { return "19Misc"; }
	if ($num eq "2135") { return "19Misc"; }
	if ($num eq "2136") { return "19Misc"; }
	if ($num eq "2817") { return "19Misc"; }
	if ($num eq "2818") { return "19Misc"; }
	if ($num eq "2819") { return "19Misc"; }
	if ($num eq "2820") { return "19Misc"; }
	if ($num eq "2821") { return "19Misc"; }
	if ($num eq "2822") { return "19Misc"; }
	if ($num eq "2825") { return "19Misc"; }
	if ($num eq "2841") { return "19Misc"; }
	if ($num eq "2842") { return "19Misc"; }
	if ($num eq "2843") { return "19Misc"; }
	if ($num eq "2844") { return "19Misc"; }
	if ($num eq "2845") { return "19Misc"; }
	if ($num eq "2846") { return "19Misc"; }
	if ($num eq "2847") { return "19Misc"; }
	if ($num eq "2848") { return "19Misc"; }
	if ($num eq "2849") { return "19Misc"; }
	if ($num eq "2850") { return "19Misc"; }
	if ($num eq "2851") { return "19Misc"; }
	if ($num eq "2852") { return "19Misc"; }
	if ($num eq "2853") { return "19Misc"; }
	if ($num eq "2854") { return "19Misc"; }
	if ($num eq "2855") { return "19Misc"; }
	if ($num eq "2856") { return "19Misc"; }
	if ($num eq "2857") { return "19Misc"; }
	if ($num eq "2858") { return "19Misc"; }
	if ($num eq "2859") { return "19Misc"; }
	if ($num eq "2860") { return "19Misc"; }
	if ($num eq "2861") { return "19Misc"; }
	if ($num eq "2862") { return "19Misc"; }
	if ($num eq "2863") { return "19Misc"; }
	if ($num eq "2864") { return "19Misc"; }
	if ($num eq "2137") { return "19Misc"; }
	if ($num eq "2138") { return "19Misc"; }
	if ($num eq "2139") { return "19Misc"; }
	if ($num eq "2140") { return "19Misc"; }
	if ($num eq "2141A") { return "19Misc"; }
	if ($num eq "2141B") { return "19Misc"; }
	if ($num eq "2142") { return "19Misc"; }
	if ($num eq "2143") { return "19Misc"; }
	if ($num eq "2144") { return "19Misc"; }
	if ($num eq "2145") { return "19Misc"; }
	if ($num eq "2146") { return "19Misc"; }
	if ($num eq "2147") { return "19Misc"; }
	if ($num eq "2148") { return "19Misc"; }
	if ($num eq "2149") { return "19Misc"; }
	if ($num eq "2150") { return "19Misc"; }
	if ($num eq "2151") { return "19Misc"; }
	if ($num eq "2152") { return "19Misc"; }
	if ($num eq "2153") { return "19Misc"; }
	if ($num eq "2154") { return "19Misc"; }
	if ($num eq "2155") { return "19Misc"; }
	if ($num eq "2156") { return "19Misc"; }
	if ($num eq "2157") { return "19Misc"; }
	if ($num eq "2158") { return "19Misc"; }
	if ($num eq "2159") { return "19Misc"; }
	if ($num eq "2160") { return "19Misc"; }
	if ($num eq "2161") { return "19Misc"; }
	if ($num eq "2162") { return "19Misc"; }
	if ($num eq "2163") { return "19Misc"; }
	if ($num eq "2164") { return "19Misc"; }
	if ($num eq "2165") { return "19Misc"; }
	if ($num eq "2166") { return "19Misc"; }
	if ($num eq "2167") { return "19Misc"; }
	if ($num eq "2168A") { return "19Misc"; }
	if ($num eq "2168B") { return "19Misc"; }
	if ($num eq "2169") { return "19Misc"; }
	if ($num eq "2170") { return "19Misc"; }
	if ($num eq "2171") { return "19Misc"; }
	if ($num eq "2172") { return "19Misc"; }
	if ($num eq "2173") { return "19Misc"; }
	if ($num eq "2174A") { return "19Misc"; }
	if ($num eq "2174B") { return "19Misc"; }
	if ($num eq "2175") { return "19Misc"; }
	if ($num eq "2176") { return "19Misc"; }
	if ($num eq "2177") { return "19Misc"; }
	if ($num eq "2178") { return "19Misc"; }
	if ($num eq "2179") { return "19Misc"; }
	if ($num eq "2180") { return "19Misc"; }
	if ($num eq "2181") { return "19Misc"; }
	if ($num eq "2182") { return "19Misc"; }
	if ($num eq "2183") { return "19Misc"; }
	if ($num eq "2184") { return "19Misc"; }
	if ($num eq "2865") { return "20Apoc"; }
	if ($num eq "2866") { return "20Apoc"; }
	if ($num eq "2867") { return "20Apoc"; }
	if ($num eq "2868") { return "20Apoc"; }
	if ($num eq "2869") { return "20Apoc"; }
	if ($num eq "2870") { return "20Apoc"; }
	if ($num eq "2871") { return "20Apoc"; }
	if ($num eq "2872") { return "20Apoc"; }
	if ($num eq "2873") { return "20Apoc"; }
	if ($num eq "2874") { return "20Apoc"; }
	if ($num eq "2875") { return "20Apoc"; }
	if ($num eq "2876") { return "20Apoc"; }
	if ($num eq "2877") { return "20Apoc"; }
	if ($num eq "2878") { return "20Apoc"; }
	if ($num eq "2879") { return "20Apoc"; }
	if ($num eq "2880") { return "20Apoc"; }
	if ($num eq "2881") { return "20Apoc"; }
	if ($num eq "2882") { return "20Apoc"; }
	if ($num eq "2883") { return "20Apoc"; }
	if ($num eq "2884") { return "20Apoc"; }
	if ($num eq "2885") { return "20Apoc"; }
	if ($num eq "2886") { return "20Apoc"; }
	if ($num eq "2887") { return "20Apoc"; }
	if ($num eq "2888") { return "20Apoc"; }
	if ($num eq "2889") { return "20Apoc"; }
	if ($num eq "2890") { return "20Apoc"; }
	if ($num eq "2891") { return "20Apoc"; }
	if ($num eq "2892") { return "20Apoc"; }
	if ($num eq "2893") { return "20Apoc"; }
	if ($num eq "2894") { return "20Apoc"; }
	if ($num eq "2895") { return "20Apoc"; }
	if ($num eq "2896") { return "20Apoc"; }
	if ($num eq "2897") { return "20Apoc"; }
	if ($num eq "2898") { return "20Apoc"; }
	if ($num eq "2899") { return "20Apoc"; }
	if ($num eq "2900") { return "20Apoc"; }
	if ($num eq "2901") { return "20Apoc"; }
	if ($num eq "2902") { return "20Apoc"; }
	if ($num eq "2903") { return "20Apoc"; }
	if ($num eq "2904") { return "20Apoc"; }
	if ($num eq "2905") { return "20Apoc"; }
	if ($num eq "2906") { return "20Apoc"; }
	if ($num eq "2907") { return "20Apoc"; }
	if ($num eq "2908") { return "20Apoc"; }
	if ($num eq "2909") { return "20Apoc"; }
	if ($num eq "2910") { return "20Apoc"; }
	if ($num eq "2911") { return "20Apoc"; }
	if ($num eq "2912") { return "20Apoc"; }
	if ($num eq "2913") { return "20Apoc"; }
	if ($num eq "2914") { return "20Apoc"; }
	if ($num eq "2915") { return "20Apoc"; }
	if ($num eq "2916") { return "20Apoc"; }
	if ($num eq "2917A") { return "20Apoc"; }
	if ($num eq "2917B") { return "20Apoc"; }
	if ($num eq "2918") { return "20Apoc"; }
	if ($num eq "2919") { return "20Apoc"; }
	if ($num eq "2920") { return "20Apoc"; }
	return "error: out of range";
}

#-----------------------------------------------------------------------
# 由 T, X, ... 這種代號取得標準大藏經名
# written by Ray 2001/5/31 12:03下午
#-----------------------------------------------------------------------
sub get_book_name_by_TX {

	my $TX = shift;

# T 大正新脩大藏經 (Taisho Tripitaka) （大正藏） 【大】
# X 卍新纂大日本續藏經 (Manji Shinsan Dainihon Zokuzokyo) （新纂卍續藏） 【卍續】
# J 嘉興大藏經 (Jiaxing Canon) （嘉興藏） 【嘉興】
# H 正史佛教資料類編 (Passages concerning Buddhism from the Official Histories) （正史） 【正史】
# W 藏外佛教文獻 (Buddhist Texts not contained in the Tripitaka) （藏外） 【藏外】 
# I 北朝佛教石刻拓片百品 (Selections of Buddhist Stone Rubbings from the Northern Dynasties) 【佛拓】

# A 金藏 (Jin Edition of the Canon) （趙城藏） 【金藏】
# B 大藏經補編 (Supplement to the Dazangjing) 　 【補編】
# C 中華大藏經 (Zhonghua Canon) （中華藏） 【中華】
# D 國家圖書館善本佛典 (Treasured Buddhist Texts of National Central Library) 【國圖】
# F 房山石經 (Fangshan shijing) 　 【房山】
# G 佛教大藏經 (Fojiao Canon) 　 【教藏】
# GA 中國佛寺史志彙刊 (Zhongguo Fosi Shizhi Huikan) 【志彙】
# GB 中國佛寺志叢刊 (Zhongguo Fosizhi Congkan) 【志叢】
# K 高麗大藏經 (Tripitaka Koreana) （高麗藏） 【麗】
# L 乾隆大藏經 (Qianlong Edition of the Canon) （清藏、龍藏、乾隆藏） 【龍】
# M 卍正藏經 (Manji Daizokyo) （卍正藏） 【卍正】
# N 漢譯南傳大藏經 【南傳】
# # N 永樂南藏 (Southern Yongle Edition of the Canon) （再刻南藏） 【南藏】
# P 永樂北藏 (Northern Yongle Edition of the Canon) （北藏） 【北藏】
# Q 磧砂大藏經 (Qisha Edition of the Canon) （磧砂藏） 【磧砂】
# S 宋藏遺珍 (Songzang yizhen) 　 【宋遺】
# U 洪武南藏 (Southern Hongwu Edition of the Canon) （初刻南藏） 【洪武】

# R 卍續藏經 (Manji Zokuzokyo) （卍續藏）
# Z 卍大日本續藏經 (Manji Dainihon Zokuzokyo)

	# TXJHWIABCFGKLMNPQSU 的名稱
	
	my %name;
	
	$name{"T"} = "大正新脩大藏經";
	$name{"X"} = "卍新纂續藏經";
	$name{"J"} = "嘉興大藏經";
	$name{"H"} = "正史佛教資料類編";
	$name{"W"} = "藏外佛教文獻";
	$name{"I"} = "北朝佛教石刻拓片百品";
	$name{"A"} = "金藏";
	$name{"B"} = "大藏經補編";
	$name{"C"} = "中華大藏經";
	$name{"D"} = "國家圖書館善本佛典";
	$name{"F"} = "房山石經";
	$name{"G"} = "佛教大藏經";
	$name{"GA"} = "中國佛寺史志彙刊";
	$name{"GB"} = "中國佛寺志叢刊";
	$name{"K"} = "高麗大藏經";
	$name{"L"} = "乾隆大藏經";
	$name{"M"} = "卍正藏經";
	$name{"N"} = "漢譯南傳大藏經";
	$name{"P"} = "永樂北藏";
	$name{"Q"} = "磧砂大藏經";
	$name{"S"} = "宋藏遺珍";
	$name{"U"} = "洪武南藏";
	$name{"ZY"} = "智諭老和尚著作全集";
	$name{"DA"} = "道安長老著作全集";

	if($name{$TX})
	{
		return $name{$TX};
	}
	else
	{
		die "error : cbetasub.pl : get_book_name_by_TX($TX)";
	}
}

#-----------------------------------------------------------------------
# 由 T, X, ... 這種代號取得標準大藏經名
# written by Ray 2001/5/31 12:03下午
#-----------------------------------------------------------------------
sub get_book_short_name_by_TX {

	my $TX = shift;

# T 大正新脩大藏經 (Taisho Tripitaka) （大正藏） 【大】
# X 卍新纂大日本續藏經 (Manji Shinsan Dainihon Zokuzokyo) （新纂卍續藏） 【卍續】
# J 嘉興大藏經 (Jiaxing Canon) （嘉興藏） 【嘉興】
# H 正史佛教資料類編 (Passages concerning Buddhism from the Official Histories) （正史） 【正史】
# W 藏外佛教文獻 (Buddhist Texts not contained in the Tripitaka) （藏外） 【藏外】 
# I 北朝佛教石刻拓片百品 (Selections of Buddhist Stone Rubbings from the Northern Dynasties) 【佛拓】

# A 金藏 (Jin Edition of the Canon) （趙城藏） 【金藏】
# B 大藏經補編 (Supplement to the Dazangjing) 　 【補編】
# C 中華大藏經 (Zhonghua Canon) （中華藏） 【中華】
# D 國家圖書館善本佛典 (Treasured Buddhist Texts of National Central Library) 【國圖】
# F 房山石經 (Fangshan shijing) 　 【房山】
# G 佛教大藏經 (Fojiao Canon) 　 【教藏】
# GA 中國佛寺史志彙刊 (Zhongguo Fosi Shizhi Huikan) 【志彙】
# GB 中國佛寺志叢刊 (Zhongguo Fosizhi Congkan) 【志叢】
# K 高麗大藏經 (Tripitaka Koreana) （高麗藏） 【麗】
# L 乾隆大藏經 (Qianlong Edition of the Canon) （清藏、龍藏、乾隆藏） 【龍】
# M 卍正藏經 (Manji Daizokyo) （卍正藏） 【卍正】
# N 永樂南藏 (Southern Yongle Edition of the Canon) （再刻南藏） 【南藏】
# P 永樂北藏 (Northern Yongle Edition of the Canon) （北藏） 【北藏】
# Q 磧砂大藏經 (Qisha Edition of the Canon) （磧砂藏） 【磧砂】
# S 宋藏遺珍 (Songzang yizhen) 　 【宋遺】
# U 洪武南藏 (Southern Hongwu Edition of the Canon) （初刻南藏） 【洪武】

# R 卍續藏經 (Manji Zokuzokyo) （卍續藏）
# Z 卍大日本續藏經 (Manji Dainihon Zokuzokyo)

	# TXJHWIABCDFGKLMNPQSU 的名稱
	
	my %name;
	
	$name{"T"} = "大正藏";
	$name{"X"} = "卍續藏";
	$name{"J"} = "嘉興藏";
	$name{"H"} = "正史佛教資料類編";
	$name{"W"} = "藏外佛教文獻";
	$name{"I"} = "北朝佛教石刻拓片百品";
	$name{"A"} = "金藏";
	$name{"B"} = "大藏經補編";
	$name{"C"} = "中華藏";
	$name{"D"} = "國圖";
	$name{"F"} = "房山石經";
	$name{"G"} = "佛教大藏經";
	$name{"GA"} = "中國佛寺史志彙刊";
	$name{"GB"} = "中國佛寺志叢刊";
	$name{"K"} = "高麗藏";
	$name{"L"} = "乾隆藏";
	$name{"M"} = "卍正藏";
	$name{"N"} = "漢譯南傳大藏經";
	$name{"P"} = "永樂北藏";
	$name{"Q"} = "磧砂大藏經";
	$name{"S"} = "宋藏遺珍";
	$name{"U"} = "洪武南藏";
	$name{"ZY"} = "智諭老和尚著作全集";
	$name{"DA"} = "道安長老著作全集";

	if($name{$TX})
	{
		return $name{$TX};
	}
	else
	{
		die "error : cbetasub.pl : get_book_name_by_TX($TX)";
	}
}
#-----------------------------------------------------------------------
# 由 T, X, ... 這種代號取得標準大藏經名
# written by Ray 2001/5/31 12:03下午
#-----------------------------------------------------------------------
sub get_eng_book_name_by_TX {

	my $TX = shift;

# T 大正新脩大藏經 (Taisho Tripitaka) （大正藏） 【大】
# X 卍新纂大日本續藏經 (Manji Shinsan Dainihon Zokuzokyo) （新纂卍續藏） 【卍續】
# J 嘉興大藏經 (Jiaxing Canon) （嘉興藏） 【嘉興】
# H 正史佛教資料類編 (Passages concerning Buddhism from the Official Histories) （正史） 【正史】
# W 藏外佛教文獻 (Buddhist Texts not contained in the Tripitaka) （藏外） 【藏外】 
# I 北朝佛教石刻拓片百品 (Selections of Buddhist Stone Rubbings from the Northern Dynasties) 【佛拓】

# A 金藏 (Jin Edition of the Canon) （趙城藏） 【金藏】
# B 大藏經補編 (Supplement to the Dazangjing) 　 【補編】
# C 中華大藏經 (Zhonghua Canon) （中華藏） 【中華】
# D 國家圖書館善本佛典 (Treasured Buddhist Texts of National Central Library) 【國圖】
# F 房山石經 (Fangshan shijing) 　 【房山】
# G 佛教大藏經 (Fojiao Canon) 　 【教藏】
# GA 中國佛寺史志彙刊 (Zhongguo Fosi Shizhi Huikan) 【志彙】
# GB 中國佛寺志叢刊 (Zhongguo Fosizhi Congkan) 【志叢】
# K 高麗大藏經 (Tripitaka Koreana) （高麗藏） 【麗】
# L 乾隆大藏經 (Qianlong Edition of the Canon) （清藏、龍藏、乾隆藏） 【龍】
# M 卍正藏經 (Manji Daizokyo) （卍正藏） 【卍正】
# N 永樂南藏 (Southern Yongle Edition of the Canon) （再刻南藏） 【南藏】
# P 永樂北藏 (Northern Yongle Edition of the Canon) （北藏） 【北藏】
# Q 磧砂大藏經 (Qisha Edition of the Canon) （磧砂藏） 【磧砂】
# S 宋藏遺珍 (Songzang yizhen) 　 【宋遺】
# U 洪武南藏 (Southern Hongwu Edition of the Canon) （初刻南藏） 【洪武】

# R 卍續藏經 (Manji Zokuzokyo) （卍續藏）
# Z 卍大日本續藏經 (Manji Dainihon Zokuzokyo)

	# TXJHWIABCDFGKLMNPQSU 的名稱
	
	my %name;
	$name{"T"} = "Taishō Tripiṭaka";
	$name{"X"} = "卍 Xuzangjing";
	$name{"J"} = "Jiaxing Canon";
	$name{"H"} = "Passages concerning Buddhism from the Official Histories";
	$name{"W"} = "Buddhist Texts not contained in the Tripiṭaka";
	$name{"I"} = "Selections of Buddhist Stone Rubbings from the Northern Dynasties";
	$name{"A"} = "Jin Edition of the Canon";
	$name{"B"} = "Supplement to the Dazangjing";
	$name{"C"} = "Zhonghua Canon";
	$name{"D"} = "Treasured Buddhist Texts of National Central Library";
	$name{"F"} = "Fangshan shijing";
	$name{"G"} = "Fojiao Canon";
	$name{"GA"} = "Zhongguo Fosi Shizhi Huikan";
	$name{"GB"} = "Zhongguo Fosizhi Congkan";
	$name{"K"} = "Tripiṭaka Koreana";
	$name{"L"} = "Qianlong Edition of the Canon";
	$name{"M"} = "Manji Daizokyo";
	$name{"N"} = "Chinese Translation of the Pali Tripiṭaka";
	$name{"P"} = "Northern Yongle Edition of the Canon";
	$name{"Q"} = "Qisha Edition of the Canon";
	$name{"S"} = "Songzang yizhen";
	$name{"U"} = "Southern Hongwu Edition of the Canon";
	$name{"ZY"} = "the Complete Works of Ven Zhiyu";
	$name{"DA"} = "the Complete Works of Ven Daoan";

	if($name{$TX})
	{
		return $name{$TX};
	}
	else
	{
		die "error : cbetasub.pl : get_eng_book_name_by_TX($TX)";
	}
}

sub cNum {
	my $num = shift;
	my $i, $str;
	my @char=("","一","二","三","四","五","六","七","八","九");

	$i = int($num/100);
	$str = $char[$i];
	if ($i != 0) { $str .= "百"; }
	
	$num = $num % 100;
	$i = int($num/10);
	if ($i==0) {
		if ($str ne "" and $num != 0) { $str .= "零"; }
	} else {
		if ($i ==1) {
			if ($str eq "") {
				$str = "十";
			} else {
				$str .= "一十";
 			}
		} else {
 		  $str .= $char[$i] . "十";
 		}
 	}
	
 	$i = $num % 10;
 	$str .= $char[$i];
 	return $str;
}

# 中文數字 -> 阿拉伯數字
# created by Ray 2000/2/21 04:39PM
sub cn2an {
	my $s = shift;
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	my %map = (
    "○",0,
    "一",1,
 	  "二",2,
 	  "三",3,
 	  "四",4,
 	  "五",5,
 	  "六",6,
 	  "七",7,
 	  "八",8,
 	  "九",9
  );
	my @chars = ();
	push(@chars, $s =~ /$big5/g);
	
	my $result=0;
	my $n=0;
	my $old="";
	foreach $c (@chars) {
		if ($c eq "百") { 
			$result += $n*100; $n=0;
		} elsif ($c eq "十") { 
		  if ($n==0) { $result+=10; } else { $result += $n*10; $n=0;}
		} elsif (exists $map{$c}) { 
		  if (($n%10) != 0 or $old eq "○") { $n *= 10; }
		  $n += $map{$c}; 
		}
		$old = $c;
	}
	$result += $n;
	if ($result == 0) { $result=""; }
	else { $result="$result"; }
	return $result;
}

sub b52utf8 {
	my $in = shift;
	my $big5 = "[\x00-\x7f]|[\x80-\xff][\x00-\xff]";
	my @a;
	my $temp='';
	push(@a, $in =~ /$big5/gs);
	my $s='', $c;
	foreach $c (@a) { 
		if ($b52utf8{$c} ne "") { 
			$temp .= $c;
			$c =  $b52utf8{$c}; 
		} else { 
			print STDERR "83 $in\n";
			print STDERR "84 $temp\n";
			die "subutf8.pl 85 Error: not in big52utf8 table. char:[$c] hex:" . unpack("H4",$c) ; 
		}
		$s.=$c; 
	}
	return $s;
}

sub getopts ($;$) {
    local($argumentative, $hash) = @_;
    local(@args,$_,$first,$rest);
    local($errs) = 0;
    local @EXPORT;

    @args = split( / */, $argumentative );
    while(@ARGV && ($_ = $ARGV[0]) =~ /^-(.)(.*)/) {
	($first,$rest) = ($1,$2);
	if (/^--$/) {	# early exit if --
	    shift @ARGV;
	    last;
	}
	$pos = index($argumentative,$first);
	if ($pos >= 0) {
	    if (defined($args[$pos+1]) and ($args[$pos+1] eq ':')) {
		shift(@ARGV);
		if ($rest eq '') {
		    ++$errs unless @ARGV;
		    $rest = shift(@ARGV);
		}
		if (ref $hash) {
		    $$hash{$first} = $rest;
		}
		else {
		    ${"opt_$first"} = $rest;
		    push( @EXPORT, "\$opt_$first" );
		}
	    }
	    else {
		if (ref $hash) {
		    $$hash{$first} = 1;
		}
		else {
		    ${"opt_$first"} = 1;
		    push( @EXPORT, "\$opt_$first" );
		}
		if ($rest eq '') {
		    shift(@ARGV);
		}
		else {
		    $ARGV[0] = "-$rest";
		}
	    }
	}
	else {
	    warn "Unknown option: $first\n";
	    ++$errs;
	    if ($rest ne '') {
		$ARGV[0] = "-$rest";
	    }
	    else {
		shift(@ARGV);
	    }
	}
    }
    unless (ref $hash) { 
	local $Exporter::ExportLevel = 1;
	import Getopt::Std;
    }
    $errs == 0;
}



1;
