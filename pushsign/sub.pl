sub cNum {
	my $num = shift;
	my $i, $str;
	my @char=("","�@","�G","�T","�|","��","��","�C","�K","�E");

	$i = int($num/100);
	$str = $char[$i];
	if ($i != 0) { $str .= "��"; }
	
	$num = $num % 100;
	$i = int($num/10);
	if ($i==0) {
		if ($str ne "" and $num != 0) { $str .= "�s"; }
	} else {
		if ($i ==1) {
			if ($str eq "") {
				$str = "�Q";
			} else {
				$str .= "�@�Q";
 			}
		} else {
 		  $str .= $char[$i] . "�Q";
 		}
 	}
	
 	$i = $num % 10;
 	$str .= $char[$i];
 	return $str;
}

# ����Ʀr -> ���ԧB�Ʀr
# created by Ray 2000/2/21 04:39PM
sub cn2an {
	my $s = shift;
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	my %map = (
    "��",0,
    "�@",1,
 	  "�G",2,
 	  "�T",3,
 	  "�|",4,
 	  "��",5,
 	  "��",6,
 	  "�C",7,
 	  "�K",8,
 	  "�E",9
  );
	my @chars = ();
	push(@chars, $s =~ /$big5/g);
	
	my $result=0;
	my $n=0;
	my $old="";
	foreach $c (@chars) {
		if ($c eq "��") { 
			if ($n==0) { 
				$result+=100; 
			} else {
				$result += $n*100; $n=0;
			}
		} elsif ($c eq "�Q") { 
		  if ($n==0) { $result+=10; } else { $result += $n*10; $n=0;}
		} elsif (exists $map{$c}) { 
		  if (($n%10) != 0 or $old eq "��") { $n *= 10; }
		  $n += $map{$c}; 
		}
		$old = $c;
	}
	$result += $n;
	if ($result == 0) { $result=""; }
	else { $result="$result"; }
	return $result;
}

# �Ǧ^���Ѫ���� yyyy/mm/dd
sub today {
	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	$year += 1900;
	return "$year/$mon/$mday";
}

1;