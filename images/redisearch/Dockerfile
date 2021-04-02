ARG REDIS_VERSION
ARG REDISEARCH_VERSION

# RediSearch image
FROM redislabs/redisearch:${REDISEARCH_VERSION} as builder

# Main image
FROM bitnami/redis:${REDIS_VERSION}

ENV LIBDIR /opt/bitnami/redis/bin
WORKDIR /data
USER 0
COPY --from=builder /usr/lib/redis/modules/redisearch.so "$LIBDIR"
USER 1001
CMD ["redis-server", "--loadmodule", "/opt/bitnami/redis/bin/redisearch.so"]
