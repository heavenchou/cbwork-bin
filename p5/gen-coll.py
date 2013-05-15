#!/usr/bin/env python
import os, sys


def test_walk(arg, dirname, names):
    for f in names:
        if '.xml' in f:
            print '<doc href="%s/%s%s"/>'%(arg, dirname[2:], f)
                                       
print "<collection>"

os.path.walk('.', test_walk, sys.argv[1])

print "</collection>"
