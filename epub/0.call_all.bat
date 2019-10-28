cd ..
cd cbreader
rem call make_epub_all.bat

cd ..
cd epub
call 2.cbrhtm2epub_all.bat
call 3.mv_same_tag_all.bat
call 4.zip_epub_all.bat
call 5.check_all.bat