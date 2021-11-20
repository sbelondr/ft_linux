#!/bin/bash

mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

pushd $LFS/sources
	md5sum -c md5sums
popd
