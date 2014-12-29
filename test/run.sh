#!/bin/bash -e

# export all variables
set -a

TEST_DIR=$(cd $(dirname $0) && pwd -P)

PATH="$TEST_DIR:$PATH"

TESTS="$@"

if [ -z "$TESTS" ]; then
  TESTS=$TEST_DIR/test_*.sh
fi

for example in $TESTS; do
  $TEST_DIR/wrapper.sh $example
done
