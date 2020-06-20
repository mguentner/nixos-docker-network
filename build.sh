#!/usr/bin/env bash
./build_containers.sh $1
./build_registry.py $1 > ${1}/default.nix
