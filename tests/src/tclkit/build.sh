#!/bin/sh

EXPECT_VERSION=5.45.4
EXPECT_TARBALL_NAME=expect$EXPECT_VERSION
EXPECT_BUILD_DIR=/tmp/$EXPECT_TARBALL_NAME.tar.gz

docker build -t tclkit_builder .

# Build expect
docker run --rm -v $(pwd)/output:/tmp/output tclkit_builder /expect_build.sh
# Build itcl
docker run --rm -v $(pwd)/output:/tmp/output tclkit_builder /itcl_build.sh
# Build tclkit
docker run --rm -v $(pwd)/output:/tmp/output tclkit_builder /tclkit_build.sh
