#!/usr/bin/env bash
THIS=$(dirname "$0")
./$THIS/build_containers.sh $1
./$THIS/build_registry.py $1 > ${1}/default.nix
