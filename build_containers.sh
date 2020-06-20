#!/usr/bin/env bash
set -x
BASE=$1
for dir in $(ls $BASE)
do
    [ ! -d $BASE/$dir ] && continue
    pushd .
    echo $dir
    cd $BASE/$dir
    COMMIT_HASH=$(docker build . | tail -n 1 | cut -d ' ' -f3)
    TAG=$(basename $(pwd)):$COMMIT_HASH
    docker tag $COMMIT_HASH $TAG
    docker save $TAG | gzip > $COMMIT_HASH.tar.gz
    popd
done
