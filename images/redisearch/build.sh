#!/bin/sh

docker build -t webanalyticsitalia/wai-redisearch:5.0.14-stable -t webanalyticsitalia/wai-redisearch:latest --build-arg REDIS_VERSION=5.0.14 --build-arg REDISEARCH_VERSION=v1.6.15 .
