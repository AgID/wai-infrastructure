#!/bin/sh
KONG_IMAGE_VERSION=2.4.1
docker build --no-cache --rm -t webanalyticsitalia/wai-kong:$KONG_IMAGE_VERSION -t webanalyticsitalia/wai-kong:latest --build-arg KONG_IMAGE_VERSION=$KONG_IMAGE_VERSION .
docker push webanalyticsitalia/wai-kong:$KONG_IMAGE_VERSION
docker push webanalyticsitalia/wai-kong:latest
