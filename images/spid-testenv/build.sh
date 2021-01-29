#!/bin/sh

docker build -t webanalyticsitalia/wai-spid-testenv:1.0.1-stable -t webanalyticsitalia/wai-spid-testenv:latest --build-arg SPID_TESTENV_VERSION=1.0.1 .
