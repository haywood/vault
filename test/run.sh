#!/bin/bash -e

# export all variables
set -a

TEST_DIR=$(cd $(dirname $0) && pwd -P)

PATH="$TEST_DIR:$PATH"

for example in $TEST_DIR/test_*.sh; do
  $TEST_DIR/wrapper.sh $example
done
