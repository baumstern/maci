#!/bin/bash

set -e

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"

mkdir ./zkeys
wget -q -P ./zkeys https://maci-develop-fra.s3.eu-central-1.amazonaws.com/v1.1.1-aa4ba27/10-2-1-2/ProcessMessages_10-2-1-2_test.0.zkey
wget -q -P ./zkeys https://maci-develop-fra.s3.eu-central-1.amazonaws.com/v1.1.1-aa4ba27/10-2-1-2/TallyVotes_10-1-2_test.0.zkey


# docker run --detach --platform linux/amd64 -p 8080:8080 ghcr.io/privacy-scaling-explorations/maci-coordinator:main

# compileSol



"$BASE_DIR"/../.github/scripts/run-e2e-tests.sh