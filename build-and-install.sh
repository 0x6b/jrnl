#!/bin/bash
set -e

echo "Building jrnl..."
xcodebuild -scheme jrnl -configuration Release -derivedDataPath build

echo "Moving app to ~/bin..."
mkdir -p ~/bin
rm -rf ~/bin/jrnl.app
mv build/Build/Products/Release/jrnl.app ~/bin/

echo "Done! App installed to ~/bin/jrnl.app"
