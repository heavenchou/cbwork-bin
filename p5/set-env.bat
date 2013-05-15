@echo off
rem 2010.10.16 Ray Chou modify Christian Wittern's set-env.sh
rem set up the paths etc for the processing of CBETA P4 to P5
rem requirements:
rem python
rem saxon (=JAVA)
rem jing (for validation)
set CBTEMP=d:/cbetatmp
set CBWORK=c:\cbwork
set BINDIR=%CBWORK%/bin/p5
set DATADIR=c:/cbwork/xml

rem directory and version of saxon, this is required for 
set SAXDIR=C:\Program Files (x86)\Oxygen XML Editor 9\lib
set SAXON=%SAXDIR%/saxon9.jar
set JING=c:/bin/jing/jing.jar
set PHASE1DIR=%CBTEMP%/cbetap5-1
set PHASE2DIR=%CBTEMP%/cbetap5-2
set PHASE3DIR=%CBTEMP%/cbetap5-3
set PHASE4DIR=%CBTEMP%/cbetap5-4
rem collection files; saxon needs this to process the XQuery
set COLLDIR=%CBTEMP%/coll
rem this is a temporary directory for by-volume mapping files.
rem since they can't be generated in one go, we do them by volume and then aggregate
rem this is done with gen-map.sh
set MAPDIR=%CBTEMP%/map
set GAIJIDIR=%CBTEMP%/gaiji
set CONVTABDIR=%CBTEMP%/convtab
rem set to -solr generating solr specific maps.  the name is silly
rem SOLR=-solr
set SOLR=
rem results of the validation process are written to this directory:
set VALRESDIR=%CBTEMP%/val

rem set this to yes to produce the convtabs.  With the convtabs, the conversion will take up to three days
set DOCONVTAB=yes

rem this sets the start volume
set SEL=X77