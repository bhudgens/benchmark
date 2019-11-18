#! /usr/bin/env bash

for drive in "/mnt/osdrive" "/mnt/mounteddrive"; do
  export TMPDIR="${drive}"
  mkdir -p "${TMPDIR}"
  WORKING_DIR=$(mktemp -d)
  pushd "${WORKING_DIR}" > /dev/null
  /usr/bin/benchmark.sh
  /usr/bin/process.sh
  popd
done
