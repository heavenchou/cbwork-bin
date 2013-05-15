#!/bin/sh
## set up the paths etc for the processing of CBETA P4 to P5
## requirements:
## python
## (not needed anymore! perl)
## saxon (=JAVA)
## jing (for validation)
CBTEMP=/Users/chris/tmp/cbetatmp
CBWORK=$HOME/cbeta
BINDIR=$CBWORK/bin/p5
#DATADIR=$CBWORK/xml
DATADIR=/Users/chris/cbeta/cbeta/xml


#DATADIR=/tmp/cbtest


#directory and version of saxon, this is required for 
SAXDIR=/usr/local/share/java
SAXON=$SAXDIR/saxon9.jar
JING=$SAXDIR/jing.jar
PHASE1DIR=$CBTEMP/cbetap5-1
PHASE2DIR=$CBTEMP/cbetap5-2
#collection files; saxon needs this to process the XQuery
COLLDIR=$CBTEMP/coll
#this is a temporary directory for by-volume mapping files.
#since they can't be generated in one go, we do them by volume and then aggregate
#this is done with gen-map.sh
MAPDIR=$CBTEMP/map
GAIJIDIR=$CBTEMP/gaiji
CONVTABDIR=$CBTEMP/convtab
#set to -solr generating solr specific maps.  the name is silly
#SOLR=-solr
SOLR=
#results of the validation process are written to this directory:
VALRESDIR=$CBTEMP/val
##set this to yes to produce the convtabs.  With the convtabs, the conversion will take up to three days
DOCONVTAB=no
##this selects the files to transform, T=taisho, X=Xuzang, J=Jiaxing etc.

#SEL=[TXJWH]*

SEL=T01*

export CBWORK BINDIR DATADIR JING SAXON PHASE1DIR PHASE2DIR COLLDIR MAPDIR SOLR CONVTABDIR GAIJIDIR CBTEMP VALRESDIR SEL DOCONVTAB



