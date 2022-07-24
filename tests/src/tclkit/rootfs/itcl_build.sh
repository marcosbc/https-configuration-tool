#!/bin/bash

source /env

curl -o /tmp/$ITCL_TARBALL_NAME.tar.gz https://liquidtelecom.dl.sourceforge.net/project/incrtcl/%5Bincr%20Tcl_Tk%5D-4-source/itcl%20$ITCL_VERSION/$ITCL_TARBALL_NAME.tar.gz
tar xzf /tmp/$ITCL_TARBALL_NAME.tar.gz -C /tmp
cd /tmp/$ITCL_TARBALL_NAME
./configure --enable-shared --enable-stubs
make
make install
cp -R /usr/lib/$ITCL_TARBALL_NAME /tmp/output
