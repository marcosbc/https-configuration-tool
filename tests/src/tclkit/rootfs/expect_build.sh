#!/bin/bash

source /env

curl -o /tmp/$EXPECT_TARBALL_NAME.tar.gz https://kent.dl.sourceforge.net/project/expect/Expect/$EXPECT_VERSION/$EXPECT_TARBALL_NAME.tar.gz
tar xzf /tmp/$EXPECT_TARBALL_NAME.tar.gz -C /tmp
cd /tmp/$EXPECT_TARBALL_NAME
./configure --enable-shared --enable-stubs
make
make install
cp -R /usr/lib/$EXPECT_TARBALL_NAME /tmp/output
