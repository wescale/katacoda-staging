#!/usr/bin/python

import sys
import re
import shutil
from tempfile import mkstemp
import shlex

installers = {"debian":"RUN apt update -y ", "ubuntu":"RUN apt update -y ", "alpine":"RUN apk upgrade --no-cache --update "}

def sed(pattern, replace, source, dest=None, count=0):
    """Reads a source file and writes the destination file.

    In each line, replaces pattern with replace.

    Args:
        pattern (str): pattern to match (can be re.pattern)
        replace (str): replacement str
        source  (str): input filename
        count (int): number of occurrences to replace
        dest (str):   destination filename, if not given, source will be over written.
    """

    fin = open(source, 'r')
    num_replaced = count

    if dest:
        fout = open(dest, 'w')
    else:
        fd, name = mkstemp()
        fout = open(name, 'w')

    for line in fin:
        out = re.sub(pattern, replace, line)
        fout.write(out)

        if out != line:
            num_replaced += 1
        if count and num_replaced > count:
            break
    try:
        fout.writelines(fin.readlines())
    except Exception as E:
        raise E

    fin.close()
    fout.close()

    if not dest:
        shutil.move(name, source)

def main() -> int:
    """Echo the input arguments to standard output"""
    phrase = shlex.join(sys.argv)
    print(phrase)

    image_os=sys.argv[1]

    print(installers.get(image_os, "not found"))

    packages_to_update = ""

    for i in range(2, len(sys.argv)):
        # i is a number, from 1 to len(inputArgs)-1
        packages_to_update += sys.argv[i] + " "

    sed("CMD ", installers.get(image_os) + packages_to_update + "\n\nCMD ", "Dockerfile", "Dockerfile.patch")

    return 0

if __name__ == '__main__':
    sys.exit(main())  # next sec
