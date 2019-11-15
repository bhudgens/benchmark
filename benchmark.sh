#!/usr/bin/env bash

# Make it compatible with running in docker scenarios for testing
sudo apt-get update -y
if ! which sudo; then
  apt-get install -t sudo || exit 1
fi

##########################################################################
## Prereqs
##########################################################################
sudo apt-get install -y \
  git \
  wget \
  curl \
  build-essential \
  gcc \
  make \
  libaio-dev \
  libibverbs-dev \
  librados-dev \
  librbd-dev \
  librdmacm-dev \
  zlib1g-dev \
  jq

##########################################################################
## Installation
##########################################################################
if ! which sysbench; then
  curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
  sudo apt -y install sysbench
fi

FIO=/usr/local/bin/fio

if [ ! -f "${FIO}" ]; then
  echo "Installling fio from git."

  if [ -d /tmp/fio ]; then
    rm -rf /tmp/fio
  fi
  cd /tmp
  git clone https://github.com/axboe/fio
  cd fio
  ./configure
  make
  sudo make install
fi

sudo sync # (move data, modified through FS -> HDD cache) + flush HDD cache
echo 3 | sudo dd status=none of=/proc/sys/vm/drop_caches # (slab + pagecache) -> HDD (https://www.kernel.org/doc/Documentation/sysctl/vm.txt)
sudo blockdev --flushbufs /dev/sda
sudo blockdev --flushbufs /dev/sdb
sudo hdparm -F /dev/sda
sudo hdparm -F /dev/sdb
sudo hdparm -W 0 /dev/sda
sudo hdparm -W 0 /dev/sdb

##########################################################################
## Sysbench
##########################################################################
NUM_CPUS=$(nproc --all)

TESTNAME=${1:-benchmark}

echo "Running CPU Benchmark (Prime Numbers)..."

sudo sysbench cpu \
  --threads="${NUM_CPUS}" \
  --cpu-max-prime=100000 \
  run > "${TESTNAME}-cpu-primes-primes.txt"

# XXX: If we think we need more we can add this later
# echo "Running CPU Benchmark (RSA)..."
# openssl speed -multi "${NUM_CPUS}" rsa > "${TESTNAME}-cpu-rsa.txt"

for oper in "read" "write"; do
  for mode in "seq"; do
    echo "Running Memory Benchmark - ${mode} ${oper}..."

    sudo sysbench memory \
      --threads="${NUM_CPUS}" \
      --memory-oper="${oper}" \
      --memory-access-mode="${mode}" \
      run > "${TESTNAME}-mem-${mode}-${oper}.txt"
  done
done

for testmode in "seqwr" "seqrewr" "seqrd" "rndrd" "rndwr" "rndrw"; do
  for iomode in "sync" "async" "mmap"; do
    echo "Running FileIO Benchmark - ${testmode} ${iomode}..."

    sudo sync
    echo 3 | sudo dd status=none of=/proc/sys/vm/drop_caches
    sudo sysbench fileio \
      --threads="${NUM_CPUS}" \
      --file-test-mode="${testmode}" \
      --file-io-mode="${iomode}" \
      run > "${TESTNAME}-io-${testmode}-${iomode}.txt"
  done
done

##########################################################################
## Disk IO
##########################################################################
HOST_IP=$(ip a s|sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\(172.[0-9.]\+\)\/.*$/\1/p}')
BLOCK_SIZES="4 16 32 64 128 512 1024"
for BLOCK_SIZE in ${BLOCK_SIZES}; do
  sudo sync
  echo 3 | sudo dd status=none of=/proc/sys/vm/drop_caches
  echo "Running FIO FileIO Benchmark - "${BLOCK_SIZE}"..."
  sudo ${FIO} \
    --randrepeat=1 \
    --ioengine=libaio \
    --direct=1 \
    --gtod_reduce=1 \
    --name="${HOST_IP}_BS=${BLOCK_SIZE}" \
    --filename=random_read_write.fio \
    --bs=${BLOCK_SIZE}k \
    --iodepth=64 \
    --size=6G \
    --readwrite=randrw \
    --rwmixread=75 \
    --output-format=json \
    | jq -c -M --arg hostip ${HOST_IP} '
    {
      host: $hostip,
      options: .jobs[0]."job options",
      read: .jobs[0].read,
      write: .jobs[0].write,
      disk: .disk_util[0].name
    }
    | .options |= { name,bs,iodepth,size,rw }
    | .read |= {
      bw,bw_min,bw_max,bw_agg,bw_mean,bw_dev,
      iops,iops_min,iops_max,iops_agg,iops_mean,iops_dev
    }
    | .write |= {
      bw,bw_min,bw_max,bw_agg,bw_mean,bw_dev,
      iops,iops_min,iops_max,iops_agg,iops_mean,iops_dev
    }' \
    > "fio-blocksize${BLOCK_SIZE}.json"
done
