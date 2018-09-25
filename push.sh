#!/usr/bin/env bash
hugo
git add docs/. && git commit -m $1
git push live