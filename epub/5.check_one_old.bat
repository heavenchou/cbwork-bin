if "%1"=="" goto end

rem path="C:\Program Files (x86)\Java\jre7\bin\";%path%

for /r C:\release\epub_ziped\%1 %%f in (*.epub) do java -jar epubcheck-1.0.5\epubcheck-1.0.5.jar %%f 2>> 5.check_out.txt 1>> 5.check_out_ok.txt

:end