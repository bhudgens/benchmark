#! /usr/bin/env bash

export TMPDIR="/benchmarking"
mkdir -p "${TMPDIR}"
WORKING_DIR=$(mktemp -d)
pushd "${WORKING_DIR}" > /dev/null
/usr/bin/benchmark.sh
/usr/bin/process.sh
popd
