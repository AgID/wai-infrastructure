#!/bin/sh

docker build -t webanalyticsitalia/wai-redisearch:5.0.9-stable -t webanalyticsitalia/wai-redisearch:latest --build-arg REDIS_VERSION=5.0.9 --build-arg REDISEARCH_GITHUB_BRANCH=v1.6.14 .
