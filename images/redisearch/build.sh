#!/bin/sh

docker build -t webanalyticsitalia/wai-redisearch:5.0.7-stable --build-arg REDIS_VERSION=5.0.7 --build-arg REDISEARCH_GITHUB_BRANCH=v1.6.8 .
