#!/bin/bash
mkdir -p dist
cp src/*.py build/
chmod +x build/*.py
cp src/*.pl build/
chmod +x build/*.pl
if command -v javac &> /dev/null; then
    javac -d build src/*.java
    if [ $? -ne 0 ]; then
        echo "Error: Java compilation failed"
        exit 1
    fi
else
    echo "Warning: Java compiler not found, skipping Java compilation"
fi
mkdir -p build/Resources