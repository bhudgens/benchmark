#! /usr/bin/env bash

WORKING_DIR=$(mktemp -d)
pushd "${WORKING_DIR}" > /dev/null
benchmark.sh
process.sh
popd
