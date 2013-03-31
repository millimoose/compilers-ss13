#!/usr/bin/env sh
(
    cd $(dirname $0)
    make clean asmb
    exec asmb
)
