#! /usr/bin/env bash

exit 0
export TMPDIR="/benchmarking"
mkdir -p "${TMPDIR}"
WORKING_DIR=$(mktemp -d)
pushd "${WORKING_DIR}" > /dev/null
/usr/bin/benchmark.sh
/usr/bin/process.sh
popd
