#!/usr/bin/env bash

##########################################################################
## Functions: Convert Sysbench Output format to JSON
##########################################################################
_parse_sysbench_cpu () {
  local output="${1}"
  events_per_sec=$(echo "$output" | grep 'events per second:' | awk '{print $4}')
  total_time=$(echo "$output" | grep 'total time:' | awk '{print $3}')
  total_number_of_events=$(echo "$output" | grep 'total number of events:' | awk '{print $5}')
  min=$(echo "$output" | grep 'min:' | awk '{print $2}')
  avg=$(echo "$output" | grep 'avg:' | awk '{print $2}')
  max=$(echo "$output" | grep 'max:' | awk '{print $2}')
  sum=$(echo "$output" | grep 'sum:' | awk '{print $2}')
  ninety_fifth=$(echo "$output" | grep '95th percentile:' | awk '{print $3}')
  events_avg=$(echo "${output}" | grep 'events (avg/stddev):' | awk '{print $3}' | cut -f 1 -d '/')
  events_stddev=$(echo "${output}" | grep 'events (avg/stddev):' | awk '{print $3}' | cut -f 2 -d '/')
  execution_time_avg=$(echo "${output}" | grep 'execution time (avg/stddev):' | awk '{print $4}' | cut -f 1 -d '/')
  execution_time_stddev=$(echo "${output}" | grep 'execution time (avg/stddev):' | awk '{print $4}' | cut -f 2 -d '/')
  echo '
  {
    "events_per_sec":"'${events_per_sec}'",
    "total_time":"'${total_time}'",
    "total_number_of_events":"'${total_number_of_events}'",
    "min":"'${min}'",
    "avg":"'${avg}'",
    "max":"'${max}'",
    "sum":"'${sum}'",
    "ninety_fifth":"'${ninety_fifth}'",
    "events_avg":"'${events_avg}'",
    "events_stddev":"'${events_stddev}'",
    "execution_time_avg":"'${execution_time_avg}'",
    "execution_time_stddev":"'${execution_time_stddev}'"
  }
  '
}

_parse_sysbench_mem () {
  local output="${1}"
  total_operations_per_sec=$(echo "$output" | grep 'Total operations:' | awk '{print $4}' | perl -pe 's|\(||')
  total_time=$(echo "$output" | grep 'total time:' | awk '{print $3}')
  total_number_of_events=$(echo "$output" | grep 'total number of events:' | awk '{print $5}')
  min=$(echo "$output" | grep 'min:' | awk '{print $2}')
  avg=$(echo "$output" | grep 'avg:' | awk '{print $2}')
  max=$(echo "$output" | grep 'max:' | awk '{print $2}')
  sum=$(echo "$output" | grep 'sum:' | awk '{print $2}')
  ninety_fifth=$(echo "$output" | grep '95th percentile:' | awk '{print $3}')
  events_avg=$(echo "${output}" | grep 'events (avg/stddev):' | awk '{print $3}' | cut -f 1 -d '/')
  events_stddev=$(echo "${output}" | grep 'events (avg/stddev):' | awk '{print $3}' | cut -f 2 -d '/')
  execution_time_avg=$(echo "${output}" | grep 'execution time (avg/stddev):' | awk '{print $4}' | cut -f 1 -d '/')
  execution_time_stddev=$(echo "${output}" | grep 'execution time (avg/stddev):' | awk '{print $4}' | cut -f 2 -d '/')
  echo '
  {
    "total_operations_per_sec":"'${total_operations_per_sec}'",
    "total_time":"'${total_time}'",
    "total_number_of_events":"'${total_number_of_events}'",
    "min":"'${min}'",
    "avg":"'${avg}'",
    "max":"'${max}'",
    "sum":"'${sum}'",
    "ninety_fifth":"'${ninety_fifth}'",
    "events_avg":"'${events_avg}'",
    "events_stddev":"'${events_stddev}'",
    "execution_time_avg":"'${execution_time_avg}'",
    "execution_time_stddev":"'${execution_time_stddev}'"
  }
  '
}

_parse_sysbench_io () {
  local output="${1}"
  file_operations_reads=$(echo "${output}" | grep 'reads/s' | awk '{print $2}')
  file_operations_writes=$(echo "${output}" | grep 'writes/s' | awk '{print $2}')
  file_operations_fsyncs=$(echo "${output}" | grep 'fsyncs/s' | awk '{print $2}')
  throughput_read=$(echo "${output}" | grep 'read, MiB/s' | awk '{print $3}')
  throughput_write=$(echo "${output}" | grep 'written, MiB/s' | awk '{print $3}')
  total_time=$(echo "$output" | grep 'total time:' | awk '{print $3}')
  total_number_of_events=$(echo "$output" | grep 'total number of events:' | awk '{print $5}')
  min=$(echo "$output" | grep 'min:' | awk '{print $2}')
  avg=$(echo "$output" | grep 'avg:' | awk '{print $2}')
  max=$(echo "$output" | grep 'max:' | awk '{print $2}')
  sum=$(echo "$output" | grep 'sum:' | awk '{print $2}')
  ninety_fifth=$(echo "$output" | grep '95th percentile:' | awk '{print $3}')
  events_avg=$(echo "${output}" | grep 'events (avg/stddev):' | awk '{print $3}' | cut -f 1 -d '/')
  events_stddev=$(echo "${output}" | grep 'events (avg/stddev):' | awk '{print $3}' | cut -f 2 -d '/')
  execution_time_avg=$(echo "${output}" | grep 'execution time (avg/stddev):' | awk '{print $4}' | cut -f 1 -d '/')
  execution_time_stddev=$(echo "${output}" | grep 'execution time (avg/stddev):' | awk '{print $4}' | cut -f 2 -d '/')
  echo '
  {
    "file_operations_reads":"'${file_operations_reads}'",
    "file_operations_writes":"'${file_operations_writes}'",
    "file_operations_fsyncs":"'${file_operations_fsyncs}'",
    "throughput_read":"'${throughput_read}'",
    "throughput_write":"'${throughput_write}'",
    "total_time":"'${total_time}'",
    "total_number_of_events":"'${total_number_of_events}'",
    "min":"'${min}'",
    "avg":"'${avg}'",
    "max":"'${max}'",
    "sum":"'${sum}'",
    "ninety_fifth":"'${ninety_fifth}'",
    "events_avg":"'${events_avg}'",
    "events_stddev":"'${events_stddev}'",
    "execution_time_avg":"'${execution_time_avg}'",
    "execution_time_stddev":"'${execution_time_stddev}'"
  }
  '
}

_parse_filename_sysbench() {
  local file="${1}"
  only_file=$(basename -s .txt "${file}")
  hw_type=$(echo ${only_file} | cut -f2 -d '-')
  test_type=$(echo ${only_file} | cut -f3 -d '-')
  io_type=$(echo ${only_file} | cut -f4 -d '-')
}

_parse_filename_fio() {
  local file="${1}"
  only_file=$(basename -s .json "${file}")
  blocksize=$(echo ${only_file} | cut -f2 -d '-')
}

_logIt() {
  export LOGURL='https://services.glgresearch.com/log/stdout/benchmarks'
  curl -X POST -H "Content-Type: application/json" "${LOGURL}" -d@"${1}"
}

host_ip=$(ip a s|sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\(172.[0-9.]\+\)\/.*$/\1/p}')

##########################################################################
## Go through the resulting benchmark files and convert
## them to json so we can upload them to sumologic
##########################################################################
for file in $(find . -type f -name "*-mem-*.txt"); do
  _parse_filename_sysbench "${file}"
  file_contents=$(cat "$file")
  stats=$(_parse_sysbench_mem "${file_contents}")
  echo '
  {
    "disk":"'${PWD}'",
    "host_ip":"'${host_ip}'",
    "sysbench":{
      "'${hw_type}'":{
        "'${test_type}'":{
          "'${io_type}'":'${stats}'
        }
      }
    }
  }
  ' \
    | jq -r -c '.' \
    > "./mergeme.${only_file}.json"
  _logIt "./mergeme.${only_file}.json"
done

for file in $(find . -type f -name "*-cpu-*.txt"); do
  _parse_filename_sysbench "${file}"
  file_contents=$(cat "$file")
  stats=$(_parse_sysbench_cpu "${file_contents}")
  echo '
  {
    "disk":"'${PWD}'",
    "host_ip":"'${host_ip}'",
    "sysbench":{
      "'${hw_type}'":{
        "'${test_type}'":{
          "'${io_type}'":'${stats}'
        }
      }
    }
  }
  ' \
    | jq -r -c '.' \
    > "./mergeme.${only_file}.json"
  _logIt "./mergeme.${only_file}.json"
done

for file in $(find . -type f -name "*-io-*.txt"); do
  _parse_filename_sysbench "${file}"
  file_contents=$(cat "$file")
  stats=$(_parse_sysbench_io "${file_contents}")
  echo '
  {
    "disk":"'${PWD}'",
    "host_ip":"'${host_ip}'",
    "sysbench":{
      "'${hw_type}'":{
        "'${test_type}'":{
          "'${io_type}'":'${stats}'
        }
      }
    }
  }
  ' \
    | jq -r -c '.' \
    > "./mergeme.${only_file}.json"
  _logIt "./mergeme.${only_file}.json"
done

##########################################################################
## Does the same for fio
##########################################################################
for file in $(find . -type f -name "fio*.json"); do
  _parse_filename_fio "${file}"
  file_contents=$(cat "$file")
  echo '
  {
    "disk":"'${PWD}'",
    "host_ip":"'${host_ip}'",
    "fio":{
      "'${blocksize}'":'${file_contents}'
    }
  }
  ' \
    | jq -r -c '.' \
    > "./mergeme.${only_file}.json"
  _logIt "./mergeme.${only_file}.json"
done

##########################################################################
## This "could" merge all the stuff into a single json
## but it might make sense to have these as single records
## in sumo logic for easier processing
##########################################################################
set -o noglob
count=0
unset jq_recipe
unset file_list
for file in $(find . -type f -name "mergeme*"); do
  jq_recipe="${jq_recipe}.[$((count++))] * "
  file_list="${file_list}${file} "
done
# The recipe to merge looks like '.[0] * .[1] ...'
# Each array reference is a file.  So, above you see
# we add a " * " at the end of each line merge, below
# yanks off the final " * " we don't want in the recipe.
jq_recipe=$(echo "${jq_recipe}" | perl -pe 's| \* $||')
jq -s "${jq_recipe}" $file_list >  final_results.json
