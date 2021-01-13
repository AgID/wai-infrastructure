ARG OPENRESTY_VERSION
FROM openresty/openresty:${OPENRESTY_VERSION}

RUN luarocks install lua-resty-redis-connector

COPY wai-csp.lua /usr/local/openresty/lualib/wai/
