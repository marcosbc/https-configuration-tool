#!/bin/bash

source /env

cd $OUTPUT_DIR

if [ ! -d "$EXPECT_TARBALL_NAME" ]; then
    echo "Could not find $(pwd)/$EXPECT_TARBALL_NAME!"
    exit 1
fi

# Download tclkit and sdx
curl -L -o /usr/bin/tclkit https://github.com/VitoVan/kitgen/releases/download/$TCLKIT_VERSION/linux-tclkit-cli
curl -L -o /usr/bin/sdx https://chiselapp.com/user/aspect/repository/sdx/uv/sdx-$SDX_VERSION.kit
chmod a+x /usr/bin/tclkit /usr/bin/sdx

# Unwrap tclkit
cp /usr/bin/tclkit .
sdx unwrap tclkit
sdx mksplit tclkit

# Include libraries into tclkit
curl -LO https://github.com/tcltk/tcllib/archive/tcllib_$TCLLIB_VERSION.tar.gz
tar -xzf tcllib_$TCLLIB_VERSION.tar.gz
cp -rp tcllib-tcllib_$TCLLIB_VERSION/modules/* tclkit.vfs/lib/
cp -rp $ITCL_TARBALL_NAME tclkit.vfs/lib/
cp -rp $EXPECT_TARBALL_NAME tclkit.vfs/lib/

# Re-wrap tclkit with the new libraries
sdx wrap tclkit -runtime tclkit.head

# Remove unnecessary files
rm -rf tclkit.* tcllib*
