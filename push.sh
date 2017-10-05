#!/usr/bin/env bash
hugo
git commit -am $1
git push origin master
git push live