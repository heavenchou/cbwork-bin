if "%1"=="" goto end

set JAVA="C:\Program Files (x86)\Java\jre7\bin\java"

for /r C:\release\epub_ziped\%1 %%f in (*.epub) do %JAVA% -jar epubcheck-3.0.1\epubcheck-3.0.1.jar %%f 2>> 5.check_out.txt 1>> 5.check_out_ok.txt

:end