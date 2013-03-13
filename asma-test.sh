#!/usr/bin/env sh
(
    cd $(dirname $0)
    make clean asma-test
    exec asma-test
)
