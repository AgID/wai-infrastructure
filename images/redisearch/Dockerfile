ARG REDIS_VERSION
FROM docker.io/bitnami/redis:${REDIS_VERSION} as builder
ARG REDISEARCH_GITHUB_BRANCH
# Build redis-search
USER root
RUN apt-get update && apt-get install -y git && \
    mkdir -p /build-redisearch && cd ~/build-redisearch && \
    git clone --branch ${REDISEARCH_GITHUB_BRANCH} --recursive https://github.com/RedisLabsModules/RediSearch.git && \
    cd RediSearch && \
    ./deps/readies/bin/getpy2 && \
    ./system-setup.py && \
    make fetch && \
    make build && \
    rm -rf /var/lib/apt/lists/*

# Package the runner
FROM docker.io/bitnami/redis:${REDIS_VERSION}
ENV LIBDIR /opt/bitnami/redis/bin
WORKDIR /data
USER 0
COPY --from=builder /build-redisearch/RediSearch/src/redisearch.so "$LIBDIR"
USER 1001
CMD ["redis-server", "--loadmodule", "/opt/bitnami/redis/bin/redisearch.so"]
