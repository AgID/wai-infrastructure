ARG OPENRESTY_VERSION
FROM openresty/openresty:${OPENRESTY_VERSION}

RUN luarocks install lua-resty-redis-connector && \
    luarocks install lua-resty-url

COPY wai-csp.lua /usr/local/openresty/lualib/wai/
