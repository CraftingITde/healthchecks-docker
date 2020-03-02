#!/bin/bash
docker tag healthchecks-docker craftingit/healthchecks-docker:$TRAVIS_TAG

if [ ! "$TRAVIS_TAG" == "dev" ];
then
    docker tag healthchecks-docker craftingit/healthchecks-docker:latest
fi

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker push craftingit/healthchecks-docker