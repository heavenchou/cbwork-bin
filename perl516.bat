@echo off

set drive=c:\perl516\
set drivep=c:\perl516

set PATH=%drivep%\perl\site\bin;%drivep%\perl\bin;%drivep%\c\bin;%PATH%
rem env variables
set TERM=dumb
rem avoid collisions with other perl stuff on your system
set PERL_JSON_BACKEND=
set PERL_YAML_BACKEND=
set PERL5LIB=
set PERL5OPT=
set PERL_MM_OPT=
set PERL_MB_OPT=

echo ----------------------------------------------
echo  Welcome to Strawberry Perl Portable Edition!
echo  * URL - http://www.strawberryperl.com/
echo  * see README.portable.TXT for more info
echo ----------------------------------------------
perl -MConfig -e "printf("""Perl executable: %%s\nPerl version   : %%vd / $Config{archname}\n""", $^X, $^V)" 2>nul
if ERRORLEVEL==1 echo.&echo FATAL ERROR: 'perl' does not work; check if your strawberry pack is complete!
echo.

if not #%1# == ## goto END
cmd /K

:END
