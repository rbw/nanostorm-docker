#!/usr/bin/env bash

cd nanostorm
git checkout master && git pull
cd ..
git add nanostorm
git commit -m "updating nanostorm to latest"
