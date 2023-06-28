#!/bin/bash

set -e

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"



docker run --detach --platform linux/amd64 -p 8080:8080 ghcr.io/privacy-scaling-explorations/maci-coordinator:main


"$BASE_DIR"/../.github/scripts/run-e2e-tests.sh