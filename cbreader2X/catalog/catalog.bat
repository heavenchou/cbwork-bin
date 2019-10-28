copy catalog.txt catalog_bak.txt
perl create_catalog.pl
cd ../gaiji2word
perl gaiji2word.pl catalog
cd ../catalog
fc catalog.txt catalog_bak.txt