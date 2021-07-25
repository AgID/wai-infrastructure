ARG KONG_IMAGE_VERSION
FROM kong:${KONG_IMAGE_VERSION}
USER root
RUN apk --update add curl jq postgresql-client && rm /var/cache/apk/*
USER kong
