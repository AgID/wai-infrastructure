#!/bin/sh

docker build -t italia/wai-redisearch:5.0.3 --build-arg REDIS_VERSION=5.0.3 --build-arg REDISEARCH_GITHUB_BRANCH=1.6 .
