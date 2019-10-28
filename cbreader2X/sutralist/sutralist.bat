copy sutralist.txt sutralist_bak.txt
copy sutralist_by_bm.txt sutralist_by_bm_bak.txt
perl create_sutralist.pl
perl create_sutralist_by_bm.pl
fc sutralist.txt sutralist_bak.txt
fc sutralist_by_bm.txt sutralist_by_bm_bak.txt