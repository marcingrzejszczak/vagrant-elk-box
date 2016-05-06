#!/usr/bin/env bash

echo -e "Will update the documentation apps submodule"

git submodule init
git submodule update
git submodule foreach git checkout master
git submodule foreach git pull origin master
