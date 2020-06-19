#!/usr/bin/env bash
set -x
for dir in $(ls static_registry)
do
    [ ! -d static_registry/$dir ] && continue
    pushd .
    echo $dir
    cd static_registry/$dir
    COMMIT_HASH=$(docker build . | tail -n 1 | cut -d ' ' -f3)
    TAG=$(basename $(pwd)):$COMMIT_HASH
    docker tag $COMMIT_HASH $TAG
    docker save $TAG | gzip > $COMMIT_HASH.tar.gz
    popd
done
