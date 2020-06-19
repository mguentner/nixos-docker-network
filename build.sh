#!/usr/bin/env bash
./build_containers.sh
./build_registry.py > static_registry/default.nix
