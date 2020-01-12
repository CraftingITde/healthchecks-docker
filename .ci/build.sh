#!/bin/bash

if [! -n "$TRAVIS_TAG" ] 
then
  docker build -t healthchecks-docker .
else
  docker build -t healthchecks-docker --build-arg HEALTHCHECKS_VERSION=$TRAVIS_TAG . 
fi