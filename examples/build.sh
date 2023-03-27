#!/bin/sh
set -eu

for f in *.ty; do
    echo "Building $f"
    typst "$f" && convert \
		      -density 150 \
		      "${f//.ty/.pdf}" \
		      "${f//.ty/.png}"
done
