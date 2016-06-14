#!/usr/bin/env bash

set -e

echo -e "Will update the documentation apps submodule"

BRANCH="${BRANCH-master}"

git submodule init
git submodule update
git submodule foreach git fetch
git submodule foreach git checkout $BRANCH
git submodule foreach git pull origin $BRANCH
