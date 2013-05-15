Conversion of CBETA TEI P4 to P5

Requirements:
* Java
* Saxon 9 
* Jing (for validation only)
* Python (used to generate some auxiliary files, most recent versions
  should be fine)
* Bash (maybe could be replaced by a batch file on windows, but this
  will certainly require some work)

All paths etc are set in the script set-env.sh, this should be changed
for local adaption.  ALso the variable SEL there controls what parts
of the collection (T, X, J, H) are created.


The following scripts are used:

* set-env.sh 
 
 this sets the required paths in the environment

* cbp4top5.sh
 (requires $BINDIR/cbetap4top5.xsl)
 this is the driver file.  It executes the first part of the
 conversion and then calls the other scripts:



* gen-map.sh
 (requires $BINDIR/gen-coll.py, $BINDIR/gen-charmap$SOLR.xq, $BINDIR/gen-charmap${SOLR}2.xq)
 this generates character maps for converting the PUA characters in
 the text back to the <g> character used for blind interchange.  The
 resulting file is a XSLT2 character map that can be imported into a
 XSLT file to do this conversion.

* gen-gaijixml.sh
 (requires $BINDIR/gen-coll.py, $BINDIR/gen-gaijixml.xq)
 this script generates <char> definitions that will be placed in the
 <teiHeader> in phase 2

* p5-pp.sh
  (requires $BINDIR/p5-pp.xsl )
