#!/bin/sh

docker build -t webanalyticsitalia/wai-openresty:1.0.0-stable -t webanalyticsitalia/wai-openresty:latest --build-arg OPENRESTY_VERSION=1.19.3.1-2-alpine-fat .
