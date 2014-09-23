#!/bin/bash
set -x
cd `dirname $0`
DIR=$(pwd)
cd $DIR/..
git archive master > packager.tar
if [ -x $(which gtar 2> /dev/null) ]; then
    TAR=gtar
elif [ -x $(which gnutar 2> /dev/null) ]; then
    TAR=gnutar
else
    TAR=tar
fi
$TAR -rf packager.tar archives
gzip packager.tar
scp packager.tar.gz root@download.alces-software.com:/var/www/html/alces
rm packager.tar.gz
