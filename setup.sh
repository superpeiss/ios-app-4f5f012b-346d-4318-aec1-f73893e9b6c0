#!/bin/bash
set -e

echo "Installing XcodeGen..."
brew install xcodegen

echo "Generating Xcode project..."
xcodegen generate

echo "Project generation complete!"
