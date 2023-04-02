#!/bin/sh
set -eu

for f in *.typ; do
    echo "Building $f"
    typst compile "$f" && convert \
		      -density 150 \
		      "${f//.typ/.pdf}" \
		      "${f//.typ/.png}"
done
