#!/usr/bin/env bash
hugo
git add docs/. && git commit -am $1
git push origin master && git push publisher
