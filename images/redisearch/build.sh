#!/bin/sh

docker build -t webanalyticsitalia/wai-redisearch:5.0.12-stable -t webanalyticsitalia/wai-redisearch:latest --build-arg REDIS_VERSION=5.0.12 --build-arg REDISEARCH_VERSION=v1.6.15 .
