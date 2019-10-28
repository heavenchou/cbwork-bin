copy spine.txt spine_bak.txt
copy spine_by_bm.txt spine_by_bm_bak.txt
perl create_spine.pl
perl create_spine_by_bm.pl
fc spine.txt spine_by_bm.txt
fc spine.txt spine_bak.txt