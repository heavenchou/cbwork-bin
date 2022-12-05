if "%1"=="" goto end

set JAVA="java"

for /r d:\temp\epub\%1 %%f in (*.epub) do %JAVA% -jar epubcheck-3.0.1\epubcheck-3.0.1.jar %%f 2>> 5.check_out.txt 1>> 5.check_out_ok.txt

:end